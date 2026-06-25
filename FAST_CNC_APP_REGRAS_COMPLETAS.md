# FAST CNC Calculator - Regras Completas do App

Atualizado em: 2026-06-25  
Fonte principal: `Cnc Calculator UI Test.html` e `CNC Calculator 1.0.html`  
URL publicada: https://spaceinvuk.github.io/cnc-calculator/Cnc%20Calculator%20UI%20Test.html

Este documento registra as regras atuais do app FAST CNC Calculator, incluindo nomes, valores, produtos, precificacao, machining, nesting, DXF, labels, checklist, Doors e Panneling.

## Arquivos Oficiais

- Arquivo oficial ativo do GitHub Pages: `Cnc Calculator UI Test.html`.
- Espelho local da versao 1.0: `CNC Calculator 1.0.html`.
- Esses dois arquivos devem ficar sincronizados quando a calculadora oficial 1.0 for alterada.
- O app continua sendo um HTML unico, sem build system, a menos que seja pedido explicitamente.
- A aba deve continuar escrita como `Panneling`.
- Nao fazer deploy no Netlify a menos que seja pedido explicitamente.

## Modulos do App

- Doors.
- Panneling.
- DXF Templates.
- Toolpaths / NC.
- Checklist / QR.
- Labels CNC.
- Labels Spray Finish.
- Smart Takeoff.
- Spray Calculator.
- Material & Pricing.
- Save / Load quote JSON.
- Print / Save PDF.
- Save DXF by Thickness.

## Regras Gerais de Nesting

- Margem externa da sheet: `7mm`.
- Espacamento entre pecas normais/front: `7mm`.
- O nesting deve respeitar os `7mm` entre pecas e borda.
- Pecas reused/internal frame voids tambem participam da regra de espacamento quando entram como area reutilizavel.
- Back side offset/pocketing sheets nao precisam respeitar o mesmo espacamento entre pecas; back pode tocar peca com peca conforme regra antiga.
- Ao arrastar pecas manualmente, o app deve manter alinhamento com bordas/pecas proximas respeitando `7mm`.
- Pecas nao podem ficar sobrepostas no nesting.
- Pecas triangulares/sloped devem aproveitar espacos reais quando couber.
- Offcuts podem receber pecas se respeitarem `7mm`.
- Offcut circular deve continuar circular, nao virar quadrado.

## Sheet Sizes

| Key | Nome | Largura | Altura | Observacao |
|---|---:|---:|---:|---|
| `8x4` | 8x4 | 2440mm | 1220mm | Sheet padrao |
| `10x4` | 10x4 | 3050mm | 1220mm | Sheet maior |
| `10x5` | 10x5 | 3050mm | 1525mm | Sheet maior |
| `jumbo` | Jumbo | 2800mm | 2070mm | Altura util `2050mm` |

## Materiais Disponiveis

- MDF
- Standard MDF
- Moisture-Resistant MDF (MR MDF)
- Fire-Rated MDF (FR MDF)
- Veneered MDF (Oak, Walnut, Ash)
- Black MDF (Valchromat)
- Tricoya (Exterior-grade MDF)
- MDF Hidrofugo Plus
- Birch
- Birch Plywood
- Hardwood Plywood
- Softwood Plywood
- Marine Plywood
- Poplar Plywood
- Phenolic-coated Plywood
- Standard Chipboard
- Moisture-Resistant Chipboard
- Melamine-Faced Chipboard (MFC)
- Veneered Chipboard
- Standard HDF
- White-faced HDF
- Oil-tempered Hardboard
- OSB/2
- OSB/3 (structural/exterior)
- Solid Oak Panels
- Solid Pine Panels
- Solid Beech Panels
- Bamboo Panels
- Melamine-faced boards
- Laminated boards (HPL)
- Veneered boards (oak, walnut, ash)
- Other (specify)

## Espessuras Disponiveis Por Material

