# Parte 44 - SVD and CUR Introduction

## 1. Metadatos del documento
- **Libro:** Mining of Massive Datasets, 3ª ed.
- **Fragmento/Parte:** Parte 44 - SVD and CUR Introduction
- **Temas principales:** Singular-Value Decomposition (SVD), Reducción de dimensionalidad, Valores singulares, Espacio de conceptos, Norma de Frobenius, Descomposición CUR, Matrices dispersas (Sparse matrices).
- **Tipo de contenido:** Teoría / Algoritmo / Mixto

## 2. Resumen técnico de alto valor
El fragmento introduce la Descomposición en Valores Singulares (SVD) como método para representar exactamente cualquier matriz $M$ de rango $r$ mediante el producto de tres matrices: $U$ (columnas ortonormales), $\Sigma$ (diagonal de valores singulares) y $V^T$ (filas ortonormales). La interpretación clave es la identificación de "conceptos" latentes: $U$ relaciona filas con conceptos, $V$ relaciona columnas con conceptos y $\Sigma$ pondera la importancia de cada concepto. La reducción de dimensionalidad se logra eliminando los valores singulares más pequeños (y sus columnas asociadas en $U$ y $V$), lo cual minimiza el error cuadrático medio (RMSE) o la norma de Frobenius de la diferencia entre la matriz original y su aproximación. Se presenta una regla heurística para retener el 90% de la "energía" (suma de cuadrados de valores singulares). El texto también detalla cómo calcular la SVD mediante los autovalores y autovectores de $M^T M$ y $M M^T$. Finalmente, se introduce la descomposición CUR como una alternativa a SVD para matrices dispersas masivas, ya que SVD genera matrices densas $U$ y $V$ que son inmanejables en grandes escalas, mientras que CUR preserva la dispersión en sus matrices $C$ y $R$.

## 3. Conceptos y definiciones clave
- **Singular-Value Decomposition (SVD):** Factorización de una matriz $M$ de dimensiones $m \times n$ y rango $r$ en $M = U \Sigma V^T$.
- **Matriz $U$ (Usuario/Concepto):** Matriz $m \times r$ columnas ortonormales. Representa la extensión en la que cada fila (ej. usuario) participa en cada concepto.
- **Matriz $\Sigma$ (Sigma):** Matriz diagonal $r \times r$. Contiene los valores singulares ($\sigma_i$) en orden descendente. Representan la "fuerza" o importancia de cada concepto.
- **Matriz $V$ (Ítem/Concepto):** Matriz $n \times r$ columnas ortonormales. Representa la extensión en la que cada columna (ej. ítem) participa en cada concepto.
- **Rango ($r$):** Máximo número de filas (o columnas) independientes. Define el número de conceptos en la descomposición exacta.
- **Conceptos:** Variables latentes ocultas que conectan filas y columnas (ej. géneros de cine en un sistema de recomendación).
- **Energía:** Suma de los cuadrados de los valores singulares. Métrica para decidir cuántos dimensiones retener.
- **Norma de Frobenius:** Raíz cuadrada de la suma de los cuadrados de los elementos de la matriz. Equivalente a la distancia Euclidiana en espacio matricial.
- **Descomposición CUR:** Aproximación matricial $M = CUR$ donde $C$ son columnas y $R$ filas de $M$. Ventaja: $C$ y $R$ son dispersas si $M$ lo es.

## 4. Principios, reglas y heurísticas
- **Principio de minimización del error:** Al reducir dimensionalidad, poner a cero los valores singulares más pequeños minimiza la norma de Frobenius de la diferencia entre la matriz original y la aproximada.
- **Regla del 90% de energía:** Retener suficientes valores singulares para que la suma de sus cuadrados sea al menos el 90% de la suma de cuadrados total.
- **Trade-off dispersión vs. exactitud:** SVD es exacta pero densa (ineficiente para datos masivos dispersos). CUR es aproximada pero dispersa (eficiente).
- **Relación SVD - Autovalores:** Los valores singulares de $M$ son las raíces cuadradas de los autovalores de $M^T M$ o $M M^T$.
- **Independencia:** Si el rango es $r$, no existe un conjunto de $r+1$ filas (o columnas) que sea linealmente independiente.

