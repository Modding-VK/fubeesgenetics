# Textos e espaçamento da HUD — 0.1.6-dev

O usuário confirmou que as alterações da 0.1.5 funcionaram perfeitamente e
pediu nomes mais claros para os comparadores, setas e ajustes de espaçamento.

## Alterações

- Equal or higher: seta para cima e texto em duas linhas; modo interno gte.
- Equal or lower: seta para baixo e texto em duas linhas; modo interno lte.
- Indifferent: substitui o traço; modo interno ignore, congela a referência.
- A legenda também usa os nomes completos, sem os antigos símbolos lógicos.
- Cabeçalho ampliado para acomodar as setas e textos. Centros das colunas de
  comparadores passam a (259,303,347), com distância de 44 pixels; referências
  ficam alinhadas à direita em x=233. Tooltips acompanham as novas posições.
- Status passa de y=24 para y=21; Last result, de y=12 para y=9. Ambos descem
  3 pixels nativos, com afastamento da divisória e margem da borda inferior.
- Reset Profile usa textAlign=center e textOffset=(0,-1), compensando o texto
  visualmente alto observado na captura do usuário. Tamanho/posição do botão
  e comportamento de clique permanecem iguais.

Setas são PNGs próprios de 7×7, gerados em resolução nativa pelo tema. Não
exigem glifos Unicode nem alteram a arte da máquina. Resolução da pane 388×332,
molduras estáticas, geometria nativa dos slots e offsets ITD 1/0/2 preservados.
Receita e scripts Lua de produção permanecem byte a byte iguais à 0.1.5.

## Referência do engine

A revisão OpenStarbound 0.1.14 cd2d804f6feaa4c588df822f01eb5504ebd4ba55
foi consultada: WidgetParsing admite textAlign/textOffset nos botões e
vAnchor/lineSpacing nos labels; labels usam bottom por padrão. ButtonWidget
renderiza o texto no centro da imagem, com âncora vertical mid, somando o
offset configurado; o deslocamento nativo de pressionamento é preservado.
TextPainter aplica lineSpacing como múltiplo do fontSize. Os cabeçalhos usam
fonte 6 e espaçamento de 7 pixels entre linhas.

## Validação e instalação

91 grupos passaram: Adapter 22, máquina 40, interface 20 e assets 9. As novas
imagens têm CRC, dimensões e caminhos conferidos. O PAK passa por round-trip
nativo com 29 arquivos, assets idênticos e metadata JSON equivalente.

[Imagem offline](../artwork/implemented/hud-labels-0.1.6.png) e
[HTML interativo](../artwork/implemented/hud-labels-0.1.6.html) usam a config e
PNGs distribuídos. Tipografia do navegador é aproximada; não são capturas do
jogo. Reteste visual no OpenStarbound segue necessário, especialmente fonte,
quebras de linha e centralização do botão na escala usada pelo jogador.

Com o jogo fechado, substitua o PAK anterior por
fubeesgenetics-mvp-0.1.6-dev.pak. Reabra a máquina existente sem quebrá-la ou
resetar seu perfil. Compare as três opções nas seis linhas e o alinhamento
do rodapé/Reset. Entrega somente em dev, sem PR ou alteração de main.
