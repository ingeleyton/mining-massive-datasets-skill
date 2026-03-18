# parte-25 — Mining-of-Massive-Datasets-Third-Edition-Jure-Leskovec-Anand-Rajaraman-etc-z-library-sk-1lib-sk-z-lib-parte-25.pdf

## 1. Metadatos del documento
- **Libro:** Mining of Massive Datasets, 3ª ed.
- **Fragmento/Parte:** Chapter 7. Clustering - Section 7.3 K-means Algorithms & Intro 7.4 CURE
- **Temas principales:** Algoritmo K-means, Inicialización de clusters, Selección de parámetro k, Algoritmo BFR, Distancia de Mahalanobis, Clustering en memoria secundaria
- **Tipo de contenido:** Mixto (Teoría / Algoritmo / Implementación)

## 2. Resumen técnico de alto valor
El fragmento aborda la familia de algoritmos de asignación de puntos, centrado en **K-means** y su extensión para grandes datos, el algoritmo **BFR** (Bradley, Fayyad, Reina). Se detalla la importancia crítica de la inicialización de centroides, proponiendo métodos como la selección de puntos maximamente distantes para evitar convergencia a mínimos locales pobres. Para la determinación del número óptimo de clusters ($k$), se describe un método basado en la detección del "codo" en la curva de diámetro promedio, optimizable mediante búsqueda binaria logarítmica.

El núcleo técnico profundo es el algoritmo **BFR**, diseñado para datos Euclidianos de alta dimensión que exceden la memoria principal. BFR asume que los clusters siguen una distribución normal con ejes alineados a los ejes del espacio. Introduce una estructura de datos sumaria ($N, SUM, SUMSQ$) que permite actualizaciones incrementales eficientes y clasifica los puntos en tres conjuntos: *Discard Set* (puntos asignados a clusters), *Compressed Set* (miniclusters de puntos cercanos no asignados) y *Retained Set* (outliers o puntos aislados). La asignación de puntos se basa en la **distancia de Mahalanobis**, que normaliza la distancia al centroide según la desviación estándar de cada dimensión.

## 3. Conceptos y definiciones clave
- **Algoritmo K-means**: Algoritmo de asignación de puntos que asume espacio Euclidiano y conocimiento previo del número de clusters $k$. Asigna puntos al centroide más cercano y actualiza dicho centroide.
- **Centroide**: Punto medio de un cluster. En K-means, puede migrar a medida que se asignan nuevos puntos.
- **Algoritmo BFR**: Variante de K-means para datos masivos en espacio Euclidiano de alta dimensión. Asume clusters con distribución normal y ejes alineados. Procesa datos en fragmentos (*chunks*) que caben en memoria.
- **Discard Set (Conjunto de descarte)**: Representación sumaria de los clusters principales. Los puntos individuales se descartan de memoria y se retienen solo sus estadísticas acumuladas ($N, SUM, SUMSQ$).
- **Compressed Set (Conjunto comprimido)**: Colección de resúmenes de *miniclusters* (puntos cercanos entre sí pero no cercanos a ningún cluster principal).
- **Retained Set (Conjunto retenido)**: Puntos que no pueden asignarse a un cluster ni agruparse en miniclusters (outliers o puntos aislados), almacenados explícitamente en memoria.
- **Distancia de Mahalanobis**: Medida de distancia entre un punto y un centroide, normalizada por la desviación estándar del cluster en cada dimensión. Permite evaluar la probabilidad de pertenencia bajo supuestos de normalidad.
- **Inicialización "puntos lejanos"**: Heurística para seleccionar centroides iniciales eligiendo iterativamente el punto más lejano a los ya seleccionados.

