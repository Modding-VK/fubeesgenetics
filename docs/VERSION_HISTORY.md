# Histórico das entregas de desenvolvimento

Cada versão preserva sua identificação no _metadata. Os links por SHA apontam
para snapshots imutáveis, incluindo o PAK exato de cada entrega. Novos commits
entram em dev; PRs exigem solicitação explícita do usuário, conforme VERSIONING.
Não sobrescrever tags ou reescrever histórico compartilhado. Os commits locais
sintéticos da recuperação não são usados como ancestrais remotos.

| Versão | Mudança | Código/PAK preservados |
| --- | --- | --- |
| 0.1.0-dev | Reconstrução inicial e distribuição PAK | [Snapshot](https://github.com/Modding-VK/fubeesgenetics/tree/484516b85f6e2b055e2d3b4240ee365032495888), [PAK](https://github.com/Modding-VK/fubeesgenetics/raw/484516b85f6e2b055e2d3b4240ee365032495888/dist/fubeesgenetics-mvp.pak), [PR 1](https://github.com/Modding-VK/fubeesgenetics/pull/1) |
| 0.1.1-dev | Inicialização do Adapter, espelhamento e transferências no OpenStarbound 0.1.14 | [Snapshot](https://github.com/Modding-VK/fubeesgenetics/tree/b5cc9caa47a2d91be3322b56757828210514c2ec), [PAK](https://github.com/Modding-VK/fubeesgenetics/raw/b5cc9caa47a2d91be3322b56757828210514c2ec/dist/fubeesgenetics-mvp.pak), [PR 2](https://github.com/Modding-VK/fubeesgenetics/pull/2) |
| 0.1.2-dev | Identificação correta dos callbacks dos seletores | [Snapshot](https://github.com/Modding-VK/fubeesgenetics/tree/8eec9f102077d634b31405d0548eeb4dced04c8a), [PAK](https://github.com/Modding-VK/fubeesgenetics/raw/8eec9f102077d634b31405d0548eeb4dced04c8a/dist/fubeesgenetics-mvp.pak), [PR 3](https://github.com/Modding-VK/fubeesgenetics/pull/3) |
| 0.1.3-dev | Tema nativo de interface inspirado no FU, aprovado pelo usuário | [Snapshot](https://github.com/Modding-VK/fubeesgenetics/tree/d46ddbce53dc72b45d62eee24e6f78dd733787cd), [PAK](https://github.com/Modding-VK/fubeesgenetics/raw/d46ddbce53dc72b45d62eee24e6f78dd733787cd/dist/fubeesgenetics-mvp.pak), [PR 4](https://github.com/Modding-VK/fubeesgenetics/pull/4) |
| 0.1.4-dev | Soma Healing Water, Sulphuric Acid e Unknown Gene à receita; inicia fluxo dev/main | [PAK versionado](https://github.com/Modding-VK/fubeesgenetics/raw/32ebf50d462484a9c0abc6b3aa5d9d82bb3a74f4/dist/fubeesgenetics-mvp-0.1.4-dev.pak), [receita](RECIPE_0_1_4.md); entrega em dev |
| 0.1.5-dev | Molduras estáticas e itens centralizados nos slots padrão | [PAK](https://github.com/Modding-VK/fubeesgenetics/raw/679c14a96d28e00223ebaa00bc6eccb2ee61c374/dist/fubeesgenetics-mvp-0.1.5-dev.pak), [detalhes](HUD_SLOTS_0_1_5.md); entrega em dev |
| 0.1.6-dev | Setas, nomes dos comparadores, rodapé e texto de Reset Profile | [PAK](https://github.com/Modding-VK/fubeesgenetics/raw/7a4ebfc102f00fc552a44e8676b753dfbb065da2/dist/fubeesgenetics-mvp-0.1.6-dev.pak), [detalhes](HUD_LABELS_0_1_6.md); entrega em dev |

| 0.2.0-dev | Segunda máquina: Bee Exchange automática com as 105 trocas do Bee Refuge e 20 slots | [PAK](https://github.com/Modding-VK/fubeesgenetics/raw/522ab60c848583a9a66494bb4c54e4cd350a33a5/dist/fubeesgenetics-mvp-0.2.0-dev.pak), [detalhes](BEE_EXCHANGE_0_2_0.md); entrega em dev |

| 0.2.1-dev | Interface nativa da Bee Exchange: 20 slots visíveis/centralizados, objeto e Take all | [PAK](https://github.com/Modding-VK/fubeesgenetics/raw/fec264835eeac70ea06147289c557799acffa9b9/dist/fubeesgenetics-mvp-0.2.1-dev.pak), [detalhes](BEE_EXCHANGE_UI_0_2_1.md); entrega em dev |

| 0.2.2-dev | Bee Exchange com 24 slots e sprite Auto Refugee, placa em tom de mel | [PAK](https://github.com/Modding-VK/fubeesgenetics/raw/9556bbcf16a6194dbfdcf51474c058e9441aacab/dist/fubeesgenetics-mvp-0.2.2-dev.pak), [detalhes](BEE_EXCHANGE_0_2_2.md); entrega em dev |

| 0.2.3-dev | Bee Exchange com 16 slots; Young Queens recebem os recursos adultos por espécie | [PAK](../dist/fubeesgenetics-mvp-0.2.3-dev.pak), [detalhes](BEE_EXCHANGE_0_2_3.md); entrega em dev |

SHA-256 do PAK e ZIP Workshop de cada snapshot estão em dist/SHA256SUMS.
Versões dev não representam aprovação de release ou publicação na Steam.

| 0.2.4-dev | Caixa de vidro e teleporte do inseto | [PAK](../dist/fubeesgenetics-mvp-0.2.4-dev.pak), [detalhes](BEE_EXCHANGE_0_2_4.md) |
| 0.2.5-dev | Display nativo, carcaça reparada, LED superior e inspeções raciais | [PAK](../dist/fubeesgenetics-mvp-0.2.5-dev.pak), [detalhes](BEE_EXCHANGE_0_2_5.md) |

| 0.2.6-dev | Carcaça vanilla sem dano e ambos os LEDs laterais originais | [PAK](../dist/fubeesgenetics-mvp-0.2.6-dev.pak), [detalhes](BEE_EXCHANGE_0_2_6.md) |

| 0.2.7-dev | Placement direcional e placa/display legíveis dos dois lados | [PAK](../dist/fubeesgenetics-mvp-0.2.7-dev.pak), [detalhes](BEE_EXCHANGE_0_2_7.md) |

| 0.2.8-dev | Placa integrada, correções pontuais e haste mais curta | [PAK](../dist/fubeesgenetics-mvp-0.2.8-dev.pak), [detalhes](BEE_EXCHANGE_0_2_8.md) |

| 0.2.9-dev | Ícone amarelo, inspeção Analytical e I/O/on-off do Terramart | [PAK](../dist/fubeesgenetics-mvp-0.2.9-dev.pak), [detalhes](BEE_EXCHANGE_0_2_9.md) |

| 0.2.10-dev | Ícone com vidro; investigação de storage documentada, integração IC pendente | [PAK](../dist/fubeesgenetics-mvp-0.2.10-dev.pak), [detalhes](BEE_EXCHANGE_0_2_10.md) |

| 0.2.11-dev | Inspeções explicam nodes e integração opcional com IC 2.11 | [PAK](../dist/fubeesgenetics-mvp-0.2.11-dev.pak), [detalhes](BEE_EXCHANGE_0_2_11.md) |

| 0.2.12-dev | Ressincroniza placa/display com a direção após init e durante locks IC | [PAK](../dist/fubeesgenetics-mvp-0.2.12-dev.pak), [detalhes](BEE_EXCHANGE_0_2_12.md) |

| 0.2.13-dev | Corrige bootstrap dos adaptadores IC para inicializar scripts e texturas | [PAK](../dist/fubeesgenetics-mvp-0.2.13-dev.pak), [detalhes](BEE_EXCHANGE_0_2_13.md) |

| 0.2.14-dev | Corrige uiConfig e abertura da GUI; ponte IC condicional por tipo de objeto | [PAK](../dist/fubeesgenetics-mvp-0.2.14-dev.pak), [detalhes](BEE_EXCHANGE_0_2_14.md) |

| Versão | Mudança | Código/PAK preservados |
| --- | --- | --- |
| 0.2.15-dev | Nome padrão Auto Refugee no item e na janela | [PAK](https://raw.githubusercontent.com/Modding-VK/fubeesgenetics/1035754fbe9fde087c9343ae9e2b015ccd8ed4f2/dist/fubeesgenetics-mvp-0.2.15-dev.pak), [detalhes](BEE_EXCHANGE_0_2_15.md) |
| 0.2.16-dev | Filter compacto, referências centralizadas e slots próximos | [PAK](https://raw.githubusercontent.com/Modding-VK/fubeesgenetics/e2314b4063201da968d933fd6547c6e2e9255eb8/dist/fubeesgenetics-mvp-0.2.16-dev.pak), [detalhes](HUD_COMPACT_0_2_16.md) |
| 0.2.17-dev | Logo centralizado, título laranja no topo e descrição curta | [PAK](https://raw.githubusercontent.com/Modding-VK/fubeesgenetics/10935100979aae7a8c4e2cdd48b089260db01505/dist/fubeesgenetics-mvp-0.2.17-dev.pak), [detalhes](HUD_HEADER_0_2_17.md) |
| 0.2.18-dev | Reset Profile centralizado entre barras e listras na faixa metálica | [PAK](../dist/fubeesgenetics-mvp-0.2.18-dev.pak), [detalhes](HUD_ALIGNMENT_0_2_18.md) |

| Versão | Mudança | Pacote e detalhes |
| --- | --- | --- |
| 0.2.19-dev | Bee Abusive Industry, autor Goblin Man e ícone Cybernetic Queen laranja | [PAK](../dist/bee-abusive-industry-0.2.19-dev.pak), [prontidão](RELEASE_READINESS.md) |
| 0.2.20-dev | Overload Apiary e Genetic Hybridizer com 595 híbridas; sucesso gera larva e apiário não solta abelhas capturáveis | [PAK](../dist/bee-abusive-industry-0.2.20-dev.pak), [detalhes](HYBRID_FIXES_0_2_20.md) |
| 0.2.21-dev | 595 folhas de sprites próprias, com cores, silhuetas e padrões das progenitoras fundidos | [PAK](../dist/bee-abusive-industry-0.2.21-dev.pak), [prévia](../artwork/hybrids/preview.png) |
| 0.2.22-dev | Híbridas funcionam nos apiários FU pequeno e grande por patch dos objetos | [PAK](../dist/bee-abusive-industry-0.2.22-dev.pak) |
| 0.2.23-dev | Catálogo híbrido calculado sob demanda e carregamento dos scripts somente quando necessários | [PAK](../dist/bee-abusive-industry-0.2.23-dev.pak) |
| 0.2.24-dev | Hybridizer acumula energia antes de receber espécies distintas | [PAK](../dist/bee-abusive-industry-0.2.24-dev.pak) |
| 0.2.25-dev | Overload Apiary produz sem energia na velocidade normal; receita de 1 AI Chip e 5 Durasteel Bars | [PAK](../dist/bee-abusive-industry-0.2.25-dev.pak) |
| 0.2.26-dev | Overload Large Apiary: 20 slots, dois drones e dois quadros, com bônus de 20% por 12 W | [PAK](../dist/bee-abusive-industry-0.2.26-dev.pak) |
| 0.2.31-dev | Textos de scanner por espécie para os três objetos que faltavam; regra documentada para objetos futuros | [Action](https://github.com/Modding-VK/fubeesgenetics/actions/workflows/build-pak.yml) |
| 0.2.32-dev | Hybridizer atualiza a cada 30 ticks, consulta a janela a cada 2 s e evita verificar energia após a carga completa | [Action](https://github.com/Modding-VK/fubeesgenetics/actions/workflows/build-pak.yml) |
| 0.2.33-dev | Gene favorável positivo das novas híbridas mantém mínimo 1; evita atributos zerados em cruzamentos comuns | [Action](https://github.com/Modding-VK/fubeesgenetics/actions/workflows/build-pak.yml) |
| 0.2.34-dev | Penalidade genética proporcional: um terço do menor valor parental para atributos favoráveis | [Action](https://github.com/Modding-VK/fubeesgenetics/actions/workflows/build-pak.yml) |
