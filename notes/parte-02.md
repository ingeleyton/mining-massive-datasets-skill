# parte-02 — Mining-of-Massive-Datasets-Third-Edition-Jure-Leskovec-Anand-Rajaraman-etc-z-library-sk-1lib-sk-z-lib-parte-02.pdf

## 1. Metadatos del documento
- **Libro:** Mining of Massive Datasets, 3ª ed.
- **Fragmento/Parte:** Chapter 2. MapReduce and the New Software Stack (Secciones 2.1, 2.2, 2.3 intro)
- **Temas principales:** Distributed File Systems (DFS), Arquitectura de Clusters, Modelo de programación MapReduce, Combiners, Tolerancia a fallos, Skew de datos.
- **Tipo de contenido:** Mixto (Teoría de sistemas / Algoritmo / Arquitectura)

## 2. Resumen técnico de alto valor
El fragmento aborda la evolución del "stack" de software para minería de datos masivos ("big-data"), transitando desde supercomputadoras propietarias hacia **computación en clúster** (commodity hardware). Se introduce el **Sistema de Archivos Distribuidos (DFS)**, como GFS o HDFS, diseñado para manejar archivos de terabytes mediante división en **chunks** (bloques de 64MB) replicados para tolerancia a fallos. Sobre esta capa, se define **MapReduce** como el paradigma de programación central: descompone cálculos en tareas **Map** (generación de pares clave-valor) y **Reduce** (agregación por clave), gestionados por un **Master Controller** que orquesta la distribución, el "shuffle" y la recuperación ante fallos de nodos. Se destaca la optimización mediante **Combiners** para reducir tráfico de red cuando la operación Reduce es asociativa y conmutativa, y se analizan estrategias para mitigar el **skew** (desequilibrio de carga) en las fases de reducción.

## 3. Conceptos y definiciones clave
- **Cluster Computing:** Arquitectura de hardware que utiliza nodos de cómputo convencionales organizados en racks, conectados por redes Ethernet o switches, reemplazando a los superordenadores propietarios.
- **Distributed File System (DFS):** Sistema de archivos diseñado para grandes volúmenes de datos (ej. GFS, HDFS, Colossus). Se caracteriza por almacenar archivos inmensos, con actualizaciones raras (principalmente "appends") y alta tolerancia a fallos.
- **Chunk:** Unidad básica de almacenamiento en un DFS (típicamente 64 MB). Los archivos se dividen en chunks que se replican (ej. 3 copias) en diferentes nodos y racks para redundancia.
- **Master Node / Name Node:** Nodo que almacena los metadatos y la ubicación de los chunks de un archivo en el DFS. Es un punto crítico que debe estar replicado.
- **MapReduce:** Modelo de programación para procesamiento paralelo masivo. Consta de una fase Map (transforma elementos de entrada en pares clave-valor) y una fase Reduce (agrega valores asociados a una misma clave).
- **Combiner:** Función de optimización que ejecuta una pre-agregación local en el nodo Map antes del "shuffle". Solo es aplicable si la función Reduce es asociativa y conmutativa.
- **Skew (Sesgo):** Variación significativa en el tiempo de ejecución de diferentes tareas Reduce debido a desequilibrios en el tamaño de las listas de valores asociadas a ciertas claves.
- **Reducer:** Aplicación de la función Reduce a una única clave y su lista de valores asociada. Un "Reduce Task" puede ejecutar múltiples "reducers".