| Material | Espessuras |
|---|---|
| MDF | 3mm, 6mm, 9mm, 12mm, 15mm, 18mm, 22mm, 25mm, 30mm |
| Standard MDF | 3mm, 6mm, 9mm, 12mm, 15mm, 18mm, 22mm, 25mm, 30mm |
| Moisture-Resistant MDF (MR MDF) | 3mm, 6mm, 9mm, 12mm, 15mm, 18mm, 22mm, 25mm, 30mm |
| Fire-Rated MDF (FR MDF) | 3mm, 6mm, 9mm, 12mm, 15mm, 18mm, 22mm, 25mm, 30mm |
| Veneered MDF (Oak, Walnut, Ash) | 3mm, 6mm, 9mm, 12mm, 15mm, 18mm, 22mm, 25mm, 30mm |
| Black MDF (Valchromat) | 3mm, 6mm, 9mm, 12mm, 15mm, 18mm, 22mm, 25mm, 30mm |
| Tricoya (Exterior-grade MDF) | 3mm, 6mm, 9mm, 12mm, 15mm, 18mm, 22mm, 25mm, 30mm |
| MDF Hidrofugo Plus | 3mm, 6mm, 9mm, 12mm, 15mm, 18mm, 22mm, 25mm, 30mm |
| Birch | 4mm, 6mm, 9mm, 12mm, 15mm, 18mm, 24mm |
| Birch Plywood | 4mm, 6mm, 9mm, 12mm, 15mm, 18mm, 24mm |
| Hardwood Plywood | 6mm, 9mm, 12mm, 15mm, 18mm, 24mm |
| Softwood Plywood | 6mm, 9mm, 12mm, 15mm, 18mm, 24mm |
| Marine Plywood | 6mm, 9mm, 12mm, 15mm, 18mm, 24mm |
| Poplar Plywood | 6mm, 9mm, 12mm, 15mm, 18mm, 24mm |
| Phenolic-coated Plywood | 6mm, 9mm, 12mm, 15mm, 18mm, 24mm |
| Standard Chipboard | 6mm, 9mm, 12mm, 15mm, 18mm, 25mm |
| Moisture-Resistant Chipboard | 6mm, 9mm, 12mm, 15mm, 18mm, 25mm |
| Melamine-Faced Chipboard (MFC) | 6mm, 9mm, 12mm, 15mm, 18mm, 25mm |
| Veneered Chipboard | 6mm, 9mm, 12mm, 15mm, 18mm, 25mm |
| Standard HDF | 3mm, 6mm, 9mm, 12mm |
| White-faced HDF | 3mm, 6mm, 9mm, 12mm |
| Oil-tempered Hardboard | 3mm, 6mm |
| OSB/2 | 6mm, 9mm, 12mm, 15mm |
| OSB/3 (structural/exterior) | 6mm, 9mm, 12mm, 15mm |
| Solid Oak Panels | 12mm, 18mm, 24mm |
| Solid Pine Panels | 12mm, 18mm, 24mm |
| Solid Beech Panels | 12mm, 18mm, 24mm |
| Bamboo Panels | 12mm, 18mm, 24mm |
| Melamine-faced boards | 6mm, 9mm, 12mm, 15mm, 18mm, 25mm |
| Laminated boards (HPL) | 6mm, 9mm, 12mm, 15mm, 18mm, 25mm |
| Veneered boards (oak, walnut, ash) | 6mm, 9mm, 12mm, 15mm, 18mm, 25mm |
| Other (specify) | 3mm, 6mm, 9mm, 12mm, 15mm, 18mm, 22mm, 24mm, 25mm, 30mm |

## Precos Base de Material

Os valores abaixo sao precos base por sheet `8x4`, exceto quando o app aplica regra especial de tamanho.

