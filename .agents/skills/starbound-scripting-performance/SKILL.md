---
name: starbound-scripting-performance
description: Aplicar o requisito de eficiência de scripting do Bee Abusive Industry ao criar ou alterar itens, objetos, máquinas, interfaces, builders ou integrações Starbound/OpenStarbound/FU.
---

# Eficiência de scripting do Bee Abusive Industry

Use esta skill em toda criação ou alteração de conteúdo do mod. A otimização
de scripting é requisito explícito do mantenedor, inclusive para itens cujo
custo venha de builders ou patches indiretos.

## Procedimento

1. Leia o `AGENTS.md` da raiz e a política
   [SCRIPTING_PERFORMANCE.md](../../../docs/SCRIPTING_PERFORMANCE.md).
   Preserve o fluxo dev/main e a geração de PAK exclusivamente no CI.
2. Identifique os caminhos executados: carregamento, builder, atualização,
   inventário, mensagens e interface. Para conteúdo estático, prefira não
   introduzir scripts; registre se não há custo recorrente novo.
3. Defina a frequência necessária e a latência aceitável. Escolha o intervalo
   compatível com a mecânica e use `dt` corretamente. Avalie custo com várias
   instâncias e janelas; não imponha um intervalo único a todos os objetos.
4. Elimine trabalho repetido e ocioso: consultas redundantes, redraws, parsing,
   cópias e cargas pesadas. Limite polling e comandos em voo, reaproveite respostas
   e descarte leituras antigas. Verifique as APIs no engine/FU antes de depender
   de eventos, retornos ou persistência de canvas.
5. Use caches pequenos e limitados, com autoridade e invalidação claras.
   Não cacheie estado mutável como substituto da revalidação. Compartilhe
   contratos/helpers leves e mantenha decisões puras separadas dos efeitos.
6. Preserve os descritores exatos e os contratos de transferência, rollback,
   escrow, persistência, genética, energia e FU/ITD. Não remova verificações
   físicas para diminuir a carga e não reconstrua espécimes sem necessidade.
7. Execute checks proporcionais ao risco e verifique falhas, reload, concorrência
   e limites afetados. Para mudanças de desempenho recorrente, prepare uma
   comparação reproduzível no jogo. Não adicionar logs por frame em produção.
8. Documente mudanças, frequências, limites, evidências e pendências. Diferencie
   contagens simuladas de medições de CPU/fila do engine. Se o runtime estiver
   indisponível, conclua o trabalho autorizado possível e entregue um roteiro de
   medição, sem afirmar que o desempenho real já foi validado.

Consulte [FILTER_PERFORMANCE_0_2_37.md](../../../docs/FILTER_PERFORMANCE_0_2_37.md)
como exemplo, sem tratar seus intervalos como valores obrigatórios para outras
máquinas. A skill não autoriza criar PR, fazer merge ou publicar versões.
