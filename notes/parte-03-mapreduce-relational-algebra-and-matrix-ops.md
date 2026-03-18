# Parte 03 - MapReduce Relational Algebra and Matrix Ops

## 1. Metadatos del documento
- **Libro:** Mining of Massive Datasets, 3ª ed.
- **Fragmento/Parte:** Parte 03 - MapReduce Relational Algebra and Matrix Ops
- **Temas principales:** Tolerancia a fallos en MapReduce, Álgebra Relacional distribuida, Multiplicación Matriz-Vector, Multiplicación Matriz-Matriz, Extensiones de MapReduce.
- **Tipo de contenido:** Teoría / Algoritmo / Implementación

## 2. Resumen técnico de alto valor
El fragmento aborda la resiliencia del paradigma MapReduce, detallando la gestión de fallos del nodo Maestro (fallo crítico que requiere reinicio) versus los nodos Worker (gestionados mediante reasignación de tareas y re-ejecución de Map tasks debido a la localidad de datos). Posteriormente, se profundiza en la implementación de operaciones del álgebra relacional (Selección, Proyección, Unión, Intersección, Diferencia, Join, Agregación) bajo el modelo MapReduce, destacando el uso de claves para agrupación y la eliminación de duplicados en la fase Reduce. Se presenta el algoritmo de multiplicación Matriz-Vector, distinguiendo escenarios donde el vector cabe en memoria versus la estrategia de "stripes" (franjas) para vectores grandes. Finalmente, se detalla la multiplicación Matriz-Matriz mediante dos enfoques: una cascada de dos trabajos MapReduce (óptimo para eficiencia) y un enfoque de un solo paso (con limitaciones de memoria), introduciendo brevemente sistemas de flujo de trabajo como Spark y Pregel.

## 3. Conceptos y definiciones clave
- **Tolerancia a fallos (Node Failures):** Mecanismo donde el Maestro monitoriza Workers. Si un Map Worker falla, sus tareas completadas se re-ejecutan porque su salida (intermedia) se perdía con el nodo; si un Reduce Worker falla, solo se reinician sus tareas actuales.
- **Álgebra Relacional:** Conjunto de operaciones matemáticas sobre relaciones (tablas). Incluye Selección ($\sigma$), Proyección ($\pi$), Unión, Intersección, Diferencia, Join Natural ($\bowtie$) y Agregación ($\gamma$).
- **Relación:** Tabla con atributos (columnas) y tuplas (filas). En el contexto de Big Data, se almacena como archivos en un DFS.
- **Multiplicación Matriz-Vector:** Operación $x_i = \sum_{j=1}^n m_{ij} v_j$. Requiere estrategias especiales si el vector $v$ no cabe en memoria (stripes).
- **Striping (Franjas):** Técnica de particionado para multiplicación matriz-vector donde la matriz se divide en franjas verticales y el vector en franjas horizontales correspondientes, permitiendo que cada tarea Map procese una porción del vector que cabe en memoria.
- **Matriz Dispersa (Sparse Matrix):** Matriz donde la mayoría de elementos son cero. Se representa eficientemente como tuplas $(i, j, m_{ij})$ omitiendo los ceros.
- **Workflow Systems:** Sistemas que extienden MapReduce permitiendo grafos acíclicos de funciones (ej. Spark, TensorFlow), a diferencia del modelo estricto Map->Reduce.

## 4. Principios, reglas y heurísticas
- **Regla de re-ejecución de Map Tasks:** Ante el fallo de un nodo Worker de Map, todas sus tareas asignadas (incluso las completadas) deben reiniciarse, ya que la salida intermedia se almacenaba localmente en ese nodo y ahora es inaccesible para los Reducers.
- **Regla de re-ejecución de Reduce Tasks:** Ante el fallo de un nodo Worker de Reduce, solo las tareas actualmente en ejecución se marcan como *idle* y se reprograman; las completadas ya escribieron su salida al DFS global.
- **Idoneidad de MapReduce:** No usar MapReduce para actualizaciones frecuentes o consultas transaccionales pequeñas (ej. ventas online). Usar para análisis masivos de datos estáticos (ej. cálculo de PageRank, analítica de patrones de compra).
- **Optimización de Proyección:** La eliminación de duplicados en la proyección ($\pi$) puede optimizarse usando un *Combiner* en la fase Map para reducir la carga de red hacia el Reduce, aunque el Reduce sigue siendo necesario para garantizar unicidad global.
- **Eficiencia en Multiplicación Matriz-Matriz:** Se prefieren dos pasos de MapReduce sobre uno solo para multiplicación de matrices, debido a la gestión de memoria y la distribución de carga (detallado en referencia a Sección 2.6.7).