## 5. Procedimientos, métodos y workflows

### 5.1 Cálculo de la SVD a partir de autovalores
**Precondiciones:** Matriz $M$ de tamaño $m \times n$.
**Pasos:**
1. Calcular la matriz cuadrada $M^T M$ (tamaño $n \times n$).
2. Encontrar los autovalores y autovectores de $M^T M$.
3. Ordenar los autovalores en orden descendente. Construir $\Sigma$ con la raíz cuadrada de estos autovalores.
4. Construir $V$ con los autovectores correspondientes como columnas.
5. Calcular la matriz cuadrada $M M^T$ (tamaño $m \times m$).
6. Encontrar autovectores de $M M^T$ para construir $U$.
**Postcondición:** $M = U \Sigma V^T$.

### 5.2 Reducción de dimensionalidad (Truncated SVD)
**Pasos:**
1. Realizar SVD completa.
2. Decidir el número de dimensiones $k$ a retener (basado en regla de energía o requerimientos).
3. Eliminar las últimas $r-k$ columnas de $U$ y $V$.
4. Eliminar los últimos $r-k$ valores en la diagonal de $\Sigma$ (o ponerlos a 0).
5. Resultado: Aproximación $M' = U_k \Sigma_k V_k^T$.

### 5.3 Consulta en espacio de conceptos (Querying)
**Contexto:** Recomendación de ítems a un nuevo usuario.
**Pasos:**
1. Representar al usuario como vector $q$ en el espacio original (ej. ratings de películas).
2. Mapear al espacio de conceptos: $q_{concept} = q V$.
3. Para predecir preferencias (volver al espacio original): $q_{reconstructed} = q_{concept} V^T$.
4. Para encontrar usuarios similares: calcular distancia coseno entre vectores en el espacio de conceptos ($q_{concept}$ vs filas de $U \Sigma$ o similar).

## 6. Problemas comunes y soluciones
- **Problema:** Matrices $U$ y $V$ resultantes de SVD son densas incluso si $M$ es dispersa.
  - **Impacto:** Imposibilidad de almacenar o procesar matrices de miles de millones de filas/columnas.
  - **Solución:** Utilizar **Descomposición CUR**, la cual selecciona columnas y filas reales de $M$, preservando la dispersión.
- **Problema:** Pérdida de precisión al reducir dimensionalidad.
  - **Mitigación:** Asegurar que la energía retenida sea alta (>90%). El error introducido es proporcional a la suma de los cuadrados de los valores singulares eliminados.
- **Problema:** Definición de "conceptos" en SVD.
  - **Limitación:** Los conceptos son combinaciones lineales abstractas. A menudo no son interpretables directamente (salvo en casos ideales como el ejemplo del libro), a diferencia de CUR que usa filas/columnas reales.

## 7. Implementación técnica y generación de código

```pseudocode
# Algoritmo: Cálculo de SVD y Reducción
Entrada: Matriz M (m x n), entero k (dimensiones a retener)
Salida: Matrices U, Sigma, V

# Paso 1: Calcular productos matriciales
A = M_transpuesta * M
B = M * M_transpuesta

# Paso 2: Calcular autovalores/autovectores
# Nota: Los autovalores de A y B son los mismos (excepto ceros extra)
autovalores, V = eigen(A) # V son autovectores columnas
_, U = eigen(B)

# Paso 3: Ordenar y construir Sigma
# Ordenar autovalores descendientemente y reordenar U y V acorde
orden = sort_indices(autovalores, descending=True)
autovalores_ordenados = autovalores[orden]
V = V[:, orden]
U = U[:, orden] # Asumiendo correspondencia correcta de signos/orden

Sigma = diagonal(sqrt(autovalores_ordenados))

# Paso 4: Reducción (Truncamiento)
# Mantener solo los primeros k valores
U_k = U[:, 0:k]
Sigma_k = Sigma[0:k, 0:k]
V_k = V[:, 0:k]

Retornar U_k, Sigma_k, V_k_transpuesta
```

