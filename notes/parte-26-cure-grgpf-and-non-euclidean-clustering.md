# Parte 26 - CURE, GRGPF, and Non-Euclidean Clustering

## 1. Metadatos del documento
- **Libro:** Mining of Massive Datasets, 3ª ed.
- **Fragmento/Parte:** Parte 26 - CURE, GRGPF, and Non-Euclidean Clustering
- **Temas principales:** Clustering CURE, Clustering en espacios no Euclidianos, Algoritmo GRGPF, Clustroides, Puntos representativos, Distancia Mahalanobis, Estructuras de datos jerárquicas.
- **Tipo de contenido:** Teoría / Algoritmo

## 2. Resumen técnico de alto valor
El fragmento aborda técnicas avanzadas de clustering para grandes volúmenes de datos que superan las limitaciones de los métodos basados puramente en centroides o suposiciones de normalidad. Se presenta **CURE** (Clustering Using REpresentatives), diseñado para espacios Euclidianos con clusters de formas arbitrarias (no esféricas, ej: anillos), utilizando múltiples puntos representativos movidos hacia el centroide para capturar la geometría del cluster. Posteriormente, se detalla **GRGPF**, un algoritmo híbrido jerárquico/de asignación puntual para espacios no Euclidianos donde no existe un "centroide" promedio. GRGPF utiliza la noción de **clustroide** (punto que minimiza la suma de distancias cuadradas) y organiza los clusters en una estructura de árbol similar a un B-tree/R-tree, permitiendo la inserción eficiente de puntos y la gestión de clusters en disco mediante estimaciones basadas en la "maldición de la dimensionalidad" (asunción de ángulos rectos). Se incluye una breve introducción a clustering en flujos de datos (streams) y paralelismo.

## 3. Conceptos y definiciones clave
- **CURE (Clustering Using REpresentatives):** Algoritmo de clustering que representa cada cluster mediante un conjunto de puntos representativos dispersos (en lugar de un solo centroide), permitiendo detectar formas no esféricas en espacios Euclidianos.
- **Punto Representativo:** En CURE, puntos seleccionados de un cluster que están lo más alejados posible entre sí y luego se mueven una fracción fija (ej. 20%) hacia el centroide del cluster.
- **Clustroide:** En espacios no Euclidianos, el punto del cluster que minimiza la suma de las distancias cuadradas a los demás puntos del cluster ($ROWSUM(p)$). Es el análogo al centroide cuando no se puede calcular una media.
- **ROWSUM(p):** Suma de los cuadrados de las distancias desde el punto $p$ hasta cada uno de los otros puntos en el cluster.
- **GRGPF Algorithm:** Algoritmo de clustering para espacios no Euclidianos y grandes datos. Combina jerarquía y asignación puntual, usando una estructura de árbol para almacenar resúmenes de clusters (features) en memoria.
- **Radio del Cluster (definición GRGPF):** Raíz cuadrada del promedio del cuadrado de las distancias desde el clustroide: $\sqrt{ROWSUM(c)/N}$.
- **Maldición de la dimensionalidad (aplicación en GRGPF):** Asumpción de que en espacios de alta dimensión, los ángulos entre vectores tienden a ser rectos ($90^\circ$), lo que permite usar el teorema de Pitágoras para estimar distancias sin acceder a todos los datos en disco.

## 4. Principios, reglas y heurísticas
- **Regla de selección de representantes (CURE):** Seleccionar puntos lo más alejados posible entre sí para capturar la forma del cluster.
- **Regla de contracción (CURE):** Mover los puntos representativos una fracción fija (sugerencia: 20%) hacia el centroide para mitigar el efecto de outliers y ruido en la forma del cluster.
- **Regla de fusión (CURE):** Fusionar dos clusters si tienen un par de puntos representativos (uno de cada cluster) suficientemente cercanos.
- **Heurística de estimación de ROWSUM (GRGPF):** Para estimar $ROWSUM(p)$ sin leer todo el cluster, usar $ROWSUM(p) = ROWSUM(c) + N \cdot d^2(p, c)$, asumiendo ángulos rectos entre $p \to c \to q$.
- **Umbral de división (GRGPF):** Si el radio del cluster supera un límite, dividir el cluster en dos.
- **Umbral de fusión (GRGPF):** Si el árbol de clusters crece demasiado para la memoria principal, aumentar el límite de radio permitido y fusionar clusters cercanos.