## 5. Procedimientos, métodos y workflows

### 5.1 Gestión de Fallos
1.  **Fallo de Map Worker:** El Maestro detecta fallo (ping). Marca tareas como *idle*. Reasigna tareas a nuevos Workers. Informa a Reduce Workers del cambio de ubicación de entrada.
2.  **Fallo de Reduce Worker:** El Maestro detecta fallo. Marca tareas en ejecución como *idle*. Se reprograman en otro Worker.

### 5.2 Multiplicación Matriz-Vector ($M \times v$)
**Caso A: Vector $v$ cabe en memoria**
1.  **Map:** Lee $v$ en memoria. Por cada elemento $m_{ij}$, emite $(i, m_{ij} \times v_j)$.
2.  **Reduce:** Suma todos los valores para la clave $i$. Resultado: $(i, x_i)$.

**Caso B: Vector $v$ NO cabe en memoria (Striping)**
1.  **Particionado:** Dividir $M$ en $k$ franjas verticales. Dividir $v$ en $k$ franjas horizontales.
2.  **Map:** Cada tarea recibe una franja de $M$ y la franja correspondiente de $v$ (que ahora sí cabe en memoria). Procesa igual que el Caso A.

### 5.3 Operaciones del Álgebra Relacional en MapReduce

**Selección $\sigma_C(R)$**
1.  **Map:** Por cada tupla $t$, si satisface $C$, emite $(t, t)$.
2.  **Reduce:** Identidad (pasa la tupla tal cual).

**Proyección $\pi_S(R)$**
1.  **Map:** Por cada tupla $t$, extraer atributos $S$ formando $t'$. Emitir $(t', t')$.
2.  **Reduce:** Recibe lista de duplicados. Emite un único $(t', t')$ (eliminación de duplicados).

**Unión $R \cup S$**
1.  **Map:** Por cada tupla $t$ (de $R$ o $S$), emitir $(t, t)$.
2.  **Reduce:** Emitir $(t, t)$ (asegura unicidad).

**Intersección $R \cap S$**
1.  **Map:** Por cada tupla $t$, emitir $(t, t)$.
2.  **Reduce:** Si la lista de valores tiene dos elementos (provenientes de $R$ y $S$), emitir $(t, t)$. Si no, ignorar.

**Diferencia $R - S$**
1.  **Map:** Si $t \in R$, emitir $(t, R)$. Si $t \in S$, emitir $(t, S)$.
2.  **Reduce:** Si la lista de valores es $[R]$ (solo está en $R$), emitir $(t, t)$. Si contiene $S$, ignorar.

**Natural Join $R(A,B) \bowtie S(B,C)$**
1.  **Map:** Si tupla $(a,b) \in R$, emitir clave $b$, valor $(R, a)$. Si tupla $(b,c) \in S$, emitir clave $b$, valor $(S, c)$.
2.  **Reduce:** Por cada clave $b$, cruzar todos los valores de $R$ con los de $S$. Emitir $(a, b, c)$ por cada combinación.

**Agregación $\gamma_{A, \theta(B)}(R)$**
1.  **Map:** Emitir clave $a$ (atributo agrupación), valor $b$ (atributo a agregar).
2.  **Reduce:** Aplicar función $\theta$ (SUM, MAX, etc.) a la lista de valores $b$. Emitir $(a, resultado)$.

### 5.4 Multiplicación Matriz-Matriz ($M \times N$) en un paso
1.  **Map:** Por cada $m_{ij}$, emitir claves $(i, k)$ para todo $k$ columnas de $N$, valor $(M, j, m_{ij})$. Por cada $n_{jk}$, emitir claves $(i, k)$ para todo $i$ filas de $M$, valor $(N, j, n_{jk})$.
2.  **Reduce:** Para clave $(i, k)$, ordenar valores por $j$. Emparejar elementos $M$ y $N$ con mismo $j$, multiplicar y sumar.

## 6. Problemas comunes y soluciones
- **Problema:** Sesgo (Skew) en tiempos de procesamiento de Reducers.
    - *Contexto:* Ejercicio 2.2.1 sugiere que sin combiners o con pocos reducers, el sesgo puede ser significativo.
    - *Solución implícita:* Uso de combiners y particionado adecuado.
