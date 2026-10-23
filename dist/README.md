# Distribuição atual — Bee Abusive Industry 0.2.25-dev

- bee-abusive-industry-0.2.25-dev.pak: instalação manual Starbound/mods.
- bee-abusive-industry-workshop-content.zip: o mesmo PAK como contents.pak.
- SHA256SUMS: hashes da entrega atual; demais pacotes são históricos.

Autor exibido: Goblin Man. Nome: [oSB][FU] Bee Abusive Industry.
O nome técnico FUBeesGenetics e os IDs permanecem iguais. Substituir o PAK antigo;
não instalar as duas marcas simultaneamente. Não precisa resetar o perfil.

Na 0.2.23-dev, 172 grupos básicos e 13 casos opcionais com IC 2.11 passaram.
O mantenedor testou as novas máquinas no jogo: o Overload Apiary parou sem
energia na versão anterior; o Hybridizer permaneceu em zero com progenitores da
mesma espécie. Na 0.2.24-dev, o Hybridizer passa a carregar antes dos insumos.
O reteste dessa mudança no OpenStarbound ainda está pendente.
Os 667 arquivos do PAK 0.2.25-dev foram conferidos por empacotamento e extração
nativos. O comportamento sem energia nesta versão ainda precisa de reteste no jogo.
Ver docs/RELEASE_READINESS.md para separar pacote pronto de publicação oficial.

A série 0.2.20 acrescentou o Overload Apiary e o Genetic Hybridizer. O sucesso
da hibridização entrega uma larva de rainha. O Overload Apiary não gera
abelhas entidades capturáveis aleatórias. Ver
docs/HYBRID_FIXES_0_2_20.md para os detalhes e a validação pendente no jogo.
Esta 0.2.21-dev acrescenta 595 folhas de sprites próprias para as híbridas;
o PAK anterior 0.2.20-dev continua preservado no histórico.
Esta 0.2.22-dev acrescenta suporte às híbridas nos apiários FU pequeno e grande;
o PAK 0.2.21-dev também permanece preservado.
Esta 0.2.23-dev retira o catálogo expandido de 1 MB do PAK e carrega os scripts
híbridos nos apiários somente quando uma híbrida está presente. O PAK
0.2.22-dev permanece preservado.
Esta 0.2.24-dev permite carregar o Hybridizer sem progenitores válidos. O PAK
0.2.23-dev permanece preservado.
Esta 0.2.25-dev mantém o Overload Apiary ativo sem energia, com velocidade
normal de recursos e drones; seus 12 W concedem o bônus de 20%. A rainha
continua envelhecendo mais rápido. Receita: 1 Normal Apiary, 1 AI Chip e
5 Durasteel Bars. O PAK 0.2.24-dev permanece preservado.

## Registros anteriores

# Arquivos de distribuição de desenvolvimento — 0.2.18-dev

- fubeesgenetics-mvp-0.2.18-dev.pak: formato nativo Starbound SBAsset6 para instalação manual.
- fubeesgenetics-workshop-content.zip: o mesmo PAK chamado contents.pak.
- SHA256SUMS: hashes dos dois arquivos.

Use Raw/Download no GitHub para baixar o arquivo binário. O ZIP do projeto pode
ser obtido pelo botão Code / Download ZIP na branch dev.
Instalação manual: Starbound/mods/fubeesgenetics-mvp-0.2.18-dev.pak, executando OpenStarbound
com FU instalado. Evite duplicar com pasta aberta ou assinatura Workshop.

Esta é uma build de desenvolvimento. Empacotamento nativo validado por round-trip
(52 arquivos); testes no jogo pendentes. A arte é provisória, recuperada do MVP;
a diretriz v1.2 disponível é consolidada do histórico, não o anexo integral.
Nenhuma publicação Steam ou aprovação de release é afirmada.

Correções: inicialização do Adapter, espelhamento nativo esquerda/direita e
confirmação de transferências no OpenStarbound 0.1.14. Ver docs/RUNTIME_FIX_0_1_1.md.

A 0.1.2 corrige os seletores; ver docs/RUNTIME_FIX_0_1_2.md. O histórico das
entregas e links dos pacotes anteriores está em docs/VERSION_HISTORY.md.

A 0.1.3 implanta o tema GUI aprovado; ver docs/HUD_THEME_0_1_3.md.
A lógica da 0.1.2, validada pelo usuário com ITD, foi preservada.

A 0.1.4 adiciona os reagentes à receita. Entrega de desenvolvimento na branch
dev; sem PR ou promoção para main. Veja docs/RECIPE_0_1_4.md e VERSIONING.md.

A 0.1.5 mantém molduras estáticas atrás dos itens e usa alinhamento de slots
nativos; ver docs/HUD_SLOTS_0_1_5.md.

A 0.1.6 usa setas e os nomes Equal or higher / Equal or lower / Indifferent,
ajusta o rodapé e centraliza Reset Profile; ver docs/HUD_LABELS_0_1_6.md.
O usuário confirmou o funcionamento visual dos slots da 0.1.5; as mudanças
visuais da 0.1.6 ainda precisam de conferência no jogo.

A 0.2.0 acrescenta Bee Exchange: trocas automáticas do Bee Refuge, 20 slots,
receita e desbloqueio pela Bee Station. São 126 grupos de testes locais;
validação de crafting, mundo e ITD da nova máquina ainda pendente.
Veja docs/BEE_EXCHANGE_0_2_0.md.

