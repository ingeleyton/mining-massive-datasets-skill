# Parte 04 - Spark, Pregel, and Distributed Workflows

## 1. Metadatos del documento
- **Libro:** Mining of Massive Datasets, 3ª ed.
- **Fragmento/Parte:** Parte 04 - Spark, Pregel, and Distributed Workflows
- **Temas principales:** Sistemas de Workflow, Apache Spark, RDDs, TensorFlow, Pregel, Computación Recursiva, Bulk-Synchronous Parallel, Tolerancia a fallos
- **Tipo de contenido:** Teoría / Algoritmo / Implementación / Mixto

## 2. Resumen técnico de alto valor
El fragmento aborda las limitaciones del modelo de dos pasos de MapReduce y presenta las extensiones diseñadas para computations complejas: los **sistemas de workflow** (flujos de trabajo acíclicos) y los sistemas recursivos. Se detalla **Apache Spark** como un sistema de workflow avanzado que introduce la abstracción **RDD** (Resilient Distributed Dataset), optimizando la ejecución mediante **evaluación perezosa** (lazy evaluation) y recuperando fallos mediante el **linaje** (lineage) en lugar de replicación de datos, lo que evita la escritura a disco de resultados intermedios. Se contrasta esto con **TensorFlow**, orientado a ML mediante tensores, y **Pregel**, un sistema **bulk-synchronous** para grafos que maneja la recursión y los fallos mediante *checkpointing* y supersteps. Se introduce el modelo de coste de comunicación como métrica crítica para algoritmos distribuidos.

## 3. Conceptos y definiciones clave
- **Workflow System:** Sistema que extiende MapReduce permitiendo grafos acíclicos de funciones, donde los arcos representan flujo de datos (archivos) entre funciones.
- **Resilient Distributed Dataset (RDD):** Abstracción central de Spark; colección distribuida de objetos tipados. Se distingue por ser 'resiliente' (recuperable vía linaje) y 'distribuida' (particionada en nodos).
- **Transformación (Spark):** Operación que toma un RDD y produce otro RDD (ej: `Map`, `Flatmap`, `Filter`, `Join`). Son evaluadas perezosamente.
- **Acción (Spark):** Operación que toma un RDD y devuelve un valor al driver o escribe al sistema de archivos (ej: `Reduce`). Dispara la ejecución del grafo.
- **Lazy Evaluation (Evaluación Perezosa):** Estrategia donde las transformaciones no se ejecutan hasta que una acción lo requiere. Permite optimizaciones y evita almacenamiento innecesario de RDDs intermedios.
- **Lineage (Linaje):** Registro de las transformaciones aplicadas a un RDD base para reconstruirlo en caso de pérdida, sustituyendo la replicación de datos.
- **Tensor (TensorFlow):** Estructura de datos principal en TensorFlow; matriz multidimensional (0-D escalar, 1-D vector, 2-D matriz, etc.).
- **Superstep (Pregel):** Unidad de ejecución en sistemas bulk-synchronous. En cada superstep, un nodo procesa todos los mensajes recibidos y envía nuevos mensajes que se entregarán en el siguiente superstep.
- **Blocking Property:** Propiedad de tareas en workflows acíclicos donde la salida solo se entrega tras completar la tarea, permitiendo reinicio seguro de tareas fallidas sin duplicación.
- **Bulk-Synchronous:** Modelo de computación donde los nodos procesan entradas y generan salidas en bloques sincronizados (supersteps), agrupando mensajes para reducir overhead de red.

## 4. Principios, reglas y heurísticas
- **Propiedad de bloqueo y fallos:** En workflows acíclicos, si una tarea falla, puede reiniciarse sin afectar a sucesores porque no ha entregado salida. En sistemas recursivos (cíclicos), esto no aplica, requiriendo mecanismos como *checkpointing*.
- **Trade-off Spark vs. MapReduce:** Spark evita la escritura a disco de resultados intermedios y replicación, ganando velocidad a costa de una recuperación de fallos potencialmente más compleja (recomputación vía linaje).
- **Agrupación de mensajes (Pregel):** Enviar mensajes en bloque al final de un superstep es órdenes de magnitud más eficiente que enviar mensajes individuales inmediatos debido al overhead de red.
- **Checkpointing óptimo:** En Pregel, el intervalo entre checkpoints debe equilibrar el coste de realizar el checkpoint y el tiempo esperado de recomputación ante fallos.
- **Transformaciones vs Acciones:** Usar transformaciones para construir la lógica del pipeline y acciones solo para disparar resultados o escritura.

