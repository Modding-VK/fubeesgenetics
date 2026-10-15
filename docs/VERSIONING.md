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

## Desenvolvimento

Cada pacote entregue tem uma versão identificável no _metadata e um commit com
seus assets, PAK e dist/SHA256SUMS. O PAK manual deve se chamar
`fubeesgenetics-mvp-<versão>.pak`, usando a versão do _metadata. O PAK da
Workshop continua contents.pak, com os mesmos bytes. Usar links por SHA nos downloads fornecidos ao
usuário, conservando acesso às versões anteriores. Validar:

```sh
python tools/check_version.py --development
python tools/run_checks.py --fetch
python tools/package.py
```

O CI executa a validação de versão de desenvolvimento nos pushes de dev. Novos
pacotes de teste continuam -dev mesmo quando o usuário autoriza implementá-los.

## Produção — somente quando solicitada

Quando o usuário solicitar a promoção, preparar o commit com versão estável e
seu PAK reconstruído. Validar versão, testes e pacote antes da integração.
Criar o PR apenas quando solicitado explicitamente. Depois do merge autorizado,
marcar o commit da main com tag anotada vX.Y.Z e manter as tags anteriores.

Exemplo de validação, sem criação de tag ou modificação de refs:

```sh
python tools/check_version.py --release --tag v0.2.0
```

Uma tag estável aponta para o commit aprovado de produção, cujo PAK e hashes
estão versionados. Publicação de release/Steam e envio de tags exigem autorização
para essa operação; não são efeitos automáticos do CI ou de um push em dev.

## Transição

A main existente contém 0.1.3-dev por causa do fluxo anterior. Ela é mantida
intacta, inclusive seu identificador histórico. A convenção estável será aplicada
na próxima promoção explicitamente solicitada; não renomear versões nem criar
uma release retroativa para simular uma validação que não ocorreu.
