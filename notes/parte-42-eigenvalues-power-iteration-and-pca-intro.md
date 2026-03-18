# Parte 42 - Eigenvalues, Power Iteration, and PCA Intro

## 1. Metadatos del documento
- **Libro:** Mining of Massive Datasets, 3ª ed.
- **Fragmento/Parte:** Parte 42 - Eigenvalues, Power Iteration, and PCA Intro
- **Temas principales:** Reducción de dimensionalidad, Autovalores y autovectores, Matrices simétricas, Power Iteration, Deflación de matrices, Análisis de Componentes Principales (PCA)
- **Tipo de contenido:** Teoría / Algoritmo

## 2. Resumen técnico de alto valor
El capítulo introduce la reducción de dimensionalidad como la búsqueda de matrices "estrechas" (menos filas o columnas) que preserven la información esencial de una matriz grande $M$, citando como predecesores la descomposición UV. Se fundamenta en el álgebra lineal de matrices simétricas, definiendo formalmente los pares propios (eigenpairs) $\lambda$ y $e$ mediante la ecuación $Me = \lambda e$, con restricciones de normalización (vectores unitarios) para eliminar ambigüedades.

Se presentan dos enfoques computacionales para hallar autovalores:
1.  **Método exacto:** Resolución del polinomio característico $\det(M - \lambda I) = 0$, con complejidad $O(n^3)$, viable solo para matrices pequeñas.
2.  **Método iterativo (Power Iteration):** Aproxima el vector propio principal mediante multiplicaciones sucesivas $M^i v$, normalizando en cada paso. Para obtener los autovectores subsecuentes, se introduce el método de **deflación**, que "elimina" la influencia del autovector encontrado modificando la matriz original a $M^* = M - \lambda x x^T$.

Finalmente, se introduce el Análisis de Componentes Principales (PCA) como la aplicación de estos conceptos para encontrar los ejes de máxima varianza en un conjunto de datos, utilizando los autovectores de $MM^T$ o $M^TM$.

## 3. Conceptos y definiciones clave
- **Reducción de dimensionalidad:** Proceso de encontrar matrices más pequeñas (menos filas/columnas) que approximen una matriz grande $M$, permitiendo un procesamiento más eficiente (ej. descomposición UV).
- **Matriz Simétrica:** Matriz cuadrada donde el elemento en la fila $i$ y columna $j$ es igual al de la fila $j$ y columna $i$. Sus autovectores son ortogonales.
- **Autovalor ($\lambda$) y Autovector ($e$):** Para una matriz cuadrada $M$, $\lambda$ es un escalar y $e$ un vector no nulo tal que $Me = \lambda e$.
- **Vector unitario:** Vector cuya suma de los cuadrados de sus componentes es 1 ($\sum e_i^2 = 1$). Se exige para estandarizar la longitud de los autovectores.
- **Par propio (Eigenpair):** La tupla $(\lambda, e)$ correspondiente.
- **Matriz Identidad ($I$):** Matriz con 1s en la diagonal principal y 0s elsewhere.
- **Power Iteration:** Algoritmo iterativo para encontrar el autovector principal (asociado al autovalor de mayor magnitud) de una matriz.
- **Deflación:** Técnica para modificar la matriz $M$ sustrayendo la contribución de un autovector ya encontrado ($M - \lambda x x^T$) para permitir el cálculo del siguiente par propio.
- **Norma de Frobenius:** Raíz cuadrada de la suma de los cuadrados de los elementos de una matriz o vector. Usada para normalización en Power Iteration.
- **PCA (Principal-Component Analysis):** Técnica que trata un dataset como una matriz y encuentra direcciones (autovectores) donde los datos están más "dispersos" (máxima varianza).

## 4. Principios, reglas y heurísticas
- **Normalización de autovectores:** Siempre se deben normalizar los autovectores a vectores unitarios. Para eliminar la ambigüedad del signo, se requiere que el primer componente no nulo sea positivo.
- **Ortogonalidad en matrices simétricas:** Los autovectores de una matriz simétrica son siempre ortogonales entre sí. Esto implica que el producto punto entre dos autovectores distintos es 0.
- **Construcción de matriz de autovectores:** Si $E$ es la matriz cuyas columnas son los autovectectores de una matriz simétrica, entonces $EE^T = E^T E = I$.
- **Cálculo de autovalor tras iteración:** Una vez convergido el vector $x$ en Power Iteration, el autovalor se calcula como $\lambda = x^T M x$.
- **Complejidad del método exacto:** El cálculo de autovalores mediante determinantes tiene complejidad $O(n^3)$, lo que lo hace inviable para matrices masivas.
- **Criterio de parada en iteración:** La iteración se detiene cuando $||x_k - x_{k+1}||$ es menor que una constante pequeña predefinida.

## 5. Procedimientos, métodos y workflows