```python
import numpy as np

def svd_reduction(M, k=None, energy_threshold=0.90):
    """
    Realiza SVD y reduce dimensionalidad basándose en energía o k fijo.
    M: Matriz numpy 2D.
    k: Número de componentes (opcional).
    energy_threshold: Umbral mínimo de energía a retener (si k no se especifica).
    """
    # 1. Calcular SVD
    # En numpy, V ya viene transpuesta como vt
    U, s, vt = np.linalg.svd(M, full_matrices=False)
    
    # 2. Calcular energía total
    total_energy = np.sum(s**2)
    
    # 3. Determinar k si no se provee
    if k is None:
        cumulative_energy = np.cumsum(s**2)
        # Encontrar primer índice donde la energía acumulada >= umbral
        k = np.searchsorted(cumulative_energy / total_energy, energy_threshold) + 1
        print(f"Reteniendo {k} dimensiones para alcanzar {energy_threshold*100}% de energía.")
    
    # 4. Truncar matrices
    U_k = U[:, :k]
    s_k = s[:k]
    vt_k = vt[:k, :]
    
    # 5. Reconstrucción aproximada (opcional)
    # Sigma_k es diagonal, optimizamos usando broadcasting
    M_approx = U_k @ np.diag(s_k) @ vt_k
    
    return U_k, s_k, vt_k, M_approx

# Ejemplo de uso con datos del libro (simplificado)
M = np.array([
    [1, 1, 1, 0, 0],
    [3, 3, 3, 0, 0],
    [4, 4, 4, 0, 0],
    [5, 5, 5, 0, 0],
    [0, 0, 0, 4, 4],
    [0, 0, 0, 5, 5],
    [0, 0, 0, 2, 2]
])

U, s, vt, M_rec = svd_reduction(M, k=2) # Forzamos k=2 como en el ejemplo del libro
```

## 8. Funciones, métodos, librerías o comandos identificados
- `np.linalg.svd`: Función estándar en NumPy para calcular la descomposición.
- `np.linalg.eig`: Función para calcular autovalores y autovectores (base teórica de SVD).
- `np.cumsum`: Útil para calcular la energía acumulada y aplicar la regla del 90%.
- `np.diag`: Construcción de la matriz diagonal $\Sigma$ a partir del vector de valores singulares.
- Dot product (`@` o `dot`): Operación fundamental para reconstruir la matriz o proyectar consultas ($qV$).

## 9. Snippets o plantillas reutilizables

**Plantilla: Proyección de nuevo usuario a espacio de conceptos**
```python
def project_user_to_concept(user_vector, V_matrix):
    """
    Mapea un usuario al espacio de conceptos latentes.
    user_vector: Array 1D de ratings del usuario en espacio original.
    V_matrix: Matriz V de la SVD (items x conceptos).
    """
    # q_concept = q * V
    return user_vector @ V_matrix

def predict_user_preferences(user_concept_vector, Vt_matrix, Sigma_matrix):
    """
    Predice ratings del usuario en el espacio original.
    """
    # q_reconstructed = q_concept * Sigma * Vt
    # O equivalentemente: q * V * Vt (si no ponderamos por Sigma en la proyección inversa simple)
    # Para predicción completa estándar: user_concept * Sigma * Vt
    return user_concept_vector @ Sigma_matrix @ Vt_matrix
```

## 10. Casos de uso y aplicaciones
- **Sistemas de Recomendación (Collaborative Filtering):** Uso de SVD para identificar conceptos latentes (géneros, estilos) y predecir ratings de usuarios para ítems no vistos (Ejemplo 11.8 y 11.11).
- **Reducción de Ruido:** Eliminación de valores singulares pequeños para limpiar datos espurios o ruido en la matriz original.
- **Compresión de Datos:** Almacenar $U, \Sigma, V$ truncados requiere menos espacio que la matriz original si el rango es bajo.
- **Procesamiento de Texto (LSI):** Aunque no detallado en este fragmento, se menciona la analogía documentos-palabras donde la matriz es dispersa, sugiriendo SVD/CUR para análisis semántico latente.

