# Bee Exchange: interface nativa de container — 0.2.1-dev

A captura da 0.2.0 mostrou uma janela vazia: o grid não tinha `backingImage`.
O engine criava os slots físicos mas não desenhava suas células vazias.
A interface agora segue o mesmo modelo usado pelo Terramart Shipments 3.5:
cabeçalho com ícone/nome/categoria, imagem do objeto à esquerda, grade nativa
à direita, contagem de slots, brilho diagonal, botão Take all e fechar.

## Auditoria do código e dos assets

- FU, commit `17868d86c9bb7bc00f92038fb78b48cebd1b41b8`:
  `objects/generic/cropshipper/cropshipper_kheAA2.object` aponta para
  `/interface/chests/chest<slots>.config`, com 40 slots. A variante codex em
  `interface/chests/cdx/chest40.config` conserva os grids de spacing 19×19 e
  `backingImage: /interface/inventory/empty.png`.
- Assets vanilla, espelho FerreiraJGB/Starbound, commit
  `3b370d25c27923155badb38c414a664e1ee2abfc`: chest24.config/chest40.config,
  interface.config, empty.png, fundos, overlay e botões de container.
- OpenStarbound v0.1.15.1, commit `e604e078e89310f1212dd20f5cd01bd59d25300b`:
  `StarWidgetParsing.cpp` usa backingImage vazio quando omitido;
  `StarItemGridWidget.cpp::locOfItemSlot` ordena colunas da esquerda para a
  direita e linhas de cima para baixo; `StarItemSlotWidget.cpp` calcula o
  tamanho do slot como max(itemDraggableArea.max, backingImage.size) e desenha
  o ícone em screenPosition + size/2 (divisão inteira).
- `source/frontend/StarContainerInterface.cpp` liga nativamente itemGrid,
  itemGrid2, clique direito, Shift+Click, clear/Take all, close e objectImage.
  O título/ícone é fornecido pelo engine quando hasWindowIcon é true, conforme
  `source/game/objects/StarContainerObject.cpp`.

As 20 referências de código/assets têm commits e hashes Git em
`tools/ui_upstream.json`. `run_checks.py --fetch` baixa e verifica esses blobs
além das 122 fontes FU. Nenhum asset vanilla é incorporado ao PAK: a janela
usa os caminhos do jogo instalado e respeita seus patches visuais.

## Implementação

Baseada em chest24.config, adaptada para **20 posições reais**:

| Grid | Dimensões | Origem | Offsets físicos |
| --- | --- | --- | --- |
| itemGrid | 4×4 | (81,62) | 0–15 |
| itemGrid2 | 4×1 | (42,43) | 16–19 |

A última fileira fica centralizada abaixo da imagem e da grade superior.
O cabeçalho mostra **20 SLOTS**, preenchido pelo engine com o tamanho real.
Os dois grids usam empty.png de **18×18** e spacing **19×19**. A área nativa
`[-2,-2,19,19]` mantém o slot em 19×19. O centro inteiro do slot é (9,9), o
mesmo centro da moldura de 18×18; a borda de raridade e o ícone ficam alinhados.
O fundo é desenhado vazio e ocupado, sem ampliar o widget com PNGs decorativos.

O objeto habilita hasWindowIcon. Não há scripts novos de interface: Take all,
cliques e tooltip continuam a cargo do container nativo. O gerador de assets
agora só desenha o sprite e o ícone próprios da máquina; os três fundos azuis
antigos foram removidos. Trocas, receita, desbloqueio e slots físicos não mudam.
O Queen Filter também permanece inalterado.

## Validação

**121 grupos passaram**: Adapter 22, Queen Filter 40, interface 20, Bee Exchange
26 e assets 13. A nova verificação S13 usa os PNGs/interface.config nativos
verificados para conferir centros, limites, espaçamento, 20 índices sem
sobreposição, título, callbacks e imagens de fundo. A verificação rejeitou
regressões de backing ausente, spacing 24×24 e offsets duplicados.

[Prévia offline](../artwork/implemented/beeexchange-0.2.1.png) e
[HTML interativo](../artwork/implemented/beeexchange-0.2.1.html) usam os assets
nativos, com fonte aproximada e ícones de exemplo. A revisão no Chromium
confirmou 20 células, centros dos exemplos e alternância cheio/vazio sem
ocultar molduras. Não é uma captura do OpenStarbound nem valida o engine real.

O PAK foi desempacotado com restauração de **36 arquivos**, assets idênticos e
metadata JSON equivalente. Hashes em dist/SHA256SUMS. Entrega somente em dev,
sem PR ou alteração de main. Validação visual/interação dentro do jogo pendente.

## Instalação e reteste

Feche o jogo e substitua o PAK anterior por
`fubeesgenetics-mvp-0.2.1-dev.pak`, mantendo só uma cópia instalada. Abra a Bee
Exchange existente: não precisa quebrar ou fabricar outra máquina.

- Confira título, imagem, **20 slots** e Take all.
- Insira um item sem receita em cada fileira; confira moldura, centro do ícone,
  quantidade, tooltip, clique direito e Shift+Click. Use itens sem receita para
  que não desapareçam por uma troca automática durante a inspeção visual.
- Use Take all e confira que todos os 20 offsets ficam acessíveis.
- Repita Honey Queen → 10 Coal e 5 Honey Drones → 7 Pixels com GUI aberta e
  fechada; confira a extração por ITD nos offsets 0–19.
