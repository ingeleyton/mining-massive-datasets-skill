# parte-32 — Mining-of-Massive-Datasets-Third-Edition-Jure-Leskovec-Anand-Rajaraman-etc-z-library-sk-1lib-sk-z-lib-parte-32.pdf

## 1. Metadatos del documento
- **Libro:** Mining of Massive Datasets, 3ª ed.
- **Fragmento/Parte:** Capítulo 9.3 - Collaborative Filtering & 9.4 - Dimensionality Reduction (UV-Decomposition)
- **Temas principales:** Filtrado Colaborativo, Matriz de Utilidad, Similitud de Usuarios/Items, Normalización de Ratings, Clustering, Descomposición UV.
- **Tipo de contenido:** Teoría / Algoritmo / Mixto

## 2. Resumen técnico de alto valor
El fragmento aborda el **Filtrado Colaborativo** como alternativa a los sistemas basados en contenido, utilizando la estructura de la **Matriz de Utilidad** (usuarios x items) para inferir similitudes. Se analizan críticamente distintas métricas de distancia: la **Distancia Jaccard** resulta inadecuada para ratings por ignorar la magnitud; la **Distancia Coseno** sobre datos crudos es problemática al tratar los valores vacíos ("blanks") como ceros (asociando "no calificado" con "no me gusta"). La solución propuesta es la **normalización de ratings** (restar la media del usuario), que permite detectar opiniones opuestas (vectores con ángulos cercanos a 180 grados).

Se presenta la **dualidad usuario-item**: la similitud item-item suele ser más robusta y estable (los items pertenecen a géneros específicos, los usuarios tienen gustos eclécticos), mientras que la similitud usuario-usuario es computacionalmente más eficiente para consultas individuales si se precomputa. Para mitigar la **esparcidad (sparsity)**, se propone el **clustering** jerárquico de usuarios e items, promediando ratings dentro de los clústeres para densificar la matriz. Finalmente, se introduce la **Descomposición UV** como técnica de reducción de dimensionalidad, factorizando la matriz de utilidad $M$ en dos matrices rank-reduced $U$ y $V$ ($M \approx UV$) para estimar valores faltantes basándose en características latentes.

## 3. Conceptos y definiciones clave
- **Filtrado Colaborativo:** Proceso de recomendación basado en identificar usuarios similares y recomendar items que a esos usuarios les gustaron, sin usar características intrínsecas de los items.
- **Matriz de Utilidad (Utility Matrix):** Estructura $R^{n \times m}$ donde las filas representan usuarios, las columnas items y las entradas representan ratings o compras. Es inherentemente dispersa (sparse).
- **Distancia Jaccard:** Medida de similitud basada en la intersección sobre la unión de conjuntos. $Sim = |A \cap B| / |A \cup B|$. Ignora los valores numéricos de los ratings, tratándolos como binarios.
- **Distancia Coseno:** Medida de similitud entre vectores. $Sim = \cos(\theta) = (A \cdot B) / (||A|| ||B||)$. En filtrado colaborativo, requiere estrategia para manejar valores vacíos (blanks).
- **Normalización de Ratings:** Transformación de ratings restando el promedio del usuario. Convierte ratings bajos en negativos y altos en positivos, permitiendo que la distancia coseno maneje adecuadamente las diferencias de opinión y los valores faltantes (cero tras normalización implica indiferencia o rating promedio, no "no me gusta").
- **Dualidad de Similitud:** Principio por el cual los métodos de similitud aplican tanto a filas (usuarios) como a columnas (items), pero con implicaciones prácticas diferentes (estabilidad de items vs. diversidad de usuarios).
- **Descomposición UV (UV-Decomposition):** Método de factorización matricial donde $M \approx U \times V$. $U$ ($n \times d$) representa la relación de usuarios con $d$ características latentes, y $V$ ($d \times m$) representa la relación de esas características con los items.

