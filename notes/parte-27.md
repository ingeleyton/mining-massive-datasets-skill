# parte-27 — Mining-of-Massive-Datasets-Third-Edition-Jure-Leskovec-Anand-Rajaraman-etc-z-library-sk-1lib-sk-z-lib-parte-27.pdf

## 1. Metadatos del documento
- **Libro:** Mining of Massive Datasets, 3ª ed.
- **Fragmento/Parte:** Chapter 7.5.5 - 7.8 (Clustering for Streams and Parallelism, Summary)
- **Temas principales:** Clustering en streams, Algoritmo BDMO, MapReduce para clustering, Algoritmo GRGPF, K-Means en flujos de datos, Ventanas deslizantes.
- **Tipo de contenido:** Mixto (Teoría / Algoritmo / Implementación)

## 2. Resumen técnico de alto valor
El fragmento aborda estrategias de clustering para datos masivos que exceden la memoria principal o que se generan en tiempo real (streams). Se detalla el **Algoritmo BDMO** (adaptación de DGIM para clustering), que utiliza una estructura de buckets basada en potencias de dos para mantener resúmenes de clusters dentro de una ventana deslizante. Se presenta la lógica de fusión de buckets y clusters, diferenciando entre espacios Euclidianos (uso de centroides y promedios ponderados) y no Euclidianos (uso de clustroids y rowsums, inspirado en GRGPF). Adicionalmente, se describe una arquitectura **MapReduce** para clustering estático masivo, donde los nodos Map realizan clustering local y un único nodo Reduce fusiona los resultados globales. Se incluye una discusión sobre la estimación de parámetros (radio, suma de distancias) durante la fusión para mantener la coherencia estadística sin almacenar los puntos originales.

## 3. Conceptos y definiciones clave
- **Clustroid:** Punto representativo de un cluster en espacios no Euclidianos (donde no existe un "promedio" o centroide). Se selecciona como el punto que minimiza la suma de distancias al cuadrado hacia los demás puntos del cluster (rowsum) u otros criterios.
- **Rowsum:** Suma de los cuadrados de las distancias desde un punto $p$ hasta todos los demás nodos del cluster. Métrica clave para seleccionar el clustroid y estimar la coherencia del cluster.
- **Ventana Deslizante (Sliding Window):** Modelo de procesamiento de streams donde las consultas se realizan sobre los últimos $N$ puntos, descartando datos antiguos.
- **Bucket (en BDMO):** Unidad de almacenamiento en streams que agrupa un número de puntos que es potencia de 2. Contiene el timestamp del punto más reciente, el tamaño y una representación comprimida de los clusters (centroides/clustroids y conteos).
- **Algoritmo BDMO:** Algoritmo de clustering para streams que generaliza el método DGIM, permitiendo responder consultas sobre los últimos $m$ puntos mediante la fusión de buckets.
- **Migración de Clusters:** Fenómeno en streams donde los centroides se mueven lentamente con el tiempo, requiriendo estrategias de fusión que manejen la ambigüedad en el emparejamiento de clusters entre buckets consecutivos.

## 4. Principios, reglas y heurísticas
- **Regla de tamaño de Bucket:** Los buckets deben tener tamaños que sigan una secuencia de potencias de dos (ej. $p, 2p, 4p...$). No se requiere empezar en 1, pero la secuencia debe ser geométrica.
- **Regla de fusión de Buckets:** Si existen tres buckets del mismo tamaño, se fusionan los dos más antiguos. Esto garantiza una complejidad de espacio $O(\log N)$.
- **Fusión de Centroides:** Al fusionar dos clusters $C_1$ y $C_2$ con $n_1, n_2$ puntos y centroides $c_1, c_2$, el nuevo centroide $c$ se calcula como el promedio ponderado:
  $$c = \frac{n_1 c_1 + n_2 c_2}{n_1 + n_2}$$