## 5. Procedimientos, métodos y workflows

### Algoritmo de Cierre Transitivo Recursivo (Ejemplo 2.12)
Implementación mediante tareas recursivas (Join tasks y Dup-elim tasks).
**Precondiciones:** Grafo dirigido con arcos $E(X, Y)$.
**Pasos:**
1.  **Inicialización:** Distribuir tuplas $E(a, b)$ como $P(a, b)$ iniciales a tareas Dup-elim.
2.  **Join Tasks ($n$ tareas):**
    *   Reciben $P(a, b)$.
    *   Si $h(a) = i$ (hash del nodo), buscan tuplas $P(x, a)$ previas y generan $P(x, b)$.
    *   Si $h(b) = i$, buscan tuplas $P(b, y)$ y generan $P(a, y)$.
    *   Envían salidas a Dup-elim tasks.
3.  **Dup-elim Tasks ($m$ tareas):**
    *   Reciben tuplas $P(c, d)$.
    *   Eliminan duplicados (si ya existe, ignorar).
    *   Si es nueva, almacenan y envían a las Join tasks correspondientes ($h(c)$ y $h(d)$).
4.  **Iteración:** El controlador maestro sincroniza rondas hasta la convergencia.

### Ejecución de programa Spark (Ejemplo 2.9)
1.  Definir RDD base (ej: desde HDFS).
2.  Aplicar transformaciones sucesivas (`Flatmap`, `Filter`). No se ejecutan aún.
3.  Llamar a una Acción (`Reduce`, `save`).
4.  **Disparador:** Spark evalúa el linaje, aplica transformaciones en paralelo en los nodos donde residen los datos (data locality) y descarta RDDs intermedios tras su uso local.

## 6. Problemas comunes y soluciones
- **Problema:** Fallo de nodo en sistemas recursivos (no hay propiedad de bloqueo).
    *   **Solución (Pregel):** Checkpointing periódico del estado completo. Reinicio desde el último checkpoint válido.
    *   **Solución (Spark):** Linaje para recomputar particiones perdidas (solo viable si el linaje no es excesivamente largo).
- **Problema:** Overhead de comunicación en algoritmos iterativos de grafos.
    *   **Solución:** Modelo Bulk-Synchronous (Pregel) para empaquetar mensajes y enviarlos en bloque una vez por superstep.
- **Problema:** Duplicación de resultados en tareas reiniciadas.
    *   **Solución:** En workflows acíclicos, la propiedad de bloqueo lo impide. En recursivos, usar tareas específicas de eliminación de duplicados (`Dup-elim` tasks) o asegurar idempotencia (ej: el cierre transitivo tolera redescubrir caminos, pero una agregación como `count` no).

## 7. Implementación técnica y generación de código

```pseudocode
# Algoritmo 2.12: Cierre Transitivo Recursivo (Organización de Tareas)
# Basado en la descripción del texto para Join y Dup-elim tasks

FUNCTION JoinTask(input_tuple P(a,b), local_storage):
    STORE P(a,b) IN local_storage
    IF hash(a) == current_task_id THEN
        FOR each tuple P(x, a) IN local_storage:
            OUTPUT P(x, b)
    IF hash(b) == current_task_id THEN
        FOR each tuple P(b, y) IN local_storage:
            OUTPUT P(a, y)

FUNCTION DupElimTask(input_tuple P(c,d), local_storage):
    IF P(c,d) NOT IN local_storage THEN
        STORE P(c,d)
        SEND P(c,d) TO JoinTask(hash(c))
        SEND P(c,d) TO JoinTask(hash(d))
    ELSE
        IGNORE tuple
```

