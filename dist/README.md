# Arquivos de distribuição de desenvolvimento — 0.2.9-dev

- fubeesgenetics-mvp-0.2.9-dev.pak: formato nativo Starbound SBAsset6 para instalação manual.
- fubeesgenetics-workshop-content.zip: o mesmo PAK chamado contents.pak.
- SHA256SUMS: hashes dos dois arquivos.

Use Raw/Download no GitHub para baixar o arquivo binário. O ZIP do projeto pode
ser obtido pelo botão Code / Download ZIP na branch dev.
Instalação manual: Starbound/mods/fubeesgenetics-mvp-0.2.9-dev.pak, executando OpenStarbound
com FU instalado. Evite duplicar com pasta aberta ou assinatura Workshop.

Esta é uma build de desenvolvimento. Empacotamento nativo validado por round-trip
(48 arquivos); testes no jogo pendentes. A arte é provisória, recuperada do MVP;
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
