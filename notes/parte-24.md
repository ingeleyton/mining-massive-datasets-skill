# parte-24 — Mining-of-Massive-Datasets-Third-Edition-Jure-Leskovec-Anand-Rajaraman-etc-z-library-sk-1lib-sk-z-lib-parte-24.pdf

## 1. Metadatos del documento
- **Libro:** Mining of Massive Datasets, 3ª ed.
- **Fragmento/Parte:** Chapter 7.1 - Introduction to Clustering Techniques & 7.2 - Hierarchical Clustering
- **Temas principales:** Clustering, Medidas de distancia, Maldición de la dimensionalidad, Clustering jerárquico, Centroide vs Clustroide, Complejidad algorítmica.
- **Tipo de contenido:** Teoría / Algoritmo

## 2. Resumen técnico de alto valor
El fragmento establece los fundamentos del clustering, distinguiendo entre espacios Euclidianos (donde existe el promedio vectorial o centroide) y no Euclidianos (donde se requiere el concepto de "clustroide"). Se introduce la "maldición de la dimensionalidad", demostrando matemáticamente que en espacios de alta dimensión, las distancias entre puntos aleatorios tienden a ser casi idénticas y los vectores tienden a la ortogonalidad, dificultando la distinción de clústeres. Se detalla el algoritmo de clustering jerárquico (aglomerativo), analizando su complejidad computacional ($O(n^2 \log n)$ optimizado) y sus variantes para definir distancia entre clústeres (mínima, máxima, promedio, radio, diámetro). Se enfatiza la inaplicabilidad del centroide en espacios no Euclidianos, proponiendo métodos de selección de clustroides basados en la minimización de sumas o máximos de distancias dentro del clúster.

## 3. Conceptos y definiciones clave
- **Clustering**: Proceso de agrupar una colección de "puntos" en "clústeres" según una medida de distancia, buscando pequeña distancia intra-clúster y gran distancia inter-clúster.
- **Espacio Euclidiano**: Espacio donde los puntos son vectores de números reales. Permite el uso de distancias como la Euclidiana, Manhattan y $L_\infty$. Permite calcular el **centroide** (promedio de los puntos).
- **Espacio No Euclidiano**: Espacios donde no tiene sentido calcular un promedio de puntos (ej. cadenas de texto). Se usan distancias como Jaccard, Coseno, Hamming o Edición. Se utiliza el **clustroide** en lugar del centroide.
- **Medida de distancia**: Función $d(x,y)$ que cumple: no negatividad ($d(x,y) \ge 0$), identidad de indiscernibles ($d(x,y)=0 \iff x=y$), simetría ($d(x,y)=d(y,x)$) y desigualdad triangular ($d(x,y) \le d(x,z) + d(z,y)$).
- **Maldición de la dimensionalidad**: Fenómeno en espacios de alta dimensión donde la distribución de distancias entre pares de puntos aleatorios se concentra alrededor del valor medio, haciendo que "cercanía" y "lejanía" pierdan significado. Además, el ángulo entre vectores aleatorios tiende a 90 grados.
- **Clustering Jerárquico (Agglomerative)**: Estrategia "bottom-up" donde cada punto inicia como su propio clúster y se fusionan iterativamente los clústeres más cercanos.
- **Centroide**: Punto medio de un clúster en espacio Euclidiano. Representación promedio del grupo.
- **Clustroide**: Punto representativo de un clúster en espacio No Euclidiano. Es un miembro existente del clúster elegido por su cercanía a los demás (ej. minimiza la suma de distancias a los otros puntos).
- **Radio de un clúster**: Máxima distancia entre el centroide/clustroide y cualquier punto del clúster.
- **Diámetro de un clúster**: Máxima distancia entre cualquier par de puntos del clúster.

