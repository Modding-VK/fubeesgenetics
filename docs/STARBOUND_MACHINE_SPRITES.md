# Direção de arte para sprites de máquinas Starbound

Referência de trabalho para pessoas e IAs do Bee Abusive Industry. Estudo de
2026-10-27, baseado em PNGs, `.frames`, `.object`, `.animation` e código do
OpenStarbound. A [prancha, fontes e medidas](SPRITE_SOURCES.md) permitem conferir
as observações. A [ficha de criação](MACHINE_SPRITE_BRIEF.md) transforma este
guia em uma especificação concreta para cada máquina.

As afirmações abaixo têm três níveis: **contrato técnico** é confirmado no
engine ou no asset; **observação** descreve a amostra; **diretriz do projeto**
é uma escolha para manter coerência nas nossas próximas criações. Não existe
evidência, nesta pesquisa, de um manual oficial que imponha uma única paleta,
espessura de contorno, perspectiva ou quantidade de frames a todo Starbound.

**Diretriz obrigatória deste projeto para máquinas no mundo:** representar
**frente e uma face lateral**, sem mostrar **jamais a face superior nem a
inferior**. O topo do contorno pode receber uma linha de luz ou espessura de
borda, mas essa linha não pode virar uma superfície horizontal visível. Essa
regra também vale para conceitos, ícones derivados e prévias de sprites. A
existência de tampos inclinados em algumas referências não revoga esta escolha
do mantenedor para as máquinas novas do mod.

**Base obrigatória:** toda aresta inferior do corpo e da base corre na horizontal.
Na passagem da lateral para a frente, não inclinar a linha de fundo para sugerir
profundidade. Os pés de uma mesma máquina terminam no mesmo eixo horizontal de
apoio, mesmo que tenham larguras ou detalhes diferentes. Vale para conceitos,
ícones, prévias e todos os frames.

## 1. O que dá identidade a uma máquina

A leitura começa por uma forma reconhecível: bancada com tampo, forno com
boca, tanque com líquido, cabine com abertura, núcleo com suportes. Uma peça
principal comunica a função. As demais explicam sustentação, alimentação,
controle e saída. Uma caixa retangular com muitos LEDs pode parecer tecnológica,
mas comunica pouco sobre o processo que executa.

Na amostra, Inventor's Table mantém a bancada inclinada e a área azul ao evoluir
de madeira para metal; o forno mantém a cavidade quente nos dois primeiros
níveis e passa a uma câmara tecnológica no terceiro. A estação de fiação usa
terminais e condutores; o Terramart usa compartimento, trilhos e placa. Esses
elementos ajudam a reconhecer os objetos mesmo com pouca resolução.

Diretriz: escrever uma frase funcional antes de desenhar, por exemplo,
“duas entradas alimentam uma câmara de experimento que produz uma larva”.
Escolher uma forma dominante para essa frase, dois ou três componentes de
apoio e uma região de foco. O tema de abelhas aparece em detalhes úteis:
módulos de colmeia, recipientes, amostras, sinais e acentos de mel.

## 2. Escala: pixel, tile, canvas e ocupação

O engine consultado define **8 pixels por tile**. Um frame 24×24 cobre uma
extensão visual de 3×3 tiles antes dos offsets; isso não prova uma ocupação
de 3×3. O frame inclui transparência, saliências e espaço para movimento.

| Medida | O que representa | Como definir |
| --- | --- | --- |
| Canvas de um frame | Retângulo que contém o desenho e a animação | `.frames` e PNG |
| Caixa visível | Limites dos pixels com alfa não nulo naquele frame | Inspeção do PNG |
| `spaces` | Células ocupadas para colocação do objeto | Configuração do objeto |
| `spaceScan` | Fração de pixels que faz uma célula ser incluída na ocupação | Engine + camadas da orientação |
| `anchors` | Suporte necessário para a colocação | Objeto, por exemplo chão |
| Colisão | Comportamento físico do objeto | Campo/configuração apropriada; conferir no jogo |
| Ícone de inventário | Representação pequena para o item | Asset próprio ou referência configurada |