- **Estimación de Distancia (Cota Superior):** Para estimar la suma de distancias en un cluster fusionado sin los datos crudos, se usa la desigualdad triangular. La distancia de un punto $x$ al nuevo centroide $c$ se estima como la distancia a su viejo centroide más la distancia entre centros.
- **Heurística de emparejamiento:** Al fusionar buckets, se asume que los clusters evolucionan lentamente. Se emparejan los clusters de buckets consecutivos minimizando la distancia entre sus centroides/clustroids.
- **Paralelismo MapReduce:** Para clustering masivo, usar múltiples Mappers para clustering local y un único Reducer para la fusión global (limitación: cuello de botella en el Reducer).

## 5. Procedimientos, métodos y workflows

### Algoritmo BDMO (Stream Clustering)
1.  **Inicialización:** Cada $p$ elementos del stream (tamaño base), crear un nuevo bucket. Agrupar estos $p$ puntos en clusters (ej. K-Means) y almacenar el resumen (conteo, centroide, otros parámetros).
2.  **Mantenimiento:**
    *   Eliminar buckets con timestamp más antiguo que la ventana $N$.
    *   Si hay 3 buckets del mismo tamaño, fusionar los dos más antiguos.
3.  **Fusión de Buckets:**
    *   Combinar los clusters de dos buckets consecutivos.
    *   Encontrar el "mejor emparejamiento" entre clusters del bucket antiguo y el reciente (minimizando distancia entre representantes).
    *   Fusionar pares de clusters correspondientes calculando nuevos parámetros (centroide ponderado, estimación de radio/diámetro).
4.  **Respuesta a Consulta (Query):**
    *   Petición: clusters de los últimos $m$ puntos.
    *   Selección: Tomar el conjunto más pequeño de buckets que cubran al menos $m$ puntos (pueden cubrir hasta $2m$).
    *   Agregación: Fusionar los clusters de los buckets seleccionados y devolver el resultado.

### Clustering en Entorno Paralelo (MapReduce)
1.  **Map:** Dividir el dataset en chunks. Cada tarea Map clusteriza su subset local y emite pares `(key=1, value=descripción_cluster)`.
2.  **Reduce:** Una única tarea Reduce recibe todas las descripciones de clusters locales y las fusiona para producir el clustering global final.

## 6. Problemas comunes y soluciones
- **Problema:** Ambigüedad al fusionar clusters en streams si los centroides migran rápidamente (no está claro qué cluster del bucket $t$ corresponde al del bucket $t-1$).
  - **Solución:** Mantener más de $k$ clusters por bucket ($p > k$) y solo fusionar aquellos que resulten en clusters suficientemente coherentes, o usar estrategias jerárquicas.
- **Problema:** Estimar la "calidad" (ej. suma de distancias al centroide) de un cluster fusionado sin acceso a los puntos originales.
  - **Solución:** Usar fórmulas de estimación basadas en la desigualdad triangular (suma de distancias internas + distancias entre centroides) o suma de cuadrados (aproximación válida en altas dimensiones).
- **Problema:** Cobertura imprecisa en consultas de streams (se piden $m$ puntos pero se devuelven hasta $2m$).
  - **Solución:** Asumir que las estadísticas entre $m$ y $2m$ no varían radicalmente. Si se requiere precisión, usar esquemas de bucketing más complejos con factor $(1+\epsilon)$.

## 7. Implementación técnica y generación de código

```pseudocode
# Algoritmo: Fusión de dos buckets (Stream Clustering)
# Entrada: Bucket_A, Bucket_B (B es más reciente que A)
# Salida: Bucket_Merged

Bucket_Merged.size = Bucket_A.size + Bucket_B.size
Bucket_Merged.timestamp = Bucket_B.timestamp

# Paso 1: Encontrar mejor emparejamiento entre clusters
# Asumimos k clusters por bucket
Pares = EncontrarMejorMatching(Bucket_A.clusters, Bucket_B.clusters)

# Paso 2: Fusionar cada par
Para cada (cluster_a, cluster_b) en Pares:
    nuevo_cluster.count = cluster_a.count + cluster_b.count
    
    # Calculo de centroide combinado (Espacio Euclidiano)
    nuevo_cluster.centroid = (cluster_a.count * cluster_a.centroid + 
                              cluster_b.count * cluster_b.centroid) / nuevo_cluster.count
    
    # Estimación de suma de distancias (Opcional, para control de calidad)
    # s = suma distancias, c = centroide
    # Estimacion = n_a*dist(c_a, c_new) + n_b*dist(c_b, c_new) + s_a + s_b
    
    Bucket_Merged.add(nuevo_cluster)

Retornar Bucket_Merged
```

