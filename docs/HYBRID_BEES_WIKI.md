# Wiki de Abelhas Híbridas

Esta página explica, em linguagem direta, como o cruzamento de abelhas funciona no
Genetic Hybridizer.

## 1. O que entra no Hybridizer

O equipamento recebe:

- uma abelha rainha de uma espécie;
- um drone de outra espécie;
- opcionalmente, um Research Microdisc, Holodisc ou Megadisc.

O resultado de uma tentativa bem-sucedida é uma **larva de rainha híbrida**, e não
uma rainha adulta.

Os dois progenitores são consumidos em toda tentativa. Um disco válido também é
consumido, independentemente do sucesso ou da falha.

## 2. Chance de sucesso

Sem disco, a chance base é:

- espécies comuns: 30%;
- espécies rivais: 10%.

Os discos aumentam essa chance:

| Disco | Bônus normal | Bônus contra espécies rivais |
| --- | ---: | ---: |
| Research Microdisc | +15 pontos percentuais | +7,5 pontos |
| Research Holodisc | +25 pontos percentuais | +12,5 pontos |
| Research Megadisc | +30 pontos percentuais | +15 pontos |

A chance nunca ultrapassa 100%.

Exemplos:

- espécie comum + Microdisc: 45%;
- espécie comum + Holodisc: 55%;
- espécie comum + Megadisc: 60%;
- espécie rival + Microdisc: 17,5%;
- espécie rival + Holodisc: 22,5%;
- espécie rival + Megadisc: 25%.

## 3. Como os traits são herdados

Cada trait é calculado separadamente a partir dos genes da rainha e do drone.

Na regra geral:

1. o Hybridizer lê o valor do trait nos dois progenitores;
2. escolhe o menor valor parental como base;
3. aplica uma redução de um terço, mantendo aproximadamente dois terços do valor;
4. arredonda para a unidade genética mais próxima;
5. se a base era maior que zero, o resultado mínimo é 1;
6. se os dois valores eram zero, o resultado permanece zero.

Assim, a híbrida não recebe automaticamente a média dos dois valores. O resultado
é uma versão reduzida do trait mais fraco entre os progenitores.

### Exemplo

Se os valores de um trait forem 3 e 1:

- menor valor: 1;
- dois terços de 1: 0,67;
- arredondamento e mínimo positivo: 1;
- resultado: 1.

Se forem 6 e 3:

- menor valor: 3;
- dois terços de 3: 2;
- resultado: 2.

## 4. Traits com regras próprias

Alguns genes não usam a regra geral.

### Subespécie

A larva recebe aleatoriamente uma das duas subespécies híbridas disponíveis.
As duas subespécies têm a mesma aparência, mas priorizam a produção de recursos
de progenitores diferentes.

O campo visível de subespécie informa:

'Predominant: [subespécie]'

O jogador usa esse campo para saber qual linhagem de produção foi priorizada.

### Work time

O tempo de trabalho possui uma regra própria para preservar combinações válidas
e evitar resultados extremos incompatíveis.

### Mutation chance

A chance de mutação parte do maior valor parental e recebe um incremento de uma
unidade genética, respeitando o limite interno do gene.

## 5. Biomas e intolerâncias

As intolerâncias ou dislikes dos dois progenitores são mantidas juntas na híbrida.
Quando os dois têm um valor explícito para o mesmo bioma, o resultado é um
meio-termo entre os valores.

A regra pode ser resumida assim:

- intolerâncias dos dois pais são preservadas;
- valores conflitantes no mesmo bioma são combinados por meio-termo;
- um valor positivo continua representando uma condição favorável;
- um valor negativo ou extremo continua representando intolerância ou perigo,
  conforme a escala usada pelo Frackin Universe.

A herança de bioma é independente da escolha de subespécie.

## 6. Plantas preferenciais

A híbrida recebe uma planta preferencial de cada progenitor.

Quando as preferências entram em conflito, o likeness é combinado por meio-termo.
A espécie híbrida não recebe uma lista ilimitada de preferências: é selecionada
uma preferência de cada lado do cruzamento.

## 7. Rivalidades

Uma espécie híbrida é considerada rival quando a combinação dos progenitores
envolve espécies rivais.

As rivalidades também se propagam para cruzamentos posteriores:

- a híbrida mantém a rivalidade derivada dos progenitores;
- espécies rivais têm chance de hibridização menor;
- uma híbrida rival pode tornar-se uma das partes rivais de cruzamentos futuros.

## 8. Produção nos apiários

A tabela de recursos e quantidades pertence ao apiário do Frackin Universe. A abelha
fornece identidade, subespécie e genética para que o apiário aplique seus cálculos.

Por isso:

- o apiário define recursos base, velocidade, slots e regras de processamento;
- a abelha fornece os dados genéticos e a linhagem consultados pelo apiário;
- a subespécie predominante determina qual produção da híbrida é priorizada;
- a híbrida pode produzir recursos associados às duas espécies progenitoras,
  com redução conforme as regras de herança e produção.

## 9. Aparência

Cada espécie híbrida possui seu próprio sprite. A aparência mistura cores, padrões
e traços visuais das duas progenitoras.

As duas subespécies da mesma espécie híbrida usam a mesma aparência. A diferença
entre elas está na genética, na subespécie predominante e na prioridade de produção.

## 10. Progresso e troca de cobaias

O Hybridizer acumula progresso somente com:

- rainha válida;
- drone válido de espécie diferente;
- saída livre para a larva;
- energia disponível.

Se uma entrada for retirada, o experimento pausa. Recolocar exatamente a mesma
abelha permite continuar.

Se uma das cobaias for trocada:

- o progresso existente é reduzido em 50%;
- a máquina exibe um alerta de retrabalho;
- o experimento continua usando o novo par.

## 11. Resultado da tentativa

Ao atingir 10.000 pontos de progresso, o Hybridizer executa uma tentativa:

- sucesso: cria uma larva de rainha híbrida;
- falha: os progenitores são consumidos e nenhuma larva é criada;
- disco inserido: o disco é consumido junto com a tentativa;
- depois do resultado: o ciclo de progresso reinicia.

Esta página descreve a lógica de traits usada pelas híbridas e deliberadamente não
inclui o gene 'miteResistance', que fica fora desta consolidação.