## 4. Principios, reglas y heurísticas
- **Inicialización de centroides**: Para evitar pobres agrupamientos locales, seleccionar puntos que estén lo más alejados posible entre sí.
- **Determinación de $k$**: Si se desconoce $k$, ejecutar K-means para valores $k=1, 2, 4, 8...$. El valor correcto se encuentra donde la medida de cohesión (ej. diámetro promedio) deja de disminuir significativamente o comienza a aumentar drásticamente al reducir $k$.
- **Eficiencia en BFR**: Utilizar representaciones sumarias ($N, SUM, SUMSQ$) en lugar de centroides y desviaciones estándar directas, ya que permiten actualizaciones aditivas simples sin recalcular sobre todo el historial de puntos.
- **Umbral de asignación en BFR**: Un punto se asigna a un cluster si su distancia de Mahalanobis es menor a un umbral (ej. 4 desviaciones estándar). Bajo distribución normal, esto implica una probabilidad de error < $10^{-6}$.
- **Supuesto de forma en BFR**: Los clusters deben ser "cigarrillos" alineados con los ejes, no rotados. Si hay rotación, BFR no es adecuado.

## 5. Procedimientos, métodos y workflows

### Algoritmo de inicialización de K-means (Puntos lejanos)
1. Seleccionar el primer punto al azar.
2. Mientras haya menos de $k$ puntos seleccionados:
   - Calcular la distancia de cada punto candidato a los puntos ya seleccionados.
   - Seleccionar el punto cuya *distancia mínima* a cualquiera de los seleccionados sea la *máxima posible*.
3. Utilizar estos puntos como centroides iniciales.

### Algoritmo BFR (Procesamiento por chunks)
**Precondición**: Datos en espacio Euclidiano, $k$ conocido, clusters con distribución normal alineada a ejes.
1. **Inicialización**: Seleccionar $k$ centroides iniciales.
2. **Lectura**: Leer un *chunk* de datos que quepa en memoria principal.
3. **Asignación al Discard Set**:
   - Para cada punto $p$ en el chunk, calcular distancia de Mahalanobis a los centroides de los $k$ clusters.
   - Si la distancia es menor al umbral, asignar $p$ al cluster y actualizar sus estadísticas ($N, SUM, SUMSQ$). Descartar $p$ de memoria.
4. **Agrupamiento de remanentes**:
   - Agrupar los puntos no asignados junto con el *Retained Set* usando un algoritmo de clustering en memoria (ej. jerárquico).
   - Crear *miniclusters* (pasan al Compressed Set) y puntos aislados (pasan al Retained Set).
5. **Fusión de Compressed Sets**: Fusionar miniclusters del Compressed Set antiguo y nuevo si están suficientemente cerca.
6. **Escritura**: Escribir a disco las asignaciones y actualizar estructuras en memoria.
7. **Finalización**: Al procesar el último chunk, asignar puntos del Retained Set y miniclusters del Compressed Set al cluster más cercano o tratarlos como outliers.

## 6. Problemas comunes y soluciones
- **Mala inicialización de centroides**: Si los centroides iniciales están muy cerca, los clusters resultantes pueden ser subóptimos.
  - *Solución*: Usar el método de "puntos lejanos" o clustering previo de una muestra.
- **Elección incorrecta de $k$**: Demasiados clusters fragmentan grupos naturales; muy pocos fusionan grupos distintos aumentando el diámetro.
  - *Solución*: Buscar el punto de inflexión ("codo") en la gráfica de diámetro promedio vs. número de clusters usando búsqueda binaria.
- **Datos que no caben en memoria**: K-means estándar requiere acceso aleatorio o múltiples pases completos.
  - *Solución*: Usar BFR con procesamiento por chunks y estructuras sumarias.
- **Clusters rotados en BFR**: El algoritmo falla si la distribución normal no está alineada con los ejes.
  - *Solución*: Usar algoritmos como CURE que no asumen forma específica.

## 7. Implementación técnica y generación de código

```pseudocode
# Algoritmo K-means (Esquema general)
Inicialmente elegir k puntos que probablemente estén en diferentes clusters;
Hacer de estos puntos los centroides de sus clusters;
FOR cada punto restante p DO
    encontrar el centroide más cercano a p;
    Agregar p al cluster de ese centroide;
    Ajustar el centroide de ese cluster para considerar a p;
END;
# Paso opcional: reasignar todos los puntos a los centroides fijos resultantes.
```

```pseudocode
# Algoritmo BFR - Estructura de representación
# Para un cluster o minicluster en d dimensiones:
# N: Número de puntos
# SUM: Vector de longitud d (Suma de componentes por dimensión)
# SUMSQ: Vector de longitud d (Suma de cuadrados de componentes por dimensión)
# Centroide[i] = SUM[i] / N
# Varianza[i] = (SUMSQ[i] / N) - (SUM[i] / N)^2
```

