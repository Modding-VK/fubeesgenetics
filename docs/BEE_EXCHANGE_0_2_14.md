# Bee Exchange 0.2.14-dev

O usuário confirmou a correção da textura na 0.2.13 e relatou erro ao abrir a
janela: JsonException Cannot convert from object to string.

Causa: storagecompat.lua gravava a tabela da GUI em uiConfig. O método nativo
ContainerObject::containerGuiConfig exige texto e chama
assets()->json(configValue("uiConfig").toString()), conforme a fonte fixada em
tools/ui_upstream.json (OpenStarbound source/game/objects/StarContainerObject.cpp).
O mock aceitava a tabela diretamente e não verificava esse contrato. A reprodução
local agora falha com a mesma conversão antes da correção e passa depois.

uiConfig passa a ser sempre /interface/chests/chest16.config. init regrava esse
caminho, reparando inclusive parâmetros persistidos em máquinas já colocadas.
A integração com o IC vem de interface/chests/chest16.config.patch: só acrescenta
storagegui.lua se os widgets/scripts do IC existirem. Sem IC o patch não altera
nada. includes no metadata ordena este patch depois do IC sem exigir sua instalação.

A ponte GUI só envolve sort/quickstack quando world.entityName confirma o ID do
Bee Exchange, após inicializar os scripts do IC. Outros contêineres de 16 slots
mantêm os callbacks do provedor. Nenhum handler privado da máquina é chamado
para baús comuns. Mantidas as travas, recuperação de conteúdo/recompensas e as
correções de bootstrap/direção anteriores; PNGs preservados byte a byte.

148 grupos locais passaram: 135 básicos + 13 com o IC real e engine/GUI simulados.
Abertura pelo caminho nativo, reparação de uiConfig salvo como JSON, sort e
quickstack do Bee Exchange e sort de um contêiner comum cobertos. PAK SBAsset6
conferido por pack/unpack de 52 arquivos. Não houve execução dentro do jogo.
Fechar o jogo, substituir o PAK e abrir novamente; não é preciso refazer a máquina.
