# Parte 45 - CUR Decomposition and Sparse Matrices

## 1. Metadatos del documento
- **Libro:** Mining of Massive Datasets, 3ª ed.
- **Fragmento/Parte:** Parte 45 - CUR Decomposition and Sparse Matrices
- **Temas principales:** Descomposición CUR, Matrices dispersas (Sparse Matrices), Pseudoinversa de Moore-Penrose, Norma de Frobenius, SVD vs CUR, Reducción de dimensionalidad.
- **Tipo de contenido:** Teoría / Algoritmo / Mixto.

## 2. Resumen técnico de alto valor
La descomposición CUR se presenta como una alternativa a la SVD para matrices grandes y dispersas (sparse). Mientras que la SVD genera matrices densas $U$ y $V$ incluso cuando la matriz original $M$ es dispersa (lo que es computacionalmente prohibitivo para millones de filas/columnas), CUR construye la aproximación utilizando filas y columnas reales de $M$. Esto garantiza que las matrices $C$ (columnas) y $R$ (filas) sean tan dispersas como la original. El método selecciona filas y columnas mediante muestreo aleatorio ponderado por la norma de Frobenius al cuadrado (importancia), y construye una matriz intermedia $U$ utilizando la pseudoinversa de Moore-Penrose de la intersección $W$. A diferencia de SVD, CUR es una aproximación probabilística; no es exacta incluso si $r$ es igual al rango de $M$, pero ofrece ventajas de interpretabilidad y eficiencia de almacenamiento masivo.

## 3. Conceptos y definiciones clave
- **Descomposición CUR:** Factorización de una matriz $M$ en tres matrices: $C$ (columnas seleccionadas de $M$), $U$ (matriz de interconexión calculada vía pseudoinversa) y $R$ (filas seleccionadas de $M$).
- **Matriz Dispersa (Sparse Matrix):** Matriz donde la mayoría de las entradas son 0. Común en sistemas de recomendación (usuario-producto) y texto (documento-palabra).
- **Norma de Frobenius al cuadrado ($f$):** Suma de los cuadrados de todos los elementos de la matriz. Se utiliza como medida de "importancia" o probabilidad de selección. $f = \sum_{i,j} m_{ij}^2$.
- **Pseudoinversa de Moore-Penrose ($\Sigma^+$):** Generalización de la inversa para matrices singulares o no cuadradas. Para una matriz diagonal $\Sigma$, se calcula invirtiendo los elementos no nulos y manteniendo en cero los nulos.
- **Matriz $W$:** Matriz intermedia de tamaño $r \times r$ formada por la intersección de las filas seleccionadas para $R$ y las columnas seleccionadas para $C$.
- **Concepto (en SVD):** Vectores latentes que conectan filas y columnas (ej. géneros de películas). SVD es óptimo para capturar conceptos, pero denso.

## 4. Principios, reglas y heurísticas
- **Regla de selección de columnas:** La probabilidad $q_j$ de seleccionar la columna $j$ es proporcional a su norma al cuadrado: $q_j = \frac{\sum_i m_{ij}^2}{f}$.
- **Regla de selección de filas:** La probabilidad $p_i$ de seleccionar la fila $i$ es proporcional a su norma al cuadrado: $p_i = \frac{\sum_j m_{ij}^2}{f}$.
- **Regla de escalado:** Toda fila/columna seleccionada debe dividirse por $\sqrt{r \cdot \text{probabilidad}}$ para mantener la invarianza estadística y la escala correcta.
- **Trade-off Exactitud vs. Eficiencia:** SVD es exacta y minimiza el error, pero genera matrices densas inmanejables. CUR es aproximada y probabilística, pero presensa la dispersión (sparsity).
- **Tratamiento de duplicados:** Si una fila/columna se selecciona $k$ veces, se fusionan en una sola y se multiplica el vector resultante por $\sqrt{k}$.

## 5. Procedimientos, métodos y workflows

### Algoritmo de Descomposición CUR
**Precondiciones:** Matriz $M$ de tamaño $m \times n$, parámetro de reducción $r$.

1.  **Cálculo de probabilidades:**
    *   Calcular la suma de cuadrados de todos los elementos $f$.
    *   Calcular probabilidad $p_i$ para cada fila y $q_j$ para cada columna.