A 0.2.1 usa interface nativa de container semelhante ao Terramart, com
20 slots visíveis e alinhados, imagem da máquina e Take all.
Veja docs/BEE_EXCHANGE_UI_0_2_1.md.

A 0.2.2 amplia para 24 slots e usa o sprite/animações do Terramart do FU,
com placa Auto Refugee amarela alaranjada. Instalação por substituição do PAK, sem refazer a máquina.
Veja docs/BEE_EXCHANGE_0_2_2.md.

A 0.2.3 reduz para 16 slots e troca Young Queens pelos mesmos recursos das
Queens adultas por espécie. Esvazie a fileira inferior antes de atualizar de 24
para 16 slots; offsets ITD agora 0–15. Veja docs/BEE_EXCHANGE_0_2_3.md.

A 0.2.4 aplica a caixa de vidro e haste aprovadas, com inseto girado 90°
no sentido horário e animação de teleporte em work. Ciclo de 1,25 s, som nativo
e retorno à caixa vazia. Mantém 16 slots e as mesmas trocas/receita.
126 grupos locais passaram; conferência no jogo pendente.

A 0.2.5 restaura display fullbright azul em ready e seta amarela em work,
carcaça com paleta nativa e sem marcas de dano, LED na lateral superior e
inspeções das sete raças básicas. A descrição esclarece o lote de cinco drones
da mesma espécie. Não houve defeito reproduzido na venda dos drones: o teste
relatado usava menos de cinco ou espécies misturadas.

A 0.2.6 substitui a carcaça FU pela original vanilla do Terramart, sem as marcas
de dano remanescentes. Restaura ambos os LEDs laterais vanilla, com dimensões,
posições e fullbright originais; não redesenha nem desloca os LEDs.

A 0.2.7 cadastra orientações esquerda/direita para a prévia de placement e
usa variantes de placa/display que compensam o espelhamento automático do
engine. Texto e símbolos ficam legíveis nos dois lados, em ready e work.
127 grupos locais passaram; validação de placement dentro do jogo pendente.

A 0.2.8 integra a estampa à moldura original da placa, corrige dois pinholes e
o vestígio da haste externa no canto superior, encurta a haste interna em dois
pixels e baixa inseto/teleporte na mesma medida. Display esquerdo deslocado
dois pixels para a esquerda.

A 0.2.9 usa placa amarela no ícone do inventário, prefixo Glitch Analytical e
I/O com chave de liga/desliga equivalente ao Terramart 3.5. Input superior: chave;
input inferior e output: rede ITD. Sem fio na chave, a venda é automática.
Refaça conexões existentes conforme os novos papéis dos nodes.

A 0.2.10 substitui a madeira do ícone por vidro azul com transparência, reflexo
e haste vazia. A integração com Improved Containers 2.11 ainda está pendente
do código do mod; a interface privada atual continua ativa nesta entrega.
Não considerar esta versão uma integração completa com Improved Containers.

A 0.2.11 conclui a integração opcional com o Improved Containers 2.11 enviado
pelo usuário: janela nativa, ordenar/empilhar/buscar/renomear e conteúdo ao quebrar,
com pausa das vendas durante as operações e recuperação das recompensas pendentes.
Inspeções raciais agora explicam os nodes. 143 grupos locais passaram, incluindo
10 que executam o Lua real do IC com bindings simulados; teste no jogo pendente.

A 0.2.12 ressincroniza a textura direcional a cada update, inclusive durante
travas IC e com a chave desligada. Corrige o caminho que deixava placa/display
espelhados se a direção mudasse ou a tag visual fosse perdida após init.
145 grupos locais passaram; PNGs aprovados preservados byte a byte.

A 0.2.13 corrige o erro de bootstrap dos adaptadores IC: root só é consultado
no init (ou na primeira chamada de aging), depois de o engine instalar callbacks.
Isso permite inicializar o controlador e selecionar corretamente os sprites.
146 grupos locais passaram com a ordem de bootstrap nativa reproduzida.

A 0.2.14 corrige Cannot convert from object to string ao abrir: uiConfig
permanece um caminho de arquivo, e a ponte IC usa patch condicional da janela
compartilhada, ativando sua trava apenas no Bee Exchange. Repara overrides salvos
sem recriar a máquina. 148 grupos locais passaram; conferência no jogo pendente.

A 0.2.15 corrige o nome exibido na interface e no item para Auto Refugee.
IDs, inventários, sprites e lógica permanecem iguais. 148 grupos locais passaram;
52 arquivos conferidos por pack/unpack nativo.

A 0.2.16 compacta o Filter de 388 para 304 pixels de largura, centraliza
as referências, aproxima os slots e baixa o cabeçalho em 3 pixels.
135 grupos básicos passaram; o IC opcional não foi repetido neste ambiente.
Detalhes em docs/HUD_COMPACT_0_2_16.md. Pacotes anteriores são históricos;
instale apenas uma versão do addon por vez.

A 0.2.17 centraliza o logo entre contorno e divisória, alinha o nome laranja ao
topo do logo e acrescenta “Sort queens by genetic traits.” em cor clara.
135 grupos básicos e pack/unpack nativo de 52 arquivos passaram.
Veja docs/HUD_HEADER_0_2_17.md.

A 0.2.18 centraliza Reset Profile entre a divisória superior e a barra STAT,
com margens iguais de 11 pixels. As duas listras foram baixadas 3 pixels para
ficarem na faixa metálica inferior. Ver docs/HUD_ALIGNMENT_0_2_18.md.