### 5.1 Método Exacto (Polinomio Característico)
1.  **Formar la matriz:** Construir $M - \lambda I$.
2.  **Calcular determinante:** Obtener el polinomio característico igualando el determinante a 0: $\det(M - \lambda I) = 0$.
3.  **Resolver raíces:** Encontrar los $n$ valores de $\lambda$ (autovalores).
4.  **Resolver sistema lineal:** Para cada $\lambda$, resolver $(M - \lambda I)e = 0$ para hallar $e$.
5.  **Normalizar:** Ajustar $e$ para que sea un vector unitario.

### 5.2 Algoritmo de Power Iteration (Para el par propio principal)
**Precondiciones:** Matriz $M$ simétrica, vector inicial $x_0$ arbitrario no nulo.
**Pasos:**
1.  Inicializar $k=0$ con vector $x_0$.
2.  Iterar:
    *   Calcular producto: $v = M x_k$.
    *   Normalizar: $x_{k+1} = \frac{v}{||v||}$ (usando norma Frobenius).
    *   Incrementar $k$.
3.  Repetir hasta convergencia ($||x_k - x_{k+1}|| < \epsilon$).
4.  Calcular autovalor: $\lambda = x^T M x$.

### 5.3 Workflow para encontrar todos los pares propios (Iteración + Deflación)
1.  Ejecutar Power Iteration sobre $M$ para obtener $(\lambda_1, x_1)$.
2.  Construir matriz modificada: $M^* = M - \lambda_1 x_1 x_1^T$.
3.  Ejecutar Power Iteration sobre $M^*$ para obtener $(\lambda_2, x_2)$ (que corresponde al segundo autovalor de $M$).
4.  Repetir el proceso de deflación y potencia para los restantes.

## 6. Problemas comunes y soluciones
- **Ambigüedad en la longitud del autovector:** Cualquier múltiplo $ce$ es también un autovector.
    *   *Solución:* Forzar la normalización a vector unitario (suma de cuadrados = 1).
- **Ambigüedad de signo:** $e$ y $-e$ son ambos autovectores válidos y unitarios.
    *   *Solución:* Convención de hacer positivo el primer componente no nulo.
- **Acumulación de errores en deflación iterativa:** Al calcular $M^*$ y volver a iterar, los errores de precisión se acumulan, alejándose de los valores exactos.
    *   *Solución:* [VACÍO] El texto menciona el problema pero no da una solución explícita en este fragmento, más allá de ser consciente de la limitación frente al método exacto.
- **Ineficiencia en matrices grandes:** El método exacto es $O(n^3)$.
    *   *Solución:* Usar Power Iteration, que es más eficiente para datos masivos, aunque solo encuentre los autovectores principales.

## 7. Implementación técnica y generación de código

```pseudocode
# Algoritmo: Power Iteration
# Entrada: Matriz M (n x n), epsilon (tolerancia)
# Salida: Par (lambda, x) principal

x = vector_aleatorio(n)
x = normalizar(x) # Convertir a vector unitario
repetir:
    x_nuevo = M * x
    norma = frobenius_norm(x_nuevo)
    x_nuevo = x_nuevo / norma
    
    si frobenius_norm(x - x_nuevo) < epsilon:
        romper
    x = x_nuevo
    
lambda = transpuesta(x) * M * x
retornar (lambda, x)
```

```python
import numpy as np

def power_iteration(M, epsilon=1e-10, max_iter=1000):
    """
    Encuentra el par propio principal (autovalor y autovector) de una matriz simétrica M
    mediante el método de Power Iteration.
    """
    n = M.shape[0]
    # Inicialización con vector aleatorio
    x = np.random.rand(n)
    x = x / np.linalg.norm(x) # Normalización inicial
    
    for _ in range(max_iter):
        # Multiplicación y normalización
        x_new = np.dot(M, x)
        x_new_norm = np.linalg.norm(x_new) # Norma Frobenius/L2 para vectores
        x_new = x_new / x_new_norm
        
        # Criterio de convergencia
        if np.linalg.norm(x - x_new) < epsilon:
            break
        x = x_new
        
    # Cálculo del autovalor correspondiente
    # lambda = x^T M x
    eigenvalue = np.dot(x.T, np.dot(M, x))
    
    return eigenvalue, x

def find_all_eigenpairs_deflation(M, epsilon=1e-10):
    """
    Encuentra todos los pares propios usando Power Iteration y Deflación.
    Nota: Propenso a acumulación de errores numéricos.
    """
    n = M.shape[0]
    eigenvalues = []
    eigenvectors = []
    M_current = M.copy()
    
    for _ in range(n):
        val, vec = power_iteration(M_current, epsilon)
        eigenvalues.append(val)
        eigenvectors.append(vec)
        
        # Deflación: M* = M - lambda * x * x^T
        # np.outer calcula el producto externo x * x^T
        M_current = M_current - val * np.outer(vec, vec)
        
    return np.array(eigenvalues), np.array(eigenvectors).T

# Ejemplo del libro (Ejemplo 11.1 / 11.2)
M_example = np.array([[3, 2], [2, 6]])
val, vec = power_iteration(M_example)
print(f"Autovalor principal: {val:.4f}") # Debería ser ~7
print(f"Autovector principal: {vec}") # Debería ser ~[0.447, 0.894]
```