```python
import numpy as np

def mahalanobis_distance(point, centroid, std_devs):
    """
    Calcula la distancia de Mahalanobis entre un punto y un centroide,
    asumiando independencia entre dimensiones (diagonal de la matriz de covarianza).
    
    Args:
        point (np.array): Vector del punto d-dimensional.
        centroid (np.array): Vector del centroide d-dimensional.
        std_devs (np.array): Vector de desviaciones estándar d-dimensional.
        
    Returns:
        float: Distancia de Mahalanobis.
    """
    diff = point - centroid
    # Evitar división por cero si std_dev es 0 (todos los puntos iguales en esa dimensión)
    with np.errstate(divide='ignore', invalid='ignore'):
        normalized_diff = np.where(std_devs != 0, diff / std_devs, 0)
    
    return np.sqrt(np.sum(normalized_diff ** 2))

class BFRCluster:
    def __init__(self, dimension):
        self.N = 0
        self.SUM = np.zeros(dimension)
        self.SUMSQ = np.zeros(dimension)
    
    def add_point(self, point):
        """Añade un punto y actualiza las estadísticas sumarias."""
        self.N += 1
        self.SUM += point
        self.SUMSQ += point ** 2
    
    @property
    def centroid(self):
        if self.N == 0: return np.zeros_like(self.SUM)
        return self.SUM / self.N
    
    @property
    def variance(self):
        if self.N == 0: return np.zeros_like(self.SUM)
        # Varianza = E[X^2] - (E[X])^2
        return (self.SUMSQ / self.N) - (self.SUM / self.N) ** 2
    
    @property
    def std_dev(self):
        return np.sqrt(self.variance)

# Ejemplo de uso basado en el Ejemplo 7.9 del libro
# Puntos: (5,1), (6,-2), (7,0)
cluster = BFRCluster(dimension=2)
points = [np.array([5, 1]), np.array([6, -2]), np.array([7, 0])]
for p in points:
    cluster.add_point(p)

print(f"Centroide: {cluster.centroid}") # Esperado: [6, -0.333]
print(f"Desv. Estándar: {cluster.std_dev}") # Esperado: [0.816, 1.25] aprox
```

## 8. Funciones, métodos, librerías o comandos identificados
- **Estructura de datos BFR ($N, SUM, SUMSQ$)**: Representación eficiente para estadísticas de clusters incrementales.
- **Distancia de Mahalanobis**: Función matemática para medir distancia normalizada por varianza.
- **Búsqueda binaria**: Método algorítmico para encontrar el $k$ óptimo en rango logarítmico.

## 9. Snippets o plantillas reutilizables

```python
# Snippet: Cálculo de estadísticas incrementales para BFR
# Útil para sistemas de streaming o procesamiento por lotes

def update_stats(N_old, SUM_old, SUMSQ_old, new_points_batch):
    """
    Actualiza las estadísticas de un cluster con un nuevo lote de puntos.
    new_points_batch: np.array de forma (m, d)
    """
    N_new = N_old + len(new_points_batch)
    SUM_new = SUM_old + np.sum(new_points_batch, axis=0)
    SUMSQ_new = SUMSQ_old + np.sum(new_points_batch ** 2, axis=0)
    return N_new, SUM_new, SUMSQ_new

def merge_clusters(N1, SUM1, SUMSQ1, N2, SUM2, SUMSQ2):
    """
    Fusiona dos clusters o miniclusters (ej. en el Compressed Set).
    """
    N_merged = N1 + N2
    SUM_merged = SUM1 + SUM2
    SUMSQ_merged = SUMSQ1 + SUMSQ2
    return N_merged, SUM_merged, SUMSQ_merged
```

## 10. Casos de uso y aplicaciones
- **Clustering de datos masivos**: Aplicación principal de BFR cuando el dataset excede la RAM pero cabe en disco.
- **Detección de anomalías**: El *Retained Set* en BFR actúa como un filtro natural de outliers.
- **Sistemas de recomendación**: Agrupamiento de usuarios o ítems en espacio Euclidiano de características.
- **Compresión de datos**: Representación de millones de puntos mediante sus estadísticas sumarias ($N, SUM, SUMSQ$).