## 4. Principios, reglas y heurísticas
- **Principio de localidad y replicación:** En un DFS, los chunks deben replicarse en nodos de diferentes racks para evitar la pérdida total de datos ante un fallo de rack (fallo de red o switch).
- **Idoneidad de DFS:** Un DFS solo es adecuado para archivos muy grandes y que rara vez se actualizan "in-place". No es apropiado para sistemas transaccionales de alta frecuencia (ej. reservas de aerolíneas).
- **Tolerancia a fallos mediante reinicio:** Ante el fallo de un nodo Worker, las tareas se reinician. Si el fallo es de un Map Worker, incluso las tareas completadas deben re-ejecutarse porque su salida intermedia (en disco local) se perdió.
- **Uso de Combiners:** Se debe implementar un Combiner si y solo si la operación de reducción es **asociativa y conmutativa** (ej. suma, conteo, max). Esto reduce drásticamente la comunicación entre nodos.
- **Gestión del Skew:**
    - No es óptimo tener una tarea Reduce por cada clave (overhead de tareas).
    - No es óptimo tener muy pocas tareas Reduce (subutilización del paralelismo).
    - **Regla:** Usar más tareas Reduce que nodos de cómputo disponibles permite que tareas cortas se encadenen en un mismo nodo, mitigando el impacto de tareas largas ("stragglers").

## 5. Procedimientos, métodos y workflows
### Workflow de ejecución de MapReduce
1.  **Inicialización:** El programa usuario hace "fork" de un proceso Master y múltiples procesos Worker.
2.  **Asignación Map:** El Master asigna tareas Map a Workers (típicamente una por chunk de entrada).
3.  **Fase Map:** Los Workers leen chunks, ejecutan la función Map definida por el usuario y generan pares clave-valor. Se escriben archivos intermedios en disco local.
4.  **Shuffle/Grouping:**
    *   El Master notifica a los Reduce Workers sobre la ubicación de los archivos intermedios.
    *   Los pares clave-valor se agrupan por clave. Se usa una función hash para asignar claves a Reduce Tasks específicas.
5.  **Fase Reduce:** Los Reduce Workers leen los archivos intermedios, ordenan por clave y aplican la función Reduce a cada lista de valores.
6.  **Salida:** El resultado se escribe en el DFS.

### Procedimiento de recuperación de fallos
- **Fallo de Map Worker:** El Master detecta el fallo (ping). Marca las tareas de ese worker como "idle". Las tareas completadas se reprograman en otro worker (porque la salida intermedia se perdió). Se notifica a los Reduce Workers del cambio de ubicación.
- **Fallo de Reduce Worker:** El Master marca sus tareas actuales como "idle" y las reprograma en otro worker disponible. No es necesario rehacer tareas completadas porque la salida va al DFS global.
- **Fallo del Master:** El trabajo entero se aborta y debe reiniciarse (punto único de fallo en este modelo).

## 6. Problemas comunes y soluciones
- **Pérdida de datos por fallo de disco/nodo:**
    *   *Problema:* En clusters masivos, los fallos de hardware son la norma.
    *   *Solución:* Replicación de chunks (ej. 3 réplicas) en DFS.
- **Cuello de botella de red (Communication Cost):**
    *   *Problema:* El "shuffle" transmite todos los pares clave-valor por la red.
    *   *Solución:* Uso de Combiners para agregar localmente antes de transmitir.
- **Explosión de archivos intermedios:**
    *   *Problema:* Si hay $R$ tareas Reduce y $M$ tareas Map, se crean $M \times R$ archivos intermedios.
    *   *Solución:* Limitar el número de tareas Reduce ($R$) para mantener manejable la cantidad de archivos.
- **Skew (Desequilibrio de carga):**
    *   *Problema:* Algunas claves tienen listas de valores mucho más largas, haciendo que un reducer tarde mucho más que otros.
    *   *Solución:* Usar un número de tareas Reduce mayor que el número de nodos de cómputo para permitir promediar la carga y encadenar tareas cortas.

## 7. Implementación técnica y generación de código

