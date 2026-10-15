# Planejamento de expansão — Abusive Bee Industry

Direção futura informada pelo usuário em 2026-10-15. Este documento registra
a intenção; não executa o rebranding nem implementa as máquinas planejadas.

## Identidade futura

- Nome do mod: **Abusive Bee Industry**.
- Título previsto na Steam Workshop: **[oSB][FU] Abusive Bee Industry**.
- [oSB] identifica OpenStarbound e [FU] identifica Frackin Universe.
- A mudança amplia a identidade do projeto para novos recursos ligados à
  indústria de abelhas; o Genetic Queen Filter permanece uma de suas máquinas.

Na entrega atual 0.1.4-dev, nomes públicos, metadata, IDs de objetos/itens,
namespace, nome do PAK e URL do repositório permanecem os existentes. Quando
o rebranding for solicitado para execução, separar nome público de IDs usados
por saves, receitas e integrações; conservar compatibilidade ou planejar uma
migração explícita. Os prefixos da Workshop identificam requisitos ao público
e não substituem a declaração técnica das dependências.

## Máquina futura — abelhas por recursos

Objetivo fornecido pelo usuário: trocar abelhas por recursos, tomando como
referência o Bee Refuge do Frackin Universe (mencionado como Bee Refugee na
conversa), com a mecânica de referência do **Terramart Shipments 3.5**.

As referências ainda não foram auditadas para essa funcionalidade. O fluxo
exato e os parâmetros não foram especificados, portanto não definir valores
ou regras como se já tivessem sido aprovados. Para preparar a implementação:

- Identificar o item/fontes exatos do Terramart Shipments 3.5 e estudar sua
  mecânica junto à implementação do Bee Refuge do FU.
- Definir abelhas aceitas, quantidades, recursos de retorno e eventuais tempos
  ou limites de operação, conforme a proposta funcional a ser discutida.
- Decidir se haverá integração direta ou lógica própria inspirada na referência.
  Citar Terramart Shipments não cria por si só uma nova dependência obrigatória.
- Planejar slots, interface e automação conforme o fluxo escolhido, preservando
  o Genetic Queen Filter e a integração ITD já existentes.

## Fluxo de trabalho

Planejamento e desenvolvimento permanecem em dev. Não criar PR ou promover
para main sem solicitação explícita. O planejamento não representa publicação
na Steam, nova versão de pacote nem promoção para produção.