| Material | Precos por espessura |
|---|---|
| MDF | 3mm=15, 6mm=25, 9mm=35, 12mm=40, 15mm=45, 18mm=55, 22mm=65, 25mm=75, 30mm=15 |
| Standard MDF | 3mm=15, 6mm=25, 9mm=35, 12mm=40, 15mm=45, 18mm=55, 22mm=65, 25mm=75, 30mm=15 |
| Moisture-Resistant MDF (MR MDF) | 3mm=25, 6mm=35, 9mm=45, 12mm=50, 15mm=55, 18mm=65, 22mm=75, 25mm=85, 30mm=25 |
| Fire-Rated MDF (FR MDF) | 3mm=30, 6mm=40, 9mm=50, 12mm=60, 15mm=70, 18mm=80, 22mm=90, 25mm=100, 30mm=30 |
| Veneered MDF (Oak, Walnut, Ash) | 3mm=35, 6mm=45, 9mm=55, 12mm=65, 15mm=75, 18mm=85, 22mm=95, 25mm=105, 30mm=35 |
| Black MDF (Valchromat) | 3mm=40, 6mm=50, 9mm=60, 12mm=70, 15mm=80, 18mm=90, 22mm=100, 25mm=110, 30mm=40 |
| Tricoya (Exterior-grade MDF) | 3mm=50, 6mm=60, 9mm=70, 12mm=80, 15mm=90, 18mm=100, 22mm=110, 25mm=120, 30mm=50 |
| MDF Hidrofugo Plus | 3mm=25, 6mm=35, 9mm=45, 12mm=50, 15mm=55, 18mm=65, 22mm=75, 25mm=85, 30mm=25 |
| Birch | 4mm=45, 6mm=55, 9mm=65, 12mm=75, 15mm=85, 18mm=95, 24mm=120 |
| Birch Plywood | 4mm=45, 6mm=55, 9mm=65, 12mm=75, 15mm=85, 18mm=95, 24mm=120 |
| Hardwood Plywood | 6mm=60, 9mm=75, 12mm=90, 15mm=105, 18mm=120, 24mm=150 |
| Softwood Plywood | 6mm=40, 9mm=50, 12mm=60, 15mm=70, 18mm=80, 24mm=100 |
| Marine Plywood | 6mm=80, 9mm=100, 12mm=120, 15mm=140, 18mm=160, 24mm=200 |
| Poplar Plywood | 6mm=35, 9mm=45, 12mm=55, 15mm=65, 18mm=75, 24mm=95 |
| Phenolic-coated Plywood | 6mm=90, 9mm=110, 12mm=130, 15mm=150, 18mm=170, 24mm=210 |
| Standard Chipboard | 6mm=20, 9mm=25, 12mm=30, 15mm=35, 18mm=40, 25mm=50 |
| Moisture-Resistant Chipboard | 6mm=30, 9mm=35, 12mm=40, 15mm=45, 18mm=50, 25mm=60 |
| Melamine-Faced Chipboard (MFC) | 6mm=35, 9mm=40, 12mm=45, 15mm=50, 18mm=55, 25mm=65 |
| Veneered Chipboard | 6mm=40, 9mm=50, 12mm=60, 15mm=70, 18mm=80, 25mm=100 |
| Standard HDF | 3mm=18, 6mm=28, 9mm=38, 12mm=48 |
| White-faced HDF | 3mm=25, 6mm=35, 9mm=45, 12mm=55 |
| Oil-tempered Hardboard | 3mm=15, 6mm=22 |
| OSB/2 | 6mm=15, 9mm=18, 12mm=22, 15mm=28 |
| OSB/3 (structural/exterior) | 6mm=18, 9mm=22, 12mm=28, 15mm=35 |
| Solid Oak Panels | 12mm=120, 18mm=140, 24mm=180 |
| Solid Pine Panels | 12mm=80, 18mm=100, 24mm=130 |
| Solid Beech Panels | 12mm=100, 18mm=120, 24mm=150 |
| Bamboo Panels | 12mm=95, 18mm=115, 24mm=145 |
| Melamine-faced boards | 6mm=35, 9mm=40, 12mm=45, 15mm=50, 18mm=55, 25mm=65 |
| Laminated boards (HPL) | 6mm=50, 9mm=60, 12mm=70, 15mm=80, 18mm=90, 25mm=110 |
| Veneered boards (oak, walnut, ash) | 6mm=45, 9mm=55, 12mm=65, 15mm=75, 18mm=85, 25mm=105 |
| Other (specify) | 3mm=0, 6mm=0, 9mm=0, 12mm=0, 15mm=0, 18mm=0, 22mm=0, 24mm=0, 25mm=0, 30mm=0 |

## Regras de Preco de Material

- `Material Cost` e editavel.
- O app pode preencher o valor automaticamente pela tabela.
- Se houver override salvo no material book, o override tem prioridade.
- Para `MDF` ou `Standard MDF`, `18mm`, tamanho `10x4`, existe preco exato especial: `75`.
- Quando nao ha preco exato para o tamanho, o app escala o preco por area da sheet.
- Sheets usadas cobram como sheet inteira.
- Regras antigas de `1/3`, `2/3` e `half sheet` foram normalizadas para `1 sheet` quando houver cobranca.
- Cada sheet pode ter override manual de preco de material.
- Cada sheet pode ter override manual de CNC service.

## CNC Service Base

Regras atuais de sugestao automatica:

- Blocks auto-generated usam `65`.
- Se a espessura for `18mm` ou `22mm`, a sugestao direta atual e `85`.
- Caso contrario, o app usa a tabela `cncPriceTables.small` por familia `MDF` ou `Birch`.
- O campo `CNC Service (£)` e editavel e pode sobrescrever a sugestao.

Tabela `cncPriceTables.small`:

| Familia | Precos |
|---|---|
| MDF | 3mm=65, 6mm=65, 9mm=65, 12mm=65, 15mm=95, 18mm=95, 22mm=120, 25mm=120, 30mm=120 |
| Birch | 4mm=65, 6mm=65, 9mm=65, 12mm=65, 15mm=95, 18mm=95, 24mm=100 |

Tabela `cncPriceTables.medium` existe no codigo:

| Familia | Precos |
|---|---|
| MDF | 3mm=95, 6mm=95, 9mm=95, 12mm=95, 15mm=120, 18mm=120, 22mm=150, 25mm=150, 30mm=150 |
| Birch | 4mm=95, 6mm=95, 9mm=95, 12mm=95, 15mm=120, 18mm=120, 24mm=150 |

## Regras de Precificacao de Machining