```pseudocode
# Algoritmo: Word Count (Ejemplo 2.1 y 2.2 del libro)

# Función Map (Ejecutada por cada Map Task)
# Entrada: Un documento o conjunto de documentos
Map(doc):
    for word in doc:
        emit(word, 1)

# Función Reduce (Ejecutada por cada Reduce Task)
# Entrada: Una clave (word) y una lista de valores [1, 1, 1, ...]
Reduce(word, list_of_values):
    sum = 0
    for value in list_of_values:
        sum += value
    emit(word, sum)

# Función Combiner (Opcional, Sección 2.2.4)
# Entrada: Salida intermedia de un Map Task local
Combiner(word, list_of_values):
    sum = 0
    for value in list_of_values:
        sum += value
    emit(word, sum)
```

```python
# Implementación conceptual en Python (simulando el flujo MapReduce)
# Nota: En la práctica real se usaría Hadoop (Java) o PySpark/MrJob

def mapper(document_content):
    """Simula una tarea Map: tokeniza y emite pares (palabra, 1)."""
    output = []
    for word in document_content.split():
        output.append((word, 1))
    return output

def reducer(key, values):
    """Simula un reducer: suma todos los valores para una clave."""
    return (key, sum(values))

def combiner(key, values):
    """Optimización local antes del shuffle."""
    return (key, sum(values))

# Simulación de flujo simple
docs = ["hola mundo", "hola data science", "mundo mundo"]
# Fase Map
intermediate_data = []
for doc in docs:
    intermediate_data.extend(mapper(doc))

# Fase Shuffle (Agrupación simulada)
grouped_data = {}
for key, value in intermediate_data:
    if key not in grouped_data:
        grouped_data[key] = []
    grouped_data[key].append(value)

# Fase Reduce
final_result = []
for key, values in grouped_data.items():
    final_result.append(reducer(key, values))

# Resultado esperado: [('hola', 2), ('mundo', 3), ('data', 1), ('science', 1)]
```

## 8. Funciones, métodos, librerías o comandos identificados
- **GFS (Google File System):** Sistema de archivos distribuido propietario de Google, pionero en la clase.
- **HDFS (Hadoop Distributed File System):** Implementación open-source de DFS, parte del ecosistema Apache Hadoop.
- **Colossus:** Evolución de GFS diseñada para servicio de archivos en tiempo real.
- **Map Function:** Función de usuario que toma un elemento de entrada y produce cero o más pares clave-valor.
- **Reduce Function:** Función de usuario que toma una clave y una lista de valores, produciendo una lista de valores (o un valor único).
- **Hash Function:** Utilizada por el Master Controller para asignar claves a buckets (Reduce tasks).

## 9. Snippets o plantillas reutilizables
> *Sección no aplicable a este fragmento.* (El fragmento es teórico y de arquitectura; el código en la sección 7 es conceptual y no un snippet de producción listo para usar).

## 10. Casos de uso y aplicaciones
- **PageRank:** Cálculo iterativo de importancia de páginas web mediante multiplicación matriz-vector (miles de millones de dimensiones).
- **Búsqueda en redes sociales:** Operaciones sobre grafos con cientos de millones de nodos y miles de millones de aristas (ej. búsqueda de "amigos").
- **Conteo de palabras (Word Count):** Ejemplo canónico para ilustrar el paradigma.
- **Análisis de logs:** Procesamiento de grandes volúmenes de logs de servidores donde los datos se añaden (append) pero no se modifican.

## 11. Limitaciones, riesgos y precauciones
- **No apto para datos pequeños:** El overhead del sistema de archivos distribuido y la orquestación de tareas no justifica su uso en archivos pequeños.
- **No apto para actualizaciones transaccionales:** El modelo DFS asume "append-only". Sistemas como reservas de aerolíneas o carritos de compra no son adecuados para este stack nativo.
- **Punto único de fallo (Master):** Si el Master falla, todo el trabajo se pierde y debe reiniciarse. (Soluciones posteriores como YARN o ZooKeeper mitigan esto, pero no se tratan en este fragmento).
- **Dependencia del ancho de banda:** La comunicación entre racks es un cuello de botella potencial. El diseño de algoritmos debe minimizar la transferencia de datos (Communication Cost).

