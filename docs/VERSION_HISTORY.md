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