2.  **Construcción de $C$ (Columnas):**
    *   Seleccionar $r$ columnas de $M$ muestreando según distribución $q$.
    *   Escalar cada columna $j$ seleccionada dividiendo por $\sqrt{r \cdot q_j}$.

3.  **Construcción de $R$ (Filas):**
    *   Seleccionar $r$ filas de $M$ muestreando según distribución $p$.
    *   Escalar cada fila $i$ seleccionada dividiendo por $\sqrt{r \cdot p_i}$.

4.  **Construcción de $W$ (Intersección):**
    *   Formar $W$ ($r \times r$) tomando los elementos de $M$ que están en las filas seleccionadas y columnas seleccionadas.

5.  **Construcción de $U$ (Conexión):**
    *   Calcular SVD de $W = X \Sigma Y^T$.
    *   Calcular pseudoinversa $\Sigma^+$ (invertir valores no nulos en la diagonal).
    *   Calcular $U = Y (\Sigma^+)^2 X^T$.

**Postcondición:** Matrices $C, U, R$ tales que $C \times U \times R \approx M$.

## 6. Problemas comunes y soluciones
- **Problema:** Matrices densas resultantes de SVD en datos masivos.
    - **Solución:** Utilizar CUR Decomposition para preservar la dispersión en $C$ y $R$.
- **Problema:** Duplicación de filas/columnas en el muestreo aleatorio.
    - **Solución:** Fusionar las $k$ copias idénticas en un solo vector y multiplicar sus elementos por $\sqrt{k}$. Ajustar dimensiones de $W$ y calcular pseudoinversa con transposición si la matriz diagonal resultante no es cuadrada.
- **Problema:** Matriz $W$ no cuadrada tras fusión de duplicados.
    - **Solución:** La pseudoinversa de una matriz diagonal con dimensiones desiguales requiere transponer el resultado final de la matriz de valores singulares.

## 7. Implementación técnica y generación de código

```pseudocode
# Algoritmo: CUR Decomposition
Entrada: Matriz M (m x n), entero r
Salida: Matrices C, U, R

# Paso 1: Calcular probabilidades
f = suma_cuadrados(M)
probs_col = [suma_cuadrados(col) / f para col en columnas(M)]
probs_row = [suma_cuadrados(fil) / f para fil en filas(M)]

# Paso 2: Seleccionar y escalar C
indices_C = muestrear_con_reemplazo(range(n), probs_col, r)
C = matriz_vacia(m, r)
Para j en 0..r-1:
    idx = indices_C[j]
    C[:, j] = M[:, idx] / sqrt(r * probs_col[idx])

# Paso 3: Seleccionar y escalar R
indices_R = muestrear_con_reemplazo(range(m), probs_row, r)
R = matriz_vacia(r, n)
Para i en 0..r-1:
    idx = indices_R[i]
    R[i, :] = M[idx, :] / sqrt(r * probs_row[idx])

# Paso 4: Construir W y U
W = M[indices_R, :][:, indices_C] # Intersección
U, Sigma, Vt = SVD(W)
Sigma_plus = pseudoinversa(Sigma) # Invertir no nulos
U_final = Vt.T @ (Sigma_plus @ Sigma_plus) @ U.T

Retornar C, U_final, R
```