## 4. Principios, reglas y heurísticas
- **Selección de Métrica:** Usar Jaccard solo si la matriz es binaria (comprado/no comprado). Para ratings, Jaccard pierde información crítica.
- **Tratamiento de Blanks:** No tratar valores vacíos como cero en distancia coseno sin normalización previa, ya que introduce un sesgo negativo falso.
- **Normalización Obligatoria:** Para ratings con escala, normalizar restando la media del usuario antes de calcular similitud coseno. Esto permite que usuarios con opiniones opuestas tengan un coseno cercano a -1 (muy distantes).
- **Preferencia de Similitud:** Preferir similitud item-item sobre usuario-usuario cuando se busca estabilidad y fiabilidad (los items son más fáciles de clasificar que los usuarios).
- **Eficiencia Computacional:** Precomputar las similitudes y mantener los resultados fijos entre actualizaciones, ya que la matriz de utilidad evoluciona lentamente.
- **Gestión de Esparsidad:** Si la matriz es demasiado dispersa para encontrar pares calificados, aplicar clustering para reducir la dimensionalidad y aumentar la densidad de datos antes de calcular similitudes.

## 5. Procedimientos, métodos y workflows

### 5.1 Predicción mediante Similitud de Usuarios (User-User Collaborative Filtering)
1.  **Normalización:** Para cada usuario $u$, calcular su rating promedio $\bar{r}_u$ y restarlo de cada rating conocido $r_{ui}$ para obtener $r'_{ui}$.
2.  **Identificación de Vecinos:** Encontrar los $n$ usuarios más similares al usuario activo $U$ basándose en la distancia coseno de sus vectores normalizados.
3.  **Estimación:** Para un item $I$ no calificado por $U$, promediar los ratings normalizados de los $n$ vecinos que sí calificaron $I$.
4.  **Des-normalización:** Sumar el promedio $\bar{r}_U$ al resultado del paso 3 para obtener la predicción en la escala original.

### 5.2 Predicción mediante Clustering
1.  **Clustering de Items:** Agrupar items (columnas) usando una medida de distancia (ej. Jaccard o Coseno). Se sugiere clustering jerárquico dejando muchos clústeres (ej. la mitad del número de items).
2.  **Agregación:** Crear una nueva matriz de utilidad donde cada columna es un clúster. El valor de la celda $(u, C)$ es el promedio de los ratings del usuario $u$ sobre los items del clúster $C$.
3.  **Clustering de Usuarios:** Repetir el proceso de clustering sobre las filas de la matriz agregada.
4.  **Predicción:** Para predecir $(U, I)$, identificar el clúster de usuario $C_U$ y el clúster de item $C_I$. Usar el valor de la celda $(C_U, C_I)$ en la matriz de clústeres como estimación.

### 5.3 Inicialización de Descomposición UV
1.  Definir dimensión latente $d$ (número de características).
2.  Inicializar matrices $U$ ($n \times d$) y $V$ ($d \times m$) con valores arbitrarios (ej. aleatorios o constantes).
3.  Objetivo: Ajustar $U$ y $V$ para minimizar el error cuadrático medio (RMSE) entre $M$ y $UV$ solo en las entradas conocidas de $M$.

## 6. Problemas comunes y soluciones
- **Problema: Sesgo de "Blank = 0" en Coseno.** Calcular coseno sobre ratings crudos trata los datos faltantes como ceros, penalizando injustamente a usuarios que no han calificado items populares.
    - **Solución:** Normalizar los vectores restando la media del usuario. El cero ahora representa el rating promedio, no un disgusto.
- **Problema: Usuarios con opiniones opuestas parecen cercanos con Jaccard.** Dos usuarios que califican las mismas películas pero uno con 5 estrellas y otro con 1 estrella tienen alta similitud Jaccard (mismo conjunto de items calificados).
    - **Solución:** Usar distancia coseno sobre datos normalizados. Los vectores apuntarán en direcciones opuestas (ángulo cercano a 180°).