## 12. Relaciones con otros temas del corpus
- **PageRank (Capítulo 5):** Mencionado como caso de uso principal que motiva el desarrollo de MapReduce.
- **Grafos (Capítulo 10):** Mencionado como aplicación para redes sociales.
- **MinHash / LSH:** Técnicas que a menudo se implementan sobre MapReduce para similitud de documentos, requiriendo diseño cuidadoso de claves para evitar skew.
- **Costo de Comunicación:** El fragmento final introduce este concepto como la métrica principal para diseñar algoritmos eficientes en este entorno.

## 13. Preguntas que la skill debería poder responder
1. ¿Por qué se utiliza hardware "commodity" en lugar de supercomputadoras para Big Data según el libro?
2. ¿Cuál es la diferencia entre un "Chunk" y un "Bloque" en un sistema de archivos convencional?
3. ¿Qué condiciones debe cumplir una función Reduce para poder utilizar un Combiner?
4. ¿Cómo maneja MapReduce el fallo de un nodo que ejecutaba tareas Map completadas?
5. ¿Qué es el "Skew" en el contexto de MapReduce y qué estrategia se recomienda para mitigarlo?
6. ¿Por qué no es adecuado un DFS para un sistema de reservas de aerolíneas?
7. ¿Cuál es el rol del "Master Controller" durante la fase de agrupación (Grouping)?
8. ¿Cómo se asignan las claves a las tareas Reduce específicas?
9. ¿Qué es un "Reducer" frente a una "Reduce Task"?
10. ¿Qué implementaciones de DFS se mencionan en el texto?

## 14. Acciones que la skill debería poder recomendar o ejecutar
- **Evaluar idoneidad tecnológica:** Determinar si un problema de datos encaja en el paradigma MapReduce basándose en el tamaño de datos y frecuencia de actualización.
- **Diseño de algoritmos:** Definir las funciones Map y Reduce para un problema dado (ej. conteo de frecuencia, índice invertido).
- **Optimización de rendimiento:** Identificar oportunidades para insertar un Combiner en un flujo de trabajo existente.
- **Configuración de cluster:** Recomendar el número de tareas Reduce basándose en el número de nodos de cómputo y la presencia de Skew.
- **Troubleshooting:** Diagnosticar por qué un trabajo falló o es lento basándose en la arquitectura de racks y replicación.

## 15. Activos finales de conocimiento en formato compacto

| Concepto | Descripción | Referencia |
| :--- | :--- | :--- |
| **DFS (Distributed File System)** | Sistema para archivos masivos (>TB), chunks grandes (64MB), replicación y rare updates. | Sec. 2.1.2 |
| **Chunk** | Unidad de almacenamiento (64MB), replicada 3 veces en racks distintos para tolerancia a fallos. | Sec. 2.1.2 |
| **Map Task** | Procesa chunks de entrada, genera pares `(clave, valor)`. Escribe salida en disco local. | Sec. 2.2.1 |
| **Reduce Task** | Recibe claves ordenadas y listas de valores. Aplica lógica de agregación. Escribe en DFS. | Sec. 2.2.3 |
| **Combiner** | Pre-agregación local en Map Workers. Requiere función Reduce asociativa y conmutativa. | Sec. 2.2.4 |
| **Master Controller** | Orquesta tareas, gestiona ubicación de archivos intermedios y detecta fallos (ping). | Sec. 2.2.5 |
| **Skew** | Desequilibrio de carga en reducers. Se mitiga con más tareas Reduce que nodos de cómputo. | Sec. 2.2.4 (Box) |
| **Fallo de Map Worker** | Requiere re-ejecutar tareas completadas (salida perdida en disco local). | Sec. 2.2.6 |
| **Fallo de Reduce Worker** | Solo requiere re-ejecutar tareas en curso (salida persistente en DFS). | Sec. 2.2.6 |
| **Cluster Architecture** | Nodos en racks conectados por switches. Ancho de banda inter-rack es recurso crítico. | Sec. 2.1.1 |