- **Problema:** Vector demasiado grande para memoria en Multiplicación Matriz-Vector.
    - *Solución:* Algoritmo de "Striping" (franjas) para particionar el vector en segmentos que quepan en memoria.
- **Problema:** Fallo del nodo Maestro.
    - *Solución:* Reiniciar todo el trabajo MapReduce (punto único de fallo en la arquitectura descrita).
- **Problema:** Memoria insuficiente en Reduce para multiplicación de matrices en un paso.
    - *Solución:* Si las filas/columnas son muy grandes, se requiere ordenamiento externo. Se sugiere que el enfoque de dos pasos es generalmente superior.

## 7. Implementación técnica y generación de código

### Algoritmo: Natural Join ($R \bowtie S$)

```pseudocode
# Map Function
Input: Tuple t
if t comes from R(A, B):
    key = t.B
    value = (tag='R', t.A)
else if t comes from S(B, C):
    key = t.B
    value = (tag='S', t.C)
Output: (key, value)

# Reduce Function
Input: key=b, values = list of (tag, val)
list_R = [val for (tag, val) in values if tag == 'R']
list_S = [val for (tag, val) in values if tag == 'S']
for a in list_R:
    for c in list_S:
        Output: (a, b, c)
```

```python
# Implementación Python (Simulación estilo MapReduce)
# Asume R y S como listas de diccionarios

def mapper_join(record, relation_name):
    if relation_name == 'R':
        # R(A, B)
        key = record['B']
        value = ('R', record['A'])
        return (key, value)
    elif relation_name == 'S':
        # S(B, C)
        key = record['B']
        value = ('S', record['C'])
        return (key, value)

def reducer_join(key, values):
    # values es una lista de tuplas ('R', a) o ('S', c)
    r_values = [v[1] for v in values if v[0] == 'R']
    s_values = [v[1] for v in values if v[0] == 'S']
    
    results = []
    # Producto cruzado
    for a in r_values:
        for c in s_values:
            results.append((a, key, c)) # Tupla resultante (A, B, C)
    return results
```

### Algoritmo: Multiplicación Matriz-Vector (Vector en memoria)

```pseudocode
# Map Function
Input: Matrix element m_ij, Vector v (in memory)
key = i
value = m_ij * v[j]
Output: (key, value)

# Reduce Function
Input: key=i, values = list of products
sum = 0
for val in values:
    sum += val
Output: (i, sum)
```

```python
# Implementación Python
def mapper_mat_vec(matrix_element, vector):
    # matrix_element: (i, j, value)
    i, j, m_val = matrix_element
    v_val = vector[j] # Asume vector accesible (ej. dict o lista)
    return (i, m_val * v_val)

def reducer_mat_vec(key_i, partial_products):
    total = sum(partial_products)
    return (key_i, total)
```

## 8. Funciones, métodos, librerías o comandos identificados
- **Master Node:** Entidad que gestiona la asignación de tareas y monitoreo de salud (ping).
- **Worker Node:** Ejecuta tareas Map o Reduce.
- **DFS (Distributed File System):** Almacenamiento subyacente para entrada y salida final.
- **Combiner:** Función de optimización local en nodos Map para reducir volumen de datos antes de la fase Shuffle (mencionado en contexto de Proyección y ejercicios).
- **Stripes:** Estrategia de particionado de datos para manejo de grandes vectores.

## 9. Snippets o plantillas reutilizables

**Plantilla para Operaciones de Conjunto (Diferencia $R-S$):**
```python
def mapper_difference(tuple_data, source_relation):
    # source_relation: string 'R' or 'S'
    return (tuple_data, source_relation)

def reducer_difference(key, sources):
    # Si solo aparece en R (lista exactamente ['R'])
    # Nota: manejar duplicados en R requiere lógica adicional si es bag vs set
    if sources == ['R']:
        return key
    return None
```

## 10. Casos de uso y aplicaciones
- **Cálculo de PageRank:** Mencionado como propósito original de Google MapReduce. Requiere multiplicación Matriz-Vector iterativa sobre matrices dispersas de tamaño trillones ($10^{12}$).
- **Análisis de Grafos Web:** Encontrar caminos de longitud 2 mediante Self-Join de la relación *Links*.
- **Redes Sociales:** Conteo de amigos por usuario mediante Agregación ($\gamma$) sobre la relación *Friends*.
- **Analítica Retail:** Identificar patrones de compra similares entre usuarios (Amazon example), distinguiendo entre transacciones OLTP (no MapReduce) y analítica OLAP (MapReduce).

