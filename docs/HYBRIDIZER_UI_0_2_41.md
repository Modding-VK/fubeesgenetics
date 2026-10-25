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
