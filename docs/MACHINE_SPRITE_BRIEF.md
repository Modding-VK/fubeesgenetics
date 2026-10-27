# Ficha de criação de sprite de máquina

Copiar esta ficha para o documento da máquina. Preencher a partir do pedido e
dos assets existentes; perguntar somente o que não puder ser decidido com esse
contexto. Consultar [direção de arte](STARBOUND_MACHINE_SPRITES.md) e
[fontes medidas](SPRITE_SOURCES.md).

## Função e identidade

- Nome público e ID técnico:
- Processo em uma frase:
- O que o jogador precisa reconhecer olhando a máquina:
- Família visual, materiais e relação com a apicultura:
- Elemento dominante da silhueta:
- Elementos secundários que explicam entrada, controle, saída e suporte:
- Cores funcionais e significado de cada uma:

## Referências reais

| Asset / revisão | O que será estudado | Decisão derivada |
| --- | --- | --- |
| Referência de escala e silhueta | | |
| Referência de material e cor | | |
| Referência de animação e integração | | |

Guardar caminho e revisão ou URL fixa; registrar autoria/proveniência de
qualquer material reutilizado. A referência de aparência não define por si
só os offsets ou a mecânica da máquina nova.

## Geometria antes de detalhar

- Canvas nativo de cada frame, em pixels:
- Extensão visual aproximada em tiles de 8 px:
- `spaces` e suporte/anchors planejados:
- Caixa visível desejada e folga para movimento:
- Origem de imagem, origem do animator e uso de `centered`:
- Pontos de interação, entrada/saída e nós de fios quando existirem:
- Direções disponíveis; peças que não podem ser espelhadas:
- Ícone de inventário e tamanho próprio:
- Emblema da janela: hexagonal, 20×20, com símbolo interno da máquina:

## Materiais, paleta e planos

- Rampa de cada material (sombra, médio, luz; tons extras justificados):
- Regiões de contraste alto e baixo:
- Peças em primeiro plano, conteúdo interno, vidro e reflexos:
- Regiões de alfa parcial e sua função:
- Quais partes são emissivas e quais iluminam o mundo:
- Como sustentar e conectar cada peça principal:

## Estados e folha de sprites

| Estado necessário | O que significa | Partes que mudam | Frames / ciclo | Saída do estado |
| --- | --- | --- | --- | --- |
| Parado / espera | | | | |
| Operação | | | | |
| Falha, bloqueio ou falta de energia, se aplicável | | | | |

- Nomes e dimensões das folhas; grade e aliases:
- Ordem das camadas e propriedades de emissão:
- Preview de colocação e correspondência com o estado inicial:
- Movimento que pode ser feito declarativamente pelo animator:
- Eventos que realmente precisam de script; frequência e custo previsto:

## Entrega e evidência

- PNGs, `.frames`, `.animation` e objetos afetados:
- Fonte e método de geração/edição, com resolução final explícita:
- Inspeção estática realizada (1×, ampliação inteira, transparência, frames):
- Conferências efetivamente realizadas no jogo e ambiente usado:
- Pendências visuais ou técnicas:
- Documentação de scanner por espécie, quando um objeto for criado/alterado:
- Commit em `dev` e Action do PAK, quando houver mudança de assets do jogo:

Não marcar uma etapa como concluída com base apenas em uma imagem de conceito.
Não executar empacotamento local; seguir `AGENTS.md`.