## 4. Principios, reglas y heurísticas
- **Regla de selección de estrategia**: Si el espacio es Euclidiano, usar centroide; si es No Euclidiano, usar clustroide.
- **Regla de fusión (Euclidiano)**: Fusionar los dos clústeres cuyos centroides tengan la menor distancia Euclidiana.
- **Regla de fusión (No Euclidiano)**: Fusionar clústeres basándose en la distancia entre sus clustroides o promedios de distancias entre pares.
- **Criterio de parada 1 (Conocimiento del dominio)**: Detenerse cuando se alcanza un número $k$ de clústeres conocido a priori.
- **Criterio de parada 2 (Umbral de compacidad)**: Detenerse si la fusión resulta en un clúster con radio o diámetro mayor a un umbral.
- **Criterio de parada 3 (Salto en diámetro)**: Detenerse si el diámetro promedio de los clústeres actuales da un "salto" repentino, indicando una fusión antinatural.
- **Heurística de alta dimensión**: En espacios de alta dimensión, la distancia entre puntos aleatorios $A$ y $C$, dadas distancias $d(A,B)=d_1$ y $d(B,C)=d_2$, se aproxima a $\sqrt{d_1^2 + d_2^2}$ (debido a la ortogonalidad de los vectores).

## 5. Procedimientos, métodos y workflows

### Algoritmo de Clustering Jerárquico (Euclidiano)
1.  **Inicialización**: Cada punto es un clúster. Calcular todas las distancias pairwise $O(n^2)$.
2.  **Iteración**:
    *   Encontrar el par de clústeres más cercanos (usando distancia entre centroides).
    *   Fusionar ambos clústeres en uno nuevo.
    *   Recalcular el centroide del nuevo clúster.
    *   Actualizar distancias.
3.  **Parada**: Aplicar criterio de parada (k clústeres, umbral de diámetro, etc.).

### Selección de Clustroide (Espacio No Euclidiano)
Dado un conjunto de puntos, seleccionar el punto $p$ que minimice alguna de las siguientes métricas respecto al resto del clúster:
1.  Suma de distancias: $\sum_{q \in C} d(p, q)$.
2.  Máxima distancia: $\max_{q \in C} d(p, q)$.
3.  Suma de cuadrados de distancias: $\sum_{q \in C} d(p, q)^2$.

### Optimización de Eficiencia (Priority Queue)
1.  Calcular distancias iniciales y almacenar en una cola de prioridad (min-heap). Costo: $O(n^2)$.
2.  Mientras no se cumpla criterio de parada:
    *   Extraer mínimo (par de clústeres a fusionar).
    *   Eliminar entradas obsoletas de la cola que involucren los clústeres fusionados.
    *   Calcular distancias del nuevo clúster a los restantes.
    *   Insertar nuevas distancias en la cola.

## 6. Problemas comunes y soluciones
- **Problema**: En espacios de alta dimensión, todos los puntos parecen estar a la misma distancia, haciendo inútil el clustering.
    - **Solución/Mitigación**: El texto sugiere que si los datos no son aleatorios, aún pueden existir clústeres válidos, pero el argumento teórico advierte que será difícil distinguirlos del ruido.
- **Problema**: No existe un "promedio" en espacios no Euclidianos (ej. promedio de dos cadenas de texto).
    - **Solución**: Uso de **Clustroide**. Se elige un punto representativo real del conjunto en lugar de calcular uno sintético.
- **Problema**: Complejidad $O(n^3)$ del algoritmo jerárquico ingenuo.
    - **Solución**: Uso de colas de prioridad para reducir la complejidad a $O(n^2 \log n)$. Aún así, limitado a datasets pequeños.
- **Problema**: Determinar cuándo detener la fusión.
    - **Solución**: Monitorear el diámetro promedio. Un aumento drástico ("jump") indica que se están fusionando clústeres que deberían permanecer separados.

## 7. Implementación técnica y generación de código

```pseudocode
# Algoritmo Jerárquico Aglomerativo (Versión Euclidiana básica)
FUNCTION HierarchicalClustering(points, k):
    clusters = { {p} for each p in points } # Cada punto es un clúster
    centroids = { p: p for p in points }    # Centroide inicial es el punto mismo
    
    WHILE len(clusters) > k:
        # Encontrar par de clústeres más cercanos
        min_dist = INFINITY
        best_pair = NULL
        FOR each c1, c2 in combinations(clusters, 2):
            dist = EuclideanDistance(centroids[c1], centroids[c2])
            IF dist < min_dist:
                min_dist = dist
                best_pair = (c1, c2)
        
        # Fusionar
        new_cluster = merge(best_pair.c1, best_pair.c2)
        # Recalcular centroide
        centroids[new_cluster] = calculate_centroid(new_cluster)
        
        # Actualizar estructura
        remove(clusters, best_pair.c1)
        remove(clusters, best_pair.c2)
        add(clusters, new_cluster)
        
    RETURN clusters
```

