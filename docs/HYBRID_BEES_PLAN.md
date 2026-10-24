# Abelhas híbridas — plano de implementação

## Objetivo

Cruzar uma Queen e um Drone de espécies diferentes para obter uma larva de
rainha híbrida (`Young Queen`). Ela se torna adulta no apiário, preservando o
genome e a linhagem. A colmeia produz os recursos das duas espécies em
quantidades menores. Há duas subespécies: uma prioriza os recursos da espécie
da Queen progenitora; a outra, os da espécie do Drone progenitor.

## Estado da implementação em `dev`

Foram adicionados os itens genéricos `bee_hybrid_queen`,
`bee_hybrid_youngQueen` e `bee_hybrid_drone`; o catálogo de 595 combinações é
incluído nos assets do mod. A linhagem guarda os progenitores, subtipos,
preferências e subespécie. Cada uma das 595 espécies tem uma folha própria
de sprites para Drone, Queen e larva. Formas, padrões e cores dos progenitores
são fundidos em cada frame. As duas subespécies da mesma linhagem têm a mesma
aparência.

A máquina de hibridização tem slots de Queen, Drone e saída, acumula 10.000
unidades de energia a 24 W, consome ambos os progenitores nos dois resultados e
exibe o progresso. A chance inicial de sucesso é 30%, reduzida a 10% para
progenitores rivais. O sucesso entrega uma larva `bee_hybrid_youngQueen`.
Após amadurecer no apiário, a Queen híbrida preserva a linhagem em Young Queens e
Drones; a produção dinâmica dos dois conjuntos de recursos está habilitada no
Overload Apiary. A receita permanece na Bee Station; o blueprint é desbloqueado pela pesquisa
Unethical Genetic Practices na árvore Agriculture do FU.

A implementação ainda precisa de validação dentro do jogo. As 595 folhas PNG
são geradas durante o desenvolvimento e incluídas no PAK. O Overload Apiary
não gera abelhas entidades capturáveis aleatórias, inclusive para as híbridas.

## Regras definidas

- Só cruzamentos entre espécies diferentes são válidos.
- Uma tentativa consome a Queen e o Drone, tanto no sucesso quanto na falha.
- Cada tentativa consome **10.000 unidades de energia**, acumuladas ao longo do
  tempo. Ao atingir o total, a máquina tenta o cruzamento e zera o progresso.
- O sucesso gera uma larva de rainha híbrida (`bee_hybrid_youngQueen`); a falha
  não gera abelha. A larva se torna adulta no apiário pelo ciclo nativo do FU.
- A chance de falha deve ser alta. Para o primeiro balanceamento, proponho
  **70% de falha / 30% de sucesso**.
- A larva de rainha híbrida deve ter genética inferior à dos progenitores;
  a rainha adulta conserva essa genética.
- A linhagem da Queen guarda as espécies progenitoras para que as abelhas
  descendentes mantenham a combinação.

## Modelo de dados

O FU já usa um nome de família, um gene `subtype` e parâmetros individuais em
Queens e Drones. Para evitar criar IDs separados para cada par de espécies,
usar uma família `hybrid` compartilhada. Os três itens (`Queen`, `Young Queen`
e `Drone`) mantêm o mesmo ID entre cruzamentos; seus parâmetros guardam:

- espécie e subtipo da Queen progenitora;
- espécie e subtipo do Drone progenitor;
- subespécie híbrida (1 ou 2);
- recursos parentais e preferências herdadas;
- genome híbrido.

Os itens derivados copiam esses dados. A assinatura do par deve ser comparada
além do nome do item para que linhagens de cruzamentos diferentes não sejam
misturadas na mesma colmeia.

## Produção

A lista de saídas híbridas é a união dos recursos produzidos pelas duas
espécies. Cada recurso conserva a taxa de referência da espécie que o produz.
Se as duas espécies produzirem o mesmo recurso, uma única saída agrega as
taxas antes de aplicar os modificadores.