```python
import numpy as np

def cur_decomposition(M, r):
    """
    Implementación básica de CUR Decomposition basada en el libro.
    M: Matriz numpy 2D.
    r: Número de conceptos/filas/columnas a seleccionar.
    """
    m, n = M.shape
    
    # 1. Calcular probabilidades (Norma Frobenius al cuadrado)
    f = np.sum(M**2)
    if f == 0: return None, None, None # Evitar división por cero
    
    # Probabilidad de columnas (para C)
    col_norms_sq = np.sum(M**2, axis=0)
    probs_col = col_norms_sq / f
    
    # Probabilidad de filas (para R)
    row_norms_sq = np.sum(M**2, axis=1)
    probs_row = row_norms_sq / f
    
    # 2. Construcción de C
    # Seleccionar r índices con reemplazo según probs_col
    selected_cols_idx = np.random.choice(n, size=r, replace=True, p=probs_col)
    C = np.zeros((m, r))
    
    for j, idx in enumerate(selected_cols_idx):
        # Escalar: dividir por sqrt(r * prob)
        scale = np.sqrt(r * probs_col[idx])
        if scale > 0:
            C[:, j] = M[:, idx] / scale
        else:
            C[:, j] = M[:, idx]

    # 3. Construcción de R
    selected_rows_idx = np.random.choice(m, size=r, replace=True, p=probs_row)
    R = np.zeros((r, n))
    
    for i, idx in enumerate(selected_rows_idx):
        scale = np.sqrt(r * probs_row[idx])
        if scale > 0:
            R[i, :] = M[idx, :] / scale
        else:
            R[i, :] = M[idx, :]
            
    # 4. Construcción de W y U
    # W es la intersección de filas y columnas seleccionadas
    W = M[np.ix_(selected_rows_idx, selected_cols_idx)]
    
    # SVD de W: W = X Sigma Y^T
    # numpy devuelve U, s, Vt donde W = U @ np.diag(s) @ Vt
    X, sigma, Yt = np.linalg.svd(W, full_matrices=False)
    
    # Pseudoinversa de Sigma (Moore-Penrose)
    # Invertir valores no nulos
    sigma_plus = np.zeros_like(sigma)
    mask = sigma > 1e-10 # Umbral pequeño para evitar inestabilidad numérica
    sigma_plus[mask] = 1.0 / sigma[mask]
    
    # Calcular U = Y (Sigma+)^2 X^T
    # Y es Yt.T, X.T es X.T
    # U = Yt.T @ np.diag(sigma_plus**2) @ X.T
    U = (Yt.T @ np.diag(sigma_plus**2)) @ X.T
    
    return C, U, R
```

## 8. Funciones, métodos, librerías o comandos identificados
- **`np.linalg.svd`**: Función estándar para calcular la Descomposición en Valores Singulares, necesaria para calcular la matriz $U$ en CUR.
- **`np.random.choice`**: Función para realizar el muestreo aleatorio ponderado (weighted sampling) necesario para seleccionar filas y columnas.
- **Norma de Frobenius**: Métrica clave para determinar la "importancia" de una fila o columna.
- **Pseudoinversa (`sigma_plus`)**: Operación algebraica para invertir valores singulares no nulos.

## 9. Snippets o plantillas reutilizables

```python
# Función auxiliar para calcular la probabilidad de selección de filas/columnas
def calculate_selection_probs(M):
    """Calcula probabilidades basadas en la norma de Frobenius al cuadrado."""
    f = np.sum(M**2)
    if f == 0: raise ValueError("La matriz es cero.")
    
    # Probabilidades columnas (suma de cuadrados por columna)
    p_cols = np.sum(M**2, axis=0) / f
    
    # Probabilidades filas (suma de cuadrados por fila)
    p_rows = np.sum(M**2, axis=1) / f
    
    return p_rows, p_cols

# Función auxiliar para construir la matriz U desde W
def compute_U_matrix(W):
    """Calcula la matriz U central de CUR decomposition."""
    X, sigma, Yt = np.linalg.svd(W, full_matrices=False)
    
    # Pseudoinversa: 1/sigma si sigma != 0
    with np.errstate(divide='ignore'):
        sigma_plus = np.where(sigma > 0, 1.0 / sigma, 0)
        
    # U = Y (Sigma+)^2 X^T
    # En numpy SVD: W = X @ diag(sigma) @ Yt
    # Por tanto Y = Yt.T
    U = Yt.T @ np.diag(sigma_plus**2) @ X.T
    return U
```

## 10. Casos de uso y aplicaciones
- **Sistemas de Recomendación:** Matrices Usuario-Producto. Permite mantener la interpretabilidad (las columnas de $C$ son usuarios reales, las filas de $R$ son productos reales) a diferencia de los "conceptos" abstractos de SVD.
- **Procesamiento de Texto:** Matrices Documento-Término. La dispersión es crítica aquí; CUR permite reducir dimensionalidad sin expandir la memoria requerida a matrices densas.
- **Análisis de Grafos:** Matrices de adyacencia grandes y dispersas.

