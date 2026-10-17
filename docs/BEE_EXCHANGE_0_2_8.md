# Bee Exchange 0.2.8-dev

A placa deixa de ser um retângulo completo sobreposto à antiga: conserva a
moldura e silhueta vanilla, preenchendo apenas seu interior com a estampa atual
Auto Refugee. Removido o vestígio de seis pixels da antiga haste externa no
canto junto à placa, na linha y=28. Os dois pinholes laterais em (9,31) e (8,32)
agora são opacos, com as cores metálicas dos pixels vizinhos.

Haste interna: base mantida em y=66; topo passa de y=60 a y=62. O vidro atrás
da posição anterior é reconstruído pela interpolação das cores adjacentes.
Inseto e teleporte são recompostos a partir da proposta aprovada, com translação
vertical exata de +2 pixels em todos os frames; sem acúmulo a cada rebuild.
A duração, orientação e som do teleporte permanecem iguais.

Display esquerdo: os sinais em ready e work se deslocam dois pixels para a
esquerda após o flip nativo. No atlas de compensação isso corresponde a +2 no x;
a posição dos LEDs e a moldura do display ficam iguais. Mantida a legibilidade
da placa e dos símbolos nas duas direções, inclusive no placement.

Validação: 127 grupos locais passaram; gerador verifica texto e todos os frames
dos sinais. Conferidas opacidade dos pinholes e translação exata das duas camadas
móveis. PAK nativo validado por pack/unpack de 47 arquivos. Conferência dentro
do jogo pendente. Substituir o PAK anterior; não precisa recriar a máquina.

Prévia: artwork/implemented/beeexchange-0.2.8-directions.gif.