```python
# Implementación Python: Selección de Clustroide y Distancia Mínima
import numpy as np
from itertools import combinations

def euclidean_distance(p1, p2):
    return np.sqrt(np.sum((p1 - p2) ** 2))

def get_clustroid(points, metric='sum'):
    """
    Selecciona el clustroide de un conjunto de puntos.
    metric: 'sum' (minimiza suma distancias), 'max' (minimiza max distancia), 'sum_sq'
    """
    points = np.array(points)
    n = len(points)
    if n == 0: return None
    
    best_score = float('inf')
    clustroid = None
    
    # Matriz de distancias para eficiencia simple
    dist_matrix = np.zeros((n, n))
    for i in range(n):
        for j in range(i + 1, n):
            d = euclidean_distance(points[i], points[j])
            dist_matrix[i][j] = d
            dist_matrix[j][i] = d
            
    for i in range(n):
        distances = dist_matrix[i]
        
        if metric == 'sum':
            score = np.sum(distances)
        elif metric == 'max':
            score = np.max(distances)
        elif metric == 'sum_sq':
            score = np.sum(distances ** 2)
        else:
            raise ValueError("Métrica no soportada")
            
        if score < best_score:
            best_score = score
            clustroid = points[i]
            
    return clustroid

# Ejemplo de uso basado en el texto (Espacio No Euclidiano simulado)
# Nota: En espacios no euclidianos, 'points' serían objetos y euclidean_distance cambiaría por la función d(x,y)
puntos_ejemplo = np.array([[2,2], [3,4], [5,2]]) # Cluster inferior izquierdo Fig 7.2
clustroid = get_clustroid(puntos_ejemplo, metric='sum')
print(f"Clustroide seleccionado: {clustroid}")
```

## 8. Funciones, métodos, librerías o comandos identificados
- **Distancia Euclidiana**: $\sqrt{\sum_{i=1}^d (x_i - y_i)^2}$.
- **Distancia Manhattan**: $\sum_{i=1}^d |x_i - y_i|$.
- **Distancia $L_\infty$**: $\max_i |x_i - y_i|$.
- **Priority Queue (Cola de Prioridad)**: Estructura de datos clave para optimizar el algoritmo jerárquico a $O(n^2 \log n)$.
- **Dendrograma**: Estructura de árbol resultante del clustering jerárquico completo (implícito en la sección de resultados).

## 9. Snippets o plantillas reutilizables

```python
# Snippet: Criterio de parada por salto en diámetro promedio
def should_stop_clustering(clusters_diameters, prev_avg_diameter):
    """
    Determina si detener el clustering basado en el salto repentino 
    en el diámetro promedio (Sección 7.2.3).
    """
    current_avg = np.mean(clusters_diameters)
    
    # Si el incremento es drástico comparado con la historia (heurística simple)
    # El libro sugiere que un salto grande indica mala fusión
    if prev_avg_diameter > 0 and (current_avg - prev_avg_diameter) > prev_avg_diameter:
        return True # Rollback sugerido
        
    return False
```

## 10. Casos de uso y aplicaciones
- **Biotecnología**: Agrupamiento de genomas de diferentes especies para construir árboles evolutivos. El resultado es un árbol, no un conjunto plano de grupos.
- **Clasificación de razas**: Agrupar perros por altura y peso para identificar variedades (Chihuahuas, Dachshunds, Beagles) en espacio 2D Euclidiano.
- **Procesamiento de texto**: Clustering de documentos por tema (espacio de alta dimensión, a menudo No Euclidiano o disperso).
- **Sistemas de recomendación**: Agrupar usuarios por tipo de películas preferidas.

