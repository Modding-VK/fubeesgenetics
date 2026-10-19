# Conformidade da reconstrução

Registro histórico da recuperação. O mantenedor posteriormente confirmou todas
as alterações funcionais validadas. A situação da candidata, os testes atuais e
as operações de publicação restantes estão em [RELEASE_READINESS](RELEASE_READINESS.md).
Os números e pendências abaixo descrevem a fase histórica em que foram registrados.

A implementação foi confrontada com o MD original e com as alterações v1.1/v1.2
preservadas no histórico. O anexo integral mais recente e a arte final não foram
recuperados; não se declara equivalência byte a byte com o projeto anterior.

| Requisito | Implementação | Evidência local |
| --- | --- | --- |
| Três slots nativos, outputs vazios antes de Input | Container real, grids 1/0/2, sem filtros ou Shift+Click especial | M1/M4/M5/S1/S5 |
| Adapter readonly e precedência estrutural | normalize/read; truthiness, 18 caracteres, family/subtype e seis raws | 22 grupos Adapter |
| Baseline/AND/igualdade/ignore | Objeto autoritativo; rejeição não atualiza refs; Mutation sem inversão | M2/M6–M9/M23/M25/M26 |
| Raw persistido/display derivado | genelib.numberToStat + statToValue, inclusive perfis compostos | M21/M35 |
| Estado incompleto e modos inválidos | Limpeza fail-safe com warnings, modos válidos preservados | M33 |
| Snapshot síncrono e count fora da identidade | Cópias locais de profile/references/modes; nome/parâmetros na revalidação | M13/M14/M20/M34 |
| Commit somente após inserção | Nenhum commit genético ou lastResult em abort/rollback | M15–M20/M27–M29 |
| Escrow excepcional de uma unidade | RECOVERY_HOLD, Reset preserva, prioridade/reload e tentativa final | M27–M32/M36/M37 |
| Sem revisão/locks/CAS | Cleanup legado, snapshots sem contador; LWW do objeto | M10/M22/M33/U4/U5/U10 |
| Uma mutação por pane | Read anterior descartado, pausa passiva e resposta autoritativa | U3–U7/U17 |
| Entidade desaparecida/callback recursivo | Fecha pane e invalida view; supressão no render | U2/U15 |
| Tooltips e pressed | Canvas transparente ao mouse, quatro textos individuais, botões corrigidos | U12–U14/S6/S9 |
| Craft e unlock não destrutivo | Receita correta, patch preserva blueprints, printable=false | S2/S7/S8 |
| Arte estática/orientação/footprint | Pixels originais do ZIP 40×32/20×20; final aprovada não recuperada | S2/S3; pendência artística explícita |

**91 grupos passaram nesta reconstrução.** Nenhuma simulação comprova multiplayer,
ITD, crafting, destruição ou persistência no runtime. Mocks não verificam fontes,
colisão, visual, event handling nativo ou construção de items pelo engine.

Permanecem os gates da seção 67; os testes adicionais A13–A18, G7–G11 e T5–T8
foram representados localmente. P3/U1/M7 precisam de jogo real, mesmo com testes
locais de cleanup/patch/LWW. O envelope {ok,error,state} e stagger são opcionais.

A exceção de spawn com efeito incerto é tratada como em
[IMPLEMENTATION_STATUS](IMPLEMENTATION_STATUS.md). Não existe journal transacional,
fila normal, quarto slot, consumo de energia ou reinterpretação de ignore.

## Formato de instalação/publicação

PAK padrão SBAsset6 produzido e lido pelas ferramentas nativas OpenStarbound
v0.1.15.1 para Starbound 1.4.4. Round-trip verificou 27 arquivos, assets idênticos
e metadata equivalente. Manual usa Starbound/mods/fubeesgenetics-mvp.pak;
Workshop usa contents.pak idêntico, gerenciado pela Steam. As fontes e a pasta
aberta continuam disponíveis para manutenção/Mod Uploader. Ver [WORKSHOP](WORKSHOP.md).
Não houve mudança nas regras do motor nem declaração de compatibilidade vanilla.

Tema GUI aprovado pelo usuário e implementado na 0.1.3-dev; ver
[HUD_THEME_0_1_3](HUD_THEME_0_1_3.md). A confirmação do usuário sobre seletores
e ITD na 0.1.2 complementa os testes simulados, sem validar todos os cenários.

A 0.1.4-dev acrescenta os reagentes por instrução posterior explícita do usuário,
preservando os quatro ingredientes anteriores. Esse ajuste prevalece sobre os
quantitativos originais da diretriz; ver [RECIPE_0_1_4](RECIPE_0_1_4.md).