Regra principal:

- `Extra Processes`, `Drillings` e `Offset/Pocketing` sao porcentagens sobre `CNC Service`.
- Eles nunca sao porcentagens sobre o preco da sheet/material.

Formula do CNC com machining:

```text
CNC efetivo = CNC base
  + CNC base * extraPct
  + CNC base * drillingPct
  + CNC base * offsetPct
```

### Extra Processes

- Campo: `Extra Processes`.
- Cada processo extra adiciona `10%`.
- Exemplo: `2` processos = `+20%` sobre CNC Service.
- Valor minimo: `0`.
- Nao conta material.
- Nao conta spray.
- Nao conta VAT diretamente.

### Drillings

- Campo: `Drillings`.
- Se ligado, adiciona `+5%` sobre CNC Service.
- Hinges contam como drilling para precificacao.
- Se uma peca tiver `Hinges = Yes`, o app liga `Drillings = Yes` no bloco.
- Nao ha cobranca por quantidade de furos.
- Nao ha multiplicador por numero de hinges.
- O DXF pode desenhar circles de hinge, mas a cobranca e so a taxa global de `+5%`.

### Offset / Pocketing

- O app usa o nome `Offset` na interface atual, mas a regra corresponde ao antigo pocket/pocketing.
- Offset ligado mostra opcoes; desligado esconde opcoes.
- Em flat, ligar Offset/Pocketing ativa o frame/pocket logic necessario.
- Ao ligar Offset/Pocketing, a regra desejada historica e trocar para Hydrofugo/MR MDF, respeitando se o usuario trocar material depois.
- Offset cost e adicionado como porcentagem sobre CNC Service.
- `Offset Min` e editavel.
- O tempo automatico e baseado em area interna de frame/cavidade.
- Regra de tempo: `1 m2 = 12 minutos`.
- O app soma as areas internas/cavidades que recebem offset.
- Se a peca precisa de back face sheet, o app soma tambem as cavidades do back.

Tabela de porcentagem por minutos:

| Minutos de Offset | Percentual |
|---:|---:|
| 0 | 0% |
| >0 e <10 | 10% |
| 10 a 15 | sobe linearmente de 10% ate o cap |
| >=15 front only | 20% |
| >=15 front + back | 40% |

Detalhe da rampa:

```text
10% + (minutos - 10) * 2
```

Cap:

- Front only: minimo/cap `20%`.
- Front + Back: cap `40%`.

### Offset Lines

Linhas configuraveis atuais:

- Offset A / layer `OFFSET_A`
- Offset B / layer `OFFSET_B`
- Offset C / layer `OFFSET_C`
- Offset D / layer `OFFSET_D`
- Offset E / layer `OFFSET_E`
- Offset F / layer `OFFSET_F`
- Offset G / layer `OFFSET_G`

Regras:

- Offset A vem ligado por default quando applicable.
- Outras linhas ficam desligadas ate o usuario ligar/configurar.
- Offset lines nunca podem entrar no frame.
- Offset lines respeitam o inner frame e vao para dentro da peca.
- Round Corner principal arredonda inner frame com radius `2.5mm`.
- Back side offset/pocketing aparece como output separado e pode ser escondido pelo menu `View`.

### Time

- Campo: `Time (£250/hr)`.
- O input e em minutos.
- Formula: `minutos * 250 / 60`.
- O valor e aplicado por sheet do block/grupo.
- Exemplo: `30 min = £125` por sheet.

## Desconto

- Campo: `Quantity Discount (%)`.
- Default: `0%`.
- Se for `0%`, o desconto nao aparece no resultado.
- Se for maior que zero, aplica no subtotal do material block/grupo.
- Base de desconto: material + CNC efetivo + time.
- Nao aplica separadamente sobre VAT.
- Nao aplica em Design, Cutting List, Assembly e Spray no codigo atual.
- Limite: de `0%` a `100%`.

## Additional Services

Servicos opcionais globais:

| Servico | Valor |
|---|---:|
| Design | £35/hr |
| Cutting List | £25/hr |
| Assembly | £50/hr |

Regras:

- Inputs aceitam passo de `0.5` hora.
- Entram no subtotal geral ex VAT.
- Nao sao porcentagens de CNC.
- Nao entram na base do Quantity Discount do material block.

## VAT

- VAT padrao: `20%`.
- Subtotal ex VAT = materials/CNC + Design + Cutting List + Assembly + Spray.
- VAT = `subtotal ex VAT * 20%`.
- Resultado mostra `Total ex VAT` em destaque.
- Resultado mostra `Total inc VAT` menor abaixo.

## Spray Calculator