Proposta inicial para a quantidade: o recurso priorizado rende **50%** da taxa
normal de sua espécie e o recurso secundário rende **25%**. As duas subespécies
trocam essa prioridade. Os valores devem ser ajustáveis em uma tabela central
para permitir balanceamento sem alterar a máquina.

O catálogo lista para cada par todos os recursos presentes nos dois subtipos
nativos de cada progenitora. Para cada recurso, a taxa de cada progenitora é
`peso × produção-base parental / exigência FU × ((produção-base genética da
híbrida + 1) × multiplicador do apiário + bônus de quadros) /
(produção-base parental + 1)`. As contribuições de recursos compartilhados
se somam em uma única saída. O denominador parental permanece fixo para que
melhorias genéticas da híbrida realmente aumentem a produção. O `+1` evita
divisão por zero quando o gene chega a zero. Bioma, flores e apiários próximos
aplicam a eficiência ambiental nativa ao resultado.

O nome de cada espécie é `<Parent A> × <Parent B> Hybrid`, em ordem alfabética
de IDs FU. Cada linhagem tem uma subespécie **Queen-parent-dominant** e outra
**Drone-parent-dominant**. A prioridade acompanha os papéis dos progenitores
usados naquela tentativa, mesmo quando a ordem alfabética dos nomes é inversa.
Isso define **595
espécies híbridas e 1.190 subespécies** sem criar uma família de item diferente
para cada combinação.

## Aparência e sprites

Cada espécie híbrida tem um único desenho de abelha compartilhado por suas
duas subespécies. A aparência da nova espécie combina características visuais
das duas progenitoras; a dominância da subespécie altera a prioridade de
produção, não o sprite. Portanto, Queens, Young Queens e Drones da mesma
linhagem usam a aparência da espécie híbrida, sem variação visual entre as
subespécies. Cada folha tem 84 × 28 pixels e três frames de 28 × 28 na ordem
Drone, Queen e larva. O gerador reúne os detalhes de silhueta presentes em
qualquer dos dois sprites parentais, mistura suas cores nas áreas comuns e
conserva padrões mais marcantes ao dar peso local ao contraste de cada fonte.
O resultado é um PNG próprio por espécie; o jogo lê esse PNG pelo ID do par.

O formato nativo `beeData.stats[family][subtype].production` não representa
saídas diferentes por linhagem. O caminho dinâmico da família `hybrid` lê os
recursos parentais dos parâmetros da Queen e dos Drones. Desde 0.2.22-dev,
patches dos objetos dos apiários pequeno e grande do FU carregam o mesmo
cálculo usado pelo Overload Apiary, com multiplicador 1 em vez de 1,2. As
abelhas nativas mantêm o comportamento original nesses objetos. Híbridas não
geram entidades capturáveis no mundo, pois não existe monstro `bee_hybrid`.

Desde 0.2.23-dev, as 595 entradas completas permanecem apenas no catálogo de
documentação. No jogo, cada par é montado sob demanda a partir dos dados FU e
de um mapa compacto de plantas. Apiários sem híbridas não carregam o script de
produção híbrida; os itens carregam apenas o código de aparência.

## Preferências de bioma

Os valores do FU são `0` (deadly), `1` (disliked), `2` (liked) e `3` (favorite).
Cada preferência não herdada explicitamente usa `2` como valor neutro.

- Intolerâncias herdadas são combinadas dos dois progenitores quando não há
  conflito explícito de valor para o mesmo bioma.
- Se um progenitor tem preferência por vários biomas, ele transmite no máximo
  uma dessas preferências. A seleção ocorre na criação da Queen e fica salva na
  linhagem, para não mudar entre recargas.
- Quando os progenitores têm valores diferentes para o mesmo bioma, usar o
  ponto médio arredondado em direção ao neutro (`2`). Exemplos: `3` e `1` dão
  `2`; `0` e `2` dão `1`.
- O conflito `3` e `0` é exceção: o resultado é neutro `2`, anulando os dois
  efeitos extremos.

O valor final de likeness é a fonte autoritativa por bioma. Portanto, quando
um conflito resulta em `2`, remove-se aquele bioma das listas de intolerância e
preferência; assim, um `3/0` não continua deadly por causa da lista original.

