# Abelhas híbridas — plano de implementação

## Objetivo

Cruzar uma Queen e um Drone de espécies diferentes para obter uma Queen
híbrida. Ela produz os recursos das duas espécies em quantidades menores. Há
duas subespécies: uma prioriza os recursos da espécie da Queen progenitora; a
outra, os da espécie do Drone progenitor.

## Estado da primeira implementação em `dev`

Foram adicionados os itens genéricos `bee_hybrid_queen`,
`bee_hybrid_youngQueen` e `bee_hybrid_drone`; o catálogo de 595 combinações é
incluído nos assets do mod. A linhagem guarda os progenitores, subtipos,
preferências e subespécie. Os ícones dos itens sobrepõem as imagens das duas
progenitoras, então as duas subespécies da mesma linhagem têm a mesma
aparência.

A máquina de hibridização tem slots de Queen, Drone e saída, acumula 10.000
unidades de energia a 24 W, consome ambos os progenitores nos dois resultados e
exibe o progresso. A chance inicial de sucesso é 30%, reduzida a 10% para
progenitores rivais. Queens híbridas preservam a linhagem em Young Queens e
Drones; a produção dinâmica dos dois conjuntos de recursos está habilitada no
Overload Apiary. A receita e o desbloqueio são feitos pela Bee Station.

A primeira implementação ainda precisa de validação dentro do jogo. A arte
combinada é gerada nos ícones dos itens usando as sprites parentais; não foram
criados 595 arquivos de sprite independentes.

## Regras definidas

- Só cruzamentos entre espécies diferentes são válidos.
- Uma tentativa consome a Queen e o Drone, tanto no sucesso quanto na falha.
- Cada tentativa consome **10.000 unidades de energia**, acumuladas ao longo do
  tempo. Ao atingir o total, a máquina tenta o cruzamento e zera o progresso.
- O sucesso gera uma Queen híbrida; a falha não gera abelha.
- A chance de falha deve ser alta. Para o primeiro balanceamento, proponho
  **70% de falha / 30% de sucesso**.
- A Queen híbrida deve ter genética inferior à dos progenitores.
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
nativos de cada progenitora. A quantidade é derivada das exigências reais do
FU: para cada recurso, soma-se `peso × produção-base parental / exigência`
entre as progenitoras; a exigência efetiva da híbrida é a produção-base híbrida
dividida por essa soma. Assim, se ambas produzem o mesmo recurso, as
contribuições se somam em uma única saída. A genética da Queen, bioma, flores,
quadros e apiários próximos continuam afetando a quantidade final como no
sistema nativo.

O nome de cada espécie é `<Parent A> × <Parent B> Hybrid`, em ordem alfabética
de IDs FU. Cada linhagem tem uma subespécie **Queen-parent-dominant** e outra
**Drone-parent-dominant**. A prioridade acompanha os papéis dos progenitores
usados naquela tentativa, mesmo quando a ordem alfabética dos nomes é inversa.
Isso define **595
espécies híbridas e 1.190 subespécies** sem criar uma família de item diferente
para cada combinação.

## Aparência e sprites

Cada espécie híbrida terá um único desenho de abelha compartilhado por suas
duas subespécies. A aparência da nova espécie combina características visuais
das duas progenitoras; a dominância da subespécie altera a prioridade de
produção, não o sprite. Portanto, Queens, Young Queens e Drones da mesma
linhagem usam a aparência da espécie híbrida, sem variação visual entre as
subespécies. O catálogo define os progenitores de cada sprite, mas a arte de
cada combinação ainda precisa ser criada.

O formato nativo `beeData.stats[family][subtype].production` não representa
saídas diferentes por linhagem. A implementação precisa de um caminho dinâmico
para a família `hybrid`, que leia os recursos parentais dos parâmetros da
Queen. Na primeira versão, o suporte deve ser limitado ao **Overload Apiary**,
que já tem script do addon e consegue tratar a linhagem sem sobrescrever o
script global de apiários do FU. A compatibilidade com Apiaries nativos fica
como etapa posterior.

## Preferências de bioma

Os valores do FU são `0` (deadly), `1` (disliked), `2` (liked) e `3` (favorite).
Cada preferência não herdada explicitamente usa `2` como valor neutro.

- Intolerâncias herdadas são combinadas dos dois progenitores.
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

O genome híbrido parte do meio-termo entre os genomes dos progenitores. Depois,
o gerador aplica uma penalidade antes de gravar o genome final: os genes
numéricos favoráveis (produção, resistência, reprodução e longevidade) ficam
abaixo do menor valor parental; `mutationChance`, que é prejudicial, fica acima
do maior valor parental. A penalidade e os limites devem ser centralizados e
reutilizados ao promover uma Young Queen a Queen.

`workTime` é categórico (`day`, `night`, `both`), portanto não tem comparação
numérica. Proposta: uma híbrida nunca herda `both`; escolhe um único turno. O
gene `subtype` identifica a subespécie de prioridade. Nos genes que já estejam
no limite mínimo representável, não existe valor inferior válido; a regra deve
preservar o limite e registrar essa exceção na exibição genética.

## Máquina de hibridização

1. Slots dedicados recebem uma Queen e um Drone. Itens inválidos, da mesma
   espécie ou cruzamentos já híbridos não iniciam o ciclo.
2. A máquina acumula energia somente quando os dois progenitores estão
   presentes e há espaço para o resultado.
3. O medidor mostra `energia acumulada / 10.000` e o estado atual.
4. Ao completar a carga, executa o sorteio. Em ambos os resultados, consome os
   dois progenitores e a energia.
5. No sucesso, escolhe uma das duas subespécies com chance igual, cria uma
   Queen adulta com genome e linhagem persistidos e libera o próximo ciclo.
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

Como ponto inicial de energia, proponho uma demanda contínua de **24 W**,
equivalente à demanda documentada da Centrifuge do FU. A 24 W constantes,
10.000 unidades levam cerca de **6 min 57 s** para acumular. A máquina deve
usar a rede `fupower` do FU e persistir o progresso para sobreviver a reloads.

## Etapas de implementação

1. **Contrato e dados:** implementados nos itens genéricos e catálogo.
2. **Geração:** implementada para validar progenitores, penalizar genes e
   persistir genome, subespécie e linhagem.
3. **Máquina:** implementada com slots, medidor de energia acumulada, chance de
   falha e consumo dos progenitores.
4. **Apiary:** produção dinâmica e herança para descendentes implementadas no
   Overload Apiary.
5. **Conteúdo:** receita Bee Station, desbloqueio e tooltip implementados.
6. **Validação no jogo:** cruzamentos com recursos distintos e compartilhados,
   os casos de likeness `3/0`, `3/1` e `0/2`, falhas repetidas, reload durante a
   carga, saída ocupada e ciclo de vida de Queens e Drones híbridos.

## Decisões de balanceamento propostas

| Parâmetro | Proposta inicial |
| --- | ---: |
| Energia por tentativa | 10.000 |
| Demanda elétrica | 24 W |
| Chance de falha | 70% |
| Saída do recurso priorizado | 50% da referência parental |
| Saída do recurso secundário | 25% da referência parental |
| Subespécie no sucesso | 50/50 |

Esses números, exceto os 10.000 de energia já definidos, são valores iniciais
de balanceamento e podem ser alterados antes da implementação final.

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
