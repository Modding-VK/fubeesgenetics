# Overload Apiary e abelhas híbridas — 0.2.20-dev

## Conteúdo

- O Overload Apiary consome 12 W, produz recursos e drones a 1,2× e reduz a
  vida útil da rainha a 0,7×. Não gera abelhas entidades capturáveis aleatórias,
  inclusive quando contém uma híbrida. Drones, larvas e recursos permanecem no
  inventário.
- A hibridizadora recebe Queen e Drone de espécies FU distintas, carrega
  gradualmente 10.000 unidades de energia até 24 W e consome ambos em sucesso
  ou falha. A chance de sucesso é 30%, reduzida a 10% para rivais. O sucesso
  entrega uma **larva de rainha híbrida**.
- O catálogo abrange as 595 combinações das 35 famílias FU e duas subespécies
  por combinação. Cada uma combina os recursos parentais com prioridade de 50%
  e 25%, herda biomas, uma planta preferencial de cada progenitora e rivalidades.
  A imagem de cada espécie junta metades dos sprites parentais em uma única
  abelha; as duas subespécies usam a mesma imagem.

## Correções da revisão

- O metadata não contém mais chaves duplicadas que impediam o empacotador
  nativo de processar o mod.
- A janela da hibridizadora usa os nomes de slots reconhecidos pelo container
  nativo, com molduras independentes e offsets 0, 1 e 2.
- Inserções no container conferem a diferença real do slot e normalizam os
  parâmetros gerados pelo item builder, evitando saídas duplicadas.
- Tentativas incompletas preservam itens retirados para devolução; uma larva
  pendente bloqueia novos cruzamentos até ser entregue.
- Rivalidades nativas em forma de texto ou lista são normalizadas e simétricas.
  A relação das híbridas atua tanto na chance da máquina quanto nos conflitos
  do apiário.
- Preferências de bioma respeitam intolerâncias não conflitantes e os pontos
  médios `3/0 → 2`, `3/1 → 2` e `0/2 → 1`. Só as duas plantas parentais
  escolhidas ganham afinidade adicional.
- A produção híbrida usa referências parentais fixas: genes melhores aumentam
  a taxa; genes zerados ainda produzem uma quantidade finita. Larvas promovidas
  podem formar seus primeiros drones híbridos sem precisar de drones nativos.
- O apiário só simula quando a energia é paga. Tempo passado com o objeto
  descarregado não é compensado por produção sem custo.

## Verificação e limite

Passaram 167 grupos básicos e 13 casos de integração opcional com Improved
Containers 2.11. A validação usa Lua real do mod, fontes FU fixadas por hash,
ligações simuladas do motor e verificação estática dos assets. Os 69 arquivos
do PAK foram conferidos por empacotamento e extração nativos.

A interface, os sprites e o comportamento elétrico ainda precisam de uma
sessão dentro de OpenStarbound com Frackin Universe instalado. Esta versão
permanece na branch `dev`.
