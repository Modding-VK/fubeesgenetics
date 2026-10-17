# Alinhamento do Filter — 0.2.18-dev

Base: dev 10935100979aae7a8c4e2cdd48b089260db01505, da 0.2.17. O usuário
apontou as listras inferiores e pediu Reset Profile centralizado entre barras.

- Reset Profile sobe 8 pixels: origem nativa (184,258) para (184,266), mantendo
  tamanho 100×20, caption e estados. Na pane 304×332, passa a ocupar y=46..66
  a partir do topo. O espaço livre entre o fim da divisória superior (y=35)
  e a barra STAT (y=77) deixa margens iguais de 11 pixels acima e abaixo.
- As duas listras paralelas descem 3 pixels, de y=323..327 para y=326..330
  a partir do topo. Antes atravessavam a borda azul interna (y=325) e chegavam
  ao fundo da pane. Agora ficam inteiras na faixa metálica abaixo dessa linha.
  Posições horizontais, cor, comprimento e inclinação de 45 graus são iguais.
- Cabeçalho, tamanho da janela, referências, comparadores, slots e rodapé textual
  permanecem iguais. Nenhum script de produção, receita ou objeto foi alterado.

135 grupos básicos passaram; os 13 casos opcionais IC não foram repetidos
porque o pacote original não está neste ambiente. PAK SBAsset6 validado por
pack/unpack nativo de 52 arquivos, com assets idênticos e metadata equivalente.
Workshop contents.pak é cópia idêntica ao PAK manual.

A revisão nativa dos pixels confirmou os 10 pixels das duas diagonais, todos
nas linhas 326..330, e a geometria 11/11 das margens do botão.

[Prévia completa](../artwork/implemented/hud-alignment-0.2.18.png),
[detalhe inferior](../artwork/implemented/hud-footer-detail-0.2.18.png) e
[HTML interativo](../artwork/implemented/hud-alignment-0.2.18.html). A fonte do
navegador é aproximada; conferir visual/hover/pressionamento no jogo.

Substituir o PAK anterior por fubeesgenetics-mvp-0.2.18-dev.pak com o jogo
fechado. Não precisa resetar perfil ou reconstruir máquinas. Entrega em dev,
sem PR, alteração de main, tag estável ou publicação Steam.