```python
# Implementación Python: Estructura de Bucket y Fusión de Centroides

class ClusterSummary:
    def __init__(self, count, centroid, sum_distances=0):
        self.count = count          # Número de puntos
        self.centroid = centroid    # Vector centroide (lista o np.array)
        self.sum_distances = sum_distances # Suma de distancias al centroide (para estimación)

def merge_two_clusters(c1, c2):
    """
    Fusiona dos resúmenes de clusters (Euclidiano).
    c1, c2: instancias de ClusterSummary
    """
    new_count = c1.count + c2.count
    # Promedio ponderado de centroides
    new_centroid = [(c1.count * x1 + c2.count * x2) / new_count 
                    for x1, x2 in zip(c1.centroid, c2.centroid)]
    
    # Estimación de la nueva suma de distancias (Cota superior vía desigualdad triangular)
    # Distancia entre centroides viejos y nuevo centroide
    dist_c1_new = sum((x - xc)**2 for x, xc in zip(c1.centroid, new_centroid))**0.5
    dist_c2_new = sum((x - xc)**2 for x, xc in zip(c2.centroid, new_centroid))**0.5
    
    estimated_sum_dist = (c1.sum_distances + c2.sum_distances + 
                          c1.count * dist_c1_new + 
                          c2.count * dist_c2_new)
    
    return ClusterSummary(new_count, new_centroid, estimated_sum_dist)

# Nota: En un entorno real de streams, se necesitaría una estructura de árbol 
# o lista ordenada para gestionar los buckets activos y su fusión automática.
```

## 8. Funciones, métodos, librerías o comandos identificados
- **Map Function:** Función de usuario en paradigma MapReduce; toma un subconjunto de puntos y devuelve descripciones de clusters locales.
- **Reduce Function:** Función de agregación que fusiona las descripciones de clusters provenientes de los Mappers.
- **Rowsum Calculation:** Función matemática para determinar la "centralidad" de un punto en un cluster no Euclidiano.
- **Pythagorean Theorem:** Utilizado en el algoritmo GRGPF y BDMO para estimar distancias en clusters fusionados asumiendo ángulos rectos entre rutas hacia clustroids.

## 9. Snippets o plantillas reutilizables

**Cálculo de Rowsum para un nuevo clustroid candidato:**
Si se fusionan clusters $C_1$ y $C_2$, y se quiere calcular la rowsum de un punto $p$ en $C_1$ respecto al cluster fusionado:
$$ROWSUM(p) = ROWSUM_{C_1}(p) + N_{C_2} \cdot d(p, c_2)^2 + ROWSUM(c_2)$$
*(Donde se asume la aproximación de "right angle" o Pitágoras mencionada en el texto para espacios no Euclidianos).*

## 10. Casos de uso y aplicaciones
- **Monitoreo de sensores en tiempo real:** Clustering de lecturas de sensores en una ventana de tiempo deslizante para detectar anomalías o grupos de comportamiento similar.
- **Sistemas de recomendación dinámicos:** Agrupación de usuarios en streams donde los intereses cambian con el tiempo (migración de centroides).
- **Procesamiento de logs web:** Análisis de patrones de navegación en los últimos $N$ minutos/horas usando clusters paralelos (MapReduce) o de flujo (BDMO).

## 11. Limitaciones, riesgos y precauciones
- **Complejidad en fusión no Euclidiana:** La fusión de clusters en espacios no Euclidianos requiere mantener puntos "distantes" y candidatos a clustroid, lo que aumenta la complejidad de la estructura de datos frente a la simple fusión de centroides.
- **Cuello de botella en Reduce:** La estrategia MapReduce descrita usa un único Reducer, lo que limita la escalabilidad si el número de clusters locales generados por los Mappers es masivo.
- **Precisión histórica:** El algoritmo BDMO ofrece una aproximación. La respuesta a una consulta sobre $m$ puntos puede incluir hasta $2m$ puntos, asumiendo estabilidad estadística. Si hay cambios bruscos ("concept drift") en la ventana extra, el error aumenta.
- **Maldición de la dimensionalidad:** En espacios de alta dimensión, la distancia entre puntos tiende a ser similar, dificultando la distinción de clusters y la elección de clustroids representativos.