Cada híbrida soma uma planta preferencial de cada progenitora. Para manter a
regra determinística, a planta parental é escolhida entre as maiores afinidades
`beeLikeness` do FU; empates escolhem o menor ID de planta em ordem alfabética.
Se uma espécie não tiver afinidade declarada, usa sua planta preferencial
definida pelo addon. A lista escolhida para cada família está no catálogo.

## Genética

O genome híbrido combina os genomes dos progenitores. Depois, o gerador aplica
uma penalidade antes de gravar o genome final: os genes numéricos favoráveis
(produção, robustez, reprodução e longevidade) ficam em **dois terços do menor
gene parental**, arredondados ao inteiro mais próximo. Por exemplo, `9 → 6`,
`6 → 4` e `4 → 3`. Um valor parental positivo produz no mínimo `1`; `0` em
um progenitor continua `0`. A resistência a ácaros positiva perde um terço;
se já for negativa, sua magnitude negativa cresce um terço. O cálculo usa o
valor decodificado, pois o gene é codificado ao redor de um ponto neutro.
`mutationChance`, que é prejudicial, mantém a regra separada de
um ponto codificado acima do maior valor parental. A penalidade é aplicada uma única vez, ao gerar a
larva. A promoção de Young Queen a Queen preserva o genome e a linhagem,
sem aplicar uma nova penalidade.

`workTime` é categórico (`day`, `night`, `both`), portanto não tem comparação
numérica. Proposta: uma híbrida nunca herda `both`; escolhe um único turno. O
gene `subtype` identifica a subespécie de prioridade. Nos genes que já estejam
no limite mínimo funcional, não existe valor inferior utilizável. Genes
favoráveis que tenham valor positivo nos dois pais ficam no mínimo em `1` na
prole; se um pai já tiver `0`, a prole conserva `0`. O limite e as exceções
são registrados na exibição genética. Isso evita que cruzamentos comuns com
gene parental `1` zerem produção ou reprodução. Híbridas já criadas preservam
o genome que receberam originalmente.

## Máquina de hibridização

1. Slots dedicados recebem uma Queen e um Drone. Itens inválidos, da mesma
   espécie ou cruzamentos já híbridos não iniciam o ciclo.
2. A máquina acumula energia somente quando os dois progenitores estão
   presentes e há espaço para o resultado.
3. O medidor mostra `energia acumulada / 10.000` e o estado atual.
4. Ao completar a carga, executa o sorteio. Em ambos os resultados, consome os
   dois progenitores e a energia.
5. No sucesso, escolhe uma das duas subespécies com chance igual, cria uma
   larva de rainha (`bee_hybrid_youngQueen`) com genome e linhagem persistidos
   e libera o próximo ciclo. A larva amadurece no apiário.
   Na falha, informa o resultado e libera o próximo ciclo sem saída.

Espécies progenitoras que rivalizam entre si têm **10% de chance de sucesso**;
pares sem rivalidade mantêm a proposta de **30%**. A penalidade usa a relação
de rivalidade nativa simetrizada do FU.

## Rivalidades híbridas

- A espécie híbrida herda as rivalidades nativas de ambas as progenitoras.
- Se as duas progenitoras forem rivais entre si, a híbrida também rivaliza cada
  uma delas.
- Duas híbridas rivalizam quando qualquer progenitora de uma é rival de
  qualquer progenitora da outra.
- O catálogo inclui os rivais nativos de cada espécie; a regra acima determina
  as relações entre todas as 595 híbridas sem uma lista duplicada de arestas.

A demanda elétrica implementada é de até **24 W**, equivalente à demanda
documentada da Centrifuge do FU. A 24 W constantes, 10.000 unidades levam
cerca de **6 min 57 s** para acumular. A máquina usa a rede `fupower` do FU e
persiste o progresso para sobreviver a reloads.

## Etapas de implementação

1. **Contrato e dados:** implementados nos itens genéricos e catálogo.
2. **Geração:** implementada para validar progenitores, penalizar genes e
   persistir genome, subespécie e linhagem.
