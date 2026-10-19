# Cabeçalho do Filter — 0.2.17-dev

A pedido do usuário, o cabeçalho segue a organização da Power Station mostrada
na captura: logo à esquerda, nome colorido no topo e descrição curta clara abaixo.
A base é a dev e2314b4063201da968d933fd6547c6e2e9255eb8, da versão 0.2.16.

## Disposição nativa

- Logo 20×20 em (14,302), deslocado 2 pixels para baixo. Na pane 304×332,
  ocupa y=10..30 em coordenadas a partir do topo. O limite interno superior
  está em y=7 e a divisória em y=33: margens iguais de 3 pixels.
  centered=false e trim=false deixam o posicionamento explícito.
- Nome Genetic Queen Filter em (42,322), vAnchor=top, fonte 10 e laranja
  #ff9b3d. A âncora superior coincide com o topo do logo, em y=10.
- Descrição “Sort queens by genetic traits.” em (42,309), vAnchor=top,
  fonte 7 e cor clara padrão #dce7f1. Ocupa y=23..30, abaixo do nome e
  alinhada à mesma origem horizontal, sem aumentar o cabeçalho.
- PNGs, resolução da pane e do cabeçalho, molduras/slots, referências, modos,
  tooltips e botão de fechar permanecem iguais à 0.2.16.

Só metadata e config da GUI mudaram nos assets de produção. Scripts Lua,
classificação, persistência, recipes e toda a Auto Refugee são byte a byte iguais
à base. Não precisa resetar perfil ou reconstruir nenhuma máquina.

## Validação

135 grupos básicos passaram e o PAK passa por pack/unpack nativo de 52 arquivos.
Os 13 casos opcionais IC não foram repetidos: o pacote original não está neste
ambiente, e não houve alterações nos scripts/integração da Auto Refugee.

[Detalhe do cabeçalho](../artwork/implemented/hud-header-detail-0.2.17.png),
[pane completa](../artwork/implemented/hud-header-0.2.17.png) e
[HTML interativo](../artwork/implemented/hud-header-0.2.17.html) usam os assets
reais. A revisão offline confirmou margem simétrica, âncoras superiores iguais
e separação das duas linhas. A fonte do navegador é aproximada: conferir o
resultado no OpenStarbound, sobretudo baseline e escala da tipografia real.

Substituir o PAK anterior por fubeesgenetics-mvp-0.2.17-dev.pak com o jogo
fechado. Reabrir a máquina existente. Entrega apenas em dev, sem PR ou alteração
de main; nenhuma publicação Steam ou release estável foi realizada.
