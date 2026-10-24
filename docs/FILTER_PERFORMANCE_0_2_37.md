# Genetic Queen Filter — 0.2.37-dev

## Escopo

O controlador usa `scriptDelta=30` em vez de 10: aproximadamente dois callbacks
por segundo em simulação a 60 ticks/s, em vez de seis. O temporizador continua
processando no máximo uma unidade por segundo, sem simular períodos descarregados.
Registro ITD, backpressure, releitura antes da retirada, confirmação de inserção,
rollback, escrow e offsets 0/1/2 estão preservados.

A janela consulta o estado uma vez por segundo, em vez de a cada 0,5 segundo.
Comandos continuam imediatos, com uma mutação em voo e descarte das respostas
anteriores ao comando. A resposta de sucesso já atualiza a janela; não dispara
uma segunda leitura. Falha de comando tenta recuperar o estado imediatamente.
Duas janelas podem levar até o próximo polling para refletir mudanças da outra.
Nenhum contador de revisão ou notificação por frame foi introduzido.

## Estrutura e caches

- `filtercontract.lua`: contrato leve compartilhado de traits, modos, intervalos
  e identidade híbrida. Não carrega código de produção, catálogo ou apiário.
- `containerutil.lua`: cópia/comparação compartilhadas e `putExact` para o Filter.
  Essa função conserva o descritor original e a confirmação por delta do retorno
  legado. Não chama `root.createItem` nem instala wrappers nas APIs globais.
  O caminho de inserção com builders dos apiários continua separado.
- A decisão genética permanece uma função pura; perfil/referências só são
  confirmados após a inserção física bem-sucedida.
- Tags de itens usam cache transitório limitado a 128 nomes por contexto Lua.
  Erros não são armazenados. Inspeção, genome e parâmetros nunca vêm desse cache.
- As referências convertidas para exibição ficam em `self`, recalculadas após
  substituição das referências. Reset e reload invalidam o cache.
- Textos e seletores são escritos apenas quando o valor exibido muda. Erros de
  conexão também atualizam esse cache, permitindo recuperar o texto correto.
- Canvas de ajuda é limpo/redesenhado somente ao mudar visibilidade, conteúdo
  ou posição. O hit test é repetido somente quando o cursor muda de posição.
  OpenStarbound 0.1.14 mantém as operações de CanvasWidget até `clear()`; fonte:
  https://github.com/OpenStarbound/OpenStarbound/blob/cd2d804f6feaa4c588df822f01eb5504ebd4ba55/source/windowing/StarCanvasWidget.cpp

## Identidade híbrida e migração

Abelhas nativas continuam usando família/subtipo. Híbridas exigem uma linhagem
válida e usam uma chave com o par parental ordenado, os subtipos nativos de
ambos e a família dominante. Cruzamentos diferentes e prioridades opostas não
compartilham baseline. Trocar os papéis dos progenitores e H1/H2 pode conservar
a identidade se os subtipos e a família dominante forem equivalentes.
O genome é a autoridade para H1/H2; campos derivados antigos não o substituem.
Queen e Young Queen da mesma identidade continuam compatíveis.

Perfis híbridos antigos sem chave de linhagem são ambíguos e têm apenas a
baseline descartada na inicialização. Modos, inventário e escrow são preservados.
A primeira híbrida válida estabelece a nova referência. Perfis nativos e perfis
híbridos novos sobrevivem a reload. Linhagens ausentes ou inválidas são rejeitadas
como genética inválida, sem inicializar ou melhorar a referência.

## Evidências e limites

Os testes de regressão incluem limites de mensagens e operações de widgets,
invalidação de caches, isolamento entre híbridas, retorno legado, rollback e
escrow. São bindings simulados, não um benchmark do engine.

| Operação | Antes | Depois |
| --- | ---: | ---: |
| Callbacks do controlador a 60 ticks/s | ~6/s | ~2/s |
| Consultas periódicas por janela aberta | 2/s | 1/s |
| Leitura adicional após comando bem-sucedido | 1 | 0 |
| Escritas de widgets após resposta idêntica | repetidas | 0 |
| Conversões das seis referências sem alteração | 6 por leitura | 0 após o cache |
| Operações Lua de canvas com tooltip visível imóvel | repetidas por frame | 0 após desenhar |

Essas contagens não significam redução equivalente de CPU ou tempo da fila de
scripts. Renderização do engine continua ocorrendo normalmente. Nenhum teste
em OpenStarbound foi executado neste ambiente.

### Comparação dentro do jogo

Usar a 0.2.36-dev como referência e o artefato CI da 0.2.37-dev, uma instalação
por vez, com o mesmo mundo, personagem, zoom, mods e rede ITD. Fazer backup do
mundo antes de alternar versões. Evitar misturar saves de teste com produção.

1. Comparar 1, 10, 50 e 100 Filters carregados, primeiro vazios e sem janela.
2. Repetir com Input alimentado por ITD, saídas extraídas e depois bloqueadas.
3. Abrir uma janela e comparar repouso, tooltip imóvel e troca de seletores;
   em multiplayer, conferir a convergência entre duas janelas.
4. Registrar tempo de script/mundo com o profiler disponível na versão instalada,
   frametimes e latência entre inserção, classificação e retirada. Separar o
   aquecimento inicial de uma amostra sustentada e repetir os mesmos cenários.
5. Conferir os retornos de itens, reload, modos anteriores à baseline e as
   linhagens híbridas. A frequência menor não autoriza remover garantias físicas.

Não ativar logs por frame para medir desempenho. Se o profiler não expuser
mensagens ou chamadas por objeto, usar as contagens automatizadas como evidência
de trabalho evitado e registrar a limitação da medição no engine.
