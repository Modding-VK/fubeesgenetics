---
name: starbound-machine-sprites
description: Consultar a pesquisa estética e técnica de sprites de máquinas Starbound ao criar, revisar ou integrar arte de objetos do Bee Abusive Industry.
---

# Sprites de máquinas Starbound

Aplicar quando o trabalho envolver aparência de uma máquina no mundo, ícone,
folha de frames, emissividade, orientação ou integração visual do objeto.

1. Ler o `AGENTS.md` da raiz e
   [STARBOUND_MACHINE_SPRITES](../../../docs/STARBOUND_MACHINE_SPRITES.md).
   Para medidas e arquivos reais, consultar
   [SPRITE_SOURCES](../../../docs/SPRITE_SOURCES.md) e a prancha vinculada.
2. Preencher os campos relevantes de
   [MACHINE_SPRITE_BRIEF](../../../docs/MACHINE_SPRITE_BRIEF.md) no documento
   da máquina. Aproveitar requisitos existentes; evitar pedir confirmações
   sobre decisões já autorizadas.
3. Abrir as imagens de referência e os contratos `.object`, `.frames` e
   `.animation`. Distinguir observação estética, regra técnica e preferência
   do projeto. Não inventar uma regra oficial para todo Starbound.
4. Trabalhar a silhueta e a função na resolução final. Preservar origem e
   canvas entre frames. Nas máquinas do projeto, mostrar frente e uma lateral,
   **jamais faces superior ou inferior**, também em conceitos, ícones e prévias.
   Não transformar a borda da tampa em plano superior visível. Verificar o significado das camadas nos arquivos,
   sem inferir emissividade pelo nome `lit`.
5. Aplicar a política de scripting do projeto: decoração estática, animação
   declarativa quando adequada, mudanças de estado comandadas por eventos
   reais. Não adicionar polling para detalhes puramente visuais.
6. Padronizar emblemas de janela como hexágonos 20×20, mantendo a liberdade
   de forma e escala dos sprites no mundo. A regra do favo de UI permanece
   específica à janela.
7. Entregar arte e contrato de integração, fontes, evidências e limites da
   revisão. A inspeção de PNG não substitui conferência no engine. O método
   de criação/edição deve seguir as ferramentas e instruções da sessão.

Esta skill não exige aprovação adicional para trabalho já solicitado. Seguir
`dev`, preservar `main`, e gerar PAK exclusivamente pelo GitHub Actions.
