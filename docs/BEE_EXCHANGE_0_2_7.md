# Bee Exchange 0.2.7-dev

Prévia de placement: orientações com direction right/left e imagens já compostas
placement-right.png/placement-left.png, incluindo os LEDs e o display ready.
O seletor nativo do Starbound usa a afinidade da direção antes de colocar o objeto,
também no fallback de placement inválido. Nenhuma dessas imagens usa flipImages.

A orientação neutra no índice zero permanece para saves anteriores: Object::init
conserva a direção armazenada quando ela não tem directionAffinity. Novos
placements selecionam as orientações explícitas nos índices 1 e 2. Pegada,
imagePosition [-8,0], slots e nós permanecem iguais nas três entradas.

O engine espelha automaticamente o NetworkedAnimator quando o objeto olha para
a esquerda. static-left.png e display-left.png são variantes de entrada que
pré-compensam somente os caracteres e símbolos; depois do flip nativo, a carcaça
e os LEDs ficam do outro lado, enquanto AUTO REFUGEE e os sinais do display
continuam legíveis. Não são screenshots da aparência final; as imagens de
placement e a prévia direcional mostram essa aparência. Inseto e teleporte
continuam usando os mesmos frames, refletidos com a estrutura.

Lua escolhe facingSuffix no init conforme object.direction(), replicado como tag
do animator. Isso também atende máquinas antigas com orientação neutra e direção
salva para a esquerda. O eixo de espelhamento é fixado em 4 tiles (32 pixels),
metade do canvas de 64 pixels, para alinhar a animação à prévia de placement.

Referência do comportamento nativo: FerreiraJGB/Starbound commit
3b370d25c27923155badb38c414a664e1ee2abfc, source/game/StarObjectDatabase.cpp
(findValidOrientation/cursorHintDrawables), source/game/StarObject.cpp
(init/configValue) e source/game/StarNetworkedAnimator.cpp (drawables/globalTag).

Validação: 127 grupos locais passaram. E32 verifica seleção dos assets em ambas
as direções, venda e recarga à esquerda. Checks estáticos verificam as orientações,
pegada, paths, frames e eixo. O gerador verifica os dois textos e símbolos em todos
os frames com o flip final do engine. PAK nativo conferido por pack/unpack de 47
arquivos. Teste de placement, save e renderização dentro do jogo ainda pendente.

Prévia: artwork/implemented/beeexchange-0.2.7-directions.gif.
Instalação: substituir o PAK anterior. Não precisa refazer a máquina.