O Terramart usa frames 64×80; no frame `ready.1` a caixa visível medida é
`[4,11,61,80)` em coordenadas de imagem. A margem transparente participa da
construção e animação. Recortar cada frame pelos pixels opacos faria a origem
variar, causando saltos. O Apiary FU tem frame 16×24 e um ícone 24×18; o
Analyzer do mod tem sprite de mundo 40×32 e ícone de inventário 20×20.

Os 17 ícones vanilla medidos têm 16×16. Os emblemas hexagonais 20×20 aprovados
para nossas **janelas** são outra categoria de asset. Não transformar toda
máquina do mundo em hexágono nem impor 20×20 a ícones vanilla por causa da UI.

Diretriz: escolher primeiro a ocupação e a escala ao lado de uma referência
existente. Desenhar na resolução final ou em uma ampliação inteira dela.
Usar nearest-neighbor na ampliação de inspeção. Uma ilustração grande reduzida
automaticamente exige revisão pixel a pixel antes de virar sprite de produção.

## 3. Silhueta e distribuição das massas

Separar a máquina em base, corpo funcional e equipamento acima do corpo quando isso
corresponder à função. Pés, contorno da tampa, abertura e acessórios devem continuar legíveis
no tamanho nativo. Espaços negativos sob bancadas, entre suportes e ao redor de
tanques tornam a silhueta mais informativa sem exigir novos detalhes.

O peso visual costuma ficar sustentado: recipientes pesados têm base, bancadas
têm pernas, braços se conectam a eixos. Componentes flutuantes podem funcionar
como tecnologia, desde que exista linguagem visual de campo, levitação ou
suporte. Evitar peças que pareçam soltas por erro de posicionamento.

Usar assimetria funcional para diferenciar lados: painel em um lado, tubo no
outro, saída acessível, alavanca junto ao mecanismo. Simetria continua válida
para colunas, tanques ou núcleos. Não aplicar simetria ou assimetria como regra
decorativa universal.

## 4. Perspectiva e volume

Para **novas máquinas deste projeto**, usar somente dois planos externos
visíveis: **frente e uma lateral**. Manter a lateral reconhecível, com cor e
contorno próprios, em toda a altura coerente do corpo. Não desenhar vista de
cima da tampa ou do chão sob a máquina. **Faces superior e inferior nunca devem
aparecer**, nem como trapézios finos, nem por mudança de ponto de fuga. O jogo
usa vista lateral; a direção de arte escolhida para este mod evita inclinação
vertical da câmera.

A amostra pesquisada inclui objetos com superfícies inclinadas, como a mesa do
inventor. Isso descreve aqueles assets; não serve de exceção à diretriz acima.
Usar as referências para escala, materiais e função, mas adaptar qualquer
ângulo que revele o topo ou a base antes de criar conceitos para o mod.

Alinhar tampa, cintas, base, painéis e acessórios à mesma quina entre frente e
lateral. As bordas longas da frente ficam horizontais e os montantes ficam
verticais. Um filete claro na borda superior pode indicar espessura e metal,
desde que não forme um plano superior visível. Uma linha escura sob uma peça
pode explicar sobreposição sem expor a face inferior. A direção exata da luz
pintada varia entre assets; não se deve inventar uma regra universal de luz
obrigatoriamente no canto superior esquerdo.

Na base, verificar a linha pixel a pixel: a aresta inferior da lateral e a da
frente devem conservar a mesma altura; a quina de encontro é vertical. Um
degrau estrutural pode subir e voltar a descer em segmentos ortogonais, mas
nunca formar uma diagonal no fundo. Conferir a coordenada vertical do último
pixel de cada pé. Pés em alturas diferentes fazem a máquina parecer inclinada
ou mal apoiada no chão.

## 5. Contorno e agrupamento dos pixels

Muitos sprites examinados usam bordas escuras finas e grupos contíguos de cor.
O contorno pode ser cinza, azul escuro ou marrom escuro conforme o material.
Um pixel é uma unidade expressiva importante, mas não existe obrigação de
contorno preto contínuo de um pixel em toda superfície.

Usar contorno para separar silhueta do cenário e explicar contato entre peças.
Reservar os tons mais escuros para recessos, vãos e junções. Destacar quinas
expostas em vez de contornar cada rebite com a mesma força. Não iluminar todas
as bordas igualmente: isso achata o objeto e compete com o ponto de foco.

