# Requisito de desempenho de scripting

A otimização de scripting é um requisito obrigatório para qualquer item ou
conteúdo criado ou alterado no Bee Abusive Industry: itens de inventário,
máquinas, objetos, interfaces, builders e patches de integração. A regra foi
determinada pelo mantenedor e também se aplica às próximas alterações de
conteúdos existentes.

## Critérios de implementação

1. **Justificar scripts.** Usar assets e mecanismos nativos quando suficientes.
   Um item estático não precisa receber script ou loop apenas para cumprir
   este requisito. Builders devem fazer apenas o trabalho necessário à criação
   ou apresentação do item.
2. **Definir frequência e latência.** Para scripts recorrentes, documentar o
   intervalo de atualização e a latência aceitável. Usar a menor frequência que
   cumpra a mecânica, considerando o `dt` real e o agendamento do engine.
   Não copiar um `scriptDelta` para todas as máquinas. Reduzir frequência não
   pode alterar produção, energia, desgaste ou cadência contratada.
3. **Evitar trabalho ocioso.** Aplicar saídas antecipadas e evitar buscas no
   mundo, decodificações, cópias, serialização ou reconstrução de itens quando
   nada mudou. Avaliar notificações nativas quando disponíveis e confiáveis;
   não substituir polling por uma quantidade maior de mensagens.
4. **Controlar comunicação e UI.** Limitar frequência e concorrência de
   consultas; reaproveitar respostas autoritativas de comandos. Descartar
   respostas antigas. Atualizar widgets e operações de canvas apenas quando
   necessário, conferindo a persistência e o comportamento do widget no engine.
   Janelas fechadas não devem manter consultas de apresentação.
5. **Limitar caches.** Cachear apenas dados estáveis ou derivados com
   invalidação definida. Fixar limites de tamanho e escopo, e tratar reload e
   alterações de estado. Não usar cache como autoridade para inventários,
   energia, espécimes, perfil ou outros dados mutáveis do mundo.
6. **Carregar e compartilhar com cuidado.** Carregar dependências pesadas
   somente quando necessárias; compartilhar contratos e helpers pequenos.
   Separar regras puras de inventário, rede e apresentação. Reduzir alocações
   e decodificações redundantes quando isso simplificar ou tiver benefício
   demonstrável, sem tornar o código opaco.
7. **Preservar a correção.** Revalidações físicas, conservação de itens,
   confirmação de transferência, rollback, escrow, persistência, identidade
   genética, ordenação de comandos e contratos FU/ITD continuam obrigatórios.
   Não remover essas garantias para melhorar contagens. Evitar alterar APIs
   globais sem necessidade e sem analisar o escopo e as compatibilidades.
8. **Evitar instrumentação onerosa.** Não registrar logs por frame ou manter
   contadores de diagnóstico persistentes em produção sem necessidade.
   Instrumentação de desempenho deve ser opcional e limitada ao teste.

## Evidência necessária em cada entrega

Registrar no documento da mudança ou na descrição do commit/PR autorizado:

- Se há script recorrente e por quê. Para item sem scripting novo, registrar
  que não há novo custo recorrente e conferir se builders ou patches indiretos
  acrescentam trabalho.
- Frequência, latência, eventos/mensagens, operações caras, limites de cache e
  comportamento ocioso relevantes. Informar o efeito ao multiplicar máquinas
  e janelas carregadas.
- Testes proporcionais ao risco: cadência/`dt`, falhas de transferência,
  reload, mensagens antigas, callbacks, invalidação e compatibilidade quando
  afetados. Não criar testes artificiais para assets estáticos.
- O que foi medido, em qual ambiente e com quais limitações. Redução de
  callbacks, mensagens ou escritas não é uma medição de redução de CPU.

Para mudanças com scripting recorrente, buscas de mundo, redes ou grande
multiplicação de objetos, preparar cenários reproduzíveis com várias máquinas,
com/sem janelas, ociosas/ativas/bloqueadas e com ITD quando aplicável. Comparar
tempo de script/mundo e latência no engine quando houver runtime disponível.
Sem acesso ao jogo, executar os checks possíveis, entregar o roteiro e registrar
explicitamente que o ganho no engine ainda não foi medido; não inventar números
nem declarar validado o que depende desse teste.

## Referências e uso por agentes

- Skill reutilizável: [starbound-scripting-performance](../.agents/skills/starbound-scripting-performance/SKILL.md).
- Instrução de entrada do projeto: [AGENTS.md](../AGENTS.md).
- Exemplo concreto com evidências e preservação de garantias:
  [Filter 0.2.37-dev](FILTER_PERFORMANCE_0_2_37.md).

A política e a skill são versionadas no repositório. Agentes com suporte à
descoberta de `.agents/skills` podem carregá-la pelo checkout. Chats que consultam
somente o GitHub devem ler os arquivos pelos links do `AGENTS.md`; isso não
instala uma skill global na conta nem garante descoberta automática em toda
ferramenta. A disponibilidade acompanha a branch acessada.
