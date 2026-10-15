# Histórico das entregas de desenvolvimento

Cada versão preserva sua identificação no _metadata. Os links por SHA apontam
para snapshots imutáveis, incluindo o PAK exato de cada entrega. Correções entram
por novas branches, commits e pull requests; não sobrescrever tags existentes,
reescrever main ou usar force push. Os commits locais da reconstrução sintética
não são usados como ancestrais dos commits publicados.

| Versão | Mudança | Código/PAK preservados |
| --- | --- | --- |
| 0.1.0-dev | Reconstrução inicial e distribuição PAK | [Snapshot](https://github.com/Modding-VK/fubeesgenetics/tree/484516b85f6e2b055e2d3b4240ee365032495888), [PAK](https://github.com/Modding-VK/fubeesgenetics/raw/484516b85f6e2b055e2d3b4240ee365032495888/dist/fubeesgenetics-mvp.pak), [PR 1](https://github.com/Modding-VK/fubeesgenetics/pull/1) |
| 0.1.1-dev | Inicialização do Adapter, espelhamento e transferências no OpenStarbound 0.1.14 | [Snapshot](https://github.com/Modding-VK/fubeesgenetics/tree/b5cc9caa47a2d91be3322b56757828210514c2ec), [PAK](https://github.com/Modding-VK/fubeesgenetics/raw/b5cc9caa47a2d91be3322b56757828210514c2ec/dist/fubeesgenetics-mvp.pak), [PR 2](https://github.com/Modding-VK/fubeesgenetics/pull/2) |
| 0.1.2-dev | Identificação correta dos callbacks dos seletores | [Snapshot](https://github.com/Modding-VK/fubeesgenetics/tree/8eec9f102077d634b31405d0548eeb4dced04c8a), [PAK](https://github.com/Modding-VK/fubeesgenetics/raw/8eec9f102077d634b31405d0548eeb4dced04c8a/dist/fubeesgenetics-mvp.pak), [PR 3](https://github.com/Modding-VK/fubeesgenetics/pull/3) |
| 0.1.3-dev | Tema nativo de interface inspirado no FU, aprovado pelo usuário | [Snapshot](https://github.com/Modding-VK/fubeesgenetics/tree/d46ddbce53dc72b45d62eee24e6f78dd733787cd), [PAK](https://github.com/Modding-VK/fubeesgenetics/raw/d46ddbce53dc72b45d62eee24e6f78dd733787cd/dist/fubeesgenetics-mvp.pak), [PR 4](https://github.com/Modding-VK/fubeesgenetics/pull/4) |
| 0.1.4-dev | Soma Healing Water, Sulphuric Acid e Unknown Gene à receita; inicia fluxo dev/main | [Receita](RECIPE_0_1_4.md), [versionamento](VERSIONING.md); entrega em dev |

SHA-256 do PAK e ZIP Workshop de cada snapshot estão em dist/SHA256SUMS.
Versões dev não representam aprovação de release ou publicação na Steam.
