# Parte 49 - k-NN, Kernel Regression, and Decision Trees

## 1. Metadatos del documento
- **Libro:** Mining of Massive Datasets, 3ª ed.
- **Fragmento/Parte:** Parte 49 - k-NN, Kernel Regression, and Decision Trees
- **Temas principales:** K-Nearest Neighbors (k-NN), Diagramas de Voronoi, Regresión Kernel, Maldición de la dimensionalidad, Estructuras de índice multidimensional, Árboles de decisión.
- **Tipo de contenido:** Teoría / Algoritmo / Caso de uso

## 2. Resumen técnico de alto valor
El fragmento aborda el aprendizaje basado en vecinos más cercanos como método de clasificación y regresión no paramétrico. Se establece un marco de decisión compuesto por cuatro elementos: medida de distancia, número de vecinos ($k$), función de ponderación (kernel) y método de agregación de etiquetas. Para el caso de un solo vecino (1-NN), se introduce el **Diagrama de Voronoi** como estructura de partición del espacio, permitiendo clasificación en $O(\log n)$ con preprocesamiento $O(n \log n)$.

En el contexto de regresión (datos unidimensionales), se contrastan métodos de interpolación simple (vecino más cercano, promedio) contra **Regresión Kernel**, donde se utilizan funciones continuas (como la distribución normal o decaimiento cuadrático inverso) para ponderar la influencia de todos los puntos del entrenamiento, garantizando la continuidad de la función estimada.

Se aborda críticamente la **maldición de la dimensionalidad** en datos euclidianos de alta dimensión, donde las estructuras de índice tradicionales (kd-Trees, R-Trees) pierden eficiencia. Se proponen dos soluciones: **VA Files** (aproximación burda + filtrado) y **Reducción de Dimensionalidad**. Para distancias no euclidianas (ej. Jaccard), se sugiere el uso de **Locality-Sensitive Hashing (LSH)** con umbrales de distancia múltiples para recuperar vecinos aproximados. Finalmente, se introduce conceptualmente el Árbol de Decisión como un programa de ramificación basado en pruebas de características.

## 3. Conceptos y definiciones clave
- **Query example (Ejemplo de consulta):** Nuevo punto de datos que llega al sistema y debe ser clasificado o etiquetado basándose en el conjunto de entrenamiento.
- **Kernel function (Función kernel):** Función que determina el peso de un punto de entrenamiento en función de su distancia al ejemplo de consulta. Decae con la distancia. Ejemplos: distribución normal, inverso del cuadrado de la distancia.
- **Voronoi diagram (Diagrama de Voronoi):** Partición del espacio en regiones convexas donde cada región contiene todos los puntos más cercanos a un punto de entrenamiento específico que a cualquier otro. Fundamental para la implementación eficiente de 1-NN en 2D.
- **VA Files (Vector Approximation Files):** Estructura de datos para alta dimensionalidad que almacena una versión comprimida (aproximada con pocos bits) de los vectores para realizar un filtrado rápido antes de acceder a los datos completos.
- **Curse of dimensionality (Maldición de la dimensionalidad):** Fenómeno donde la eficiencia de las estructuras de índice espacial se degrada drásticamente a medida que la dimensionalidad aumenta, obligando a escanear una gran porción de los datos.
- **Decision Tree (Árbol de decisión):** Modelo predictivo que utiliza una estructura de árbol donde cada nodo interno representa una "prueba" sobre un atributo, cada rama representa el resultado de la prueba y cada hoja representa la etiqueta de clase.

## 4. Principios, reglas y heurísticas
- **Regla de interpolación lineal:** Si se usan los dos vecinos más cercanos ponderados inversamente a la distancia, el resultado es equivalente a una interpolación lineal entre ellos.
- **Regla de continuidad:** Para garantizar una función de predicción continua, se deben usar funciones kernel continuas (ej. distribución normal) en lugar de promedios discretos o ponderaciones simples.
- **Heurística de alta dimensionalidad:** En espacios de alta dimensión, las estructuras de índice complejas (kd-Trees) son ineficientes. Es preferible aceptar un escaneo lineal optimizado (VA Files) o reducir la dimensionalidad previamente.
- **Heurística LSH para k-NN:** Si se usa LSH para encontrar vecinos en distancias no euclidianas y los vecinos más cercanos varían mucho en distancia, se deben construir buckets para múltiples distancias $d_1 < d_2 < \dots$ e iterar hasta encontrar suficientes vecinos.
- **Clasificación 1-NN:** La etiqueta del query es idéntica a la de su vecino más cercano; no se requiere kernel ni ponderación.

