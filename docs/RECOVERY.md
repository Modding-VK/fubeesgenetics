# Procedência e limites da reconstrução

Recuperação realizada em 2026-10-14 (horário do usuário).

| Fonte recebida | SHA-256 | Uso |
| --- | --- | --- |
| MVP mod ZIP | d7eca1bdbe9669678526b7586920bfa56c8ccae0f4b22a98670711f6c2c30c52 | Base mais atual: 26 arquivos do mod |
| Phases 1–2 ZIP | bb60ac80a85919ea0b8618afbaf619d60678866e3ed9a776c3c5113c446a28ee | Documentos, Adapter/probe, testes iniciais, runner e CI |

Adapter e probe eram idênticos nos dois arquivos. Os ZIPs originais foram
preservados fora do projeto e passaram no teste de integridade. A base Git
local d9c1222 representa a sobreposição MVP sobre o scaffold inicial, não um
commit remoto. A branch local é recovered-mvp.

O MD original permanece no blob 698cb35f0c34e95af49089d2fd6c21162b1eec32.
Não estavam disponíveis: anexo integral MasterSpec v1.2, sprite final aprovado,
fontes completas do commit c3a0238, nem os testes/gerador/documentos finais.
As correções v1.1/v1.2 foram refeitas a partir do histórico e estão consolidadas
em [MASTER_SPEC_V1_2_RECOVERED](MASTER_SPEC_V1_2_RECOVERED.md).

Foram reconstruídos: controlador com escrow, Adapter, coordenação da GUI,
tooltips, pressed, suites de máquina/interface/assets, gerador que preserva
os pixels recuperados, documentação, empacotamento e preparação de CI.
Os 85 grupos atuais são uma suíte reconstruída e executada nesta recuperação;
não são os mesmos arquivos perdidos nem prova de identidade com a entrega anterior.

A arte do ZIP foi mantida sem edição, em artwork e no mod. Não representa
restauração do modelo final aprovado, que dependia de outra imagem não recuperada.
O retorno desse PNG e do anexo v1.2 permitiria comparação e integração exatas.

Os pacotes finais incluem PAK padrão, conteúdo Workshop e todos os arquivos necessários ao desenvolvimento,
sem caches ou .git. Um bundle Git separado preserva o histórico local e um
manifesto externo registra hashes dos arquivos entregues. Guarde ao menos o
ZIP de fontes ou o bundle; os links do workspace dependem da vida do ambiente.

## Armazenamento externo após reconexão

Em 2026-10-15, a instalação da integração na organização Modding-VK permitiu
criar a branch recovery/genetic-queen-filter-20261015. O projeto e PAK de
desenvolvimento são armazenados nessa branch, oferecendo recuperação persistente
além dos ZIPs/bundle locais. A main original e os gates de release são preservados.
