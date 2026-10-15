# Receita do Genetic Queen Filter — 0.1.4-dev

Por solicitação explícita do usuário, somar os três reagentes aos quatro
ingredientes anteriores. A receita completa produz um Genetic Queen Filter:

| Ingrediente | ID | Quantidade |
| --- | --- | ---: |
| AI Chip | aichip | 2 |
| Laser Diode | laserdiode | 5 |
| Reinforced Glass | skathreinforcedglass | 5 |
| Titanium Bar | titaniumbar | 10 |
| Healing Water | liquidhealing | 10 |
| Sulphuric Acid | liquidsulphuricacid | 5 |
| Unknown Gene | unknowngene | 2 |

Continuam a estação Bee Station/aba Functional, o mesmo blueprint, output e
quantidade. A mudança não modifica inventário, perfil ou modos de máquinas
existentes. IDs de inventário dos líquidos são usados na receita, em vez dos
nomes do líquido no mundo. Healing Water é o líquido coletado, não a garrafa
bottledhealingwater.

## Fontes verificadas

FU fixado em 17868d86c9bb7bc00f92038fb78b48cebd1b41b8:

- items/liquids/liquidsulphuricacid.liqitem: itemName=liquidsulphuricacid,
  shortdescription=Sulphuric Acid, blob 16af52179833726867300f435ec4b43e70201fd6.
- items/generic/crafting/precursor/unknowngene.item: itemName=unknowngene,
  shortdescription=Unknown Gene, blob f585b4160dcf5cb625f7c4af9d0020065bf5df18.
- As duas fontes estão fixadas em tools/upstream.json; os checks verificam
  integridade Git e os IDs dos itens/quantidades da receita. Total: 14 fontes FU.

Healing Water foi conferido no espelho vanilla FerreiraJGB/Starbound, revisão
3b370d25c27923155badb38c414a664e1ee2abfc, arquivo
assets/packed/items/liquids/healingwater.liqitem, itemName=liquidhealing e
shortdescription=Healing Water. O patch FU items/liquids/healingwater.liqitem.patch
altera apenas a descrição e preserva o ID. Os assets de referência não são
redistribuídos no mod.

## Verificação e entrega

91 grupos passaram com a receita atualizada, incluindo IDs FU, quantidades e
grupos da estação. O PAK padrão é validado por desempacotamento nativo dos 27
arquivos. A fabricação real com os sete ingredientes ainda requer teste no jogo.

A entrega está em dev. Por instrução de operação do usuário, não criar PR nem
promover para main sem pedido explícito. A main permanece na versão anterior.
Ver [VERSIONING](VERSIONING.md).