## 11. Limitaciones, riesgos y precauciones
- **Aproximación No Exacta:** CUR no garantiza una reconstrucción exacta incluso si $r$ es grande. Para obtener errores bajos (ej. 1%), $r$ podría necesitar ser tan grande que el método se vuelve impráctico.
- **Aleatoriedad:** Los resultados varían entre ejecuciones. Se requiere un $r$ suficientemente grande para estabilidad estadística.
- **Complejidad de $W$:** Si bien $C$ y $R$ son dispersas, el cálculo de $U$ requiere la SVD de $W$, que es densa, aunque pequeña ($r \times r$).
- **Duplicados:** Si no se manejan correctamente los duplicados (fusionando y escalando), el rango de la aproximación se ve afectado negativamente.

## 12. Relaciones con otros temas del corpus
- **SVD (Singular Value Decomposition):** CUR es una alternativa aproximada a SVD diseñada para datos dispersos. Utiliza SVD internamente para calcular la matriz $U$.
- **PCA (Principal Component Analysis):** Técnica relacionada con SVD para reducción de dimensionalidad, pero también sufre de problemas de densidad.
- **Norma de Frobenius:** Concepto matemático fundamental para la selección de características en este algoritmo.
- **Matrices Dispersas:** Contexto fundamental donde CUR supera a SVD.

## 13. Preguntas que la skill debería poder responder
1. ¿Por qué SVD no es adecuada para matrices muy grandes y dispersas?
2. ¿Cómo se seleccionan las filas y columnas en la descomposición CUR y por qué se usa la norma de Frobenius?
3. ¿Cuál es el propósito de la matriz $W$ en CUR y cómo se calcula la matriz $U$ a partir de ella?
4. ¿Cómo se debe manejar la situación donde una fila o columna es seleccionada múltiples veces en CUR?
5. ¿Qué diferencia clave existe entre la interpretabilidad de SVD y CUR?
6. ¿Qué es la pseudoinversa de Moore-Penrose y cuándo se utiliza en CUR?
7. ¿Es CUR una descomposición exacta o aproximada?
8. ¿Cómo escala el tamaño de las matrices resultantes en CUR comparado con SVD?

## 14. Acciones que la skill debería poder recomendar o ejecutar
- **Recomendar algoritmo:** Sugerir CUR sobre SVD cuando el dataset sea masivo y disperso (>90% ceros) y la memoria sea una restricción.
- **Implementar muestreo:** Calcular las probabilidades de selección para realizar el muestreo de filas/columnas.
- **Ajustar parámetro $r$:** Ayudar a elegir un valor de $r$ que balancee precisión y costo computacional (trade-off).
- **Validar dispersión:** Verificar que las matrices $C$ y $R$ resultantes mantienen la dispersión esperada.
- **Fusionar duplicados:** Detectar y fusionar filas/columnas duplicadas en el paso de post-procesamiento.

## 15. Activos finales de conocimiento en formato compacto

| Concepto | Descripción | Referencia |
| :--- | :--- | :--- |
| **CUR vs SVD** | CUR preserva dispersión (sparse); SVD genera matrices densas ineficientes en memoria. | Sec 11.4 intro |
| **Probabilidad $p_i$** | $p_i = \frac{\sum m_{ij}^2}{f}$. Importancia basada en norma Frobenius. | Sec 11.4.2 |
| **Escalado** | Dividir vector seleccionado por $\sqrt{r \cdot \text{prob}}$. | Sec 11.4.2 |
| **Matriz $W$** | Intersección de filas $R$ y columnas $C$ seleccionadas. Tamaño $r \times r$. | Sec 11.4.1 |
| **Cálculo de $U$** | $U = Y(\Sigma^+)^2 X^T$. Derivada de SVD de $W$. | Sec 11.4.1 |
| **Pseudoinversa $\Sigma^+$** | Inverso numérico de elementos no nulos; cero para elementos nulos. | Sec 11.4.1 |
| **Duplicados** | Fusionar $k$ copias en una y multiplicar por $\sqrt{k}$. | Sec 11.4.5 |
| **Exactitud** | CUR es siempre aproximada; requiere $r$ grande para alta precisión. | Sec 11.4 intro |
| **Interpretabilidad** | $C$ y $R$ son datos reales (ej. usuarios/películas), no conceptos abstractos. | Sec 11.4 intro |
| **Aplicación** | Sistemas de recomendación y matrices documento-término. | Sec 11.4 intro |