## 5. Procedimientos, métodos y workflows

### Procedimiento: Clasificación k-NN General
1.  **Preprocesamiento:** Almacenar el conjunto de entrenamiento (opcionalmente construir índices espaciales o LSH).
2.  **Llegada del Query:** Recibir el nuevo punto $q$.
3.  **Búsqueda:** Encontrar los $k$ puntos más cercanos $x_1, \dots, x_k$ según la medida de distancia elegida.
4.  **Ponderación:** Calcular pesos $w_i$ para cada vecino usando la función kernel (si aplica).
5.  **Agregación:** Calcular la etiqueta estimada.
    *   Clasificación: Votación mayoritaria (ponderada o no).
    *   Regresión: Promedio ponderado $\frac{\sum w_i y_i}{\sum w_i}$.

### Procedimiento: Regresión Kernel (Cálculo de etiqueta)
1.  Definir un query point $q$ y un ancho de banda $\sigma$.
2.  Para cada punto de entrenamiento $x_i$ con etiqueta $y_i$:
    *   Calcular distancia $d(x_i, q)$.
    *   Calcular peso $w_i = e^{-d(x_i, q)^2 / \sigma^2}$ (Kernel Gaussiano) o similar.
3.  Sumar los valores ponderados: $S_{val} = \sum w_i y_i$.
4.  Sumar los pesos: $S_{w} = \sum w_i$.
5.  Resultado: $y_{estimada} = S_{val} / S_{w}$.

### Procedimiento: Búsqueda con VA Files (Alta Dimensionalidad)
1.  Crear un archivo resumen usando una fracción de los bits de cada componente del vector (ej. 1/4 de los bits).
2.  Escanear el archivo resumen para generar una lista de candidatos que *podrían* estar entre los $k$ vecinos más cercanos.
3.  Acceder al archivo completo solo para los candidatos seleccionados para verificar distancias exactas.

## 6. Problemas comunes y soluciones
- **Problema: Discontinuidad en la función aprendida.**
    - *Causa:* Usar promedios simples de vecinos o funciones kernel no continuas.
    - *Solución:* Usar funciones kernel suaves y definidas para todo punto, como la distribución normal (gaussiana).
- **Problema: Peso infinito en Regresión Kernel.**
    - *Causa:* Usar kernel $w = 1/(x-q)^2$ cuando el query $q$ coincide exactamente con un punto de entrenamiento $x$.
    - *Solución:* Analizar el límite matemático. En el límite, la etiqueta del punto de entrenamiento domina la expresión, por lo que la estimación es correcta (etiqueta del propio punto).
- **Problema: Ineficiencia de índices en alta dimensión.**
    - *Causa:* "Maldición de la dimensionalidad"; los hiperplanos de corte no particionan efectivamente el espacio.
    - *Solución:* Usar VA Files (escaneo aproximado) o Reducción de Dimensionalidad (PCA, SVD) antes de indexar.
- **Problema: Falsos negativos en LSH para k-NN.**
    - *Causa:* LSH es una técnica aproximada.
    - *Solución:* Iterar sobre múltiples distancias $d_1 < d_2 < \dots$ hasta encontrar suficientes vecinos, aceptando el trade-off de precisión.

## 7. Implementación técnica y generación de código

```pseudocode
# Algoritmo: Estimación de etiqueta mediante Regresión Kernel
# Entrada: Conjunto de entrenamiento T, Query q, Función kernel K, Parámetro sigma
# Salida: Valor estimado y_estimado

funcion estimar_kernel(T, q, K, sigma):
    suma_ponderada = 0
    suma_pesos = 0
    para cada (x_i, y_i) en T:
        distancia = d(x_i, q) # d es la función de distancia (ej. Euclidiana)
        peso = K(distancia, sigma) # ej. exp(-dist^2 / sigma^2)
        suma_ponderada += peso * y_i
        suma_pesos += peso
    
    si suma_pesos == 0:
        retornar error "No se pudieron calcular pesos"
    sino:
        retornar suma_ponderada / suma_pesos
```

