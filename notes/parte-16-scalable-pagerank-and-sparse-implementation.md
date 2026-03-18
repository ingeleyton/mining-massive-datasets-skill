# Parte 16 - Scalable PageRank and Sparse Implementation

## 1. Metadatos del documento
- **Libro:** Mining of Massive Datasets, 3ª ed.
- **Fragmento/Parte:** Parte 16 - Scalable PageRank and Sparse Implementation
- **Temas principales:** PageRank, Matrices de Transición Dispersas, MapReduce, Optimización de Memoria, Thrashing, Block-Stripe Partitioning.
- **Tipo de contenido:** Algoritmo / Implementación / Teoría.

## 2. Resumen técnico de alto valor
El fragmento aborda la escalabilidad del algoritmo PageRank para grafos masivos (ej. la Web), donde la matriz de transición $M$ es extremadamente dispersa. Se detalla cómo comprimir $M$ almacenando solo el grado de salida y la lista de sucesores por columna, reduciendo el espacio por entrada no nula a ~4 bytes. Se presenta una implementación en MapReduce que resuelve el problema del *thrashing* (intercambio excesivo de memoria a disco) mediante el particionamiento de la matriz en $k^2$ bloques cuadrados en lugar de franjas verticales simples. Esta estrategia permite que las tareas Map mantengan en memoria las partes relevantes de los vectores $v$ y $v'$, consolidando resultados parciales antes del paso Reduce. Finalmente, se introduce la motivación para el PageRank Sensible a Tópicos como solución a la ambigüedad de consultas mediante la personalización de vectores de ranking.

## 3. Conceptos y definiciones clave
- **Matriz de Transición ($M$):** Matriz estocástica por columnas que representa la probabilidad de transición entre nodos de un grafo. Para la Web, es altamente dispersa (sparse).
- **Matriz Dispersa (Sparse Matrix):** Matriz donde la mayoría de los elementos son cero. Su almacenamiento eficiente omite los ceros.
- **Thrashing:** Degradación severa del rendimiento del sistema ocurrida cuando el sistema operativo pasa más tiempo intercambiando páginas de datos entre memoria RAM y disco que ejecutando la aplicación. Ocurre en PageRank si se intentan actualizar componentes del vector resultado que no caben en memoria.
- **Striping (Franjas):** Método de particionamiento de datos donde la matriz se divide en franjas verticales y el vector en franjas horizontales correspondientes.
- **Blocking (Bloques):** Estrategia de particionamiento donde la matriz se divide en una cuadrícula de $k \times k$ bloques cuadrados, y el vector en $k$ franjas. Permite que una tarea Map procese un bloque $M_{ij}$ con la franja $v_j$ y genere contribuciones solo para la franja $v'_i$.
- **Combiner:** Función de optimización en MapReduce que realiza agregación local en el nodo Map antes de enviar datos a la red, reduciendo la carga del Reduce.
- **Dead End:** Página sin enlaces de salida (out-links) que causa fugas de probabilidad en el cálculo estándar de PageRank.

## 4. Principios, reglas y heurísticas
- **Regla de almacenamiento para matrices dispersas:** Si la densidad de elementos no nulos es baja, almacenar solo las coordenadas y valores de los elementos no nulos es más eficiente que almacenar la matriz completa.
- **Regla de compresión para Matrices de Transición Web:** Dado que los valores no nulos en una columna son iguales a $1/\text{out-degree}$, no es necesario almacenar el valor. Basta con almacenar el grado de salida y la lista de filas (destinos).
- **Regla de particionamiento para evitar Thrashing:** Si el vector resultado $v'$ no cabe en memoria, no se debe usar una estrategia que requiera acceso aleatorio a $v'$ para sumar términos. Usar particionamiento por bloques ($k^2$) asegura que cada tarea Map solo afecte a una porción de $v'$ que cabe en memoria.
- **Trade-off de espacio en bloques:** La representación por bloques puede requerir hasta el doble de espacio que la representación por franjas, debido a la repetición del grado de salida en cada bloque donde el nodo tiene sucesores.
- **Cálculo de iteración:** La fórmula de actualización es $v' = \beta M v + (1-\beta)e/n$.

## 5. Procedimientos, métodos y workflows

