# Parte 34 - Recommender Systems Wrap-Up

## 1. Metadatos del documento
- **Libro:** Mining of Massive Datasets, 3ª ed.
- **Fragmento/Parte:** Parte 34 - Recommender Systems Wrap-Up
- **Temas principales:** Sistemas de Recomendación, Netflix Challenge, Factorización de Matrices (UV-Decomposition), Filtrado Colaborativo, RMSE, Matrices de Utilidad
- **Tipo de contenido:** Mixto (Caso de estudio histórico / Resumen teórico / Mejores prácticas)

## 2. Resumen técnico de alto valor
El fragmento detalla el caso de estudio del Netflix Challenge, estableciendo que el algoritmo base CineMatch tenía un RMSE de ~0.95 y el objetivo era mejorarlo en un 10%. Se revela que un algoritmo simple basado en promedios (usuario y ítem) rendía solo un 3% peor que CineMatch, demostrando la importancia de las líneas base simples. La estrategia ganadora no fue un modelo único, sino un *ensemble* (combinación) de múltiples algoritmos, destacando la descomposición UV con normalización como una técnica clave que aportó mejoras significativas (~7%).

El resumen teórico (Sección 9.6) formaliza los sistemas de recomendación en dos clases: *Content-based* (basado en atributos del ítem) y *Collaborative Filtering* (basado en similitudes entre usuarios o ítems). Introduce la descomposición UV como método para predecir valores faltantes en matrices de utilidad dispersas, optimizando mediante descenso de gradiente (implícito en la minimización de RMSE) y advierte sobre la convergencia a óptimos locales. Se destaca la utilidad de la normalización y el clustering previo para mitigar la dispersión extrema de datos.

## 3. Conceptos y definiciones clave
- **Matriz de Utilidad (Utility Matrix):** Estructura que relaciona usuarios con ítems, donde las entradas representan preferencias conocidas (ratings). La mayoría de las entradas suelen ser desconocidas (dispersas).
- **Filtrado Colaborativo (Collaborative Filtering):** Método para predecir la respuesta de un usuario a un ítem basándose en las preferencias de otros usuarios similares o en usuarios que prefirieron ítems similares.
- **UV-Decomposition:** Técnica de factorización matricial que aproxima la matriz de utilidad $M$ mediante el producto de dos matrices "delgadas" $U$ y $V$. La dimensión compartida representa "conceptos" o factores latentes.
- **RMSE (Root-Mean-Square Error):** Métrica estándar para evaluar la precisión de predicción. Calcula la raíz cuadrada del promedio de los cuadrados de las diferencias entre los valores predichos y los reales.
- **Content-based Recommendation:** Sistema que recomienda ítems basándose en características intrínsecas (features) compartidas con ítems que el usuario prefirió anteriormente.
- **Ensemble / Blending:** Estrategia de combinar múltiples algoritmos independientes para producir una predicción final, demostrada superior en el Netflix Challenge frente a modelos individuales.

## 4. Principios, reglas y heurísticas
- **Regla de la Línea Base Simple:** Antes de implementar algoritmos complejos, probar un promedio simple del rating promedio del usuario y el rating promedio del ítem. En Netflix, esto rindió casi tan bien como el algoritmo industrial existente (solo 3% peor).
- **Regla del Ensemble:** Para problemas difíciles de predicción, la combinación de algoritmos diversos supera consistentemente a los modelos individuales.
- **Normalización:** Es crucial normalizar la matriz de utilidad (restando promedios por fila/columna) antes de aplicar medidas de distancia como el coseno o factorizaciones UV.
- **Gestión de la Dispersión:** Si la matriz es demasiado dispersa, las medidas de similitud directa (Jaccard, Coseno) fallan. Se recomienda *clustering* previo de usuarios/ítems para densificar las comparaciones.
- **Heurística de Inicialización en UV:** La optimización de $U$ y $V$ converge a óptimos locales. Es obligatorio ejecutar el proceso desde múltiples puntos de partida aleatorios para buscar el óptimo global.
- **Información Temporal:** La fecha del rating puede ser un predictor. Algunos ítems ("Patch Adams") se valoran mejor inmediatamente y peor después; otros ("Memento") mejoran con el tiempo.

## 5. Procedimientos, métodos y workflows
### Procedimiento: Predicción mediante Promedios (Baseline)
1.  Calcular el rating promedio $\bar{r}_u$ para cada usuario $u$.
2.  Calcular el rating promedio $\bar{r}_m$ para cada ítem $m$.
3.  Para una celda vacía $(u, m)$, predecir el valor como el promedio de $\bar{r}_u$ y $\bar{r}_m$.

