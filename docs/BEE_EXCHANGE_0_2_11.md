# Bee Exchange 0.2.11-dev

As inspeções Human, Apex, Avian, Floran, Glitch, Hylotl, Novakid e o fallback
genérico agora incluem as mesmas três instruções: input superior on/off (sem
fio = ligado), input inferior entrada da rede de itens e output saída da rede.
Preservados o tom racial e o prefixo Analytical do Glitch.

## Improved Containers 2.11 original

Analisado o contents.pak enviado pelo usuário, Workshop 729427606. Hashes do PAK
e dos arquivos executados nos testes constam em tools/ic_upstream.json.
Nenhum código ou asset do IC é redistribuído dentro do mod ou do repositório.

O objeto passa a usar /interface/chests/chest16.config, recebendo os patches
oficiais do IC, sem copiar posições de outra capacidade de baú. Mantém 16 slots,
a pegada, dados de inventário e os sprites aprovados. A cópia privada anterior
da interface fica no repositório como referência histórica, sem uso pelo objeto.

storagecompat.lua detecta a presença do script IC na janela nativa e carrega o
provedor instalado. Encadeia sua inicialização com a máquina e restaura
scriptDelta 10 após o IC tentar alterá-lo para 60. A dependência é opcional
(includes, sem requires): sem IC, a máquina conserva o funcionamento normal.

A janela IC recebe uma ponte privada, exclusiva desta máquina, que aguarda uma
confirmação do servidor antes de ordenar ou inserir itens por quick stack.
A trava do servidor pausa novas vendas e entregas pendentes durante a organização;
ela cobre os 1,4 s de verificação do IC, evitando a devolução de abelhas já vendidas.
Usados o sort, quickstack, busca e rename reais do mod instalado.

O IC substitui die sem encadeá-lo. A ponte chama primeiro a recuperação de
recompensas da máquina e depois o empacotamento de conteúdo do IC, uma única vez.
smashOnBreak evita um segundo drop do objeto pelo engine. A opção dropOnBreak do
IC mantém o caminho normal de drops. Conteúdo volta aos slots originais ao
reposicionar. O shim de aging usa o script instalado do IC para alimentos.

Ao remover o IC, a ponte desfaz apenas seus overrides persistidos de interface e
smashOnBreak. Conteúdo de uma máquina empacotada ainda é restaurado, sem depender
dos scripts removidos. Esses caminhos também estão cobertos pelos testes.

## Verificação

143 grupos locais passaram: 133 existentes e 10 novos com os scripts reais do
PAK fornecido, executados em contextos Lua isolados com engine, jogador e GUI
simulados. Casos: ausência do IC, init/cadência/handlers, sort com confirmação,
quick stack com venda posterior sem duplicação, busca/rename, quebra com conteúdo
e recompensa pendente, restauração, dropOnBreak, aging e remoção opcional do IC.

Reproduzir os checks extras: desempacotar o IC com asset_unpacker e executar
`python3 tools/run_checks.py --ic-root .cache/improved-containers`. O runner
verifica os hashes antes de executar código externo. O CI sem esse PAK continua
executando os checks básicos e a compilação dos arquivos do mod.

Pacote SBAsset6 validado por pack/unpack e conferência dos 51 arquivos.
Não houve execução dentro do jogo. Testar os botões, nomes raciais e a quebra/
recolocação no OpenStarbound com IC instalado. Compatibilidade com outros mods
de armazenamento e com Post-Load Mega-Patch não foi validada.
Substituir o PAK anterior sem manter duas cópias; não precisa refazer a máquina.
