# FastCNC — Pedidos Online de Portas → Produção (v1)

**Status:** spec aprovada em conversa (2026-07-17). Etapa 1 validada na prática (pedido de teste #4004).
**Escopo v1:** só **Plain Shaker**. Auto-gerar **DXF + NC + .fastcnc** após pagamento (sem air-cut — template validado). Arquivos por e-mail para **services@fastcnc.co.uk** + Supabase Storage.

## Decisões fechadas

| Decisão | Escolha |
|---|---|
| Loja | WooCommerce (site teste: `fast-cnc-test.local`, Local, `W:\Websites\Local Sites\fast-cnc by Codex`) |
| Site oficial | Em reconfiguração no PC **LaptopEdnei** (mesmo domínio local!). Portar = copiar mu-plugins + constantes no wp-config |
| Ponte | Supabase do Kabacal (Edge Functions + Storage + Postgres) |
| Automação v1 | Pagamento confirmado → Edge Function roda engine headless → DXF + NC + .fastcnc → Storage + e-mail |
| E-mail produção | services@fastcnc.co.uk, máximo de informação, anexos nomeados com nº da ordem |
| Cliente | E-mails padrão Woo (já funcionam); conta opcional pós-compra; marketing opt-in separado |

## Estado verificado (2026-07-17, site teste)

- **Configurador já existe**: mu-plugin `fastcnc-door-prep.php` v2.0.0 — type-your-size (H×W×espessura), preço por banda server-side (meta `_fcnc_size_data` por produto), preparação CNC (finish, hinge holes, positions, side, soft-close, notes), preço aplicado no carrinho, meta gravada no pedido.
- **Catálogo**: 12 portas + Wall Panel. **Plain Shaker = produto 2830**. Para 600×400×18: banda 720x400 → **£68** (confirmado na UI e no pedido).
- **Stripe**: gateway ativo, **testmode=yes**, chaves de teste reais, live keys são placeholders. Checkout = Woo Blocks + UPE (accordion). PayPal também aparece no checkout.
- **Mailpit** embutido no Local (web :10000, SMTP :10001) captura todos os e-mails.
- **Pedido de teste #4004** (guest, COD temporário para contornar iframe Stripe em automação): status `wc-processing`, £136, item meta completa (abaixo). E-mails disparados: cliente ("Your FAST CNC order has been received!") e admin ("[FAST CNC]: You've got a new order: #4004" → info@fastcnc.co.uk).

### Meta real gravada no item (pedido #4004)

```
Size: 600 x 400 mm | Thickness: 18 mm | Finish: Primed white
Hinge holes: 2 holes | Hole positions: Standard | Hinge side: Left
CNC notes: (texto livre)  [+ _fcnc_prep_cost quando > 0]
```

⚠️ A meta atual é **texto de exibição**. A ponte precisa de números — ver "Mudança no door-prep" abaixo.

## Arquitetura v1

```
Cliente → produto Woo (configurador door-prep) → checkout Stripe (test→live)
   → pedido wc-processing
   → [fastcnc-order-bridge.php] hook woocommerce_order_status_processing
        → monta Order Schema v1 → POST Edge Function (URL+secret via wp-config)
   → Edge Function (Supabase):
        1. valida secret + idempotência (order id)
        2. grava pedido em fastcnc_orders
        3. roda kabacal-engine headless (Plain Shaker): .fastcnc + DXF + NC
        4. salva arquivos no Storage: orders/FC-{id}/FC-{id}-door{n}.{dxf,nc,fastcnc.json}
        5. e-mail services@fastcnc.co.uk com resumo completo + anexos
```

Componentes novos: **(a)** mu-plugin ponte no site; **(b)** Edge Function `order-intake`; **(c)** engine headless extraído do Kabacal (Etapa 2); **(d)** e-mail transacional (Resend ou SMTP).

## Kabacal Order Schema v1 (contrato site ↔ produção)

```json
{
  "schema": "kabacal-order/v1",
  "source": "woocommerce",
  "site_url": "https://fast-cnc-test.local",
  "bridge_version": "1.0.0",
  "order": {
    "id": 4004,
    "number": "4004",
    "status": "processing",
    "currency": "GBP",
    "total": "136.00",
    "created_gmt": "2026-07-17T07:12:00Z",
    "payment_method": "stripe",
    "transaction_id": "pi_...",
    "customer_note": "",
    "customer": {
      "first_name": "Joao", "last_name": "Teste",
      "email": "cliente.teste@example.com", "phone": "07510000000",
      "billing_address": "1 Test Street, Upminster, RM14 1TP, GB",
      "shipping_address": "1 Test Street, Upminster, RM14 1TP, GB"
    }
  },
  "items": [
    {
      "product_id": 2830,
      "name": "Plain Shaker",
      "kind": "door",
      "style": "plain-shaker",
      "qty": 2,
      "h_mm": 600, "w_mm": 400, "t_mm": 18,
      "finish": "Primed white",
      "hinge_holes": 2, "hole_positions": "Standard", "hinge_side": "Left",
      "soft_close_hinges": 0,
      "cnc_notes": "…",
      "unit_price": "68.00", "line_total": "136.00",
      "prep_cost": "0.00"
    }
  ]
}
```

Regras: campos **aditivos** (nunca renomear — mesma filosofia do `.fastcnc`); `style` mapeado do produto (v1: 2830 → `plain-shaker`); preço = **snapshot** do que foi pago (produção não recalcula).

## Mudança no door-prep (v2.1)

`order_meta()` passa a gravar também meta oculta machine-readable por item:
`_fcnc_data` = JSON `{h,w,t,finish,holes,positions,side,hinges,notes,unit_price,prep_cost}`.
A ponte lê `_fcnc_data`; a meta de exibição continua igual (e-mails/admin não mudam). Aditivo, zero impacto no que existe.

## Etapas

1. ✅ **Checkout funciona** — validado com pedido #4004 (guest, configurador, preço banda, e-mails Woo). Pendências: teste manual do cartão Stripe na UI (iframes bloqueiam automação); decidir VAT (ver riscos).
2. **Engine headless** — extrair geração Plain Shaker (geometria/DXF/CAM/NC) do `index.html` do Kabacal para módulo JS puro rodável em Deno/Node; golden tests byte-a-byte vs app. *Maior lift da v1.*
3. **Ponte + Edge Function** — mu-plugin `fastcnc-order-bridge.php` (repo: `site/mu-plugins/`, deploy = cópia) + `order-intake` no Supabase + e-mail services@ com anexos.
4. **Depois da v1**: aba Online Orders no Kabacal, status de produção sincronizado, conta cliente, mais tipos de porta.

## Riscos / pendências

- **VAT**: pedido #4004 saiu com tax £0 — Woo sem imposto configurado. Confirmar com Ednei antes do site oficial (UK VAT 20%).
- **Mini-carrinho** (widget Salient) mostra preço "From £28" na linha em vez do preço calculado; página do carrinho (Blocks) mostra certo. Cosmético.
- **Stripe UI**: pagamento por cartão na UI não foi exercitado por automação (iframes UPE resistem a eventos sintéticos + renderer trava). Validar manualmente uma vez.
- **Dois sites no mesmo domínio** (teste aqui, oficial no LaptopEdnei): risco de confusão — sonda `claude-probe` se precisar desambiguar.
- **E-mail admin atual** vai para info@fastcnc.co.uk; o e-mail de produção (services@) é novo e sai da Edge Function, não do Woo.

## Ambiente / credenciais

- Site teste: DB `local` root/root :10006 (MySQL do Local), nginx :10004, one-click admin ON.
- wp-config do site oficial precisará: `FCNC_BRIDGE_URL`, `FCNC_BRIDGE_SECRET` (+ Stripe live keys no gateway).
- Supabase: projeto do Kabacal (ver `docs/SAAS.md` no repo Kabacal e `supabase/README.md`).