### Procedimiento: Representación eficiente de Matriz de Transición
1.  **Entrada:** Grafo dirigido $G$.
2.  **Para cada nodo (página) $j$:**
    a. Identificar sucesores (out-links).
    b. Calcular grado de salida $d_j$.
    c. Almacenar: `[ID Nodo j, Grado $d_j$, Lista de IDs de sucesores]`.
3.  **Salida:** Estructura de datos que permite reconstruir la columna $j$ de $M$ con valores $1/d_j$ en las filas de los sucesores.

### Procedimiento: Iteración PageRank con MapReduce (Método de Bloques)
1.  **Precondición:** Matriz $M$ dividida en $k^2$ bloques $M_{ij}$. Vector $v$ dividido en $k$ franjas $v_j$.
2.  **Configuración:** Se crean $k^2$ tareas Map (o $k$ tareas si se agrupan filas de bloques).
3.  **Fase Map (para cada tarea manejando $M_{ij}$ y $v_j$):**
    a. Cargar en memoria la franja del vector de entrada $v_j$.
    b. Cargar en memoria el bloque $M_{ij}$.
    c. Inicializar en memoria la franja del vector resultado $v'_i$ (inicialmente ceros).
    d. Para cada columna en $M_{ij}$, multiplicar por el valor correspondiente de $v_j$ y sumar acumulativamente a la posición correcta en $v'_i$.
    e. Aplicar factor de amortiguamiento $\beta$ y sumar $(1-\beta)/n$ si corresponde en esta etapa.
    f. Emitir la franja $v'_i$ (parcial o total).
4.  **Fase Reduce:**
    a. Recibir franjas $v'_i$ completas (si se usaron $k$ tareas Map agrupadas) o parciales para sumar.
    b. Concatenar/Sumar para formar el vector $v'$ completo.
5.  **Postcondición:** Nuevo vector $v'$ calculado con una pasada sobre $M$ y $k$ pasadas sobre $v$.

## 6. Problemas comunes y soluciones
- **Problema:** Representar la matriz de transición de la Web explícitamente es imposible por tamaño cuadrático ($n^2$).
    - **Solución:** Representación dispersa implícita (grado + lista de sucesores).
- **Problema:** Thrashing al usar Combiners o actualización in-place en una sola máquina con vector $v'$ grande.
    - **Solución:** Particionar matriz en bloques cuadrados $M_{ij}$. Cada bloque contribuye solo a una sub-parte $v'_i$ del resultado, la cual cabe en memoria principal durante el procesamiento de ese bloque.
- **Problema:** Ambigüedad en consultas de búsqueda (ej. "jaguar").
    - **Solución:** PageRank Sensible a Tópicos (Topic-Sensitive PageRank), usando vectores de teletransportación específicos por tema.

## 7. Implementación técnica y generación de código

```pseudocode
# Algoritmo: Representación Compacta de Columna para Matriz de Transición
# Entrada: Lista de aristas (src, dest)
# Salida: Estructura Columna: {ID_Nodo: [Grado, [Lista_Destinos]]}

Para cada nodo src en el grafo:
    destinos = ObtenerSucesores(src)
    grado = Longitud(destinos)
    Almacenar(src, grado, destinos)

# Algoritmo: Multiplicación Matriz-Vector con Bloques (Lógica Map)
# Entrada: Bloque M_ij, Franja Vector v_j
# Salida: Contribuciones a la Franja Vector v'_i

Inicializar vector_temporal v'_i de tamaño tamaño_franja con ceros
Para cada columna col en M_ij:
    grado = col.grado
    sucesores = col.destinos
    valor_v = v_j[col.id]
    Si valor_v > 0:
        contribucion = valor_v / grado
        Para cada fila_idx en sucesores:
            v'_i[fila_idx] += contribucion
Retornar v'_i
```

