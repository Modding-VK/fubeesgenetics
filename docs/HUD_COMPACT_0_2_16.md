# Filter compacto — 0.2.16-dev

A captura do usuário mostrou a janela larga, referências alinhadas à direita,
slots muito distantes e setas próximas do contorno superior do cabeçalho.
Esta entrega usa a dev 97a47fd6cea6369697ca3981c2f9e090da00ff35 como base,
preservando os avanços da Auto Refugee e o histórico compartilhado.

## Layout

- Pane de 388×332 para 304×332: 84 pixels a menos, redução de 21,65% na largura.
  Frame, trilhos, divisórias, fechar e Reset acompanham a nova largura, sem
  reescalar os controles ou reduzir fontes.
- REFERENCE e os seis valores usam hAnchor=mid em x=142. Zero, inteiros e
  percentuais se alinham ao mesmo centro, sem depender do comprimento do texto.
- Comparadores ficam centrados em x=182/224/266, com espaçamento de 42 pixels.
  Textos e setas do cabeçalho descem 3 pixels. O painel ganha 3 pixels na base
  para manter margem também abaixo dos nomes, sem invadir a primeira linha.
- Slots Approved/Input/Rejected centrados em x=96/152/208, distância de 56 pixels
  em vez de 120. Molduras estáticas 24×24 em (84,35)/(140,35)/(196,35), grids
  nativos em (87,38)/(143,38)/(199,38). O deslocamento +3/+3 preserva a igualdade
  entre o centro da moldura (12,12) e o centro inteiro do ItemSlot 19×19 (9,9).
- Labels dos slots acompanham seus centros; offsets físicos e ITD continuam
  Approved=1, Input=0, Rejected=2. Raridade, contagem e interação são nativas.
- Status e Last result mantêm o afastamento do rodapé corrigido na 0.1.6.
- Os 28 helpRegions acompanham a tabela. A rotina visual limita o tooltip ao
  tamanho declarado no helpCanvas, com margem de 6 pixels em todos os lados,
  em vez de continuar considerando a antiga largura de 388.

Nenhum controle foi removido. Classificação, perfil, modos, polling, recuperação,
receitas, objeto da máquina e todos os assets/scripts da Auto Refugee permanecem
iguais à base; no Lua da GUI, só mudou o cálculo visual dos limites de tooltip.

## Verificação

135 grupos básicos passaram: Adapter 22, Filter 40, interface 20, Auto Refugee 40
e assets 13. U13/U14 usam as posições reais e verificam o desaparecimento do
help sobre os slots e a contenção do tooltip nas 28 regiões da pane reduzida.
Referências FU/vanilla/OpenStarbound são fixadas e verificadas por hash. Os
bindings do engine são simulados; os 13 casos opcionais com o IC original não
foram repetidos, pois esse pacote não está disponível neste ambiente.

[Prévia](../artwork/implemented/hud-compact-0.2.16.png) e
[HTML interativo](../artwork/implemented/hud-compact-0.2.16.html) usam a config
real e os PNGs distribuídos, ampliados 3×. O navegador aproxima a fonte do jogo;
não é captura do engine. A revisão conferiu separação dos cabeçalhos, centros
das referências e preenchimento dos slots sem deslocamento das molduras.
O gerador da prévia agora extrai largura/altura diretamente dos PNGs.

PAK SBAsset6 conferido com pack/unpack nativo: 52 arquivos, assets idênticos e
metadata JSON equivalente. A cópia Workshop contents.pak tem os mesmos bytes.

## Instalar e testar

Com o jogo fechado, substitua o pacote anterior por
fubeesgenetics-mvp-0.2.16-dev.pak em Starbound/mods e execute OpenStarbound com FU.
Mantenha apenas uma versão do addon. Abra o Filter existente; não precisa
quebrar a máquina ou resetar seu perfil. Confira textos, setas, tooltips,
slots e fluxo ITD na escala usada. Validação visual no jogo segue pendente.
Entrega em dev, sem PR, merge, tag estável ou publicação Steam.