- **Problema: Usuario con ratings constantes (ej. todo 3).** Tras la normalización, sus valores se vuelven 0. El usuario se vuelve invisible para la distancia coseno.
    - **Solución:** Reconocer que este usuario no aporta información discriminatoria. El texto sugiere que sus opiniones "no valen la pena tomar en serio" para el modelo.
- **Problema: Esparsidad extrema.** Pocos usuarios han calificado los mismos items, haciendo imposible calcular similitud fiable.
    - **Solución:** Clustering previo de items y usuarios para densificar la matriz mediante promedios.

## 7. Implementación técnica y generación de código

```pseudocode
# Algoritmo: Predicción User-User con Normalización
Función PredecirRating(Usuario u, Item i, Matriz M, k_vecinos):
    promedio_u = Media(M[u, :])
    # 1. Normalizar toda la matriz (restar media por fila)
    M_norm = NormalizarFilas(M)
    
    # 2. Calcular similitud coseno entre u y todos los demás usuarios
    similitudes = {}
    Para cada usuario v en M:
        Si v != u:
            sim = Coseno(M_norm[u], M_norm[v])
            similitudes[v] = sim
            
    # 3. Seleccionar k vecinos más similares que hayan rateado i
    vecinos = FiltrarYOrdenar(similitudes, item=i, top_k)
    
    # 4. Calcular rating ponderado
    rating_estimado_norm = PromedioPonderado(M_norm[vecinos, i], similitudes[vecinos])
    
    # 5. Desnormalizar
    return rating_estimado_norm + promedio_u
```

```python
# Implementación Python: Cálculo de Similitud Coseno con Normalización
import numpy as np

def normalize_utility_matrix(M):
    """
    Resta la media de cada usuario (fila) de la matriz de utilidad.
    Los valores NaN (blanks) se mantienen como NaN.
    """
    # Calcular media ignorando NaNs
    user_means = np.nanmean(M, axis=1, keepdims=True)
    M_norm = M - user_means
    return M_norm, user_means

def cosine_similarity_normalized(u, v):
    """
    Calcula la similitud coseno entre dos vectores normalizados,
    ignorando las entradas donde ambos no tienen datos (NaN).
    Nota: En una implementación real, se usaría máscaras para alinear índices.
    Aquí asumimos vectores donde los blanks son 0 post-normalización 
    (aunque el libro sugiere que desaparecen, en la práctica se enmascaran).
    """
    # Filtrar donde ambos tienen datos para una comparación justa
    mask = ~np.isnan(u) & ~np.isnan(v)
    if np.sum(mask) == 0:
        return 0.0
    
    u_filt = u[mask]
    v_filt = v[mask]
    
    dot = np.dot(u_filt, v_filt)
    norm_u = np.linalg.norm(u_filt)
    norm_v = np.linalg.norm(v_filt)
    
    if norm_u == 0 or norm_v == 0:
        return 0.0
        
    return dot / (norm_u * norm_v)

# Ejemplo del libro (Fig 9.6)
# A: [4, 5, 1] -> Media 10/3 -> Norm: [2/3, 5/3, -7/3]
# C: [2, 4, 5] -> Media 11/3 -> Norm: [-5/3, 1/3, 4/3]
# Nota: El ejemplo 9.9 calcula A vs C usando solo los items en común.
# A_norm_common: [5/3, -7/3] (items 2 y 3 comunes en el ejemplo, aunque el texto dice "two movies in common")
# Revisando Fig 9.4: A calificó HP1(4), TW(5), SW1(1). C calificó HP1(2), SW1(4), SW2(5).
# Comunes: HP1 y SW1.
# A_norm_comunes: [4-3.33, 1-3.33] = [0.66, -2.33] -> [2/3, -7/3]
# C_norm_comunes: [2-3.66, 4-3.66] = [-1.66, 0.33] -> [-5/3, 1/3]
# Cálculo del libro: (5/3)(-5/3) + (-7/3)(1/3) = -25/9 - 7/9 = -32/9 = -3.55
# Denominador libro: sqrt((2/3)^2 + (5/3)^2 + (-7/3)^2) * sqrt((-5/3)^2 + (1/3)^2 + (4/3)^2)
# Esto implica que el libro usó TODOS los componentes para la normalización, 
# pero solo los comunes para el producto punto? O usó los componentes completos asumiendo 0 en blanks?
# El texto dice: "D's ratings have effectively disappeared... 0 is the same as blank".
# El cálculo en el Ej 9.9 usa los vectores completos (asumiendo blanks como 0 post-normalización).
```