### Procedimiento: Optimización de Descomposición UV
1.  **Inicialización:** Crear matrices $U$ y $V$ arbitrarias (delgadas).
2.  **Iteración:** Seleccionar un elemento de $U$ o $V$.
3.  **Ajuste:** Modificar ese elemento para minimizar el RMSE entre $UV$ y la matriz de utilidad $M$ (solo en celdas conocidas).
4.  **Convergencia:** Repetir hasta que el RMSE no mejore significativamente.
5.  **Predicción:** El valor predicho para la celda vacía $(u, m)$ es el valor en la posición $(u, m)$ del producto matricial $UV$.

## 6. Problemas comunes y soluciones
- **Problema: Datos externos no útiles.** En Netflix, integrar datos de IMDB (géneros, directores) no mejoró el rendimiento.
    - *Causa:* Los algoritmos de ML ya inferían estos patrones latentes o la resolución de entidades (matching de nombres) era imperfecta.
    - *Solución:* Confiar en los factores latentes derivados de los datos de interacción propios antes que en metadatos externos difíciles de alinear.
- **Problema: Óptimos locales en Factorización.** El ajuste iterativo de $U$ y $V$ puede estancarse en mínimos locales.
    - *Solución:* Ejecutar el algoritmo múltiples veces con inicializaciones aleatorias diferentes y seleccionar el resultado con menor RMSE final.
- **Problema: Matrices demasiado dispersas.** Imposibilidad de calcular similitudes efectivas.
    - *Solución:* Aplicar *clustering* de usuarios e ítems antes de comparar, para agrupar entidades similares y tener más datos en común.

## 7. Implementación técnica y generación de código

```pseudocode
# Algoritmo de predicción simple (Baseline) mencionado en Sección 9.5
Función PredecirRatingSimple(Usuario u, Item m, Matriz M):
    avg_u = Promedio(M[u, :]) // Promedio de ratings del usuario
    avg_m = Promedio(M[:, m]) // Promedio de ratings del item
    return (avg_u + avg_m) / 2
```

```python
# Implementación del cálculo de RMSE y Predicción Base
import numpy as np

def calculate_rmse(original_matrix, predicted_matrix):
    """
    Calcula el RMSE entre la matriz original y la predicha,
    ignorando valores desconocidos (NaNs en original).
    """
    # Máscara de valores conocidos
    mask = ~np.isnan(original_matrix)
    
    # Diferencia cuadrada solo donde hay datos
    diff_sq = (original_matrix[mask] - predicted_matrix[mask]) ** 2
    
    return np.sqrt(np.mean(diff_sq))

def baseline_prediction(utility_matrix):
    """
    Implementación del algoritmo 'obvio' del Netflix Challenge:
    Promedio del promedio del usuario y del promedio del ítem.
    """
    # Promedio por usuario (fila), ignorando NaNs
    user_means = np.nanmean(utility_matrix, axis=1, keepdims=True)
    # Promedio por ítem (columna), ignorando NaNs
    item_means = np.nanmean(utility_matrix, axis=0, keepdims=True)
    
    # Predicción: (avg_user + avg_item) / 2
    # Usamos broadcasting para sumar vectores columna y fila
    prediction_matrix = (user_means + item_means) / 2.0
    
    return prediction_matrix

# Ejemplo de uso conceptual
# M = np.array([[5, 3, np.nan], [4, np.nan, 2], [np.nan, 1, 5]])
# pred = baseline_prediction(M)
# rmse = calculate_rmse(M, pred)
```

