# Bee Exchange 0.2.13-dev

Depois da 0.2.12, o usuário confirmou que a máquina colocada ainda selecionava
textura incorreta. A sincronização de facing isolada não resolvia a causa.

Causa identificada no código do OpenStarbound 0.1.14, commit
cd2d804f6feaa4c588df822f01eb5504ebd4ba55:
source/game/scripting/StarLuaRoot.cpp, LuaRoot::createContext carrega os arquivos
Lua antes de instalar m_luaCallbacks; LuaComponents instala também os callbacks
do objeto depois dessa criação. storagecompat.lua consultava root.assetJson no
corpo do módulo, quando root ainda não existia. Isso abortava a criação do
contexto inteiro, antes do init do controlador e da seleção dos atlas direcionais.
storageaging.lua tinha a mesma falha no carregamento do módulo de aging.

A nova reprodução local retira root/config/object/animator e demais bindings
antes de carregar os arquivos, imitando a ordem real. A versão anterior falhou
com storagecompat.lua:3: attempt to index a nil value (global root). A nova passa.
Os testes anteriores forneciam as APIs antes do carregamento e não capturavam
esse defeito; essa limitação dos mocks foi corrigida também no runner básico.

Correção: detecção e carga do IC movidas para init. Antes do require, os hooks
init/update/die originais são disponibilizados ao IC; depois são preservados e
encadeados, sem recursão para o próprio init da ponte. Aging resolve o provedor
na primeira chamada de ageItem, quando root já está disponível. Não há chamadas
de API do engine no corpo desses módulos durante a criação do contexto.

146 grupos locais passaram: 135 básicos, incluindo bootstrap sem IC e aging
sem root durante load, mais 11 com os scripts reais do IC. Vendas, direção,
trava, GUI e recuperação de conteúdo/recompensas continuam cobertos. Sprites PNG
inalterados byte a byte. PAK nativo conferido por pack/unpack de 51 arquivos.
Sem execução dentro do jogo: conferir o resultado após reiniciar com o novo PAK.
Fechar o jogo, substituir o PAK anterior e abrir novamente; não precisa quebrar
ou refazer a máquina. Main permanece inalterada.
