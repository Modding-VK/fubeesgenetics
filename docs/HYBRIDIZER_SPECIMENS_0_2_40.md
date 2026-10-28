# Cobaias do Genetic Hybridizer — 0.2.40-dev

O experimento guarda um retrato do ID e dos parâmetros completos de cada
progenitor quando encontra entradas válidas. A quantidade da pilha é ignorada.
Ao retirar uma entrada, o progresso pausa. Se o exemplar reinserido corresponder
ao retrato, o progresso continua; se qualquer progenitor for diferente, o
progresso acumulado é multiplicado por 0,5 uma vez para aquela troca. Outra
troca aplica novamente a penalidade. A janela mostra o aviso de retrabalho até
a tentativa terminar. Os retratos, progresso e aviso sobrevivem a reloads.

A comparação acontece no update existente de 30 ticks. Não foram adicionados
polling, mensagens nem dependências recorrentes; a cópia profunda dos parâmetros
ocorre apenas no início e quando uma cobaia muda. A janela continua consultando
no máximo a cada 2 segundos e só escreve textos alterados. Alterações feitas e
desfeitas entre dois updates são invisíveis para a máquina. Exemplares com
descritores exatamente iguais não têm identidade física distinguível na API.

Não houve medição de CPU ou fila do engine. Para observar custo e latência no
jogo, comparar várias máquinas paradas e ativas, substituir uma ou ambas as
cobaias, fechar e reabrir a janela, recarregar o mundo, e acompanhar tempo de
script e resposta da interface.