- Spray default: OFF.
- Spray pode ser ligado para quote.
- Spray auto areas podem preencher areas automaticamente.
- Spray Finish por peca e separado de Labels CNC.
- Labels CNC e Labels Spray Finish sao opcoes separadas.
- Spray Finish ON: clicar nas bordas da peca selecionada marca lados pintados.
- Label Spray mostra setas dos lados marcados.
- Spray Finish nao cria layer DXF extra.

### Regras de Area de Spray

- Flat sem frame/pocket/shaker: conta face + bordas pela thickness.
- Inserts/flushback/reeded contam front + back.
- Frame/shaker: conta `10 lados`: front, back, 4 outside edges e 4 inside edges.
- Esses detalhes orientam o calculo, mas nao precisam aparecer no resultado do cliente.

### Spray Profiles

| Profile | Rate |
|---|---:|
| End Panels | £50/m2 |
| With Plastic Edge | £45/m2 |
| Shaker | £65/m2 |
| Shaker with Cock Bead | £75/m2 |
| V Groove on Flat Panel | £55/m2 |
| Profiled Shaker | £75/m2 |
| Profiled Shaker & Cock Bead | £85/m2 |
| Fluted and Ribbed | £140/m2 |

### Spray Add-ons

| Add-on | Default | Tipo |
|---|---:|---|
| Additional Squares | 10% | Porcentagem sobre spray base |
| High Gloss Polishing | £100/m2 | Por m2 |
| Gun Gloss | £50/m2 | Por m2 |
| Extra Preparation | £0/m2 default | Por m2, editavel |

Formula:

```text
spray base = soma(area profile * rate profile)
percent add-on = spray base * percent
per m2 add-on = total spray area * rate
spray total = spray base + add-ons
```

## Doors

Door types padrao:

- Flat
- Traditional
- Flushback
- Reeded
- Custom DXF templates

Regras:

- Cada part pode ter door type individual em Part Dimensions.
- Door Setup controla material, thickness, size, frame, grain, reeded, beading, machining e offset.
- Clique em uma peca no sheet preview abre `Edit Piece`.
- `Hinges` por peca liga drilling no bloco.
- `Hinge side`: auto, left, right, top, bottom.
- `Hinge offset`: default `100`.
- `Hinge spacing`: auto quando vazio.
- Shapes: rectangle e sloped/loft.
- Sloped/Loft usa alturas left/right diferentes.
- A peca ainda e nested pelo max rectangle, mas o outline visivel/DXF segue o shape inclinado.

## Grain Direction

- Grain Direction e controlado no Door Setup.
- Quando ligado no block, parts herdam grain ON.
- Cada part pode desligar grain manualmente.
- Quando grain esta ON, a peca nao deve girar no nesting.
- A altura da peca acompanha a direcao do grain.
- A sheet deve mostrar textura woodgrain quando grain estiver ligado.
- Parts com grain devem mostrar simbolo/direcao de grain.

## Beading / Biding

- Beading cria material block secundario a partir de cada abertura interna.
- `G + Enter` no texto da peca vira Glass.
- Glass parts nao geram inserts.
- Auto usa fit gap de `0.15mm`.
- Manual permite alterar o fit gap.
- Espessuras disponiveis: `3mm`, `6mm`.
- Default beading size: `19.85mm`.
- Fit gap default: `0.15mm`.
- Round corners default ligado.
- Glass frame no DXF deve ter so tres linhas: `INSIDE`, `BEADING`, e outline relevante.
- Nomes DXF de glass frame devem ser em maiusculas: `INSIDE`, `BEADING`.

## Reeded

- Reeded direction: vertical ou horizontal.
- Spacing default: `12.5mm`.
- Spacing minimo: `1mm`.
- No DXF, reeded lines devem fazer zig-zag: uma linha de cima para baixo, proxima de baixo para cima, e assim por diante.

## Panneling - Regras Gerais

- O nome da aba fica `Panneling`.
- Room pode conter ate `50` walls.
- Cada Room tem walls, panel setup, previews, nesting e sheets proprios.
- Default wall size: `5200mm x 3200mm`.
- Cada wall tem width/height proprios.
- Alterar uma wall nao altera as outras.
- Cada wall pode escolher panel orientation: horizontal ou vertical.
- Vertical wall orientation deve preencher a wall automaticamente com panels verticais.
- Vertical orientation em uma wall nao altera outras walls.
- Vertical panel standard height permanece `3000mm`, mesmo quando wall height e `3200mm`.
- Max vertical panel width: `1206mm`.
- Max horizontal panel width: `2400mm`.
- H Panel H default: `1030mm`.
- V Panel H default: `3000mm`.
- Room names prefixam labels: exemplo `Kitchen Wall 1 - P2`.
- Wall preview, sheet preview, labels e DXF devem usar a mesma geometria fisica e o mesmo nome.

