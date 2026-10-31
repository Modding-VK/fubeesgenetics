# Favo e logo do Analyzer — 0.2.42-dev

O Genetic Queen Filter mantém a pane 304×332 e as posições de textos, slots e
controles. O favo do mesmo arquivo fonte usado pelo Hybridizer foi incorporado
à parte inferior direita dos PNGs de fundo do Analyzer, com recorte no limite
interno para que a moldura metálica permaneça na frente. Os textos de estado
ficam à esquerda; o favo ocupa a margem livre à direita dos slots.

O logo do Analyzer continua a representar DNA azul e âmbar, agora dentro da
mesma silhueta hexagonal de 20×20 usada no Hybridizer. A moldura é gerada pela
função `hex_badge` compartilhada em `tools/ui_theme.py`; cada máquina mantém
seu próprio símbolo interno. A regra de logos hexagonais foi adicionada a
`AGENTS.md` para futuras interfaces.

Os arquivos `body.png`, `footer.png` e `dna.png` do Analyzer são gerados por
`tools/ui_theme.py` com o motivo de
`artwork/ui/hybridizer/honeycomb-source.png`. A geração dos assets requer
ImageMagick no ambiente de desenvolvimento. Os PNGs finais são carregados
diretamente pelo jogo: não há script recorrente novo, mudança de polling ou
trabalho adicional na janela aberta. A composição foi inspecionada nos PNGs;
é necessária conferência da apresentação no OpenStarbound.