```python
import numpy as np

def kernel_gaussiano(distancia, sigma):
    """Calcula el peso usando un kernel gaussiano."""
    return np.exp(-(distancia**2) / (2 * sigma**2))

def regresion_kernel(query, X_train, y_train, sigma=1.0):
    """
    Implementación simple de Regresión Kernel para datos 1D o ND.
    
    Args:
        query (np.array): Punto de consulta.
        X_train (np.array): Matriz de características de entrenamiento.
        y_train (np.array): Vector de etiquetas/valores.
        sigma (float): Ancho de banda del kernel.
    
    Returns:
        float: Valor estimado para el query.
    """
    # Calcular distancias euclidianas entre query y todos los puntos de entrenamiento
    # Nota: En producción real, usar métricas vectorizadas o espaciales
    distancias = np.linalg.norm(X_train - query, axis=1)
    
    # Calcular pesos
    pesos = kernel_gaussiano(distancias, sigma)
    
    # Calcular promedio ponderado
    suma_ponderada = np.sum(pesos * y_train)
    suma_pesos = np.sum(pesos)
    
    if suma_pesos == 0:
        return np.mean(y_train) # Fallback si sigma es muy pequeño
    
    return suma_ponderada / suma_pesos

# Ejemplo de uso basado en el libro (datos 1D)
# Training set: (1,1), (2,2), (3,4), (4,8), (5,4), (6,2), (7,1)
X = np.array([[1], [2], [3], [4], [5], [6], [7]])
y = np.array([1, 2, 4, 8, 4, 2, 1])

query_point = np.array([[3.5]])
estimacion = regresion_kernel(query_point, X, y, sigma=0.5)
# print(f"Estimación para q=3.5: {estimacion}")
```

## 8. Funciones, métodos, librerías o comandos identificados
- **kd-Trees / R-Trees / Quad Trees:** Estructuras de datos para indexación multidimensional eficientes en baja dimensión.
- **Locality-Sensitive Hashing (LSH):** Técnica para búsqueda de vecinos aproximados en distancias no euclidianas (ej. Jaccard).
- **VA Files (Vector Approximation Files):** Método de acceso basado en escaneo de aproximaciones para alta dimensión.

## 9. Snippets o plantillas reutilizables

```python
# Snippet: Clasificador 1-NN usando distancia Euclidiana
def clasificar_1nn(query, X_train, y_train):
    """
    Clasifica un punto query usando el vecino más cercano.
    """
    # Calcula distancias
    dists = np.linalg.norm(X_train - query, axis=1)
    # Encuentra el índice del mínimo
    idx_min = np.argmin(dists)
    return y_train[idx_min]

# Snippet: Interpolación lineal (2-NN ponderado por distancia)
def interpolar_2nn(query, X_train, y_train):
    """
    Estima valor usando los 2 vecinos más cercanos con peso inverso a la distancia.
    Equivalente a interpolación lineal en 1D.
    """
    dists = np.linalg.norm(X_train - query, axis=1)
    # Obtener índices de los 2 más cercanos
    idxs = np.argsort(dists)[:2]
    
    d1, d2 = dists[idxs[0]], dists[idxs[1]]
    y1, y2 = y_train[idxs[0]], y_train[idxs[1]]
    
    # Manejar caso donde query coincide exactamente con un punto
    if d1 == 0: return y1
    
    # Peso inverso a la distancia
    w1, w2 = 1/d1, 1/d2
    return (w1*y1 + w2*y2) / (w1 + w2)
```

## 10. Casos de uso y aplicaciones
- **Clasificación de razas de perros:** Uso de Diagramas de Voronoi para clasificar perros (Chihuahuas, Dachshunds, Beagles) basándose en vectores de peso y altura (2D). Las fronteras de decisión son las bisectrices perpendiculares entre puntos de distintas clases.
- **Interpolación de funciones:** Reconstrucción de una función continua a partir de muestras discretas (ej. función con pico en $x=4$ y decaimiento exponencial). Se comparan métodos de "escalón" (1-NN) vs. suavizado (Kernel).
- **Sistemas de recomendación implícita:** Aunque no se menciona explícitamente, el framework de ponderar "vecinos" (items o usuarios similares) es la base de filtros colaborativos user-user o item-item.