## 5. Procedimientos, métodos y workflows

### Algoritmo CURE (Inicialización y Ejecución)
1.  **Muestreo:** Tomar una muestra pequeña de datos y agruparla en memoria (preferiblemente con clustering jerárquico).
2.  **Selección de Representantes:** En cada cluster resultante, seleccionar $k$ puntos representativos lo más alejados posible entre sí.
3.  **Contracción:** Mover cada representante una fracción fija (ej. 20%) de la distancia hacia el centroide de su cluster.
4.  **Fusión Iterativa:** Mientras existan pares de clusters con representantes cercanos: fusionarlos y recalcular representantes.
5.  **Asignación:** Asignar cada punto del dataset (en disco) al cluster del representante más cercano.

### Algoritmo GRGPF (Inserción de Puntos)
1.  **Travesía del Árbol:** Comenzar en la raíz. Descender al hijo cuyo clustroide muestral esté más cerca del nuevo punto $p$.
2.  **Llegada a Hoja:** Al llegar a una hoja, seleccionar el cluster cuyo clustroide $c$ esté más cerca de $p$.
3.  **Actualización de Features:**
    *   Incrementar $N$ en 1.
    *   Actualizar $ROWSUM(q)$ para el clustroide y los puntos cercanos/lejanos almacenados: añadir $d^2(p, q)$.
    *   Estimar $ROWSUM(p)$ si $p$ se convierte en un punto cercano/lejano.
4.  **Verificación de Clustroide:** Si $ROWSUM(p) < ROWSUM(c)$ o algún punto cercano reduce su rowsum por debajo del clustroide actual, actualizar el clustroide.
5.  **Gestión de Tamaño:** Si el radio excede el límite, dividir el cluster. Si el árbol excede la memoria, fusionar clusters.

## 6. Problemas comunes y soluciones
- **Problema:** K-means y BFR asumen clusters esféricos o distribuciones normales, fallando en formas anidadas (ej. círculo dentro de un anillo).
    - **Solución (CURE):** Usar múltiples puntos representativos que definen la "forma" del cluster, permitiendo distinguir el anillo del círculo interno.
- **Problema:** En espacios no Euclidianos no se puede calcular un centroide (promedio de puntos no definido).
    - **Solución (GRGPF):** Usar el **clustroide**, que es un punto real del dataset que minimiza las distancias cuadradas.
- **Problema:** Calcular $ROWSUM$ exacto para un nuevo punto requiere acceder a todos los puntos del cluster en disco (costoso).
    - **Solución:** Usar la fórmula de estimación basada en la asunción de ortogonalidad (maldición de la dimensionalidad): $ROWSUM(p) \approx ROWSUM(c) + N \cdot d^2(p,c)$.

## 7. Implementación técnica y generación de código

```pseudocode
# Algoritmo CURE: Selección y movimiento de representantes
Entrada: Cluster C, numero_de_representantes k, factor_de_contraccion alpha
Salida: Conjunto de representantes R

# Paso 1: Seleccionar k puntos dispersos
p1 = Punto aleatorio de C
R = {p1}
Mientras |R| < k:
    p_nuevo = ArgMax(distancia(p, R) para cada p en C) # Punto más lejano al conjunto actual
    Añadir p_nuevo a R

# Paso 2: Mover representantes hacia el centroide
centroide = CalcularCentroide(C) # Solo posible en espacio Euclidiano
Para cada r en R:
    r_nuevo = r + alpha * (centroide - r)
    Actualizar r en R
Retornar R
```