## 11. Limitaciones, riesgos y precauciones
- **Complejidad Computacional:** Calcular autovalores de $M M^T$ es costoso para matrices grandes. SVD escala mal con $m$ y $n$.
- **Densidad de Salida:** SVD convierte matrices dispersas en densas. Para Big Data, esto es un cuello de botella de memoria crítico.
- **Interpretabilidad:** Los conceptos en SVD son abstractos. En CUR, las matrices $C$ y $R$ son interpretables (son columnas/filas reales), pero el texto advierte que CUR es una aproximación y requiere $r$ grande para alta precisión.
- **Estabilidad Numérica:** Los valores singulares pequeños pueden ser inestables o ruido; truncarlos es una decisión de diseño, no solo de almacenamiento.

## 12. Relaciones con otros temas del corpus
- **Álgebra Lineal (Autovalores/Eigenvectores):** Fundamento matemático directo de SVD.
- **MinHash / LSH:** Técnicas de reducción de dimensionalidad para conjuntos y búsqueda de similitud aproximada (contexto de capítulos anteriores del libro).
- **PageRank:** Uso de autovalores para determinar importancia, relacionado conceptualmente con la "fuerza" de los conceptos en SVD.
- **Matrices dispersas (Sparse Matrices):** Concepto crítico que motiva la existencia de CUR frente a SVD.

## 13. Preguntas que la skill debería poder responder
1. ¿Por qué la descomposición SVD genera matrices densas incluso si la entrada es dispersa?
2. ¿Cómo se relacionan los valores singulares de $M$ con los autovalores de $M^T M$?
3. ¿Qué criterio se utiliza para decidir cuántos valores singulares descartar en la reducción de dimensionalidad?
4. ¿Cuál es la diferencia fundamental entre SVD y CUR Decomposition en términos de manejo de datos masivos?
5. ¿Cómo se utiliza la matriz $V$ para transformar un vector de consulta (usuario) al espacio de conceptos?
6. ¿Por qué poner a cero los valores singulares más pequeños minimiza el error RMSE?
7. ¿Qué representan las matrices $U$, $\Sigma$ y $V$ en el contexto de un sistema de recomendación usuario-ítem?
8. ¿Qué es la "energía" de una matriz en el contexto de SVD y cómo se calcula?

## 14. Acciones que la skill debería poder recomendar o ejecutar
- **Selección de Algoritmo:** Recomendar CUR sobre SVD si el dataset es masivo y disperso (ej. >90% de ceros).
- **Ajuste de Hiperparámetros:** Calcular el número óptimo de dimensiones $k$ basándose en la regla del 90% de energía.
- **Implementación de Consultas:** Guiar la implementación de un motor de recomendación simple usando proyección $qV$ y distancia coseno.
- **Diagnóstico de Error:** Verificar si la reducción de dimensionalidad ha perdido demasiada información comparando la energía retenida.

## 15. Activos finales de conocimiento en formato compacto

| Concepto | Descripción en una línea | Referencia interna |
|---|---|---|
| **SVD** | Factorización $M = U \Sigma V^T$ que descompone una matriz en conceptos latentes. | Sec. 11.3.1 |
| **Valores Singulares** | Elementos de la diagonal de $\Sigma$; raíces cuadradas de autovalores de $M^T M$. | Sec. 11.3.6 |
| **Regla del 90%** | Heurística para retener dimensiones cuya energía acumulada $\ge$ 90% del total. | Sec. 11.3.4 |
| **Espacio de Conceptos** | Representación reducida donde filas/columnas se relacionan por variables latentes. | Sec. 11.3.2 |
| **Norma Frobenius** | Métrica de error minimizada al truncar SVD; suma de cuadrados de elementos. | Sec. 11.3.4 |
| **CUR Decomposition** | Alternativa a SVD que preserva dispersión usando columnas/filas reales ($C, R$). | Sec. 11.4 |
| **Matriz Densa** | Problema de SVD: $U$ y $V$ son densas aunque $M$ sea dispersa. | Sec. 11.4 |
| **Querying SVD** | Proceso $q_{concept} = qV$ para mapear usuarios a conceptos latentes. | Sec. 11.3.5 |
| **Rango ($r$)** | Número de filas/columnas independientes; define la dimensionalidad exacta. | Sec. 11.3.1 |
| **RMSE Minimization** | Propiedad matemática que justifica eliminar valores singulares pequeños. | Sec. 11.3.4 |