Diagonais precisam de sequências de degraus deliberadas. Ruído de um pixel só
é útil quando representa rebite, faísca, LED, pequena lasca ou detalhe legível.
Padrões aleatórios por toda a carcaça tornam a textura mais forte que a forma.

## 6. Paleta e hierarquia de contraste

Na composição dos frames vanilla estudados há de **6 a 27 cores RGB opacas**.
Isso é uma medida da amostra, não limite do engine. Cores de alfa parcial,
outros frames, iluminação do mundo e pós-processamento não entram nessa conta.

| Material/objeto observado | Exemplos reais de cores frequentes | Leitura |
| --- | --- | --- |
| Forno I | `#282828`, `#565656`, `#7a7a7a`, `#9f9f9f` | Pedra em planos, fogo como acento |
| Forno II | `#151515`, `#303030`, `#555555`, `#808080` | Estrutura industrial mais escura |
| Inventor I | `#251c0b`, `#463818`, `#6d6330`; azul `#5588d4` | Madeira quente e área funcional azul |
| Refinery | `#171717`, `#383838`, `#616161`, `#9e9e9e`, `#cccccc` | Metal por degraus de valor |
| Terramart | `#26323b`, `#435868`, `#64859c`; claro `#c3bfb3` | Carcaça azul acinzentada e placa legível |

Essas cores são exemplos de materiais, não uma paleta a copiar integralmente.
Uma boa base para trabalho é uma rampa curta por material e poucos acentos.
Começar com sombra, médio e luz; adicionar tons quando uma forma exigir.

Distribuir contraste por função: massa principal relativamente calma, junções
mais escuras, operação e controles reconhecíveis. Cores saturadas ficam mais
eficazes quando ocupam regiões pequenas. O Apex Pod é uma exceção instrutiva:
o grande líquido verde é o assunto da máquina, então domina sua cor.

Para o mod, âmbar pode ligar a arte à apicultura e ciano pode indicar análise,
energia ou processo. O mesmo significado deve ser mantido entre estados.
Esses são acentos de identidade do projeto; carcaças e partes orgânicas podem
usar outras cores adequadas aos materiais.

## 7. Materiais que precisam ser reconhecidos

| Material | Tratamento útil observado/inferido | Erro comum |
| --- | --- | --- |
| Metal pintado | Planos relativamente uniformes, quinas claras, junções escuras | Granulação em toda a superfície |
| Metal polido | Reflexo estreito e contraste localizado | Gradiente suave cobrindo o objeto |
| Madeira | Tábuas e estrutura, duas ou três variações de valor | Desenhar veios aleatórios em cada pixel |
| Pedra | Blocos grandes irregulares e juntas | Textura sem massa ou espessura |
| Vidro | Moldura, conteúdo visível, reflexo curto; alfa opcional | Transformar toda a área em brilho branco |
| Líquido | Nível e recipiente; cor funcional dominante | Manchas sem contorno do tanque |
| Tela/LED | Forma simples, emissividade local, poucos sinais | Texto ilegível ou toda a carcaça emissiva |
| Tubos/cabos | Origem, destino e espessura coerentes | Fios decorativos sem conexão |

Transparência parcial existe em efeitos de Furnace III e Inventor III.
Portanto, evitar antialiasing acidental na silhueta não significa proibir alfa
parcial em vidro, vapor ou energia. O alfa deve servir a uma intenção visual.

## 8. Iluminação pintada, emissividade e luz do mundo

São mecanismos diferentes. A sombra pintada no PNG descreve volume. A
propriedade `fullbright` mantém uma camada visível independentemente da luz
ambiente. `lightColor` ou luzes do animator iluminam o mundo ao redor conforme
sua configuração. Pintar amarelo no sprite não cria luz no cenário.

**O nome do arquivo não define a emissividade.** No forno vanilla, o estado
`stone` usa `craftingfurnacelit.png` para `chassis`, enquanto `craftingfurnace.png`
é a parte `fire` com `fullbright: true`. A Refinery também mostra esse risco
de inferir a função pelo sufixo. Ler `.object` e `.animation` antes de escolher
qual PNG é corpo ou emissão.