## 12. Relaciones con otros temas del corpus
- **DGIM (Counting Ones in a Stream):** El algoritmo BDMO es una generalización directa de la técnica de buckets DGIM (Sección 4.6), aplicada a estructuras de datos complejas (clusters) en lugar de conteos binarios.
- **K-Means:** Es el algoritmo base utilizado dentro de los buckets para la inicialización y fusión en espacios Euclidianos.
- **GRGPF Algorithm:** Proporciona la metodología de representación de clusters (clustroids, rowsums, puntos cercanos/lejanos) utilizada en la variante no Euclidiana de BDMO.
- **BFR Algorithm:** Otra técnica para datos masivos, pero orientada a disco (no streams), mencionada en el resumen como contraparte para datos estáticos que no caben en memoria.

## 13. Preguntas que la skill debería poder responder
1. ¿Cómo se calcula el nuevo centroide al fusionar dos clusters en un entorno de stream Euclidiano?
2. ¿Qué es un clustroid y cuándo se utiliza en lugar de un centroide?
3. ¿Cómo maneja el algoritmo BDMO la ventana deslizante para descartar datos antiguos?
4. ¿Cuál es el procedimiento para fusionar buckets cuando se alcanza el límite de 3 buckets del mismo tamaño?
5. ¿Cómo se estima la suma de distancias de un cluster fusionado si no se guardan los puntos originales?
6. ¿Por qué se utiliza un único Reducer en el enfoque MapReduce para clustering y cuál es su limitación?
7. ¿Qué estrategias existen para manejar la migración rápida de centroides en streams?
8. ¿Qué información mínima debe almacenarse en un bucket para permitir la fusión de clusters?

## 14. Acciones que la skill debería poder recomendar o ejecutar
- **Seleccionar representación:** "Si el espacio es Euclidiano, usar centroides y promedios ponderados. Si es no Euclidiano, implementar lógica de clustroids y rowsums."
- **Configurar BDMO:** "Definir el parámetro $p$ (tamaño base del bucket) como múltiplo de $k$ para asegurar suficiente granularidad en la inicialización."
- **Implementar fusión:** "Aplicar la fórmula de promedio ponderado para fusionar centroides y la estimación basada en desigualdad triangular para actualizar métricas de dispersión."
- **Diseñar Query:** "Para responder a una consulta de los últimos $m$ puntos, seleccionar buckets desde el más reciente hacia atrás hasta cubrir $m$, y fusionar sus resúmenes."

## 15. Activos finales de conocimiento en formato compacto

| Concepto | Descripción | Referencia |
| :--- | :--- | :--- |
| **BDMO** | Algoritmo de clustering en streams con ventana deslizante usando buckets de tamaño exponencial. | Sec 7.6.2 |
| **Fusión de Centroides** | Promedio ponderado: $c = \frac{n_1 c_1 + n_2 c_2}{n_1 + n_2}$. | Sec 7.6.4 |
| **Clustroid** | Punto representativo en espacio no Euclidiano (minimiza rowsum). | Sec 7.5 / 7.6.4 |
| **Bucket Structure** | Tamaño (potencia de 2), Timestamp, Resumen de Clusters (count, centroid/roid). | Sec 7.6.2 |
| **MapReduce Clustering** | Map: clustering local. Reduce: fusión global (cuello de botella). | Sec 7.6.6 |
| **Estimación Rowsum** | Usa Pitágoras/Desigualdad Triangular para estimar distancias en clusters fusionados. | Sec 7.5 / 7.6.4 |
| **Query Approximation** | Consulta $m$ puntos devuelve representación de hasta $2m$ puntos. | Sec 7.6.5 |
| **Migración** | Cambio lento de centroides en el tiempo; justifica emparejar clusters de buckets adyacentes. | Sec 7.6.1 |