```python
# Implementación Python: Estructura de datos y paso de iteración simple
import numpy as np

class SparseTransitionMatrix:
    """
    Representación eficiente de la matriz de transición M.
    Almacena por columnas: grado y lista de filas (destinos).
    """
    def __init__(self, graph_edges, num_nodes):
        self.num_nodes = num_nodes
        # Diccionario: id_nodo -> [out_degree, [destino1, destino2, ...]]
        self.columns = {}
        
        # Construcción a partir de lista de aristas (src, dest)
        # Asumimos nodos 0 a num_nodes-1
        from collections import defaultdict
        adj_list = defaultdict(list)
        degrees = defaultdict(int)
        
        for src, dest in graph_edges:
            adj_list[src].append(dest)
            degrees[src] += 1
            
        for src in range(num_nodes):
            dests = adj_list.get(src, [])
            deg = degrees.get(src, 0)
            self.columns[src] = (deg, dests)

    def multiply_vector(self, v):
        """
        Realiza la operación v' = M * v
        """
        v_prime = np.zeros(self.num_nodes)
        for col_idx, (deg, dests) in self.columns.items():
            if deg > 0 and v[col_idx] != 0:
                contribution = v[col_idx] / deg
                for row_idx in dests:
                    v_prime[row_idx] += contribution
        return v_prime

def pagerank_iteration(M, v, beta, n):
    """
    Ejecuta un paso de la iteración de PageRank.
    v' = beta * M * v + (1 - beta) * e / n
    """
    v_prime = M.multiply_vector(v)
    # Aplicar factor de amortiguamiento y vector de teletransportación
    v_prime = beta * v_prime + (1 - beta) / n
    return v_prime

# Ejemplo de uso basado en el libro (Figura 5.1 / 5.11)
# Nodos: A=0, B=1, C=2, D=3
# Enlaces: A->B,C,D; B->A,D; C->A; D->B,C
edges = [(0, 1), (0, 2), (0, 3), (1, 0), (1, 3), (2, 0), (3, 1), (3, 2)]
n_nodes = 4
M = SparseTransitionMatrix(edges, n_nodes)

# Vector inicial uniforme
v = np.full(n_nodes, 1/n_nodes)

# Una iteración
v_next = pagerank_iteration(M, v, 0.85, n_nodes)
print("Vector PageRank siguiente:", v_next)
```

## 8. Funciones, métodos, librerías o comandos identificados
- **Estructura de datos `Columna`:** Tupla o registro `(Grado, ListaDestinos)`. Usada para representar columnas dispersas de la matriz de transición.
- **Operación `Multiply(Block, Stripe)`:** Función central en la optimización de MapReduce. Multiplica un bloque de la matriz por una franja del vector.
- **Parámetro `k`:** Factor de particionamiento. Determina el número de bloques ($k^2$) y el tamaño de las franjas ($1/k$ del vector).

## 9. Snippets o plantillas reutilizables

```python
# Plantilla para particionar una matriz dispersa en bloques lógicos
# Útil para simular el algoritmo de bloque en memoria limitada o para preparar datos MapReduce

def partition_into_blocks(adjacency_list, num_nodes, k):
    """
    Divide el grafo en k^2 bloques lógicos.
    Retorna un diccionario de bloques: {(i, j): [datos_bloque]}
    """
    block_size = num_nodes // k
    blocks = defaultdict(list)
    
    for src, dests in adjacency_list.items():
        # Determinar a qué bloque de columna pertenece src
        # Bloque de columna j (0 a k-1)
        j = src // block_size
        
        for dest in dests:
            # Determinar a qué bloque de fila perteneve dest
            # Bloque de fila i (0 a k-1)
            i = dest // block_size
            
            # Guardar la arista en el bloque correspondiente
            # Formato: (src, dest)
            blocks[(i, j)].append((src, dest))
            
    return blocks
```

## 10. Casos de uso y aplicaciones
- **Motores de Búsqueda Web:** Cálculo de importancia de páginas a escala de miles de millones de nodos ($n \approx 10^{10}$).
- **Análisis de Redes Sociales:** Identificación de usuarios influyentes en grafos de seguimiento (follow graphs).
- **Sistemas de Recomendación:** Puntuación de ítems basada en estructuras de grafo bipartito (usuarios-ítems).
- **Procesamiento en Clústeres:** Optimización de trabajos MapReduce/Spark para algoritmos iterativos sobre grafos donde el vector estado no cabe en memoria de un solo nodo.