```python
# Implementación Python: Estimación de ROWSUM (GRGPF) y cálculo de Clustroide
import numpy as np

def calculate_rowsums(points):
    """Calcula la suma de distancias cuadradas para cada punto (candidato a clustroide)."""
    # Matriz de distancias cuadradas
    dist_matrix = np.sum((points[:, np.newaxis] - points) ** 2, axis=2)
    rowsums = np.sum(dist_matrix, axis=1)
    return rowsums

def find_clustroid(points):
    """Encuentra el clustroide (punto con menor ROWSUM)."""
    rowsums = calculate_rowsums(points)
    clustroid_idx = np.argmin(rowsums)
    return points[clustroid_idx], rowsums[clustroid_idx]

def estimate_rowsum_new_point(clustroid_rowsum, N, dist_p_clustroid):
    """
    Estima el ROWSUM de un nuevo punto p basado en la asunción de 
    maldición de la dimensionalidad (ángulos rectos).
    Ecuación: ROWSUM(p) = ROWSUM(c) + N * d^2(p, c)
    """
    return clustroid_rowsum + N * (dist_p_clustroid ** 2)

# Ejemplo de uso
data = np.array([[1, 2], [1.5, 1.8], [5, 8], [8, 8], [1, 0.6], [9, 11]])
c, c_rowsum = find_clustroid(data)
print(f"Clustroide: {c}, ROWSUM: {c_rowsum}")

# Estimar rowsum para un punto nuevo
new_p = np.array([2, 2])
dist = np.linalg.norm(new_p - c)
est_rowsum = estimate_rowsum_new_point(c_rowsum, len(data), dist)
print(f"ROWSUM estimado para {new_p}: {est_rowsum}")
```

## 8. Funciones, métodos, librerías o comandos identificados
- **ROWSUM(p):** Función métrica clave en GRGPF. Suma de cuadrados de distancias.
- **Clustroid:** Función de selección. ArgMin(ROWSUM(p)).
- **Mahalanobis Distance:** Mencionada en ejercicios previos (Sección 7.3). Distancia normalizada por la desviación estándar del cluster.
- **B-tree / R-tree:** Estructuras de datos análogas usadas para organizar el árbol de clusters en GRGPF.

## 9. Snippets o plantillas reutilizables

```python
# Snippet: Lógica de actualización de features en GRGPF al insertar punto p
def update_cluster_features_grgpf(cluster_features, new_point):
    # cluster_features dict: {'N': int, 'clustroid': vec, 'rowsum_c': float, ...}
    
    c = cluster_features['clustroid']
    N = cluster_features['N']
    
    # 1. Calcular distancia al clustroide
    d_sq = distance_sq(new_point, c) # Función de distancia definida por el usuario
    
    # 2. Actualizar N
    cluster_features['N'] = N + 1
    
    # 3. Actualizar ROWSUM del clustroide
    cluster_features['rowsum_c'] += d_sq
    
    # 4. Estimar ROWSUM del nuevo punto (para ver si entra en los k-cercanos/lejanos)
    # Nota: Se usa N antiguo en la fórmula del libro, aquí simplificado
    estimated_rowsum_p = cluster_features['rowsum_c'] + (N + 1) * d_sq 
    
    # Lógica para decidir si el nuevo punto es parte de la representación
    # (k cercanos o k lejanos) o si se convierte en el nuevo clustroide...
    # [Implementación detallada requeriría mantener listas ordenadas]
    
    return cluster_features
```

## 10. Casos de uso y aplicaciones
- **Sistemas Solares (Astronomía):** Diferenciar entre planetas interiores (círculo) y el cinturón de Kuiper (anillo exterior) como dos clusters distintos, donde K-means fallaría al tener el mismo centroide.
- **Anillos de Saturno:** Decidir si múltiples anillos estrechos se consideran un solo objeto o clusters separados basándose en la distancia entre puntos representativos.
- **Datos Categóricos / No Euclidianos:** Clustering de documentos o secuencias genéticas donde la media no tiene sentido (GRGPF).

## 11. Limitaciones, riesgos y precauciones
- **CURE:** Requiere espacio Euclidiano para el paso de mover puntos hacia el centroide (linealidad).
- **GRGPF:** La estimación de $ROWSUM$ depende de la asunción de alta dimensionalidad (ángulos rectos). En dimensiones bajas, la estimación puede ser inexacta.
- **Complejidad:** GRGPF requiere rebalancear el árbol (similar a B-tree) y potencialmente recomputar features periódicamente desde disco, lo cual es costoso.
- **Sensibilidad a parámetros:** En CURE, la elección de la fracción de movimiento (20%) y la distancia de fusión determinan agresivamente la granularidad del clustering.

