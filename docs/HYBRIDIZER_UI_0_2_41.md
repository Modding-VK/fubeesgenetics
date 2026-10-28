# Janela do Genetic Hybridizer — 0.2.41-dev

A referência visual foi a captura enviada pelo mantenedor. O painel anterior
media 304×220 pixels. O novo mede 270×165: menos 55 pixels de altura (25%) e
34 de largura (aproximadamente 1/9). Cabeçalho, corpo e rodapé têm 34, 119 e
12 pixels de altura, respectivamente.

O cabeçalho repete a geometria do Genetic Queen Filter: emblema 20×20 à
esquerda, título laranja e descrição clara com a mesma origem horizontal. O
emblema do Hybridizer combina DNA e um hexágono. Os slots de rainha e drone
passaram de 64 para 48 pixels de distância entre centros; o slot da larva
continua separado à direita. Os três itens usam os slots nativos, com molduras
estáticas em camada inferior. Chance, estado, alerta, progresso, consumo e
resultado permanecem visíveis. A arte do favo ocupa o canto inferior direito,
encosta no limite interno e é recortada sob a moldura de metal.

Os PNGs finais ficam em `FUBeesGenetics/interface/fubeesgenetics/hybridizer/`.
`tools/hybridizer_ui_assets.py` recria esses assets a partir da paleta comum
e de `artwork/ui/hybridizer/honeycomb-source.png`. O script de geração só é
executado durante desenvolvimento; a janela no jogo carrega PNGs prontos.

Diretriz para futuras janelas de máquinas: incluir um favo estático no canto
inferior direito, sob a borda, com contraste suficiente para ser percebido sem
disputar leitura com dados e controles. Usar o alinhamento do cabeçalho do
Analyzer e ajustar as dimensões ao conteúdo de cada máquina. Esta regra está
também em `AGENTS.md`.

Não há script recorrente novo, nova mensagem ou alteração de frequência:
Hybridizer continua em 30 ticks e a interface consulta a cada 2 segundos.
A composição foi inspecionada pelos assets gerados; tipografia, escala e
interação ainda precisam de conferência no OpenStarbound.

### Clear space for the power draw label (0.2.53-dev)

Removed the decorative horizontal rule at full-window y=132 from the generated
background. It crossed the `Power draw` label at the bottom of the pane. The
other horizontal panel dividers remain. Source and generated assets stay in
sync; no label coordinates or recurring scripting changed.

### Slot positions (0.2.57-dev)

Queen remains at x=42. Drone moves from x=90 to x=72, reducing the center
distance from 48 to 30 pixels. Disc is at x=120, 48 pixels after Drone. Larva
is at x=211, the previous Disc position. All four slots remain at y=81, with
their labels and independent static frames aligned. The native two-cell
`outputItemGrid` displays Disc then Larva; the server migrates existing
container items from the former Larva/Disc order once. Its row and column
spacing vectors keep the clickable grid bounds inside the 270-pixel window
while the two native cells remain 91 pixels apart. No additional pane
scripts or polling are introduced; in-game interaction still needs inspection.

### Disc hints and success text (0.2.58-dev)

The empty Disc slot cycles through the original FU Microdisc, Holodisc and
Megadisc 16×16 icons, then a blank state, changing every two seconds. The
icons use `?multiply=ffffff33` for 20% alpha and render below the native item
grid. A real item hides the hint. The pane reuses its existing two-second
timer and only changes the image or visibility when needed. The machine's
existing state reply includes disc presence and both calculated chances; it
reads the Disc slot once per reply even if no parents are present. There is no
new world polling cycle. Layout, alpha and interaction still need in-game
visual inspection.
