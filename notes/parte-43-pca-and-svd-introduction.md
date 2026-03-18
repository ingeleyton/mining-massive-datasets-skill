# Parte 43 - PCA and SVD Introduction

## 1. Metadatos del documento
- **Libro:** Mining of Massive Datasets, 3ª ed.
- **Fragmento/Parte:** Parte 43 - PCA and SVD Introduction
- **Temas principales:** PCA (Análisis de Componentes Principales), Autovectores y Autovalores, Reducción de Dimensionalidad, Matrices Simétricas, SVD (Descomposición en Valores Singulares), Rotación de coordenadas.
- **Tipo de contenido:** Teoría / Algoritmo / Ejemplo Ilustrativo

## 2. Resumen técnico de alto valor
El fragmento introduce el Análisis de Componentes Principales (PCA) como una técnica para transformar datos de alta dimensión en un nuevo sistema de coordenadas donde la varianza se maximiza a lo largo de los primeros ejes. Se demuestra que tratar los datos como una matriz $M$ y calcular los autovectores de $M^T M$ (o $M M^T$) permite encontrar estas direcciones principales. La matriz de autovectores $E$ actúa como una rotación rígida del espacio; proyectar los datos originales sobre los primeros $k$ autovectores ($M E_k$) resulta en la mejor aproximación de rango $k$ que preserva la "significancia" (varianza) de los datos. Se establece la relación fundamental entre los autovalores de $M^T M$ y $M M^T$: comparten los mismos autovalores no nulos, permitiendo calcular la estructura dimensional usando la matriz más pequeña computacionalmente. Finalmente, se introduce la Descomposición en Valores Singulares (SVD) como una generalización que permite representar exactamente cualquier matriz y aproximarla eliminando conceptos menos importantes.

## 3. Conceptos y definiciones clave
- **Principal-Component Analysis (PCA):** Técnica para encontrar las direcciones (ejes) a lo largo de las cuales los datos (tuplas) se alinean mejor o tienen la mayor varianza.
- **Matriz de autovectores ($E$):** Matriz cuyas columnas son los autovectores de $M^T M$, ordenados por autovalor descendente. Representa una rotación del sistema de coordenadas original.
- **Varianza maximizada:** El eje correspondiente al autovector principal es aquel donde la dispersión de los puntos es máxima.
- **Matriz de distancias ($M M^T$):** Matriz simétrica donde la entrada $(i, j)$ es el producto escalar de la fila $i$ y la fila $j$ de $M$. Útil para encontrar similitudes entre puntos.
- **Rango de una matriz ($r$):** El número máximo de filas (o columnas) linealmente independientes. Define el número de autovalores no nulos.
- **Singular-Value Decomposition (SVD):** Método de factorización matricial que permite una representación exacta o aproximada de una matriz mediante "conceptos" latentes.

## 4. Principios, reglas y heurísticas
- **Regla de selección de ejes:** Para reducir dimensionalidad, seleccionar siempre los autovectores asociados a los mayores autovalores, ya que capturan la mayor varianza (información) de los datos.
- **Cálculo eficiente:** Si $M$ tiene más filas que columnas ($m > n$), calcular autovalores de $M^T M$ (tamaño $n \times n$) en lugar de $M M^T$ (tamaño $m \times m$) para reducir costo computacional.
- **Relación de autovalores:** Los autovalores de $M M^T$ son los mismos que los de $M^T M$, con la adición de ceros extra si las dimensiones de las matrices difieren.
- **Proyección óptima:** La proyección de los datos sobre el eje del autovector principal minimiza el error cuadrático medio entre los puntos originales y su representación reducida.

## 5. Procedimientos, métodos y workflows
### Procedimiento PCA (Basado en Sección 11.2.1 y 11.2.2)
1.  **Representación:** Construir la matriz $M$ donde cada fila es un punto en el espacio $n$-dimensional.
2.  **Cálculo de covarianza:** Calcular $M^T M$ (o $M M^T$ según convenga por tamaño).
3.  **Descomposición espectral:** Encontrar los pares eigen (autovalores $\lambda$ y autovectores $e$) de la matriz resultante.
4.  **Ordenamiento:** Ordenar los autovectores en una matriz $E$ de mayor a menor autovalor.
5.  **Transformación:** Rotar los datos multiplicando $M$ por $E$. El resultado $ME$ son los datos en el nuevo sistema de coordenadas.
6.  **Reducción (Opcional):** Para reducir a $k$ dimensiones, tomar las primeras $k$ columnas de $E$ ($E_k$) y calcular $M E_k$.

