# Progresso do Genetic Hybridizer — 0.2.39-dev

O medidor representa o progresso do experimento. Cada ponto consome uma unidade
de energia. A máquina só chama a rede elétrica quando há Queen e Drone válidos
e a saída está livre. Sem essas condições, o progresso parcial fica salvo e
nenhuma energia é consumida. Ao atingir 10.000, a tentativa é executada; os
progenitores são consumidos e o progresso zera. Uma carga anterior à mudança
(`hybridCharge`) é descartada ao carregar o objeto, porque podia ter sido
obtida sem as entradas exigidas agora.

O script continua agendado a cada 30 ticks. A janela consulta o estado no
máximo a cada 2 segundos e atualiza somente textos alterados. Instâncias
ociosas ainda verificam os dois slots, mas deixam de percorrer a rede de energia.
Não foram acrescentados scripts ou caches recorrentes. O tempo real pode variar
até o próximo update; a energia usa o `dt` recebido, com limite de 10.000.

As expectativas do CI cobrem entrada inválida, saída ocupada, progresso
parcial, reload, consumo exato e entrega da larva. Não há medição de CPU ou
fila do engine neste ambiente. Para medir no jogo, comparar muitas máquinas
ociosas, em progresso e bloqueadas, com e sem janelas abertas, antes/depois,
observando tempo de script do mundo e latência da interface.