## 12. Relaciones con otros temas del corpus
- **BFR Algorithm:** Antecesor de CURE/GRGPF en el libro. BFR asume clusters normales (Gaussianos) y usa centroides. CURE relaja la forma; GRGPF relaja el espacio métrico.
- **MinHashing / LSH:** Técnicas para encontrar candidatos a vecinos cercanos, útil para la fase de inicialización o fusión en grandes escalas.
- **MapReduce:** Mencionado en la sección 7.6 como enfoque para paralelizar el clustering.
- **Hierarchical Clustering:** Usado como paso de inicialización (bootstrapping) tanto en CURE como en GRGPF sobre muestras.

## 13. Preguntas que la skill debería poder responder
1.  ¿Cómo maneja el algoritmo CURE clusters con formas no esféricas, como anillos o lunas?
2.  ¿Qué es un clustroide y en qué se diferencia de un centroide en el contexto de GRGPF?
3.  ¿Por qué el algoritmo GRGPF asume que los ángulos son rectos al estimar el ROWSUM de un nuevo punto?
4.  ¿Cuál es el procedimiento para seleccionar los puntos representativos en CURE?
5.  ¿Cómo se actualiza la representación de un cluster en GRGPF cuando se inserta un nuevo punto?
6.  ¿Qué condiciones provocan la división o fusión de clusters en el algoritmo GRGPF?
7.  ¿Es posible aplicar CURE en un espacio no Euclidiano? ¿Por qué?
8.  ¿Cómo se calcula el radio de un cluster en GRGPF y qué significa?

## 14. Acciones que la skill debería poder recomendar o ejecutar
- **Seleccionar algoritmo:** Recomendar CURE sobre K-means/BFR si se sospecha que los clusters tienen formas anulares o elongadas.
- **Seleccionar algoritmo:** Recomendar GRGPF si el espacio de características es no Euclidiano (ej. distancia Jaccard, ediciones de texto).
- **Configurar CURE:** Ajustar el porcentaje de movimiento de representantes (ej. 20%) para controlar la sensibilidad a outliers.
- **Implementar métrica:** Calcular ROWSUM para identificar el punto más central en un dataset sin media aritmética.
- **Diagnosticar fallo:** Identificar por qué K-means fusiona dos clusters concéntricos (mismo centroide) y proponer CURE como solución.

## 15. Activos finales de conocimiento en formato compacto
| Concepto | Descripción | Referencia |
| :--- | :--- | :--- |
| **CURE** | Clustering Euclidiano usando puntos representativos móviles para formas arbitrarias. | Sec 7.4 |
| **Clustroide** | Punto real que minimiza la suma de distancias cuadradas (centroide para no-Euclidianos). | Sec 7.5.1 |
| **ROWSUM(p)** | Suma de cuadrados de distancias desde $p$ al resto de puntos; métrica de centralidad. | Sec 7.5.1 |
| **Representantes CURE** | $k$ puntos dispersos movidos $\alpha\%$ hacia el centroide para definir forma. | Sec 7.4.1 |
| **Estimación ROWSUM** | $ROWSUM(p) \approx ROWSUM(c) + N d^2(p,c)$ (asume ángulos rectos). | Sec 7.5.3 |
| **Radio GRGPF** | $\sqrt{ROWSUM(c)/N}$; umbral para decidir división de cluster. | Sec 7.5.4 |
| **Árbol GRGPF** | Estructura tipo B-tree con clustroides muestrales en nodos internos. | Sec 7.5.2 |
| **Fusión CURE** | Fusionar si distancia entre representantes $< d_{threshold}$. | Sec 7.4.2 |
| **Inicialización** | Muestreo + Clustering Jerárquico para ambos algoritmos. | Sec 7.4.1, 7.5.2 |
| **Limitación CURE** | Requiere espacio Euclidiano para mover puntos sobre una línea. | Sec 7.4.1 |


