# Molduras estáticas e centralização — 0.1.5-dev

A captura do usuário mostrou que, ao preencher um slot, a moldura do mod sumia
e aparecia a borda nativa de raridade com o ícone deslocado. O usuário solicitou
molduras estáticas, itens por cima e dimensões padrão Starbound/FU.

## Causa verificada

No OpenStarbound 0.1.14 (cd2d804f6feaa4c588df822f01eb5504ebd4ba55),
ItemSlotWidget calcula seu tamanho a partir do maior entre itemDraggableArea.max
e o tamanho de backingImage. Nossos PNGs de 24×24 ampliavam o slot filho de
19×19 para 24×24 e moviam seu centro de (9,9) para (12,12). A borda de raridade
é desenhada na origem do slot; os ícones são desenhados no centro calculado.
Isso deslocava o ícone em relação à borda nativa. Além disso, o comportamento
padrão esconde backingImage ao preencher o slot.

Referências verificadas: ItemSlotWidget/ItemGridWidget/WidgetParsing na revisão
acima; chest1.config vanilla e interface.config, revisão
3b370d25c27923155badb38c414a664e1ee2abfc do espelho FerreiraJGB/Starbound;
bees/interface/beeexaminer/beeexaminer.config no FU fixado em
17868d86c9bb7bc00f92038fb78b48cebd1b41b8. O padrão usa spacing 19×19; imagens
de fundo/borda de inventário conferidas têm 18×18 e o slot filho tem 19×19.
A área de clique nativa é [-2,-2,19,19], independente da imagem decorativa.

## Implementação

- approvedFrame, inputFrame e rejectedFrame são widgets image de 24×24, nas
  origens (60,35), (180,35) e (300,35). São mouseTransparent, sem trim/centered
  e zlevel=1. Não dependem do estado de ocupação do container.
- Os três grids continuam nativos 1×1, com spacing 19×19, backingImage vazio
  e desenho do backing desativado, zlevel=2. Sem a imagem de 24×24 no grid,
  seu slot filho conserva tamanho nativo 19×19.
- Origens dos grids: (63,38), (183,38) e (303,38). A soma do centro inteiro
  nativo (9,9) coincide com o centro da moldura (12,12). Assim, os centros
  visuais permanecem (72,47), (192,47) e (312,47), sob os mesmos rótulos.
- A moldura não substitui contagem, borda de raridade ou tooltip do engine.
  As imagens decorativas não interceptam mouse ou cliques.
- Slots físicos e offsets ITD permanecem Approved=1, Input=0, Rejected=2.
  Scripts Lua de produção, recipe e objeto da máquina não foram alterados.

## Verificação

91 grupos passaram; S5 confere camadas, transparência ao mouse, ausência de
backing, espaçamento, dimensões e igualdade dos centros, além dos offsets.
Os seletores e helpRegions/helpTexts conservam os mesmos dados da versão anterior.
Na revisão offline, preencher/esvaziar as três posições não deslocou nem ocultou
molduras e os centros dos ícones de exemplo coincidiram com os centros das imagens.
O exemplo usa o próprio ícone de inventário do mod, de 20×20, como fixture.

[Imagem offline](../artwork/implemented/hud-slots-0.1.5.png) e
[HTML interativo](../artwork/implemented/hud-slots-0.1.5.html). Tipografia de
navegador é aproximada; não são capturas do jogo nem executam o engine.
O PAK é verificado por round-trip nativo. Validar também no jogo com larvas,
Queens, stacks e interação nativa; o resultado visual no engine segue pendente.

## Instalação

Feche o jogo, remova o PAK anterior da pasta de mods e instale
fubeesgenetics-mvp-0.1.5-dev.pak. Abra a máquina existente, sem quebrar ou
resetar o perfil. Confira moldura e centralização nas três posições com itens
vazios/ocupados, contagem, tooltip, clique direito e Shift+Click; repita ITD.
Entrega somente em dev, sem PR ou promoção para main.