## 11. Limitaciones, riesgos y precauciones
- **Supuesto de distribución normal en BFR**: Si los clusters no tienen forma elipsoidal alineada a los ejes, el rendimiento decae drásticamente.
- **Sensibilidad a la inicialización**: K-means puede converger a óptimos locales; la inicialización "puntos lejanos" mitiga pero no elimina el riesgo.
- **Elección de $k$**: Requiere heurísticas adicionales (método del codo) que pueden ser costosas computacionalmente si no se usa búsqueda binaria.
- **Maldición de la dimensionalidad**: En dimensiones muy altas, la distancia Euclidiana (y por ende Mahalanobis) pierde significado; BFR asume alta dimensión pero con clusters distinguibles.

## 12. Relaciones con otros temas del corpus
- **Clustering Jerárquico (Sección 7.2)**: Utilizado dentro de BFR para agrupar puntos del *Retained Set* y crear *miniclusters* en el *Compressed Set*.
- **CURE Algorithm (Sección 7.4)**: Alternativa a BFR para clusters de forma arbitraria (no Gaussiana).
- **MapReduce**: El procesamiento por *chunks* de BFR es conceptualmente compatible con paradigmas de procesamiento distribuido.
- **Teorema del límite central**: Fundamento teórico del supuesto de normalidad en clusters grandes para BFR.

## 13. Preguntas que la skill debería poder responder
1. ¿Cómo se seleccionan los centroides iniciales en K-means para maximizar la probabilidad de éxito?
2. ¿Qué estructura de datos utiliza el algoritmo BFR para representar clusters en memoria y por qué se prefiere sobre guardar el centroide y desviación estándar directamente?
3. ¿Cuál es la diferencia entre el *Discard Set*, *Compressed Set* y *Retained Set* en BFR?
4. ¿Cómo se utiliza la distancia de Mahalanobis en BFR para decidir si un punto pertenece a un cluster?
5. ¿Qué estrategia se recomienda para encontrar el valor óptimo de $k$ si se desconoce a priori?
6. ¿Cuáles son las limitaciones geométricas del algoritmo BFR respecto a la forma de los clusters?
7. ¿Cómo se actualiza la varianza de un cluster en BFR al agregar un nuevo punto sin recalcular desde cero?

## 14. Acciones que la skill debería poder recomendar o ejecutar
- Implementar la inicialización de K-means mediante selección de puntos lejanos.
- Calcular la distancia de Mahalanobis para un punto respecto a un cluster dado.
- Diseñar un flujo de procesamiento de datos por lotes (chunks) usando la lógica BFR.
- Fusionar dos miniclusters sumando sus vectores $N, SUM, SUMSQ$.
- Evaluar si un dataset es candidato para BFR o si se requiere CURE basándose en la forma esperada de los clusters.

## 15. Activos finales de conocimiento en formato compacto

| Concepto | Descripción | Referencia |
| :--- | :--- | :--- |
| **BFR** | Algoritmo K-means para datos masivos que no caben en memoria, asume clusters normales alineados a ejes. | Sec 7.3.4 |
| **N, SUM, SUMSQ** | Estructura de datos sumaria que permite cálculo incremental de media y varianza. | Sec 7.3.4 |
| **Mahalanobis Distance** | Distancia normalizada por desviación estándar; usada para asignación de puntos en BFR. | Sec 7.3.5 |
| **Discard Set** | Conjunto de puntos ya asignados a clusters principales, representados solo por estadísticas. | Sec 7.3.4 |
| **Compressed Set** | Conjunto de *miniclusters* (puntos cercanos entre sí pero no a clusters principales). | Sec 7.3.4 |
| **Retained Set** | Puntos aislados (outliers) que no forman miniclusters, almacenados explícitamente en memoria. | Sec 7.3.4 |
| **Init. Puntos Lejanos** | Heurística para elegir centroides iniciales: elegir iterativamente el punto más lejano a los ya elegidos. | Sec 7.3.2 |
| **Selección de k** | Buscar el "codo" en la gráfica de diámetro promedio; usar búsqueda binaria para eficiencia. | Sec 7.3.3 |