## 11. Limitaciones, riesgos y precauciones
- **Escalabilidad**: El clustering jerárquico tiene complejidad mínima $O(n^2 \log n)$ y requerimientos de memoria $O(n^2)$ para la matriz de distancias. **No es adecuado para "Massive Datasets"** en memoria principal.
- **Alta dimensionalidad**: En dimensiones muy altas, la noción de distancia se degrada; los algoritmos basados en distancia pueden fallar al encontrar estructuras significativas si los datos son aleatorios.
- **Espacios No Euclidianos**: No se puede usar el "promedio" para resumir un clúster. Esto aumenta el costo de representación, ya que el "clustroide" es un punto real y requiere recalcular distancias a todos los puntos del clúster para su selección.

## 12. Relaciones con otros temas del corpus
- **Capítulo 3 (Finding Similar Items)**: Base para las medidas de distancia (Jaccard, Coseno, Edición) y espacios métricos.
- **Capítulo 7.3 (K-means)**: Introducido al final del fragmento como la alternativa "point-assignment" para grandes datos, asumiendo conocimiento de $k$.
- **LSH (Locality Sensitive Hashing)**: Técnica relacionada para encontrar vecinos cercanos en alta dimensión, relevante debido a la "maldición de la dimensionalidad" mencionada.

## 13. Preguntas que la skill debería poder responder
1. ¿Cuál es la diferencia fundamental entre un centroide y un clustroide y cuándo se debe usar cada uno?
2. ¿Cómo afecta la "maldición de la dimensionalidad" a la distribución de distancias en un espacio Euclidiano?
3. ¿Cuál es la complejidad temporal del clustering jerárquico optimizado y por qué no escala bien para grandes volúmenes de datos?
4. ¿Qué estrategias existen para determinar el número óptimo de clústeres en un algoritmo jerárquico?
5. ¿Por qué la distancia entre dos puntos aleatorios en alta dimensión se aproxima a la raíz cuadrada de la suma de los cuadrados de sus distancias a un tercer punto?
6. ¿Cómo se define el diámetro y el radio de un clúster en un espacio no Euclidiano?

## 14. Acciones que la skill debería poder recomendar o ejecutar
1. **Seleccionar representante de clúster**: "Si el espacio es Euclidiano, calcula el promedio vectorial. Si es no Euclidiano, itera sobre los puntos para encontrar el clustroide que minimiza la suma de distancias."
2. **Evaluar parada**: "Monitorea el diámetro promedio de los clústeres en cada paso; si detectas un incremento súbito (salto), revierte la última fusión y finaliza."
3. **Optimizar código**: "Para clustering jerártrico, implementa una cola de prioridad (heap) para almacenar las distancias entre clústeres y evitar el escaneo $O(n^2)$ en cada iteración."
4. **Validar datos**: "Advertencia: Si la dimensión del dataset es muy alta, verifica si los datos tienen estructura real o parecen aleatorios, ya que las distancias serán uniformes."

## 15. Activos finales de conocimiento en formato compacto

| Concepto | Descripción | Referencia |
| :--- | :--- | :--- |
| **Centroide** | Promedio vectorial de puntos. Solo válido en espacios Euclidianos. | Sec 7.1.2, 7.2.1 |
| **Clustroide** | Punto representativo en espacios No Euclidianos (miembro existente del set). | Sec 7.2.4 |
| **Maldición Dim.** | En alta dimensión, distancias $\to$ constante y ángulos $\to 90^\circ$. | Sec 7.1.3 |
| **Agglomerative** | Estrategia de clustering "bottom-up": fusionar pares más cercanos iterativamente. | Sec 7.2.1 |
| **Complejidad** | Jerárquico: $O(n^3)$ ingenuo, $O(n^2 \log n)$ con cola de prioridad. | Sec 7.2.2 |
| **Criterio Parada** | k fijo, umbral de diámetro/radio, o salto repentino en métrica de calidad. | Sec 7.2.3 |
| **Distancia Inter-Cl.** | Opciones: Min (single-link), Max (complete-link), Promedio, Centroide. | Sec 7.2.3 |
| **Diámetro** | Máxima distancia entre cualquier par de puntos dentro del clúster. | Sec 7.2.3 |
| **Radio** | Máxima distancia del centroide/clustroide a cualquier punto del clúster. | Sec 7.2.3 |
| **Distancia $L_\infty$** | Máxima diferencia absoluta en cualquier dimensión (Chebyshev). | Sec 7.1.1 |
