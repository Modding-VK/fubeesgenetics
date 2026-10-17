# Auto Refugee — validação estática em pixels nativos

Proposta de arte, **não aplicada ao mod/PAK**. Sem alteração de versão, receita,
regras, interface ou animações. Mantida em dev para revisão, sem promoção de main.

O conceito aprovado nesta conversa remove as hastes superiores, substitui a
caixa por vidro parcialmente transparente e inclui uma haste interna sem inseto
no estado parado. `concept.png` preserva a imagem aprovada antes desta validação.

## Escala real e encaixe

O sprite do Terramart/FU usa frames **64×80 px** (default.frames nativo).
A origem atual da Bee Exchange é **(-8,0)** e seu footprint físico é 6×5 tiles.
A proposta mantém esse quadro e a base; a área visível fica em **(4,28)–(61,80)**,
ou **57×52 px**. As 28 linhas de cima ficam transparentes após remover as hastes.
Nenhuma escala artificial é necessária no mundo para reproduzir esse encaixe.

A imagem conceitual é 1122×1402. O conteúdo visível foi recortado em
(49,442), tamanho 1041×944, e levado a 57×52 por nearest-neighbor, com origem
(4,28) em um PNG RGBA de 64×80. `native.png` é a redução direta, sem alteração
de cor/alpha. Ela demonstra que o texto não deve ser entregue só por redução:
REFUGEE perde definição na grade pequena.

## Adaptação em pixels inteiros

`native-adjusted.png` contém dois ajustes limitados à placa e à haste:

- Placa já existente no mod, desenhada nativamente com letras de **3×5 px**.
- Haste regularizada, eixo de **2 px**, ponta/base de **4 px**, limites
  (31,60)–(35,67), com os dois pixels centrais conectados de y=60 até y=66.
  A ponta permanece no meio da caixa, sem inseto. O futuro inseto deverá ser
  ajustado em escala nativa na etapa de animação.
- Vidro e suas arestas foram preservados pela redução direta; área aproximada
  de 31×15 px, limites (17,53)–(48,68). As faces superior e inferior não são expostas.
- A área livre acima da ponta é pequena, cerca de 6 pixels de altura: o inseto
  precisa ser um sprite pequeno, com teste próprio de contraste/movimento.

A comparação pixel a pixel verificou que só a placa e a haste diferem da
redução direta. Arestas/reflexos e alpha do vidro não foram redesenhados nessa etapa.
A amostra de vidro fora da haste contém **349 pixels com alpha intermediário**.
Não houve conversão da imagem para alpha binário. O PNG foi conferido em RGBA.

## Evidência visual e limites

- [Comparação 1×/3×/6× e redução direta/adaptada](review.png).
- [HTML com fundo claro/escuro](review.html).
- [PNG nativo adaptado, 64×80](native-adjusted.png).
- [Resultados das verificações](validation.json).

O Chromium confirmou dimensões exatas de 64×80, 192×240 e 384×480 nas três
escalas, com image-rendering pixelated. Os painéis usam um fundo quadriculado
apenas na página de revisão; ele **não faz parte** dos PNGs da máquina.
São renderizações offline. Nenhum jogo, save, iluminação real ou animação foi
executado; não é uma aprovação de release nem uma afirmação de implementação.
A máquina no PAK atual continua usando o sprite/animação da versão 0.2.3-dev.

Para implementar posteriormente: retirar madeira e hastes do sprite-base nos
frames correspondentes, preservar origens e animações, compor o vidro/haste e
introduzir o inseto somente nos estados de venda. Apenas sobrepor vidro com
alpha à caixa de madeira atual faria a madeira aparecer através dele.
O retrato da interface também deve ser conferido: o quadro de 80 px conserva
área transparente acima, portanto o corpo visível fica menor ao usar maxSize=40.

## Reproduzir a redução e composição

Requer ImageMagick; a validação de PNG usa Pillow e a captura offline usa Chromium.
Os arquivos finais já estão preservados para revisão.

```sh
cd /workspace/fubeesgenetics
magick -size 64x80 xc:none \
  \( artwork/proposals/auto-refugee-glass-native-v1/concept.png \
  -crop 1041x944+49+442 +repage -filter point -resize '57x52!' \) \
  -geometry +4+28 -compose Over -composite -depth 8 -define png:color-type=6 \
  /tmp/auto-refugee-native.png
magick /tmp/auto-refugee-native.png \
  FUBeesGenetics/objects/bees/fubeesgenetics/beeexchange/autorefugee-plaque.png \
  -compose Over -composite \
  artwork/proposals/auto-refugee-glass-native-v1/rod-overlay.png \
  -compose Over -composite -depth 8 -define png:color-type=6 \
  /tmp/auto-refugee-native-adjusted.png
```