## 11. Limitaciones, riesgos y precauciones
- **Fallo del Master:** Punto único de fallo que aborta todo el trabajo.
- **Sesgo de Datos (Skew):** En Joins o agregaciones, ciertas claves pueden dominar el tiempo de ejecución (ej. URLs populares).
- **Memoria en Reduce:** El enfoque de un solo paso para multiplicación de matrices puede fallar si una fila/columna completa no cabe en memoria para el ordenamiento.
- **Actualizaciones:** MapReduce no es adecuado para datos que cambian frecuentemente "in-place".

## 12. Relaciones con otros temas del corpus
- **PageRank (Capítulo 5):** Dependencia directa. El algoritmo de Matriz-Vector aquí descrito es el núcleo computacional de PageRank.
- **Sistemas de Archivos Distribuidos (Sección 2.1):** Requisito previo para entender dónde residen los datos antes/después del trabajo MapReduce.
- **Spark / Pregel (Sección 2.4):** Evolución del modelo MapReduce para flujos de trabajo cíclicos o iterativos (como PageRank) y grafos, respectivamente.

## 13. Preguntas que la skill debería poder responder
1.  ¿Por qué es necesario re-ejecutar tareas Map completadas cuando falla su nodo Worker, pero no las tareas Reduce completadas?
2.  ¿Cómo se implementa la operación de Proyección ($\pi$) en MapReduce para garantizar la eliminación de duplicados?
3.  ¿Qué estrategia se utiliza para multiplicar una matriz por un vector cuando el vector no cabe en la memoria principal de un nodo?
4.  ¿Cuál es la diferencia en la función Map entre calcular la Unión y la Intersección de dos relaciones?
5.  ¿Cómo se traduce una operación de Natural Join a funciones Map y Reduce?
6.  ¿Por qué MapReduce no es adecuado para gestionar transacciones de ventas en tiempo real (ej. Amazon)?
7.  ¿Cuál es la complejidad o el riesgo de intentar multiplicar matrices en un solo paso MapReduce?
8.  ¿Cómo se representa una matriz dispersa en el contexto de MapReduce para optimizar el almacenamiento?

## 14. Acciones que la skill debería poder recomendar o ejecutar
- **Diagnóstico de fallos:** Si un trabajo falla parcialmente, verificar si el fallo ocurrió en el Master (requiere reinicio total) o en Workers (gestión automática).
- **Diseño de algoritmos:** Proponer la estructura de funciones Map/Reduce para consultas SQL traducidas a álgebra relacional.
- **Optimización de memoria:** Recomendar el uso de "Striping" para operaciones vectoriales con datos masivos.
- **Selección de herramienta:** Distinguir cuándo usar MapReduce (batch) vs Sistemas de flujo de trabajo (iterativo) vs Bases de datos transaccionales.

## 15. Activos finales de conocimiento en formato compacto

| Concepto | Descripción | Referencia |
| :--- | :--- | :--- |
| **Fallo Map Worker** | Requiere re-ejecutar tareas completadas (salida local perdida). | Sec 2.2.6 |
| **Fallo Reduce Worker** | Solo reinicia tareas en curso (salida en DFS). | Sec 2.2.6 |
| **Selección $\sigma$** | Map filtra; Reduce es identidad. | Sec 2.3.4 |
| **Proyección $\pi$** | Map extrae campos; Reduce elimina duplicados. | Sec 2.3.5 |
| **Join Natural** | Map usa atributo común como clave; Reduce hace producto cruzado de valores. | Sec 2.3.7 |
| **Matriz-Vector (Grande)** | Usar particionado en franjas (stripes) verticales/horizontales. | Sec 2.3.2 |
| **Matriz-Matriz 1 Paso** | Map genera claves $(i,k)$; Reduce ordena por $j$ y suma productos. Riesgo: memoria. | Sec 2.3.10 |
| **Agregación $\gamma$** | Map agrupa por clave; Reduce aplica SUM/MAX/MIN. | Sec 2.3.8 |
| **Diferencia $R-S$** | Reduce emite tupla solo si la lista de fuentes es $[R]$. | Sec 2.3.6 |
| **Workflow Systems** | Extienden MapReduce para grafos acíclicos (Spark) o modelos de grafos (Pregel). | Sec 2.4 |