```python
# Implementación Python (PySpark) del Ejemplo 2.7 y 2.8
# Word Count con eliminación de Stop Words usando FlatMap y Filter

from pyspark.sql import SparkSession

# Inicialización (conceptual, no explícita en el libro pero necesaria para el contexto)
spark = SparkSession.builder.appName("MMDS_Example").getOrCreate()
sc = spark.sparkContext

# Definición de datos simulados (RDD R0)
# En el libro: "input RDD is a file of documents"
documents = ["hello world", "hello spark", "world of massive data"]
r0 = sc.parallelize(documents)

# Stop words list (Ejemplo 2.8)
stop_words = {"the", "and", "of"} # 'of' está en los datos de ejemplo

# Paso 1: FlatMap (Ejemplo 2.7)
# "turns words of a document into (w,1) pairs"
# Nota: Spark Map produce 1 objeto, FlatMap produce lista de objetos
def tokenize(text):
    return [(word, 1) for word in text.split()]

r1 = r0.flatMap(tokenize)

# Paso 2: Filter (Ejemplo 2.8)
# "eliminates pairs whose first component is a stop word"
def is_not_stop_word(pair):
    word, count = pair
    return word not in stop_words

r2 = r1.filter(is_not_stop_word)

# Paso 3: Acción - Reduce (Sección "Reduce")
# "applies repeatedly to each pair... reducing them to a single element"
# El libro menciona que Reduce es una Acción, no una Transformación.
# Sin embargo, para un conteo distribuido típico, se usa reduceByKey (Transformación) 
# antes de una acción final o collect. 
# El texto dice: "Reduce applies to an RDD but returns a value... result will be a single integer".
# Aquí simulamos la lógica descrita de suma:

# Nota: El texto distingue 'Reduce' (acción que devuelve valor único global) 
# de operaciones como GroupByKey. Para word count distribuido real se usaría reduceByKey,
# pero seguimos la descripción del libro de 'Reduce' como acción de agregación total.
total_count = r2.reduce(lambda a, b: (a[0], a[1] + b[1])) 
# Nota: Esta implementación específica de reduce asume que el resultado intermedio 
# sigue siendo una tupla, lo cual es incómodo para el reduce estándar de Spark que 
# espera tipos compatibles. Una implementación más idiomática a la teoría del libro 
# (sumar los 1s) sería:

def sum_counts(a, b):
    return a + b

# Extraemos solo los conteos para el ejemplo del libro sobre Reduce
counts = r2.map(lambda x: x[1]).reduce(sum_counts)
print(f"Total word count (excluding stop words): {counts}")
```

## 8. Funciones, métodos, librerías o comandos identificados
- **Spark Transformations:**
    - `Map`: Aplica función a cada elemento, produce exactamente un objeto de salida.
    - `Flatmap`: Aplica función a cada elemento, produce 0 o más objetos (analógico a Map de MapReduce).
    - `Filter`: Toma un predicado, retorna RDD solo con elementos que cumplen la condición.
    - `Join`: Toma dos RDDs clave-valor, produce `(k, (v1, v2))` para claves coincidentes.
    - `GroupByKey`: Agrupa valores por clave, produce `(k, [v1, v2...])`.
- **Spark Actions:**
    - `Reduce`: Toma función asociativa, combina elementos del RDD en un único valor resultado.
- **TensorFlow:**
    - `tensorflow.matmul(A, B)`: Multiplicación de matrices (tensores).
- **Pregel Concepts:**
    - `Superstep`: Unidad de ejecución sincronizada.
    - `Checkpoint`: Mecanismo de recuperación.

## 9. Snippets o plantillas reutilizables

**Patrón de diseño Spark para ETL con Logging (basado en teoría de Lazy Evaluation):**
```python
# Patrón: Definición de linaje sin ejecución
raw_data = sc.textFile("hdfs://...")
clean_data = raw_data.filter(lambda x: x is not None)
transformed_data = clean_data.map(lambda x: process(x))

# Punto de disparo (Action)
# Aquí es cuando realmente se ejecutan filter y map en los nodos
result = transformed_data.count()
```

**Patrón Pregel (Pseudocódigo conceptual para grafos):**
```python
# Bucle de Supersteps
while not converged:
    # Fase de Procesamiento Local
    for node in nodes:
        process_messages(node.inbox)
        node.outbox = generate_messages()
    
    # Fase de Entrega (Bulk Synchronous)
    deliver_messages_to_next_superstep()
    if failure_detected:
        restore_from_last_checkpoint()
        break
```

## 10. Casos de uso y aplicaciones
- **Spark (Word Count):** Procesamiento de texto, conteo de frecuencias, eliminación de ruido (stop words).
- **Spark (Joins):** Operaciones relacionales sobre datasets masivos representados como RDDs.
- **TensorFlow (ML):** Construcción de modelos mediante descenso de gradiente, operaciones de álgebra lineal sobre tensores.
- **Pregel (Grafos):** Cálculo de caminos más cortos (Ejemplo 2.13), Cierre transitivo (Ejemplo 2.12), PageRank (mencionado como caso de recursión).
- **Iterative MapReduce (HaLoop):** Algoritmos que requieren múltiples pasadas sobre los mismos datos.