Criar máscara emissiva só para o que produz luz: tela, bobina, núcleo, chama,
indicador. Manter a carcaça reagindo ao ambiente. Separar a emissão evita que
a máquina pareça um adesivo inteiro iluminado dentro de uma caverna escura.
Quando houver conteúdo atrás de vidro, decidir explicitamente a ordem entre
conteúdo, vidro, reflexos, borda e emissão.

## 9. Animação como explicação do processo

Desenhar a máquina parada antes dos efeitos. O estado parado precisa explicar
a função, a escala e a sustentação. Animar as partes que fazem trabalho:
ventilador, pistão, indicador, líquido, amostra ou transporte.

No Terramart, `ready` tem 2 frames e `ship` tem 23. Entre os dois frames de
espera analisados só quatro pixels mudam em cada camada. Isso ilustra como
uma atividade mínima pode comunicar prontidão sem deslocar toda a carcaça.
O forno inicial tem 4 frames em 0,5 s; o terceiro tem 14 em 1 s. A duração
de um ciclo não deve ser confundida com o intervalo de `update` do script Lua.

Definir o significado de cada estado antes da folha: desligado, espera,
operação e falha são candidatos, não estados obrigatórios de toda máquina.
Usar mudanças pequenas no repouso e reservar movimentos maiores à operação.
Uma falha pode combinar sinal, cor e postura do mecanismo; não depender
exclusivamente de vermelho versus verde.

Todos os frames de uma parte conservam canvas e origem. Não recortar cada
frame independentemente. Usar aliases quando um frame existente puder servir
à transição inversa, como nas consoles e no Shield Generator. Contagem,
nomes, duração e transições devem corresponder aos assets realmente presentes.

Preferir estados declarativos do animator. Scripts controlam mudanças reais
de estado; evitar consultas de inventário e mensagens por frame só para piscar
um LED. Separar partes pode facilitar a arte, mas cada camada também tem custo
de renderização: não criar dezenas de partes sem uma razão visual ou mecânica.

## 10. Espelhamento, placa e preview

`dualImage` é expandido pelo engine em orientações esquerda/direita, uma delas
com `flipImages`. Isso serve para objetos que toleram inversão. Uma placa
legível, seta funcional ou processo com lado específico pode precisar de
arte própria para cada direção. Espelhar uma palavra não mantém sua leitura.

A Auto Refugee do projeto já usa carcaça e display direcionais. Sua origem
`[-8,0]` difere da origem `[-32,0]` do Terramart de referência. Copiar offsets,
conexões ou pegada sem recalcular pode separar fios e peças da nova carcaça.

O preview de colocação, o estado inicial e as camadas animadas precisam
compartilhar o mesmo alinhamento visual. Não assumir que `flipImages` na
orientação resolve automaticamente todas as tags e transformações do animator.
Consultar os arquivos da máquina e a referência do engine.

Texto no mundo é possível: Terramart e Bee Refuge têm placas dominantes.
Usá-lo quando fizer parte da identidade e houver pixels para lê-lo. Para
máquinas pequenas, um sinal ou pictograma costuma ser mais legível que uma
frase miniaturizada. Não colocar explicações de gameplay inteiras no sprite.

## 11. Integração que pode estragar uma boa arte

`imagePosition` e `animationPosition` são convertidos de pixels para unidades
de mundo no código consultado. `centered` altera a referência do desenho.
Uma origem incorreta produz desalinhamento mesmo quando o PNG está correto.

`spaceScan` calcula a fração de pixels ocupados por célula; no código observado,
qualquer alfa maior que zero conta. Um halo quase transparente pode acrescentar
ocupação. Para máquinas com efeitos largos, conferir `spaces`, preview e
camadas usadas no scan, em vez de aumentar toda a área ocupada por acidente.

A malha de tiles é de 8 pixels, mas isso não exige que toda dimensão de PNG
seja múltipla de 8: Bee Refuge FU mede 106×126. É preciso resolver origem e
ocupação explicitamente. Também não igualar o retângulo da textura a colisão,
suporte ou ponto clicável sem consultar a configuração.

Na entrega, registrar tamanho da folha, tamanho de cada frame, nomes de
frames, origem de cada parte, ordem de desenho, `fullbright`, orientações,
ícone e ocupação. Um sprite sem esse contrato ainda não é um objeto integrado.

## 12. Aplicação à identidade Bee Abusive Industry