## 8. Funciones, métodos, librerías o comandos identificados
- **$M - \lambda I$**: Construcción para el cálculo del polinomio característico.
- **$\det(M)$**: Función determinante.
- **$x^T M x$**: Fórmula para recuperar el autovalor a partir del autovector.
- **$M^* = M - \lambda x x^T$**: Fórmula de deflación para eliminar la contribución de un autovector.
- **$EE^T = I$**: Propiedad de ortogonalidad de la matriz de autovectores.

## 9. Snippets o plantillas reutilizables
> *Sección no aplicable a este fragmento.*

## 10. Casos de uso y aplicaciones
- **Web (PageRank):** La matriz de transición de la Web se trata como una matriz estocástica donde el autovector principal representa el vector de PageRank (capítulo 5, referenciado).
- **Sistemas de recomendación:** Descomposición UV para predecir ratings de ítems (capítulo 9, referenciado).
- **Redes sociales:** Análisis de matrices de conexión (capítulo 10, referenciado).
- **Análisis de varianza (PCA):** Identificar los ejes donde los datos están más dispersos para reducción de ruido y visualización.

## 11. Limitaciones, riesgos y precauciones
- **Complejidad computacional:** El método exacto es $O(n^3)$, prohibitivo para "Massive Datasets".
- **Inestabilidad numérica:** El método de deflación iterativa acumula errores. Para matrices grandes y precisión completa, se requieren métodos más robustos (como SVD, mencionado como tema futuro) en lugar de deflación simple.
- **Supuesto de simetría:** Las propiedades de ortogonalidad ($EE^T=I$) y la lógica de deflación presentada dependen fuertemente de que $M$ sea simétrica.
- **Matrices estocásticas vs Simétricas:** El texto distingue que las técnicas de PageRank (matrices estocásticas) difieren en algunos aspectos de las técnicas para matrices simétricas presentadas aquí.

## 12. Relaciones con otros temas del corpus
- **Capítulo 5 (Link Analysis):** Uso de Power Iteration para PageRank en matrices estocásticas (precedente directo).
- **Capítulo 9 (Recommender Systems):** Descomposición UV como forma de reducción de dimensionalidad (antecedente conceptual).
- **SVD (Singular-Value Decomposition):** Mencionado como "versión más potente" de la descomposición UV, tema central posterior del capítulo.
- **CUR-Decomposition:** Mencionado como variante de SVD que preserva la dispersión (sparsity) de la matriz original.

## 13. Preguntas que la skill debería poder responder
1.  ¿Cuál es la diferencia entre el método exacto y el método iterativo para hallar autovalores en términos de complejidad computacional?
2.  ¿Cómo se normaliza un autovector y por qué es necesario?
3.  ¿Qué es la deflación de matrices y para qué se utiliza en el cálculo de autovectores?
4.  ¿Por qué los autovectores de una matriz simétrica son ortogonales?
5.  ¿Cómo se calcula el autovalor una vez que el algoritmo de Power Iteration ha convergido?
6.  ¿Qué relación tiene el Análisis de Componentes Principales (PCA) con los autovectores de $MM^T$?
7.  ¿Qué problemas de precisión introduce el método de deflación iterativa?

## 14. Acciones que la skill debería poder recomendar o ejecutar
- Implementar el algoritmo de Power Iteration en Python para encontrar el vector dominante.
- Calcular el polinomio característico para matrices pequeñas ($2 \times 2$ o $3 \times 3$).
- Aplicar la fórmula de deflación $M^* = M - \lambda x x^T$ para encontrar el segundo componente principal.
- Verificar si un vector dado es autovector de una matriz comprobando $Me = \lambda e$.
- Elegir entre métodos exactos o iterativos basándose en el tamaño $n$ de la matriz.

## 15. Activos finales de conocimiento en formato compacto
| Concepto | Descripción | Referencia |
| :--- | :--- | :--- |
| **Autovalor/Autovector** | Par $(\lambda, e)$ tal que $Me = \lambda e$, con $e$ vector unitario. | Sec 11.1.1 |
| **Power Iteration** | Algoritmo iterativo $x_{k+1} = \frac{M x_k}{||M x_k||}$ para hallar autovector principal. | Sec 11.1.3 |
| **Deflación** | Método $M^* = M - \lambda x x^T$ para aislar y encontrar autovectores subsecuentes. | Sec 11.1.3 |
| **Matriz Simétrica** | $M_{ij} = M_{ji}$. Sus autovectores son ortogonales ($e_i \cdot e_j = 0$). | Sec 11.1.4 |
| **Polinomio Característico** | $\det(M - \lambda I) = 0$. Método exacto con complejidad $O(n^3)$. | Sec 11.1.2 |
| **Cálculo de $\lambda$** | Post-convergencia: $\lambda = x^T M x$. | Sec 11.1.3 |
| **PCA** | Uso de autovectores de $MM^T$ para encontrar ejes de máxima varianza. | Sec 11.2 |
| **Matriz Ortonormal** | Matriz $E$ de autovectores donde $EE^T = I$. | Sec 11.1.4 |