## 11. Limitaciones, riesgos y precauciones
- **Spark Lineage:** Si el linaje es muy largo (muchas transformaciones), la recomputación ante fallo puede ser costosa. Se recomienda *checkpointing* manual de RDDs en pipelines largos.
- **Recursión y Bloqueo:** Los algoritmos recursivos no pueden usar la propiedad de bloqueo simple para recuperarse de fallos; requieren arquitecturas específicas (Pregel) o tolerancia a duplicados.
- **Comunicación en Grafos:** En algoritmos de grafos distribuidos, enviar mensajes unitarios es ineficiente; siempre usar agrupación (bulk-synchronous).
- **Tipado en Spark:** A diferencia de MapReduce (key-value fijo), Spark permite cualquier tipo, pero el programador debe asegurar la consistencia de tipos en transformaciones.

## 12. Relaciones con otros temas del corpus
- **MapReduce (Cap. 2 previo):** Base de la que parten los workflows. Spark se presenta como una evolución eficiente.
- **PageRank (Cap. 5):** Mencionado explícitamente como ejemplo de algoritmo recursivo implementable en estos sistemas.
- **Descenso de Gradiente (Caps. 9 y 12):** Mencionado como aplicación clave de TensorFlow y recursión.
- **MinHash / LSH (Cap. 3):** Posibles candidatos para implementarse como workflows Spark sobre datos masivos.
- **Sistemas de Archivos Distribuidos (DFS):** Infraestructura subyacente necesaria para todos estos sistemas.

## 13. Preguntas que la skill debería poder responder
1. ¿Cuál es la diferencia fundamental entre una transformación y una acción en Spark?
2. ¿Cómo maneja Spark la tolerancia a fallos sin replicar datos intermedios?
3. ¿Por qué el modelo de ejecución de Pregel se considera "bulk-synchronous" y qué ventaja ofrece?
4. ¿Qué problema presenta la propiedad de bloqueo en algoritmos recursivos y cómo lo soluciona Pregel?
5. ¿En qué se diferencia `FlatMap` de Spark respecto al `Map` de MapReduce tradicional?
6. ¿Qué es un tensor en el contexto de TensorFlow y qué dimensionalidades maneja?
7. ¿Cómo optimiza Spark la localidad de datos (data locality) gracias a la evaluación perezosa?
8. ¿Qué es el linaje (lineage) de un RDD?
9. ¿Cómo se implementa una operación de Join relacional en Spark?
10. ¿Cuál es el trade-off entre velocidad de ejecución y recuperación de fallos en Spark comparado con sistemas que materializan resultados intermedios?

## 14. Acciones que la skill debería poder recomendar o ejecutar
- **Elegir motor de procesamiento:** Recomendar Spark sobre MapReduce para pipelines iterativos o de múltiples pasos.
- **Optimizar código Spark:** Identificar uso indebido de `Map` donde corresponde `FlatMap` (ej: tokenización).
- **Gestionar fallos:** Sugerir implementar checkpointing manual en Spark si el linaje excede un umbral de complejidad.
- **Diseñar algoritmos de grafos:** Estructurar la solución usando el modelo de supersteps y mensajes agrupados (estilo Pregel) en lugar de requests individuales.
- **Depuración:** Explicar por qué un código Spark no ejecuta nada hasta encontrar una acción (debugging de lazy evaluation).

## 15. Activos finales de conocimiento en formato compacto

| Concepto | Descripción | Referencia |
| :--- | :--- | :--- |
| **RDD** | Colección distribuida inmutable, base de Spark, recuperable vía linaje. | Sec 2.4.2 |
| **Lazy Evaluation** | Retraso de ejecución hasta una acción; optimiza recursos y localidad. | Sec 2.4.3 |
| **Lineage** | Grafo de transformaciones para reconstruir RDDs perdidos sin replicación. | Sec 2.4.3 |
| **FlatMap** | Transformación Spark que emite 0+ objetos por entrada (vs 1 de Map). | Sec 2.4.2 |
| **Superstep** | Unidad atómica de cómputo en Pregel; procesa inputs y envía outputs en bloque. | Sec 2.4.6 |
| **Tensor** | Array multidimensional (escalar a N-D), estructura base de TensorFlow. | Sec 2.4.4 |
| **Blocking Property** | Garantía de no entrega de salida hasta completar tarea; clave para recuperación en DAGs. | Sec 2.4.1 |
| **Checkpointing** | Guardado periódico de estado global para recuperación en sistemas recursivos. | Sec 2.4.6 |
| **Workflow System** | Generalización de MapReduce: grafo acíclico de funciones conectadas por archivos. | Sec 2.4.1 |
| **Dup-elim Task** | Tarea específica para eliminación de duplicados en algoritmos recursivos distribuidos. | Sec 2.4.5 |