## 11. Limitaciones, riesgos y precauciones
- **Sobrecarga de Almacenamiento:** La representación por bloques puede requerir hasta el doble de espacio que la representación por columnas completas debido a la duplicación de metadatos de grado.
- **Elección de $k$:** Un $k$ muy pequeño provoca que las franjas del vector sean grandes y no quepan en memoria. Un $k$ muy grande aumenta la complejidad de gestión de tareas y la sobrecarga de comunicación del vector $v$ (que se transmite $k$ veces).
- **Dead Ends:** El fragmento menciona ejercicios sobre "dead ends" (callejones sin salida) pero no detalla la solución computacional en esta sección específica, aunque la fórmula $v' = \beta M v + (1-\beta)e/n$ mitiga el problema de la fuga de masa ("taxation").
- **Complejidad de Pases a Disco:** En el método de un solo procesador, el vector $v$ debe leerse de disco $k$ veces por iteración.

## 12. Relaciones con otros temas del corpus
- **MapReduce (Capítulo 2):** Este fragmento aplica directamente los conceptos de Map, Reduce, Combiner y Striping definidos anteriormente en el libro.
- **PageRank Básico (Sección 5.1):** Define el problema y la teoría que esta sección implementa eficientemente.
- **Topic-Sensitive PageRank (Sección 5.3):** Extensión del modelo básico para resolver ambigüedad semántica (introducida al final del fragmento).
- **Spam y Link Spam (Sección 5.4):** Mencionado como contexto para Topic-Sensitive PageRank.

## 13. Preguntas que la skill debería poder responder
1. ¿Cómo se representa eficientemente una matriz de transición dispersa para el cálculo de PageRank?
2. ¿Por qué el método de "striping" simple puede causar *thrashing* en memoria durante la iteración de PageRank?
3. ¿En qué consiste la estrategia de particionamiento por bloques ($k^2$) para optimizar PageRank en MapReduce?
4. ¿Cuál es el trade-off de espacio al usar representación por bloques frente a representación por columnas completas?
5. ¿Cómo se calcula el costo de transmisión de datos en el algoritmo de bloques respecto al tamaño de la matriz y el vector?
6. ¿Qué es un *dead end* en el contexto de grafos web y cómo afecta la representación de la matriz?
7. ¿Cómo se implementa un Combiner en el contexto de la multiplicación matriz-vector para PageRank?
8. ¿Cuál es la fórmula de actualización del vector PageRank en una iteración incluyendo el factor de amortiguamiento $\beta$?

## 14. Acciones que la skill debería poder recomendar o ejecutar
- **Diseñar esquema de almacenamiento:** Recomendar almacenar solo grado y sucesores para matrices de transición web en lugar de matrices densas.
- **Configurar particionamiento:** Sugerir un valor de $k$ basado en el tamaño de la memoria RAM disponible y el tamaño del vector $v$.
- **Diagnosticar cuellos de botella:** Identificar *thrashing* si la implementación intenta actualizar un vector grande en memoria sin particionar.
- **Optimizar MapReduce:** Estructurar el código para usar $k^2$ tareas Map o $k$ tareas con procesamiento secuencial de bloques en fila.
- **Implementar iteración:** Escribir el bucle de iteración que aplica la fórmula $v' = \beta M v + (1-\beta)e/n$.

## 15. Activos finales de conocimiento en formato compacto

| Concepto | Descripción | Referencia |
| :--- | :--- | :--- |
| **Matriz Dispersa** | Almacenar solo entradas no nulas. Para Web, ~4 bytes por entrada (grado + destinos). | Sec 5.2.1 |
| **Thrashing** | Fallo de rendimiento por intercambio excesivo memoria-disco al actualizar vector grande. | Sec 5.2.3 |
| **Particionamiento Bloques** | Divide $M$ en $k^2$ cuadrados. Permite mantener $v'_i$ en memoria RAM durante el procesamiento del bloque. | Sec 5.2.3 |
| **Fórmula Iteración** | $v' = \beta M v + (1-\beta)e/n$. Combina transición y teletransportación. | Sec 5.2.2 |
| **Trade-off Espacio** | Representación por bloques usa hasta 2x espacio de representación por columnas (repetición de grados). | Sec 5.2.4 |
| **Costo Transmisión** | Vector $v$ se transmite $k$ veces; Matriz $M$ se transmite 1 vez. Óptimo para $M \gg v$. | Sec 5.2.5 |
| **Topic-Sensitive PR** | Variante para desambiguación; usa vectores de teletransportación sesgados por tema. | Sec 5.3.1 |
| **Combiner Use** | Pre-agrega términos $m_{ij}v_j$ en el Map task, reduciendo datos enviados al Reduce. | Sec 5.2.3 |


