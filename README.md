# Mining Massive Datasets

Skill para estudio tecnico, navegacion del corpus y respuesta guiada sobre *Mining of Massive Datasets* usando referencias locales consolidadas y notas en Markdown. Convierte preguntas sobre `MapReduce`, `Spark`, `LSH`, `PageRank`, `Bloom filters`, `A-Priori`, `clustering`, `recommender systems`, `PCA`, `SVD`, `SVM`, `CNN`, `LSTM` y otros temas del libro en respuestas accionables, comparativas o explicativas con trazabilidad a las secciones consultadas.

Repositorio publico sugerido: `ingeleyton/mining-massive-datasets-skill`  
Skill invocable: `$mining-massive-datasets`

## Que resuelve

Usa esta skill cuando necesites ayuda con:

- fundamentos de data mining, `TF-IDF`, hashing, Bonferroni o leyes de potencia
- `MapReduce`, `Spark`, costo de comunicacion, joins distribuidos o complejidad de reducers
- similitud de documentos, `shingling`, `MinHash`, `LSH`, `banding` o entity resolution
- data streams, `Bloom filters`, `Flajolet-Martin`, `AMS`, `DGIM`, ventanas deslizantes o decaying windows
- `PageRank`, `topic-sensitive PageRank`, `TrustRank`, `HITS` o link spam
- support, confidence, interest, `A-Priori`, `PCY`, `SON`, `Toivonen` o frequent itemsets
- clustering jerarquico, `k-means`, `BFR`, `CURE`, `GRGPF` o stream clustering
- algoritmos online para ads, `matching bipartito`, `Adwords` o `Balance`
- `utility matrix`, filtrado colaborativo, recomendacion basada en contenido, `UV` o `RMSE`
- graph mining, comunidades, `Girvan-Newman`, particion espectral, `SimRank`, triangulos o `SCC`
- `PCA`, `SVD`, `CUR`, eigenvalues, `Power Iteration` o reduccion de dimensionalidad
- `Perceptron`, `Winnow`, `SVM`, `k-NN`, arboles, bosques, `CNN`, `RNN`, `LSTM`, dropout o early stopping

## Instalacion recomendada

La forma mas simple es instalarla directo desde GitHub:

```bash
npx skills add ingeleyton/mining-massive-datasets-skill -g -y
```

Notas:

- `-g` instala la skill a nivel de usuario.
- `-y` evita prompts interactivos.
- No necesitas clonar el repo para usarla.
- El comando ya apunta al repo publico previsto.

## Si prefieres clonar el repo

Hay dos escenarios distintos y conviene no mezclarlos.

### Opcion 1: clonar el repo y luego instalarlo con el CLI desde la copia local

```bash
git clone https://github.com/ingeleyton/mining-massive-datasets-skill.git
cd mining-massive-datasets-skill
npx skills add . -g -y
```

Ventajas:

- el CLI detecta la skill desde la raiz del repo
- evita instalacion manual por rutas
- sirve para probar cambios locales antes de publicar

### Opcion 2: clonar o copiar el repo manualmente, sin usar `npx skills`

En este caso tu debes poner la carpeta en la ruta de skills del agente.

Importante:

- el nombre de la skill es `mining-massive-datasets`
- si haces instalacion manual, la carpeta final que contiene `SKILL.md` deberia llamarse `mining-massive-datasets`
- manten juntas estas rutas: `SKILL.md`, `agents/`, `references/`, `scripts/` y `notes/`

## Instalacion manual por sistema operativo

En macOS y Linux, `~` significa tu carpeta home.  
En Windows, el equivalente suele ser `$HOME` en PowerShell o `%USERPROFILE%` en CMD.

### macOS y Linux

#### Clonar directo en la carpeta global de Codex

```bash
mkdir -p ~/.codex/skills
git clone https://github.com/ingeleyton/mining-massive-datasets-skill.git ~/.codex/skills/mining-massive-datasets
```