## 8. Funciones, métodos, librerías o comandos identificados
- **RMSE (Root-Mean-Square Error):** Métrica de evaluación principal.
- **Jaccard Distance:** Medida de similitud para matrices binarias (1's y blancos).
- **Cosine Distance:** Medida de similitud para valores continuos en matrices de utilidad.
- **UV-Decomposition:** Algoritmo de factorización matricial.
- **Normalization:** Preprocesamiento de datos (centrado por fila/columna).

## 9. Snippets o plantillas reutilizables
> *Sección no aplicable a este fragmento.* (El fragmento es teórico/descriptivo, el código generado en la sección 7 cubre la necesidad de implementación básica).

## 10. Casos de uso y aplicaciones
- **Netflix Challenge:** Predicción de ratings de películas (1-5 estrellas) para reducir el RMSE en un 10% respecto al baseline industrial.
- **Sistemas de Streaming:** Análisis de la variación temporal de preferencias (ej. películas que se valoran mejor con el tiempo vs. películas de "un solo uso").
- **Comercio Electrónico (Amazon):** Uso de perfiles de usuario y filtrado colaborativo ítem-ítem para recomendaciones de productos.

## 11. Limitaciones, riesgos y precauciones
- **Complejidad Computacional:** La descomposición UV requiere múltiples pasadas sobre la matriz y reinicios aleatorios, siendo costosa para matrices masivas.
- **Dependencia de Datos Explícitos:** El enfoque del Netflix Challenge se basó en ratings explícitos (estrellas). La aplicación a feedback implícito (clicks, vistas) requiere adaptaciones matemáticas.
- **Falsa Intuición sobre Metadatos:** Asumir que agregar datos externos (IMDB) siempre ayuda es un error; puede introducir ruido o problemas de resolución de entidades (*entity resolution*).
- **Sesgo Temporal:** Las preferencias cambian con el tiempo. Un modelo estático puede fallar si no considera la pendiente temporal de los ratings.

## 12. Relaciones con otros temas del corpus
- **MinHashing / LSH:** Técnicas mencionadas como base para medir similitudes eficientemente en otros contextos, relacionadas con la distancia Jaccard mencionada aquí.
- **Clustering (Capítulos previos):** Se menciona como paso previo para manejar la dispersión en sistemas de recomendación.
- **SVD (Singular Value Decomposition):** Concepto matemático subyacente a la UV-Decomposition (una aproximación simplificada/iterativa de SVD).
- **Entity Resolution:** Mencionado como problema difícil al intentar unir datos de Netflix con IMDB.

## 13. Preguntas que la skill debería poder responder
1. ¿Por qué la estrategia de *ensemble* fue clave para ganar el Netflix Challenge?
2. ¿Qué algoritmo simple funcionó casi tan bien como CineMatch y cómo se calcula?
3. ¿Cuál es el propósito de normalizar la matriz de utilidad antes de calcular la distancia coseno?
4. ¿Qué problema resuelve el *clustering* previo en sistemas de recomendación con matrices dispersas?
5. ¿Cómo afecta el factor tiempo a la valoración de ciertas películas según el estudio de Netflix?
6. ¿Qué es la UV-Decomposition y qué representan las dimensiones de las matrices U y V?
7. ¿Por qué el uso de metadatos externos (géneros, directores) no mejoró significativamente los resultados en el Netflix Challenge?
8. ¿Cómo se calcula el RMSE y cuál fue el umbral de victoria para Netflix?

## 14. Acciones que la skill debería poder recomendar o ejecutar
- Implementar una línea base de promedios (usuario/ítem) antes de entrenar modelos complejos para establecer un benchmark de rendimiento.
- Evaluar si la matriz de utilidad es demasiado dispersa y aplicar clustering si las medidas de similitud fallan.
- Considerar la inclusión de características temporales (fecha de rating) en el modelo si el dominio lo permite (ej. noticias, entretenimiento).
- Utilizar múltiples inicializaciones aleatorias al entrenar modelos de factorización matricial para evitar óptimos locales.
- Diseñar una arquitectura de *ensemble* si un solo modelo no alcanza la precisión requerida.

## 15. Activos finales de conocimiento en formato compacto
Concepto | Descripción en una línea | Referencia interna
--- | --- | ---
Baseline Simple | Promedio del rating medio del usuario y del ítem; rendimiento sorprendentemente alto. | Sección 9.5
UV-Decomposition | Factorización $M \approx UV$ para predecir celdas vacías mediante factores latentes. | Sección 9.6
RMSE | Raíz del error cuadrático medio; métrica objetivo a minimizar. | Sección 9.6
Ensemble Strategy | Combinación de algoritmos diversos; estrategia ganadora en Netflix. | Sección 9.5
Temporal Dynamics | Variación de preferencias en el tiempo (ej. Memento vs Patch Adams). | Sección 9.5
Sparsity Handling | Uso de clustering previo para permitir cálculo de similitudes en matrices vacías. | Sección 9.6
Local Optima | Riesgo en UV-Decomposition; mitigado con múltiples inicios aleatorios. | Sección 9.6
Normalization | Centrado de datos (fila/columna) esencial para distancia coseno y UV. | Sección 9.6


