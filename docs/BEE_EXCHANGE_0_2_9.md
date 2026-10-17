# Bee Exchange 0.2.9-dev

Ícone próprio de 16×16: apenas os pixels vermelhos da placa vanilla (109,37,26)
foram trocados por (244,187,66), #F4BB42, o mesmo amarelo da placa do móvel.
A geometria e os outros pixels do ícone permanecem iguais. Gerador separado:
python3 tools/build_beeexchange_icon.py. Inspeção Glitch agora começa com Analytical.

I/O baseado no cropshipper_kheAA2.object e cropshipper_kheAA.lua fixados no
manifest tools/upstream.json: logicNode 0, inDataNode 1 e outDataNode 0.
Input superior: on/off; input inferior e output: rede de itens do FU/ITD.
Sem fio no input 0, vende automaticamente. Conectado em baixo, pausa novas vendas;
conectado em alto, habilita. Entregas já devidas e a animação iniciada terminam
mesmo ao desligar; o contêiner permanece acessível e anunciado à rede nativa.
O teste do fornecedor de contêiner executa as funções reais de transferUtil.lua.

As coordenadas dos nodes são transladadas em +3 tiles no x, pois a origem do
sprite é [-8,0] aqui e [-32,0] na referência. Assim inputNodes [[3,1],[3,0]] e
outputNodes [[4,0]] ocupam exatamente os mesmos pontos físicos da imagem que
[[0,1],[0,0]] e [[1,0]] no Terramart. Não deslocamos a máquina ou sua pegada.
Como os papéis e posições dos nodes mudaram em relação aos placeholders antigos,
refazer conexões existentes. Não precisa refazer a máquina nem esvaziar slots.

Validação: 131 grupos locais passaram (incluindo pausa/retomada, chave desconectada,
interface nativa da rede e entrega pendente enquanto desligado). Checks estáticos
conferem coordenadas por comparação à referência e o ícone local. PAK nativo
conferido por pack/unpack de 48 arquivos. Teste real de cabos/ITD no jogo pendente.