## Panneling - Rooms e Walls

- Room Setup tem Add Room e Remove Room.
- Remover a ultima Room deve criar uma Room vazia em vez de quebrar o app.
- Wall removal pode deixar zero walls.
- Cada wall pode ter Add Door, Add Window e Add Object.
- Door, Window e Object podem existir multiplos por wall.
- Opening X pode ser medido From L ou From R.
- Adicionar/editar um opening nao deve mover openings existentes.
- Se houver colisao, mostrar erro/estado no opening atual.
- Door e Object removem cobertura de panel naquele trecho da wall.
- Object default: `2000mm x 2000mm`.
- Object pode ter nome editavel.
- Object e tratado como espaco sem panel.

## Panneling - Shakers

- Auto shaker por wall mira aproximadamente `350mm`.
- Global shaker quantity foi removido do Panel Setup.
- Shaker count pode ser override por wall.
- Part Dimensions tem `Auto` por panel para devolver aquele panel ao calculo automatico da wall.
- Panel fisico so trava shaker quando usuario edita diretamente ou quando ha flag manual.
- Valores antigos de JSON em `wallPanelOverrides` sem flag manual devem ser tratados como Auto.
- Wall-level shakers orientam a distribuicao geral da wall, mas nao fazem cada panel repetir obrigatoriamente o mesmo count.
- Main shakers devem ficar consistentes dentro da wall onde possivel.
- Edge shakers podem crescer/encolher perto de wall ends, doors, windows, object spaces, corners e columns.
- Se o shaker count pedido faria um cut panel passar do max width, o max-width tem prioridade.
- Nesse caso, o app aumenta para a menor quantidade de shakers que cabe.
- Vertical panel em Auto volta para `2` shaker rows.
- Row count vertical so muda por override manual daquele panel.

## Panneling - Vertical Panels

- Vertical individual pode usar Irregular Shape ON por default.
- Vertical por wall usa regular shape por default.
- Vertical wall orientation faz todos os panels daquela wall virarem verticais.
- Vertical panel usa `2` shaker rows por coluna inicialmente.
- Bottom shaker row deve tentar igualar tamanho/altura do shaker horizontal.
- Top shaker row ocupa o restante da abertura respeitando frame.
- Vertical panel pode usar mais de uma shaker column se a largura fisica permitir.
- Se 3 shakers nao cabem em `1206mm`, tentar 2; se 2 nao cabem, usar 1.
- Vertical panel usa largura dominante/padrao do shaker horizontal do job, nao a sobra pequena da extremidade.
- Quando vertical encontra horizontal/residual, aplica step/joint.
- Se lado do vertical termina a wall, volta para frame normal cheio.

## Panneling - Side Rules

Side rules disponiveis:

- Normal
- Joint
- Vertical Joint
- Door
- Corner
- Column

Regras:

- Normal usa frame size.
- Joint usa metade do frame.
- Vertical Joint usa zero.
- Door usa Door Side.
- Corner e Column adicionam material thickness.
- Side rules devem poder ser setadas por lado de panel fisico, nao apenas por wall.
- Overrides de side rules devem fluir para wall preview, nesting/sheet preview e geometria/DXF.

## Panneling - Skirting

- Skirting default: `225mm`.
- Skirting pode comecar como default da Room e ser override por wall.
- Com frame `80mm` e skirting `225mm`, a linha guia pontilhada fica a `225mm` do chao.
- O shaker inferior comeca em `skirting + frame`.
- Exemplo: `225 + 80 = 305mm`.
- A linha pontilhada do skirting e apenas guia visual da wall preview.
- Skirting guide nao aparece no nesting/sheet.
- Skirting guide nao aparece no DXF.

## Panneling - Doors, Windows e Objects

- Door aparece na wall preview, mas nao vira peca no nesting.
- Window pode criar lower panel separado.
- Quando uma window entra abaixo do topo normal dos panels horizontais, cria um lower panel separado cobrindo toda a largura da window.
- Por enquanto, lower window panel usa a altura do window bottom.
- Lower window panel fica separado e horizontal.
- Panels horizontais que tocam lower window panel usam half-frame joint no lado da window.
- Window Sill Height default: `22mm`.
- Window side panels continuam depois da linha inferior da window por `Window Sill Height`, depois entram half frame para dentro da janela.
- Com frame `80mm`, esse step entra `40mm`.
- Esse step e frame-only: nao deve deslocar/redimensionar shakers/cavidades.
- Window preenchida deve ser desenhada atras dos panels; por cima fica apenas contorno/texto clicavel transparente.
- Object cap panel cobre largura do Object + half frame de cada lado quando ha espaco, limitado pela wall/openings vizinhos.
- Object cap panels e window lower panels permanecem horizontais e nao herdam vertical override de vizinhos.