## 11. Limitaciones, riesgos y precauciones
- **Complejidad espacial y temporal:** El enfoque de "memorizar todo el entrenamiento" implica alto costo de almacenamiento y búsqueda ($O(n)$ por query sin índices).
- **Sensibilidad al ruido:** El método 1-NN es muy sensible a outliers (ruido en las etiquetas), ya que una sola instancia errónea puede crear una región de clasificación incorrecta grande.
- **Maldición de la dimensionalidad:** En dimensiones altas, la noción de "vecino más cercano" pierde sentido porque las distancias tienden a ser similares entre todos los puntos. Se recomienda reducción de dimensionalidad previa.
- **Falsos negativos en LSH:** Al usar hashing sensible a la localidad para distancias no euclidianas, se pueden perder vecinos cercanos reales, afectando la precisión del modelo.

## 12. Relaciones con otros temas del corpus
- **MinHash / LSH (Capítulo 3):** El texto referencia explícitamente LSH como solución para distancias no euclidianas (Jaccard). Es una dependencia técnica clave.
- **Reducción de Dimensionalidad (Capítulo 11):** Se menciona como preprocesamiento necesario para aplicar índices multidimensionales en datos de alta dimensión (SVD, PCA).
- **Máquinas de Vectores de Soporte (SVM - Sección 12.3):** El fragmento incluye ejercicios sobre SVM. La relación conceptual es que SVM busca un hiperplano óptimo global, mientras que k-NN es una aproximación local.
- **Hiperplanos y Vectores (Secciones 12.2, 12.3):** La construcción del diagrama de Voronoi se basa en bisectrices perpendiculares, que son hiperplanos.

## 13. Preguntas que la skill debería poder responder
1. ¿Cuáles son los cuatro componentes de diseño para un algoritmo de aprendizaje basado en vecinos más cercanos?
2. ¿Cómo se relaciona el Diagrama de Voronoi con el algoritmo 1-NN?
3. ¿Por qué el promedio ponderado de los dos vecinos más cercanos equivale a una interpolación lineal?
4. ¿Qué es la Regresión Kernel y cómo evita las discontinuidades de los métodos simples de k-NN?
5. ¿Qué es un VA File y por qué se recomienda para datos de alta dimensionalidad?
6. ¿Cómo se adapta el aprendizaje de vecinos cercanos para distancias no euclidianas como la distancia de Jaccard?
7. ¿Qué problema resuelve iterar sobre múltiples distancias $d_1 < d_2$ al usar LSH para k-NN?
8. ¿Cuál es la complejidad temporal de construir un Diagrama de Voronoi y de realizar una consulta en él?

## 14. Acciones que la skill debería poder recomendar o ejecutar
- **Seleccionar estrategia de indexación:** Recomendar usar VA Files o reducción de dimensionalidad si el dataset tiene cientos de dimensiones, en lugar de kd-Trees.
- **Elegir función kernel:** Sugerir usar kernel gaussiano para asegurar continuidad en problemas de regresión frente a promedios simples.
- **Implementar clasificador:** Generar código para clasificación 1-NN o k-NN con votación ponderada.
- **Diagnosticar fallos:** Identificar si un modelo k-NN tiene sobreajuste (ruido) y sugerir aumentar $k$ o suavizar el kernel.

## 15. Activos finales de conocimiento en formato compacto
| Concepto | Descripción | Referencia |
| :--- | :--- | :--- |
| **Framework k-NN** | Distancia + Número vecinos ($k$) + Kernel + Agregación etiqueta. | Sec. 12.4.1 |
| **Voronoi Diagram** | Partición del espacio para 1-NN; regiones convexas; construcción $O(n \log n)$. | Sec. 12.4.2 |
| **Interpolación Lineal** | Caso especial de 2-NN con pesos inversos a la distancia. | Sec. 12.4.3 |
| **Regresión Kernel** | Ponderación de todos los puntos mediante función continua (ej. Gaussiana) para suavizar predicciones. | Sec. 12.4.4 |
| **VA Files** | Técnica para alta dimensión: escaneo de resumen comprimido + verificación de candidatos. | Sec. 12.4.5 |
| **LSH para k-NN** | Uso de hashing sensible a localidad para distancias no euclidianas; requiere iteración de distancias. | Sec. 12.4.6 |
| **Maldición Dimensión** | Ineficacia de índices espaciales en alta dimensión; obliga a escaneos lineales o reducción previa. | Sec. 12.4.5 |
| **Árbol de Decisión** | Estructura de ramificación donde nodos son pruebas y hojas son conclusiones/clases. | Sec. 12.5 |