## 8. Funciones, métodos, librerías o comandos identificados
- **`np.nanmean`**: Función clave para calcular la media de usuarios ignorando valores faltantes (blanks).
- **`sklearn.metrics.pairwise.cosine_similarity`**: Librería estándar para calcular similitud, requiere preprocesamiento de NaNs.
- **`scipy.cluster.hierarchy`**: Librería sugerida para implementar el clustering jerárquico mencionado en la sección 9.3.3.
- **Factorización Matricial (SVD/UV)**: Concepto matemático subyacente, implementable mediante optimización (Gradient Descent o Alternating Least Squares, aunque el libro solo menciona la descomposición conceptualmente).

## 9. Snippets o plantillas reutilizables

```python
import numpy as np
import pandas as pd

def get_user_similarity_df(df_utility):
    """
    df_utility: DataFrame con usuarios como índice y items como columnas.
    Retorna matriz de similitud coseno normalizada.
    """
    # Paso 1: Normalización (Centrado en media)
    # Advertencia: Usuarios con varianza 0 (todos ratings iguales) se vuelven 0
    df_norm = df_utility.sub(df_utility.mean(axis=1), axis=0)
    
    # Paso 2: Rellenar NaNs con 0 para cálculo matricial 
    # (Asumiendo que la normalización hace que 0 sea "neutral")
    df_filled = df_norm.fillna(0)
    
    # Paso 3: Similitud Coseno
    from sklearn.metrics.pairwise import cosine_similarity
    sim_matrix = cosine_similarity(df_filled)
    
    return pd.DataFrame(sim_matrix, index=df_utility.index, columns=df_utility.index)

# Plantilla para estimar rating
def predict_rating(user_id, item_id, df_utility, sim_matrix, k=5):
    # Obtener k usuarios más similares que hayan rateado el item
    # [Implementación lógica de selección de vecinos y promedio ponderado]
    pass
```

## 10. Casos de uso y aplicaciones
- **Recomendación de Películas:** Caso principal del texto. Usuarios con gustos opuestos (ej. A vs C en Ej 9.9) son distinguidos correctamente solo tras normalización.
- **Sistemas de E-commerce:** Detección de usuarios "eclecticos" vs items "de nicho". El texto destaca que los items suelen pertenecer a un único género (fácil de clusterizar), mientras los usuarios cruzan géneros.
- **Filtrado de Ruido:** Identificación de usuarios cuyos ratings son constantes (ej. Usuario D en Fig 9.6) y que pueden ser ignorados tras la normalización.

## 11. Limitaciones, riesgos y precauciones
- **Complejidad en Clustering:** El proceso de clustering iterativo (items -> usuarios -> items) puede ser costoso y no garantiza convergencia a clústeres óptimos.
- **Pérdida de Información en Clustering:** Promediar ratings dentro de un clúster suaviza las diferencias individuales entre items.
- **Elección de $d$ en UV-Decomposition:** El texto menciona que $d$ debe ser "relativamente pequeño", pero no da un método exacto para determinarlo (requiere validación cruzada).
- **Usuarios "Planos":** Usuarios que califican todo con el mismo valor se vuelven vectores nulos tras la normalización, haciéndolos invisibles para el modelo coseno.