3. **Máquina:** implementada com slots, medidor de energia acumulada, chance de
   falha e consumo dos progenitores.
4. **Apiary:** produção dinâmica e herança para descendentes implementadas no
   Overload Apiary.
5. **Conteúdo:** receita Bee Station, pesquisa Unethical Genetic Practices e
   tooltip implementados.
6. **Validação no jogo:** cruzamentos com recursos distintos e compartilhados,
   os casos de likeness `3/0`, `3/1` e `0/2`, falhas repetidas, reload durante a
   carga, saída ocupada e ciclo de vida de Queens e Drones híbridos.

## Balanceamento implementado

| Parâmetro | Valor inicial |
| --- | ---: |
| Energia por tentativa | 10.000 |
| Demanda elétrica | 24 W |
| Chance de falha | 70% |
| Saída do recurso priorizado | 50% da referência parental |
| Saída do recurso secundário | 25% da referência parental |
| Subespécie no sucesso | 50/50 |

Esses valores podem ser ajustados após a conferência no jogo.

## Catálogo completo

[HYBRID_SPECIES_CATALOG.json](HYBRID_SPECIES_CATALOG.json) registra as 595
combinações, as duas subespécies de cada uma, os recursos de cada subtipo
parental, plantas preferenciais, pesos de produção, rivalidades e chance de
sucesso por cruzamento. A referência de produção é o `beeData.config` fixado
em `17868d86c9bb7bc00f92038fb78b48cebd1b41b8`.

As plantas preferenciais selecionadas por família são:

| Progenitora | Subtipos FU | Planta preferencial herdada |
| --- | --- | --- |
| Aquarum | aquarum / mariner | Aquapod Bud |
| Artisan | artisan / workman | Bracken Tree Seed |
| Assassin | assassin / burrowJack | Lasher Seed |
| Bumblebee | bumblebee / chubbychump | Beeflower Seed |
| Carpenter | carpenter / woodCarver | Algae Pod |
| Crystalwing | crystalwing / shuttershard | Crystallite |
| Cuckoo | cuckoo / feignFly | Haleflower Seed |
| Cybernetic | cybernetic / cybermorphic | Battery Stem |
| Devoratrix | devoratrix / fleshCarver | Aenema Flower |
| Digger | digger / miner | Capriole Seed |
| Exspiravit | exspiravit / burrower | Gray Flower |
| Gelidburrower | gelidburrower / snowStalker | Blizzberry Seed |
| Goldensaint | goldensaint / purewing | Goldenglow Seed |
| Harlequin | harlequin / lacedLady | Erithian Algae Seed |
| Honey | honey / platedHoneybee | Beeflower Seed |
| Inventor | inventor / windsweeper | Vextongue Seed |
| Isovapitdae | isovapitdae / gunkMucker | Blister Pod |
| Leafcutter | leafcutter / meanderer | Beeflower Seed |
| Loamzipper | loamzipper / veilFlush | Greenleaf Seed |
| Mason | mason / ironmason | Green Flower |
| Orchid | orchid / ulrotra | Black Orchid |
| Oremason | oremason / eyeGouger | Brown Flower |
| Plasterer | plasterer / mincer | Algae Pod |
| Reaper | reaper / deathSting | Red Flower |
| Redbanded | redbanded / stalkerBee | Blex Cactus Bulb |
| Rimewing | rimewing / snatchling | Gray Flower |
| Sandprowler | sandprowler / dunedropper | Blex Cactus Bulb |
| Scoria | scoria / firetip | Hellfire Plant Seed |
| Shrouded | shrouded / vocadahl | Black Flower |
| Squash | squash / harrowwing | Beeflower Seed |
| Stalwart | stalwart / armored | Black Flower |
| Stellar | stellar / cosmonaut | Lumivine Seed |
| Sweat | sweat / pesterer | Algae Pod |
| Tunguskudae | tunguskudae / pordratetch | Corvex Sprout |
| Xenodaemonae | xenodaemonae / puker | Aenema Flower |
