# Branches, versões e promoção

Convenção autorizada pelo usuário em 2026-10-15:

| Branch | Papel | Versão das novas entregas |
| --- | --- | --- |
| dev | Desenvolvimento e pacotes para teste | X.Y.Z-dev |
| main | Produção | X.Y.Z, na próxima promoção autorizada |

Alterações são armazenadas em dev. Não criar PRs, fazer merges ou promover para
main sem pedido explícito do usuário. CI de push valida a branch e não cria PRs.
Sem force push, rebase de histórico compartilhado ou substituição de tags.
Branches antigas são preservadas como histórico; não são removidas por este fluxo.

## Coordenação entre chats

O fluxo foi conferido novamente no chat Bee Analyzer em 2026-10-17. Ele vale
para as duas máquinas e para as atualizações solicitadas no chat Automatic Seller.
Antes de publicar, comparar a branch local com o HEAD remoto para preservar o
trabalho do outro chat. Mudanças de documentação não exigem uma nova versão de
PAK; nesse caso, conservar metadata, pacote e hashes da entrega existente.
Ver [procedimento GitHub](GITHUB_PUBLICATION.md).

## Desenvolvimento

Cada pacote entregue tem uma versão identificável no _metadata e um commit com
seus assets. Novos PAKs são gerados exclusivamente pelo GitHub Actions e ficam
no artefato da execução; os PAKs antigos em `dist/` são históricos. O PAK manual
deve se chamar
`bee-abusive-industry-<versão>.pak`, usando a versão do _metadata. O PAK da
Workshop continua contents.pak, com os mesmos bytes. Usar links por SHA nos downloads fornecidos ao
usuário, conservando acesso às versões anteriores. A validação de código é feita
no CI; o workflow Build development PAK empacota e confere o resultado.
Não executar `tools/package.py` localmente.

Comandos de validação disponíveis no CI:

```sh
python tools/check_version.py --development
python tools/run_checks.py --fetch
```

O CI executa a validação de versão de desenvolvimento nos pushes de dev. Novos
pacotes de teste continuam -dev mesmo quando o usuário autoriza implementá-los.

## Produção — somente quando solicitada

Quando o usuário solicitar a promoção, preparar o commit com versão estável.
Gerar o PAK estável somente no GitHub Actions, após aprovação da integração.
Validar versão, código e pacote antes da distribuição.
Criar o PR apenas quando solicitado explicitamente. Depois do merge autorizado,
marcar o commit da main com tag anotada vX.Y.Z e manter as tags anteriores.

Exemplo de validação, sem criação de tag ou modificação de refs:

```sh
python tools/check_version.py --release --tag v0.2.0
```

Uma tag estável aponta para o commit aprovado de produção. Preservar o PAK
estável e seus hashes sem prazo no GitHub quando a promoção for autorizada;
artefatos temporários do Actions não substituem esse registro. Publicação de
release/Steam e envio de tags exigem autorização
para essa operação; não são efeitos automáticos do CI ou de um push em dev.

## Transição

A main existente contém 0.1.3-dev por causa do fluxo anterior. Ela é mantida
intacta, inclusive seu identificador histórico. A convenção estável será aplicada
na próxima promoção explicitamente solicitada; não renomear versões nem criar
uma release retroativa para simular uma validação que não ocorreu.

O rebranding autorizado usa bee-abusive-industry nos novos arquivos públicos.
Os nomes antigos fubeesgenetics-mvp e os links por SHA são preservados como
histórico; o name interno e os IDs do mod continuam FUBeesGenetics.