## Panneling - Teclado e Selecionar Panels

- Em wall/panoramic preview, `ArrowUp` transforma panel selecionado em vertical.
- Em wall/panoramic preview, `ArrowDown` transforma panel selecionado em horizontal.
- `ArrowLeft` e `ArrowRight` selecionam panel fisico anterior/proximo.
- Left/right podem atravessar para outra wall dentro da mesma Room.
- Esses atalhos valem apenas para wall panels.
- Nao valem para Door, Window ou Object.
- Clique em Door, Window ou Object no preview deve dar foco real.
- `Delete` ou `Backspace` remove opening selecionado.
- `Delete` ou `Backspace` pode remover panel fisico selecionado sem esticar/reconstruir vizinhos.

## Panneling - Previews e Sheets

- Panoramic header usa nome da Room e quantidade de walls.
- Nao deve dizer "panels shown in green".
- Cores das Rooms devem ser sobrias: verdes, castanhos, cinzas quentes, musgo.
- Evitar rosa, roxo, azul bebe e amarelo.
- Wall previews devem escalar walls menores mais estreitas que walls maiores.
- Textos de milimetros nao podem remover zeros: `3500mm` deve aparecer como `3500mm`, nao `35mm`.
- Part Dimensions deve ter ajuda curta.
- Notas de `7mm` e rotacao devem ficar perto das sheets.
- Nesting/sheets no Panneling ficam ocultos por default; botao `Nesting` mostra/oculta sheets depois das wall previews.
- Sheet counts e captions sao por Room em Panneling.

## DXF

- Export DXF deve incluir somente layers relevantes.
- Nao exportar layers vazias.
- Export by thickness gera um DXF por material thickness.
- DXF by thickness salva arquivos separados em pasta, nao ZIP.
- Motivo: ZIP/NC vinha causando alerta do Windows Security.
- Preview da wall, nesting/sheet e DXF devem usar a mesma geometria fisica.
- DXF de vertical panel deve usar o mesmo outline stepped/irregular da wall preview.
- Internal shaker/cavity lines do DXF devem seguir as mesmas row/column sizes do nesting preview.
- Offcut templates DXF devem preservar forma real.
- Circulo permanece circulo.
- Smart Takeoff DXF sem layers deve preferir outer shape.
- Exemplo: DXF `300x750` nao deve virar `295x755`.
- Se detectar frame via layers/retangulos internos, deve configurar frame e door type automaticamente quando possivel.

## Toolpath / NC

Tipos de operacao conhecidos:

- Profile Outside
- Profile Inside
- Pocket
- Drilling
- Engraving
- V-Groove
- Chamfer
- Profile On Line

Regras:

- Tipos de toolpath nao criam cobranca automaticamente sozinhos.
- A cobranca vem dos campos de pricing/machining.
- Drilling como operacao e diferente do campo de preco `Drillings`, mas hinges ligam `Drillings`.
- Pocket como toolpath e diferente das linhas de Offset/Pocketing de precificacao, mas faz parte da mesma familia de machining.

## Labels e Checklist

- Labels precisam ser vetoriais/SVG/HTML de alta qualidade.
- Labels nao devem ser raster blur.
- Labels CNC e Labels Spray Finish sao separados.
- `Print Labels Map` imprime uma pagina A4 landscape por sheet, mantendo o desenho/nesting da sheet como mapa de referencia.
- `Print Labels Map` deve mostrar em cada peca o mesmo numero global usado nas labels CNC/A4, para a peca 1 bater com a peca 1, a peca 31 bater com a peca 31, e assim por diante.
- `Print A4 Labels` imprime uma pagina A4 landscape por sheet, com blocos de labels legiveis em grid, sem usar nesting real/proporcional.
- `Print A4 Labels` segue a ordem das pecas da sheet e usa o mesmo numero global da peca usado no Labels Map.
- Em `Print A4 Labels`, cada label/bloco deve ocupar no maximo 1/4 da pagina; mesmo uma sheet com uma unica peca nao pode virar uma label de pagina inteira.
- Em `Print A4 Labels`, o header `Sheet X of Y` fica pequeno e as informacoes principais sao dimensao, texto da peca, numero global e quantidade/copia quando aplicavel.
- Checklist usa QR/job payload.
- QR code deve carregar com part relationship para o checklist app marcar pecas completas.
- Checklist QR depende de calculo/checklist file.
- Label Spray mostra setas dos lados marcados para Spray Finish.

## Smart Takeoff

