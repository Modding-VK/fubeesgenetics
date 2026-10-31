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
| 0.2.35-dev | Nome das híbridas mostra as subespécies nativas de origem e H1/H2; subtítulo mostra somente a subespécie híbrida | [Action](https://github.com/Modding-VK/fubeesgenetics/actions/workflows/build-pak.yml) |
| 0.2.36-dev | Campo de subespécie da híbrida mostra `Predominant:` com o nome da subespécie nativa priorizada | [Action](https://github.com/Modding-VK/fubeesgenetics/actions/workflows/build-pak.yml) |

| 0.2.37-dev | Filter: callbacks reduzidos, polling 1 s, renderização condicional, caches limitados, contrato compartilhado e isolamento de linhagens híbridas | [Detalhes](FILTER_PERFORMANCE_0_2_37.md) · [Action](https://github.com/Modding-VK/fubeesgenetics/actions/workflows/build-pak.yml) |

| 0.2.38-dev | Auditoria geral: snapshots bulk e gates na Auto Refugee, detecção híbrida no snapshot FU, flores por tick, caches compartilhados e UI/ponte IC condicionais | [Auditoria](SCRIPTING_AUDIT_0_2_38.md) · [Action](https://github.com/Modding-VK/fubeesgenetics/actions/workflows/build-pak.yml) |
| 0.2.39-dev | Hybridizer só avança com entradas válidas e saída livre; medidor mostra progresso do experimento | [Detalhes](HYBRIDIZER_PROGRESS_0_2_39.md) · [Action](https://github.com/Modding-VK/fubeesgenetics/actions/workflows/build-pak.yml) |
| 0.2.40-dev | Hybridizer preserva progresso com a mesma cobaia e perde 50% ao substituí-la, com alerta na janela | [Detalhes](HYBRIDIZER_SPECIMENS_0_2_40.md) · [Action](https://github.com/Modding-VK/fubeesgenetics/actions/workflows/build-pak.yml) |
| 0.2.41-dev | Janela do Hybridizer compactada, cabeçalho com logo e favo no canto; diretriz para futuras máquinas | [Detalhes](HYBRIDIZER_UI_0_2_41.md) · [Action](https://github.com/Modding-VK/fubeesgenetics/actions/workflows/build-pak.yml) |
| 0.2.42-dev | Favo estático no Analyzer e logos hexagonais padronizados no Analyzer/Hybridizer | [Detalhes](ANALYZER_UI_0_2_42.md) · [Action](https://github.com/Modding-VK/fubeesgenetics/actions/workflows/build-pak.yml) |
| 0.2.54-dev | Receita do Genetic Hybridizer alterada para 5 AI Chips, 10 Cell Matter, 1 Red Matter, 5 Isogen Bars e 1 Lasombrium Seed | |
| 0.2.55-dev | Hybridizer aceita discos de pesquisa consumíveis para elevar a chance de sucesso | [Detalhes](HYBRIDIZER_RESEARCH_DISCS_0_2_55.md) |
| 0.2.56-dev | Remove H1/H2 do nome visível das híbridas; conserva o gene interno de subespécie para produção e identidade. Mudança apenas no builder do item, sem custo recorrente novo de scripting; desempenho no jogo não medido. | |
| 0.2.57-dev | Aproxima Queen e Drone; Disc fica 48 px após Drone, Larva ocupa a antiga posição do Disc. Migração única troca os itens antigos dos slots 3 e 4, preservando itens pendentes. Sem polling ou custo recorrente novo além de uma checagem simples de versão por atualização; interação e migração no jogo ainda precisam ser conferidas. | |
| 0.2.58-dev | Texto de sucesso mostra chances comuns e rivais para o disco presente; slot vazio alterna ícones FU dos três discos a 20% de visibilidade e um estado vazio a cada 2 s. Reutiliza a consulta existente da janela. | |
| 0.2.59-dev | Chance de sucesso movida para cima de Status com a mesma fonte; bloco inferior centralizado entre divisória e moldura. Aviso de retrabalho reposicionado acima dos slots para evitar sobreposição. Mudança estática, sem custo adicional de scripting. | |
| 0.2.60-dev | Genetic Hybridizer passa de Rare para Essential; Genetic Queen Filter passa de Rare para Legendary. Apenas metadados estáticos dos objetos, sem novo custo de scripting. | |
| 0.2.61-dev | Hybridizer recebe corpo 40×32 e ícone baseados no Queen Filter, vidro roxo, ocupação 5×4 e luz roxa mínima; remove animação antiga do Apiary FU. | [Sprite](HYBRIDIZER_SPRITE_0_2_61.md) |
| 0.2.62-dev | Encurta a descrição do item Hybridizer, removendo a menção a 10.000 de progresso; somente texto estático, sem custo recorrente de scripting. | |
| 0.2.63-dev | Corrige a posição da fonte de luz na orientação do Hybridizer e aumenta a intensidade para um roxo discreto e visível. Sem script novo. | [Detalhes](HYBRIDIZER_SPRITE_0_2_61.md) |
| 0.2.64-dev | Filter: Equal/Within range fixos e editor por atributo; Auto Refugee: venda agregada de drones com capacidade e cota global | [Detalhes](FILTER_TARGETS_AND_BATCHES_0_2_64.md) · build manual na Action |
| 0.2.65-dev | Desce 5 pixels os cinco textos inferiores do Hybridizer para afastá-los da divisória e da moldura. Apenas layout estático, sem custo recorrente novo de scripting. | [Detalhes](HYBRIDIZER_UI_0_2_41.md) |
| 0.2.66-dev | Nomes dos dois Overload Apiaries usam a cor padrão branca, sem código de cor laranja no `shortdescription`. Somente texto estático; nenhum custo recorrente novo de scripting. | |
| 0.2.67-dev | Bônus dos discos do Hybridizer: Micro +15, Holo +25 e Mega +30 pontos; espécies rivais recebem metade. Mesma tabela atende tentativa e interface, sem custo recorrente novo. | [Detalhes](HYBRIDIZER_RESEARCH_DISCS_0_2_55.md) |
| 0.2.68-dev | Remove o bypass que permitia à rainha híbrida gerar drones sem drones previamente presentes; o ciclo e a decadência de drones sem rainha voltam a seguir as validações nativas do FU. | |
| 0.2.69-dev | Atualiza o teste H29 para validar o ciclo nativo de drones híbridos: exige um drone inicial e verifica a decadência após remover a rainha. | |
| 0.2.70-dev | Inicia a produção híbrida ponderada em 2/3 para a linhagem predominante e 1/3 para a recessiva; adiciona quatro saídas de status ao Hybridizer. | |
| 0.2.71-dev | Adiciona à descrição e às inspeções do Hybridizer o mapeamento dos quatro nós de status: ativo, disco, larva e pronto. | |
| 0.2.72-dev | Overload Apiary passa a ter 12 slots de output em 3×4; Overload Large passa a ter 20 slots de output em 4×5. Interfaces próprias preservam os slots nativos. | |
