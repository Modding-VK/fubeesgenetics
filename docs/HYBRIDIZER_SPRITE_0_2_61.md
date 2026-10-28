# Genetic Hybridizer — sprite 0.2.61-dev

O Hybridizer cruza duas linhagens numa câmara genética. Sua carcaça e origem
seguem o Genetic Queen Filter do próprio mod: sprite estático 40×32 px,
ocupação explícita de 5×4 tiles, `imagePosition` [0,0], apoio no chão, entrada
à esquerda e saída à direita. A frente e uma lateral permanecem visíveis; não
há face superior ou inferior. Base e apoios conservam as mesmas linhas
horizontais do sprite de origem.

O vidro, os reflexos e os pequenos detalhes luminosos cianos foram trocados
por uma rampa roxa de seis cores. Os demais pixels, transparência, silhueta e
apoios são idênticos aos do Queen Filter. O ícone de 20×20 px recebeu a mesma
troca de paleta. Fonte: `geneticqueenfilter.png` e
`geneticqueenfiltericon.png`, ambos no mod. Não foram adicionadas formas nem
frames. A cor funcional roxa diferencia a câmara de hibridização do filtro.

A luz do mundo usa `lightColor` [14,2,22] e `lightPosition` [2,2]: um brilho
roxo mínimo e constante. O sprite não usa animação nem emissividade separada.
As chamadas antigas do animator do Apiary FU foram removidas. Não existe
novo script, polling, cache, mensagem ou custo recorrente para a aparência.

Os PNGs finais foram inspecionados em 1×. O resultado no mundo, o alcance da
luz e a colocação junto a outras máquinas ainda precisam de conferência no
OpenStarbound. O PAK fica para a Action manual do mantenedor.
