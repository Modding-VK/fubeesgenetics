# Planejamento de expansão — Abusive Bee Industry

Direção futura informada pelo usuário em 2026-10-15. Este documento registra
a intenção; não executa o rebranding nem implementa as máquinas planejadas.

## Identidade futura

- Nome do mod: **Abusive Bee Industry**.
- Título previsto na Steam Workshop: **[oSB][FU] Abusive Bee Industry**.
- [oSB] identifica OpenStarbound e [FU] identifica Frackin Universe.
- A mudança amplia a identidade do projeto para novos recursos ligados à
  indústria de abelhas; o Genetic Queen Filter permanece uma de suas máquinas.

Na entrega atual 0.2.14-dev, nomes públicos, metadata, IDs de objetos/itens,
namespace, nome do PAK e URL do repositório permanecem os existentes. Quando
o rebranding for solicitado para execução, separar nome público de IDs usados
por saves, receitas e integrações; conservar compatibilidade ou planejar uma
migração explícita. Os prefixos da Workshop identificam requisitos ao público
e não substituem a declaração técnica das dependências.

## Máquina implementada — abelhas por recursos

Objetivo fornecido pelo usuário: trocar abelhas por recursos, tomando como
referência o Bee Refuge do Frackin Universe (mencionado como Bee Refugee na
conversa), com a mecânica de referência do **Terramart Shipments 3.5**.

Implementada na **0.2.0-dev**, com o nome provisório **Bee Exchange**.
As fontes do FU foram auditadas no commit fixado em tools/upstream.json:
105 receitas do Bee Refuge; Terramart Shipments 3.5 usa o ID cropshipper_kheAA2
e 40 slots. A Bee Exchange atualmente usa 16 slots compartilhados e lê as receitas reais
do FU em runtime. Crafting: 1 beerefuge + 1 cropshipper_kheAA2 + 2 aichip,
na Bee Station, com desbloqueio ao obtê-la. Não há dependência adicional de mod.

Ver [especificação, tabela e testes](BEE_EXCHANGE_0_2_0.md).
A implementação não executa o rebranding planejado. A textura foi validada na
0.2.13; a GUI corrigida na 0.2.14 e a integração IC ainda aguardam confirmação
no jogo. Ver [estado atual](IMPLEMENTATION_STATUS.md).

## Fluxo de trabalho

Planejamento e desenvolvimento permanecem em dev. Não criar PR ou promover
para main sem solicitação explícita. O planejamento não representa publicação
na Steam, nova versão de pacote nem promoção para produção.