### Relación entre $M^T M$ y $M M^T$
1.  Si $e$ es autovector de $M^T M$ con autovalor $\lambda$, entonces $Me$ es autovector de $M M^T$ con el mismo autovalor $\lambda$ (si $Me \neq 0$).
2.  Si $M^T e = 0$, entonces $\lambda = 0$.

## 6. Problemas comunes y soluciones
> *Sección no aplicable a este fragmento.*

## 7. Implementación técnica y generación de código

```pseudocode
# Algoritmo PCA conceptual basado en el texto
Entrada: Matriz M (m x n), entero k (dimensiones deseadas)
Salida: Matriz M_reducida (m x k)

1. Calcular A = M^T * M  # Matriz n x n
2. Calcular autovalores y autovectores de A
3. Ordenar autovectores por autovalor descendente -> E
4. Seleccionar las primeras k columnas de E -> E_k
5. Retornar M * E_k
```

```python
# Implementación del Ejemplo 11.2.1 y 11.6 del libro
import numpy as np

def pca_example():
    # Definición de la matriz M (4 puntos en 2D)
    M = np.array([
        [1, 2],
        [2, 1],
        [3, 4],
        [4, 3]
    ])
    
    # Paso 1: Calcular M^T M
    MTM = np.dot(M.T, M)
    # Resultado esperado según libro: [[30, 28], [28, 30]]
    
    # Paso 2: Calcular autovalores y autovectores
    # Nota: np.linalg.eig devuelve los autovalores no ordenados necesariamente
    eigenvalues, eigenvectors = np.linalg.eig(MTM)
    
    # Paso 3: Ordenar autovectores por autovalor descendente
    idx = eigenvalues.argsort()[::-1]   
    eigenvalues = eigenvalues[idx]
    eigenvectors = eigenvectors[:, idx]
    
    # E es la matriz de autovectores
    E = eigenvectors
    
    # Verificación de resultados del libro
    # Autovalores esperados: 58 y 2
    print(f"Autovalores: {eigenvalues}")
    
    # Paso 4: Transformación completa (Rotación) - ME
    M_transformed = np.dot(M, E)
    print(f"Datos transformados (ME):\n{M_transformed}")
    
    # Paso 5: Reducción a 1 dimensión (k=1) - ME_1
    E_1 = E[:, :1] # Primer autovector
    M_reduced = np.dot(M, E_1)
    print(f"Datos reducidos (ME_1):\n{M_reduced}")

if __name__ == "__main__":
    pca_example()
```

## 8. Funciones, métodos, librerías o comandos identificados
- **$M^T M$**: Producto matriz-transpuesta por matriz, clave para calcular la estructura de correlaciones/varianza.
- **Eigenpairs (Pares eigen)**: Par compuesto por un autovalor $\lambda$ y su autovector asociado $e$.
- **Matriz ortonormal**: Matriz cuyas columnas son vectores unitarios ortogonales entre sí. Propiedad: su inversa es su transpuesta.
- **Power Iteration**: Método mencionado en ejercicios previos (11.1.6) para encontrar el autovector principal iterativamente.

## 9. Snippets o plantillas reutilizables

```python
# Función genérica para reducir dimensionalidad usando PCA (enfoque del libro)
def reduce_dimensionality_pca(M, k):
    """
    Reduce la dimensionalidad de una matriz M a k dimensiones 
    utilizando autovectores de M^T M.
    
    Args:
        M (np.array): Matriz de datos (muestras x caracteristicas).
        k (int): Numero de dimensiones objetivo.
        
    Returns:
        np.array: Datos proyectados en el nuevo espacio k-dimensional.
    """
    # Calcular matriz de covarianza/gramos M^T M
    cov_matrix = np.dot(M.T, M)
    
    # Obtener autovalores y autovectores
    eig_vals, eig_vecs = np.linalg.eig(cov_matrix)
    
    # Ordenar índices por autovalor descendente
    sorted_indices = np.argsort(eig_vals)[::-1]
    
    # Seleccionar los top k autovectores
    top_k_eig_vecs = eig_vecs[:, sorted_indices[:k]]
    
    # Proyectar datos
    return np.dot(M, top_k_eig_vecs)
```

## 10. Casos de uso y aplicaciones
- **Visualización de datos:** Proyectar datos de alta dimensión a 2D o 3D para visualización humana (identificar clusters).
- **Compresión de datos:** Representar datos con menos bits manteniendo la información esencial (ej. imágenes).
- **Preprocesamiento:** Reducir ruido eliminando componentes con varianza baja (autovalores pequeños).
- **Análisis de similitud:** Uso de $M M^T$ para encontrar puntos similares basados en productos escalares.