- Smart Takeoff aceita texto, imagem ou DXF.
- Exemplos de texto aceitos historicamente: `D 2x 700 x 730`, `700 x 730 x2`.
- Smart Takeoff aceita linhas coladas do Excel/listas de corte com quantidade em formato `2 @ 2305 x 710 texto`.
- O valor antes de `@` e a quantidade de pecas iguais daquele tamanho.
- O texto depois das dimensoes deve ser preservado/resumido no campo de texto da peca; exemplo: `2 @ 2305 x 710 SA-4 SIDES- 2S/2L` cria 2 pecas `2305 x 710` com texto `SA-4 SIDES- 2S/2L`.
- Quando houver coluna/valor de Sub-Assembly, o texto final pode usar prefixo `SA-<valor>` para manter a referencia do conjunto.
- As quantidades importadas precisam ser respeitadas, criando linhas/pecas suficientes para cada quantidade detectada.
- OCR carrega imagens.
- DXF takeoff le closed rectangular outlines.
- DXF sem layers deve preferir outer shape.
- Se o DXF tiver layers ou retangulos internos reconheciveis, o app deve tentar detectar frame/door type.
- Smart Takeoff ainda precisa mais variacoes aceitas conforme exemplos reais do usuario.

## UI / Layout

- A command bar fica fixa no topo.
- Menu superior inclui File, Edit, View, Print, Checklist.
- Linha de comandos inclui Calculate, Doors, Panneling, DXF Templates, Toolpaths.
- Remover/evitar botao `Round?` se nao for util.
- UI deve ser compacta e profissional.
- Fontes devem ser menores, claras e legiveis.
- Evitar excesso de cards dentro de cards.
- Areas como Part Dimensions devem ser mais limpas e menos confusas.
- Selected piece foi renomeado para Edit Piece quando aplicavel.
- O clique nao deve fazer a pagina pular para outro lugar.
- Ao clicar em uma peca/opening, a selecao deve permanecer nela.

## Back Side Offset / Pocketing

- Back Side Offset pode ser mostrado/escondido pelo menu View.
- Quando mostrado, aparece nas sheets/preview como output separado.
- Back side pocketing aparece em vermelho/identificado.
- Back side pocketing deve ser considerado no calculo de offset minutes quando Front+Back estiver ligado.
- Back side pocketing nao deve gerar retangulos/layers extras indevidos no DXF.

## Regras de Compatibilidade JSON

- Arquivos antigos podem ter `wallDoor*` e `wallWindow*`.
- Ao carregar, esses campos devem ser convertidos para `wallOpenings`.
- Isso permite editar/remover Door/Window/Object no preview e na lista.
- Arquivos antigos podem ter `wallPanelOverrides` sem flag manual.
- Esses valores devem ser tratados como Auto, nao como trava manual.
- Loaded jobs devem permitir remover rooms, walls, openings e selected panels.
- Panels importados verticais devem poder voltar para horizontal individualmente.

## Validacao Local

Syntax check dos scripts inline:

```powershell
@'
const fs = require('fs');
for (const file of ['Cnc Calculator UI Test.html', 'CNC Calculator 1.0.html']) {
  const html = fs.readFileSync(file, 'utf8');
  const scripts = [...html.matchAll(/<script[^>]*>([\s\S]*?)<\/script>/gi)].map(m => m[1]);
  for (let i = 0; i < scripts.length; i++) new Function(scripts[i]);
  console.log(`${file}: checked ${scripts.length} inline script(s)`);
}
'@ | node -
```

Servidor local:

```powershell
cd "C:\Users\ednei\Documents\CNC App"
python -m http.server 8765 --bind 127.0.0.1
```

URL local:

```text
http://127.0.0.1:8765/Cnc%20Calculator%20UI%20Test.html
```

## Regras de Git / Publicacao

- Branch default para Codex Cloud: `main`.
- Arquivo publicado: `Cnc Calculator UI Test.html`.
- Espelho local: `CNC Calculator 1.0.html`.
- GitHub Pages URL: https://spaceinvuk.github.io/cnc-calculator/Cnc%20Calculator%20UI%20Test.html
- Antes de trabalhar: fetch, checkout main, pull ff-only.
- Depois de alterar a calculadora oficial, manter os dois HTML sincronizados.
- Nao staging de arquivos nao relacionados.
- Nao apagar/restaurar arquivos do usuario sem pedido explicito.

## Pendencias / Cuidados Conhecidos

- QR library pode falhar se nao carregar, fora do escopo de Panneling.
- Smart Takeoff precisa mais exemplos reais para aceitar mais variacoes.
- DXF deve ser revisado para garantir que nao cria retangulos extras que prejudiquem corte.
- Nesting manual precisa evitar overlaps em todos os casos.
- Window side frame step deve entrar na janela como frame-only, sem mexer nos shakers.
- Object cap/top panels e joints especiais continuam sendo area sensivel.
- Back Side Offset deve aparecer quando util, mas nao deve poluir PDF/cliente se escondido.