## 12. Relaciones con otros temas del corpus
- **MinHash / LSH (Capítulo 3):** Mencionado como técnica para encontrar usuarios similares eficientemente en lugar de fuerza bruta.
- **Clustering (Capítulo 7):** Dependencia directa para la sección 9.3.3. Se asume conocimiento de métodos jerárquicos y distancia euclidiana/Jaccard.
- **SVD (Singular Value Decomposition):** Mencionado como la teoría general detrás de la Descomposición UV.
- **PageRank:** Concepto relacionado de estructura de grafos, aunque no aplicado directamente aquí, la idea de "importancia" subyace en la selección de vecinos.

## 13. Preguntas que la skill debería poder responder
1. ¿Por qué la distancia Jaccard es inadecuada para matrices de utilidad con ratings numéricos?
2. ¿Cómo afecta el tratamiento de valores vacíos ("blanks") como ceros en la distancia coseno sin normalización?
3. ¿Cuál es el efecto matemático de normalizar los ratings restando la media del usuario?
4. ¿En qué casos es preferible la similitud item-item sobre la similitud usuario-usuario?
5. ¿Cómo se utiliza el clustering para mitigar el problema de la esparcidad (sparsity) en la matriz de utilidad?
6. ¿Qué representa un ángulo de 180 grados entre dos vectores de usuarios normalizados?
7. ¿Qué es la Descomposición UV y cuál es su objetivo en sistemas de recomendación?
8. ¿Qué sucede con un usuario que califica todos los items con el mismo valor tras la normalización?

## 14. Acciones que la skill debería poder recomendar o ejecutar
- **Recomendar normalización:** "Antes de calcular similitud coseno, normaliza los datos restando la media del usuario para evitar sesgos por valores faltantes."
- **Seleccionar métrica:** "Si los datos son binarios (compra/no compra), usa Jaccard. Si son ratings, usa Coseno Normalizado."
- **Estrategia de optimización:** "Para sistemas grandes, precomputa la matriz de similitud item-item en batch debido a su estabilidad temporal."
- **Gestión de sparsity:** "Si la matriz tiene < 1% de densidad, aplica clustering jerárquico antes de intentar calcular similitudes par a par."

## 15. Activos finales de conocimiento en formato compacto

| Concepto | Descripción | Referencia |
|---|---|---|
| **Filtrado Colaborativo** | Recomendación basada en similitud de comportamiento (ratings) entre usuarios o items. | Sec 9.3 |
| **Normalización** | Restar media del usuario ($r - \bar{r}_u$). Convierte blanks implícitos en "neutros" y detecta antipatías. | Sec 9.3.1 |
| **Similitud Item-Item** | Más robusta que User-User; items suelen tener características únicas (géneros), usuarios son mixtos. | Sec 9.3.2 |
| **Problema Jaccard** | Ignora magnitud del rating. Usuarios opuestos (1 vs 5 estrellas) aparecen como similares. | Ej 9.7 |
| **Problema Coseno Crudo** | Trata blanks como 0. Penaliza falsamente a usuarios con pocos ratings vs items populares. | Sec 9.3.1 |
| **Clustering en CF** | Agrupar items/usuarios para reducir esparcidad. Promedio de ratings dentro del clúster. | Sec 9.3.3 |
| **UV-Decomposition** | Factorización $M \approx UV$. $U$ y $V$ capturan características latentes para predecir blanks. | Sec 9.4.1 |
| **Usuario "Invisible"** | Usuario con varianza 0 (ratings constantes). Vector normalizado es 0; no aporta al modelo. | Ej 9.9 |
| **Precomputación** | Calcular similitudes en batch. La matriz de utilidad cambia lentamente. | Sec 9.3.2 |
| **Dualidad** | Similitud aplicable a filas y columnas, pero con semántica y eficiencia distintas. | Sec 9.3.2 |