#### Si ya clonaste el repo en otra ruta

Puedes enlazarlo con un symlink:

```bash
ln -s /ruta/a/mining-massive-datasets-skill ~/.codex/skills/mining-massive-datasets
```

Si no quieres usar symlink, copia la carpeta completa asegurandote de que el destino final sea `~/.codex/skills/mining-massive-datasets`.

### Windows

#### Clonar directo en la carpeta global de Codex con PowerShell

```powershell
New-Item -ItemType Directory -Force "$HOME\.codex\skills" | Out-Null
git clone https://github.com/ingeleyton/mining-massive-datasets-skill.git "$HOME\.codex\skills\mining-massive-datasets"
```

#### Si ya clonaste el repo en otra ruta

Puedes crear un enlace simbolico desde PowerShell:

```powershell
New-Item -ItemType Directory -Force "$HOME\.codex\skills" | Out-Null
New-Item -ItemType SymbolicLink -Path "$HOME\.codex\skills\mining-massive-datasets" -Target "C:\ruta\a\mining-massive-datasets-skill"
```

Notas:

- en Windows, crear symlinks puede requerir Developer Mode o permisos de administrador
- si prefieres evitar symlinks, copia el contenido del repo a `$HOME\.codex\skills\mining-massive-datasets`

## Rutas manuales comunes por agente

Si no usas `npx skills`, estas son rutas globales utiles para instalacion manual.

| Agente | macOS / Linux | Windows |
| --- | --- | --- |
| Codex | `~/.codex/skills/mining-massive-datasets` | `%USERPROFILE%\.codex\skills\mining-massive-datasets` |
| Claude Code | `~/.claude/skills/mining-massive-datasets` | `%USERPROFILE%\.claude\skills\mining-massive-datasets` |
| Cursor | `~/.cursor/skills/mining-massive-datasets` | `%USERPROFILE%\.cursor\skills\mining-massive-datasets` |
| Cline | `~/.agents/skills/mining-massive-datasets` | `%USERPROFILE%\.agents\skills\mining-massive-datasets` |
| Gemini CLI | `~/.gemini/skills/mining-massive-datasets` | `%USERPROFILE%\.gemini\skills\mining-massive-datasets` |
| GitHub Copilot | `~/.copilot/skills/mining-massive-datasets` | `%USERPROFILE%\.copilot\skills\mining-massive-datasets` |

Si tu agente soporta instalacion por proyecto en vez de global, una ruta frecuente es:

```text
.agents/skills/mining-massive-datasets
```

## Como usarla

Una vez instalada, invocala por nombre:

```text
Usa $mining-massive-datasets para explicarme cuando conviene MinHash + LSH frente a un metodo exacto para similitud alta y dime que partes del corpus debo abrir primero.
```

Tambien funciona bien para casos como:

```text
Usa $mining-massive-datasets para comparar PageRank y HITS, explicar cuando aparece link spam y darme un checklist rapido de validacion.
```

```text
Usa $mining-massive-datasets para revisar si conviene usar A-Priori, PCY o SON segun memoria disponible, numero de pasadas y si los datos estan en batch o MapReduce.
```

```text
Usa $mining-massive-datasets para contrastar UV factorization, PCA y SVD, y decirme cual es el punto de partida correcto para recomendacion vs reduccion dimensional general.
```

## Que contexto conviene pasarle

Para obtener una respuesta util, incluye:

- concepto, algoritmo o capitulo sospechado
- restriccion principal: memoria, precision, latencia, numero de pasadas, comunicacion o escalabilidad
- si buscas teoria, comparacion, implementacion, troubleshooting o plan de estudio
- metrica o representacion relevante: conjunto, bolsa, vector, grafo, matriz dispersa o stream
- formula, fragmento de codigo o error concreto si quieres aterrizarlo a un caso real
- si la pregunta cruza dominios, cual es el objetivo principal y cual es el secundario