O tema industrial deve aparecer na função e na construção: amostras em
câmaras, coletores, entradas/saídas, manutenção, ventilação e sinais de esforço.
Um detalhe de favo ou âmbar pode identificar a família sem cobrir o objeto
com hexágonos. Os apiários podem conservar madeira ou formas de colmeia e
ganhar elementos de tecnologia que expliquem a sobrecarga.

As regras aprovadas de UI são específicas: emblemas hexagonais 20×20 com
moldura metálica/âmbar, cabeçalho alinhado como o Analyzer e favo no canto
inferior direito sob a borda. Aplicar essas regras às janelas. Para sprites
de mundo, escolher proporções e materiais conforme o processo e a família.

O Analyzer 40×32, a Auto Refugee 64×80, o Apiary FU 16×24 e o Bee Refuge
106×126 mostram escalas muito diferentes. A máquina nova deve ser comparada
a objetos que executam trabalho de tamanho semelhante. Essa escolha deve
constar da ficha de criação; não aumentar a resolução para obter mais detalhes.

## 13. Procedimento para IA

1. Ler `AGENTS.md`, este guia e a ficha da máquina. Confirmar objetivo, tamanho
   no mundo e estados com base no pedido e nos arquivos disponíveis.
2. Selecionar de duas a quatro referências reais, com funções claras: uma para
   silhueta/escala, uma para material e outra para animação se necessário.
3. Registrar quais observações vêm dessas referências e quais escolhas são
   novas. Consultar os arquivos visuais e técnicos, além dos nomes dos objetos.
4. Propor massas e paleta no tamanho nativo. Verificar primeiro a silhueta e
   a separação entre entrada, processamento, controles e saída. Conferir que
   aparecem frente e lateral, sem faces superior ou inferior, inclusive no conceito.
   Conferir arestas inferiores horizontais e todos os pés na mesma linha de apoio.
5. Resolver volume, contato e materiais. Acrescentar detalhes somente após
   a função principal continuar legível em 1×.
6. Preparar ícone, partes emissivas, orientações e folha com origem fixa.
   Arte gerada como conceito precisa de adaptação e inspeção na resolução final.
7. Inspecionar os arquivos estáticos e, quando houver runtime, observar escala,
   luz, preview e estados no jogo. Registrar quais etapas foram realmente feitas.
8. Documentar fontes, decisões, medidas e limitações. Gerar PAK só pelo GitHub
   Actions, conforme a política do projeto.

## 14. Revisão visual e critérios de entrega

| Pergunta de revisão | Sinal de problema | Correção típica |
| --- | --- | --- |
| A função aparece em 1×? | Só é entendida com zoom ou legenda | Reforçar a peça funcional dominante |
| O ângulo segue o projeto? | Tampa ou base revelam faces de cima ou de baixo; lateral desaparece | Mostrar frente e uma lateral, mantendo topo e base apenas como contornos |
| O fundo e os pés estão alinhados? | Linha inferior diagonal ou pés terminando em alturas diferentes | Nivelar arestas inferiores na horizontal e alinhar o último pixel de todos os pés |
| A escala combina com a vizinhança? | Rebites maiores que componentes de objetos vanilla | Redesenhar na grade nativa |
| O corpo tem massa e apoio? | Peças pairando sem conexão | Resolver base, contato e suportes |
| O foco está claro? | Todo canto brilha com a mesma força | Reduzir contraste em áreas secundárias |
| Materiais são diferentes? | Pedra, vidro e metal usam a mesma textura | Mudar distribuição dos planos e reflexos |
| O sprite é estável durante a animação? | Carcaça ou pés saltam | Unificar canvas, origem e partes fixas |
| A placa funciona nos dois lados? | Letras invertidas | Separar orientação da placa |
| A luz corresponde ao processo? | Carcaça inteira acesa no escuro | Restringir máscara emissiva |
| A colocação coincide com o objeto? | Preview, chão ou fios deslocados | Rever offsets, spaces e nós |
| A arte está leve? | Animação ociosa exige Lua constante | Usar estados do animator e assets estáticos |

Essas perguntas orientam revisão; não autorizam alegar que um teste em jogo
foi feito. A prancha e as medições deste estudo são evidências estáticas.