## 11. Limitaciones, riesgos y precauciones
- **Interpretación de ejes:** Los nuevos ejes (componentes principales) son combinaciones lineales de los originales, lo que a menudo dificulta la interpretación semántica directa.
- **Escalado:** El PCA es sensible a la escala de las variables. Si una variable tiene un rango mucho mayor, dominará el primer componente. *[VACÍO: El fragmento no menciona explícitamente la necesidad de normalización, pero es un requisito implícito crítico en la práctica]*
- **Costo computacional:** Calcular autovalores de matrices muy grandes puede ser costoso ($O(n^3)$ para matrices densas), aunque el texto sugiere usar la matriz más pequeña ($M^T M$ vs $M M^T$).
- **Linealidad:** PCA solo captura relaciones lineales.

## 12. Relaciones con otros temas del corpus
- **Eigenvalues/Eigenvectors (Cap 11.1):** Fundamento matemático necesario para PCA.
- **SVD (Cap 11.3):** Generalización de PCA. Mientras PCA se centra en $M^T M$, SVD descompone $M$ directamente en $U \Sigma V^T$, donde $V$ contiene los autovectores de $M^T M$.
- **MinHash / LSH (Cap 3):** Técnicas alternativas para reducción de dimensionalidad en datos esparsos (Jaccard), mientras PCA es para datos densos euclidianos.
- **PageRank:** Usa métodos de autovectores (power iteration) para encontrar el vector propio principal de una matriz de transición.

## 13. Preguntas que la skill debería poder responder
1. ¿Cuál es el objetivo principal del Análisis de Componentes Principales (PCA)?
2. ¿Por qué se calculan los autovectores de $M^T M$ en lugar de operar directamente sobre $M$ en PCA?
3. ¿Qué representa el autovalor asociado a un componente principal en términos de los datos?
4. ¿Cómo se relacionan los autovalores de $M M^T$ con los de $M^T M$?
5. ¿Qué significa que la matriz de autovectores represente una "rotación" en el espacio?
6. ¿Cómo se realiza la reducción de dimensionalidad una vez obtenidos los autovectores?
7. ¿Qué es la matriz de distancias $M M^T$ y qué información contiene?
8. ¿Cuándo es preferible calcular autovectores de $M M^T$ en lugar de $M^T M$?
9. ¿Qué introduce la Descomposición en Valores Singulares (SVD) respecto a PCA?
10. ¿Cómo se determina el número de dimensiones $k$ a conservar en una reducción?

## 14. Acciones que la skill debería poder recomendar o ejecutar
- Calcular la matriz de covarianza $M^T M$ dado un dataset.
- Implementar la proyección de datos sobre los componentes principales.
- Determinar si usar $M^T M$ o $M M^T$ basándose en las dimensiones de la matriz de entrada.
- Interpretar la varianza explicada a partir de los autovalores.
- Generar código Python para realizar una reducción de dimensionalidad básica.

## 15. Activos finales de conocimiento en formato compacto
| Concepto | Descripción | Referencia |
| :--- | :--- | :--- |
| **PCA** | Transformación lineal para maximizar varianza en los primeros ejes. | Sec 11.2 |
| **Eje Principal** | Dirección del autovector con mayor autovalor (máxima dispersión). | Sec 11.2 |
| **Reducción** | Proyección $M E_k$ donde $E_k$ son los $k$ principales autovectores. | Sec 11.2.2 |
| **Matriz $M^T M$ | Base para calcular autovectores cuando $n < m$ (menos columnas). | Sec 11.2.1 |
| **Matriz $M M^T$ | Base para calcular autovectores cuando $m < n$ (menos filas). | Sec 11.2.3 |
| **Autovalores compartidos** | $M^T M$ y $M M^T$ tienen los mismos autovalores no nulos. | Sec 11.2.3 |
| **Rotación** | La matriz de autovectores ortonormales rota el sistema de coordenadas. | Sec 11.2.1 |
| **SVD** | Factorización exacta $U \Sigma V^T$ para cualquier matriz. | Sec 11.3 |
| **Rango ($r$)** | Número de autovalores no nulos; define la dimensión intrínseca. | Sec 11.3.1 |
| **Producto Escalar** | Entrada $(i,j)$ de $M M^T$ es el producto escalar de las filas $i$ y $j$. | Sec 11.2.3 |