## Que devuelve

La skill esta disenada para responder con:

- contexto del problema o pregunta
- algoritmo o bloque tematico correcto
- supuestos, tradeoffs y limitaciones relevantes
- acciones inmediatas o siguiente ruta de lectura
- referencias exactas al corpus y a los archivos consultados

## Que incluye este repo

- [SKILL.md](./SKILL.md): workflow principal, reglas de routing y contrato de respuesta
- [references/corpus-map.md](./references/corpus-map.md): mapa de navegacion rapida del corpus
- [references/foundations-and-distributed.md](./references/foundations-and-distributed.md): fundamentos, MapReduce, Spark y costo de comunicacion
- [references/similarity-and-lsh.md](./references/similarity-and-lsh.md): similitud, MinHash, LSH y entity resolution
- [references/recommenders.md](./references/recommenders.md): recomendacion, utility matrix y UV factorization
- [references/graph-mining.md](./references/graph-mining.md): comunidades, SimRank, triangulos y SCC
- [references/deep-learning.md](./references/deep-learning.md): redes neuronales, CNN, RNN, LSTM y regularizacion
- [scripts/find_corpus_notes.ps1](./scripts/find_corpus_notes.ps1): buscador local del corpus
- [agents/openai.yaml](./agents/openai.yaml): metadata de interfaz para clientes compatibles
- [notes/](./notes): las 57 notas fuente consolidadas

## Como se complementa con otras skills

Esta skill esta enfocada en el corpus de *Mining of Massive Datasets* y en consulta tecnica guiada por ese material.

Si el problema real es de operacion de plataforma, deployment, pipelines productivos o tuning de un framework especifico, conviene combinarla con una skill especializada del stack concreto.

Ejemplos:

- para Spark productivo y performance real, combinarla con una skill especializada de Spark
- para serving o MLOps, combinarla con una skill enfocada en inferencia, pipelines o deployment
- para troubleshooting operativo de Hadoop/YARN, combinarla con una skill centrada en infraestructura

## Desarrollo local

Si quieres validar o probar la skill desde este repo:

```bash
npx skills add . -g -y
```

Para busquedas rapidas dentro del corpus en Windows PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\find_corpus_notes.ps1 "pagerank spam" -Top 5
powershell -ExecutionPolicy Bypass -File .\scripts\find_corpus_notes.ps1 "cnn dropout early stopping" -Top 5
```

## Licencia

Este repositorio usa licencia [MIT](./LICENSE).

La licencia MIT permite uso personal, comercial, modificacion, distribucion y sublicenciamiento, manteniendo el aviso de copyright y la licencia.

## Antes de publicar

Antes de hacer publico el repo, revisa estas piezas:

- verificar que el repo expone directamente `SKILL.md`, `agents/`, `references/`, `scripts/` y `notes/` en la raiz
- probar instalacion local con `npx skills add . -g -y`
- probar busqueda local con `powershell -ExecutionPolicy Bypass -File .\scripts\find_corpus_notes.ps1 "lsh cosine similarity" -Top 5`
- probar instalacion remota con `npx skills add ingeleyton/mining-massive-datasets-skill -g -y` una vez publicado

## Checklist final de publicacion

1. Crear el repositorio publico en GitHub, idealmente con nombre `mining-massive-datasets-skill`.
2. Subir como raiz del repo el contenido actual de esta carpeta, sin envolverlo en otra carpeta adicional.
3. Verificar que [SKILL.md](./SKILL.md), [agents/openai.yaml](./agents/openai.yaml), [references/corpus-map.md](./references/corpus-map.md) y [scripts/find_corpus_notes.ps1](./scripts/find_corpus_notes.ps1) esten visibles.
4. Copiar o aplicar los topics sugeridos desde [.github/settings.yml](./.github/settings.yml).
5. Confirmar que la skill se invoca como `$mining-massive-datasets`.

