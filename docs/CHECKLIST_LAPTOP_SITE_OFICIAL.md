# Checklist — portar Doors Online para o site oficial (LaptopEdnei)

Contexto para quem executa (Codex ou humano): o pipeline pedido-online → arquivos de produção
está LIVE no ambiente de teste (PCGu). Spec completa: `docs/FASTCNC_DOORS_ONLINE_V1.md` neste
repo (branch `doors-online-v1-spec`). O Supabase (função `order-intake`, tabela, bucket) serve
os dois sites — **no laptop não há nada de Supabase para instalar**.

## 1. Copiar os mu-plugins (o único código que viaja)

Origem (fonte da verdade): repo `SpaceInvUK/cnc-calculator`, branch `doors-online-v1-spec`,
pasta `site/mu-plugins/`. Destino: `wp-content/mu-plugins/` do site oficial.

- [ ] `fastcnc-door-prep.php` — **v2.1** (tem a meta `_fcnc_data`; NÃO usar a v2.0 antiga do site)
- [ ] `fastcnc-order-bridge.php` — v1.0.0 (novo)
- [ ] `fastcnc-panels.php` — só conferir que o site oficial já tem a mesma versão

**Regra para o Codex:** esses 3 arquivos são versionados neste repo. Não editar direto no
wp-content; qualquer mudança = editar no repo e re-copiar. Nunca renomear campos do payload
`kabacal-order/v1` (contrato aditivo — a spec explica).

## 2. wp-config.php do site oficial

Adicionar antes do `/* That's all, stop editing! */`:

```php
/* FastCNC order bridge (Kabacal order-intake) */
define( 'FCNC_BRIDGE_URL', 'https://rvmyalrtoblxmxciiovd.supabase.co/functions/v1/order-intake' );
define( 'FCNC_BRIDGE_SECRET', '<copiar do wp-config do site teste no PCGu>' );
```

- [ ] O valor do secret está no wp-config do site teste (PCGu) — mesmo valor salvo no cofre do
  Supabase. **Não commitar o valor em lugar nenhum.**
- [ ] Quando o site sair da máquina local para hosting real: gerar um secret NOVO, atualizar no
  cofre (dashboard → Edge Functions → Secrets → `FCNC_BRIDGE_SECRET`) e nos wp-configs.

## 3. Conferências no WooCommerce (se a cópia divergiu do teste)

- [ ] Produto **Plain Shaker** existe com a meta `_fcnc_size_data` (bandas de preço). No teste é
  o produto 2830, `/product/plain-shaker-door/`.
- [ ] Stripe gateway em **test mode** enquanto for ambiente local; chaves LIVE só no go-live real.
- [ ] **VAT: decisão pendente do Ednei** — hoje os pedidos saem com imposto £0. Configurar UK VAT
  20% no Woo antes do site real vender.
- [ ] E-mail transacional do WP: no teste o Local/Mailpit captura tudo; no hosting real precisa
  de SMTP (o e-mail do cliente e o admin "New order" dependem disso).

## 4. Teste de aceitação no laptop (depois de 1+2)

- [ ] Comprar uma Plain Shaker de teste (guest, Stripe test mode, cartão 4242 4242 4242 4242 —
  de quebra valida a UI de cartão que faltou testar).
- [ ] O pedido deve ganhar a nota **"Kabacal bridge: order delivered to production intake"**.
- [ ] No Supabase: linha nova em `fastcnc_orders` (status `files_generated`) e arquivos em
  `fastcnc-orders/orders/FC-{nº}/` (`.fastcnc.json` + `.dxf` + `.nc`).
- [ ] Se a nota disser FAILED: ver o log da função no dashboard (Edge Functions → order-intake
  → Logs) e o WooCommerce → Status → Logs → `fastcnc-bridge`.

## 5. Limitações v1 (comportamento esperado, não é bug)

- Só **Plain Shaker 18/22mm** gera arquivos. Outros produtos/estilos: a ponte entrega, a função
  registra a linha e marca `failed` ("unsupported style") — inofensivo, some quando os próximos
  estilos entrarem no engine.
- E-mail para services@fastcnc.co.uk fica **skipped** até existir `RESEND_API_KEY` no cofre
  (pendente global, não é passo do laptop).
- O preço que vale é o do site (snapshot no pedido); o quote interno do Kabacal difere por design.

## 6. Fora do escopo do laptop (fica no PCGu / decisão do Ednei)

- Regenerar a função quando o engine do Kabacal mudar: `node tools/build-intake.mjs` + redeploy
  (runbook `supabase/README.md` do repo kabacal).
- Integração do `main` deste repo (commits do Codex no remote × branch `doors-online-v1-spec`).
- Air-cut protocol antes de cortar material real com qualquer NC gerado.
