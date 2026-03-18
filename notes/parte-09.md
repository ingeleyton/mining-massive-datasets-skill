# parte-09 — Mining-of-Massive-Datasets-Third-Edition-Jure-Leskovec-Anand-Rajaraman-etc-z-library-sk-1lib-sk-z-lib-parte-09.pdf

## 1. Metadatos del documento
- **Libro:** Mining of Massive Datasets, 3ª ed.
- **Fragmento/Parte:** [Archivo: Mining-of-Massive-Datasets-Third-Edition-Jure-Leskovec-Anand-Rajaraman-etc-z-library-sk-1lib-sk-z-lib-parte-09.pdf]
- **Temas principales:** Locality-Sensitive Hashing (LSH), Técnica de Bandas (Banding), Medidas de Distancia, Distancia de Jaccard, Distancia Euclidiana, Distancia de Edición, Distancia del Coseno.
- **Tipo de contenido:** Mixto (Teoría / Algoritmo / Definiciones)

## 2. Resumen técnico de alto valor
El fragmento aborda la optimización de la búsqueda de ítems similares mediante **Locality-Sensitive Hashing (LSH)** para superar la complejidad cuadrática ($O(N^2)$) de comparar todos los pares de firmas MinHash. Se detalla la **técnica de bandas (banding)**, que particiona la matriz de firmas en $b$ bandas de $r$ filas, permitiendo que dos documentos se conviertan en pares candidatos si coinciden en al menos una banda completa. La probabilidad de detección se modela mediante la función $1 - (1 - s^r)^b$, generando una curva en forma de S que discrimina eficazmente entre pares similares y disímiles según un umbral aproximado $(1/b)^{1/r}$.

Posteriormente, el texto formaliza las **medidas de distancia**, definiendo los axiomas matemáticos que debe cumplir una métrica (no negatividad, identidad de indiscernibles, simetría y desigualdad triangular). Se examinan la **Distancia Euclidiana** ($L_2$-norm), **Manhattan** ($L_1$-norm) y $L_\infty$-norm, la **Distancia de Jaccard** (definida como $1 - SIM(x,y)$), la **Distancia del Coseno** (ángulo entre vectores), la **Distancia de Edición** (basada en inserciones/borrados y LCS) y la **Distancia de Hamming**. Se sientan las bases para la teoría general de funciones LSH, estableciendo condiciones de independencia estadística y eficiencia.

## 3. Conceptos y definiciones clave
- **Locality-Sensitive Hashing (LSH):** Técnica para reducir el espacio de búsqueda de pares similares, hasheando ítems múltiples veces de modo que ítems similares colisionen en los mismos buckets con mayor probabilidad que los disímiles.
- **Par Candidato:** Par de ítems que hashean al mismo bucket en al menos una de las funciones de hash aplicadas. Son el conjunto reducido sobre el que se realiza la verificación exhaustiva.
- **Falso Positivo:** Par disímil que hashea al mismo bucket (se verifica innecesariamente).
- **Falso Negativo:** Par similar que no hashea al mismo bucket en ninguna banda (se pierde).
- **Técnica de Bandas (Banding):** Método para LSH sobre firmas MinHash. Divide la firma de longitud $n$ en $b$ bandas de $r$ filas ($n = b \times r$). Dos columnas son candidatas si son idénticas en al menos una banda.
- **Curva-S (S-curve):** Gráfico de la probabilidad de convertirse en candidato frente a la similitud de Jaccard $s$. Tiene una pendiente pronunciada cerca del umbral, actuando como un filtro.
- **Medida de Distancia:** Función $d(x, y)$ sobre un espacio de puntos que satisface cuatro axiomas: $d(x, y) \ge 0$; $d(x, y) = 0 \iff x=y$; $d(x, y) = d(y, x)$; y la desigualdad triangular $d(x, y) \le d(x, z) + d(z, y)$.
- **Distancia de Jaccard:** Definida como $d(x, y) = 1 - SIM(x, y)$. Es la probabilidad de que un MinHash aleatorio no coincida para dos conjuntos.
- **Distancia Euclidiana ($L_r$-norm):** Distancia en espacio $n$-dimensional. $L_2$ es la raíz de la suma de cuadrados; $L_1$ (Manhattan) es la suma de valores absolutos; $L_\infty$ es la diferencia máxima en cualquier dimensión.
- **Distancia del Coseno:** El ángulo entre dos vectores. Se calcula como el arcocoseno del producto punto dividido por el producto de sus normas $L_2$. Rango: 0 a 180 grados.
- **Distancia de Edición:** Número mínimo de inserciones y/o borrados para transformar una cadena en otra. Equivale a $|x| + |y| - 2|LCS(x,y)|$.
- **Distancia de Hamming:** Número de componentes en los que difieren dos vectores.

## 4. Principios, reglas y heurísticas
- **Regla de decisión LSH:** Si el objetivo es minimizar falsos negativos, configurar $b$ y $r$ para que el umbral sea menor que la similitud objetivo $t$. Si se prioriza la velocidad (minimizar falsos positivos), configurar un umbral mayor.
- **Umbral de similitud:** Para $b$ bandas y $r$ filas, el umbral aproximado donde la curva-S es más pronunciada es $(1/b)^{1/r}$.
- **Relación $b$ y $r:** La longitud de la firma $n$ debe cumplir $n = b \times r$. Aumentar $b$ (más bandas) baja el umbral; aumentar $r$ (más filas por banda) sube el umbral.
- **Axiomas de distancia:** Cualquier función que no cumpla los cuatro axiomas (ej. $max(x,y)$ o $x+y$ en enteros no negativos) no es una medida de distancia válida.
- **Espacios No Euclidianos:** En espacios como conjuntos (Jaccard) o cadenas (Edición), no existe un concepto de "promedio" de puntos, lo cual es una distinción importante frente a espacios Euclidianos.

## 5. Procedimientos, métodos y workflows
**Workflow completo para encontrar documentos similares (Sección 3.4.3):**
1.  **Shingling:** Seleccionar $k$ y construir conjuntos de $k$-shingles para cada documento. Opcionalmente hashear shingles a buckets.
2.  **Ordenamiento:** Ordenar pares documento-shingle por shingle.
3.  **MinHashing:** Calcular firmas MinHash de longitud $n$ para todos los documentos.
4.  **Configuración LSH:** Elegir umbral $t$. Seleccionar $b$ y $r$ tal que $br=n$ y el umbral sea aprox $(1/b)^{1/r}$.
5.  **Identificación de Candidatos:** Aplicar LSH (bandas) para identificar pares candidatos.
6.  **Verificación de Firmas:** Para cada par candidato, calcular la similitud real de las firmas. Descartar los que no superan $t$.
7.  **Verificación de Documentos (Opcional):** Si las firmas son similares, verificar la similitud real de los documentos (shingles) para evitar falsos positivos debidos a la suerte en el MinHash.

**Cálculo de Distancia de Edición vía LCS:**
1.  Encontrar la Subsecuencia Común más Larga (LCS) de las cadenas $x$ e $y$.
2.  Calcular distancia como $|x| + |y| - 2 \times |LCS|$.

## 6. Problemas comunes y soluciones
- **Problema:** Escalabilidad al comparar todos los pares de documentos ($N^2$).
    - **Solución:** Uso de LSH para reducir el espacio de búsqueda a solo pares candidatos.
- **Problema:** Ajuste del umbral de similitud.
    - **Solución:** Manipular los parámetros $b$ (bandas) y $r$ (filas). Un umbral bajo requiere bandas anchas (poco $r$) o muchas bandas (alto $b$).
- **Problema:** Falsos negativos en LSH.
    - **Solución:** Bajar el umbral de la curva-S aumentando el número de bandas $b$ o reduciendo $r$.
- **Problema:** Falsos positivos excesivos.
    - **Solución:** Subir el umbral reduciendo $b$ o aumentando $r$.
- **Problema:** Columnas con solo 0's (conjunto vacío) en MinHash.
    - **Solución:** [VACÍO] El texto menciona el problema en ejercicios previos pero no detalla la solución en este fragmento específico, aunque implica que deben manejarse para evitar errores de estimación.

## 7. Implementación técnica y generación de código

```pseudocode
# Algoritmo LSH para Firmas MinHash (Banding)
# Entrada: Matriz de firmas M (n filas, m columnas), b bandas, r filas por banda
# Salida: Conjunto de pares candidatos

Candidatos = Conjunto vacío

Para cada banda i de 1 a b:
    # Crear una tabla hash para esta banda
    Buckets = Tabla Hash vacía
    
    Para cada columna j (documento):
        # Extraer el vector de la banda actual
        vector = M[fila_inicio : fila_fin, j]
        
        # Hashear el vector a un bucket
        # Se asume que vectores idénticos van al mismo bucket
        bucket_id = hash_func(vector)
        
        # Almacenar el documento en el bucket
        Buckets[bucket_id].agregar(j)
        
    # Extraer pares candidatos de esta banda
    Para cada bucket en Buckets:
        Si tamaño(bucket) > 1:
            # Todos los pares en este bucket son candidatos
            Para cada par (d1, d2) en bucket:
                Candidatos.agregar(par(d1, d2))

Retornar Candidatos
```

```python
import numpy as np
from collections import defaultdict

def lsh_banding(signature_matrix, b, r):
    """
    Implementación de LSH usando técnica de bandas.
    
    Args:
        signature_matrix (np.array): Matriz de firmas (n_filas, n_docs).
        b (int): Número de bandas.
        r (int): Número de filas por banda.
        
    Returns:
        set: Conjunto de tuplas (doc_id1, doc_id2) que son candidatos.
    """
    n_rows, n_docs = signature_matrix.shape
    assert n_rows == b * r, "El número de filas debe ser igual a b * r"
    
    candidate_pairs = set()
    
    # Iterar sobre cada banda
    for i in range(b):
        start_row = i * r
        end_row = start_row + r
        
        # Tabla hash para esta banda: bucket_id -> lista de doc_ids
        buckets = defaultdict(list)
        
        # Para cada documento, obtener la sub-firma de esta banda y hashearla
        for doc_id in range(n_docs):
            # Convertir la sub-firma a una tupla para que sea hasheable
            band_signature = tuple(signature_matrix[start_row:end_row, doc_id])
            
            # Usar el hash nativo de Python (se puede usar una función más robusta)
            bucket_id = hash(band_signature)
            buckets[bucket_id].append(doc_id)
            
        # Revisar buckets con colisiones para formar pares candidatos
        for bucket_docs in buckets.values():
            if len(bucket_docs) > 1:
                # Generar todas las combinaciones de pares en este bucket
                for idx1 in range(len(bucket_docs)):
                    for idx2 in range(idx1 + 1, len(bucket_docs)):
                        pair = tuple(sorted((bucket_docs[idx1], bucket_docs[idx2])))
                        candidate_pairs.add(pair)
                        
    return candidate_pairs

def jaccard_distance(set_a, set_b):
    """Calcula la distancia de Jaccard entre dos conjuntos."""
    intersection = len(set_a.intersection(set_b))
    union = len(set_a.union(set_b))
    similarity = intersection / union if union != 0 else 0
    return 1 - similarity

def edit_distance_lcs(s1, s2):
    """Calcula la distancia de edición usando la longitud del LCS."""
    # Nota: Implementación de LCS es costosa O(N*M), aquí versión simple
    m, n = len(s1), len(s2)
    dp = [[0] * (n + 1) for _ in range(m + 1)]
    
    for i in range(m + 1):
        for j in range(n + 1):
            if i == 0 or j == 0:
                dp[i][j] = 0
            elif s1[i-1] == s2[j-1]:
                dp[i][j] = dp[i-1][j-1] + 1
            else:
                dp[i][j] = max(dp[i-1][j], dp[i][j-1])
    
    lcs_len = dp[m][n]
    return m + n - 2 * lcs_len
```

## 8. Funciones, métodos, librerías o comandos identificados
- **Hash Function (LSH):** Función que toma vectores de enteros y los mapea a buckets. Debe minimizar colisiones aleatorias para que solo vectores idénticos colisionen.
- **Dot Product:** Operación clave para calcular la distancia del coseno ($x \cdot y$).
- **$L_2$-norm:** Norma Euclidiana estándar.
- **Arc-cosine:** Función para convertir el coseno del ángulo en el ángulo real (distancia del coseno).
- **LCS (Longest Common Subsequence):** Algoritmo base para calcular la distancia de edición eficiente.

## 9. Snippets o plantillas reutilizables

```python
# Cálculo de la probabilidad de ser candidato según parámetros LSH
def lsh_probability(s, b, r):
    """
    Calcula la probabilidad de que un par con similitud s 
    se convierta en candidato.
    """
    return 1 - (1 - s**r)**b

# Estimación del umbral óptimo
def estimate_threshold(b, r):
    """
    Estimación aproximada del umbral de similitud.
    """
    return (1/b)**(1/r)

# Ejemplo de uso con b=20, r=5 (Firma total 100)
s_similar = 0.8
s_dissimilar = 0.2
prob_sim = lsh_probability(s_similar, 20, 5)
prob_dissim = lsh_probability(s_dissimilar, 20, 5)
print(f"Probabilidad candidato (sim={s_similar}): {prob_sim:.4f}") # ~0.9996
print(f"Probabilidad candidato (sim={s_dissimilar}): {prob_dissim:.4f}") # ~0.006
```

## 10. Casos de uso y aplicaciones
- **Deduplicación de Documentos:** Encontrar copias casi idénticas en repositorios masivos (ej. 1 millón de documentos) sin comparar todos los pares.
- **Detección de Plagio:** Identificar documentos con alta similitud estructural o de contenido.
- **Búsqueda de Vecinos Cercanos:** Encontrar puntos "cerca" en espacios de alta dimensión usando medidas como Euclidiana o Coseno.
- **Comparación de Genomas:** Uso de distancia de edición para medir diferencias entre cadenas de ADN.

## 11. Limitaciones, riesgos y precauciones
- **Falsos Negativos:** LSH no garantiza encontrar *todos* los pares similares. Existe una probabilidad no nula de que pares con similitud justamente por encima del umbral no se conviertan en candidatos.
- **Dependencia de Parámetros:** La elección incorrecta de $b$ y $r$ puede hacer que el algoritmo sea inútil (umbral muy alto -> pocos candidatos; umbral muy bajo -> demasiados falsos positivos).
- **Costo de Memoria:** Aunque reduce comparaciones, LSH requiere mantener tablas hash en memoria para cada banda.
- **Espacios No Euclidianos:** Técnicas como promediar puntos (k-means estándar) no aplican directamente en espacios con distancia de Jaccard o Edición.
- **Distancia del Coseno:** Requiere tratar vectores que son múltiplos escalares como el mismo punto (misma dirección), lo cual puede no ser deseable en todos los contextos.

## 12. Relaciones con otros temas del corpus
- **MinHashing (Sección 3.3):** Precondición necesaria para el LSH de documentos descrito aquí. LSH opera sobre la matriz de firmas generada por MinHash.
- **Shingling (Sección 3.2):** Representación original del documento antes de ser hasheado.
- **Clustering (Capítulo 7):** Las medidas de distancia definidas aquí (Euclidiana, Jaccard, Coseno) son fundamentales para algoritmos de agrupamiento.
- **Teoría General LSH (Sección 3.6):** Este fragmento introduce la aplicación específica a documentos; la teoría general aborda otras familias de funciones para distintas métricas.

## 13. Preguntas que la skill debería poder responder
1. ¿Cómo afecta el aumento del número de bandas ($b$) a la tasa de falsos negativos en LSH?
2. ¿Cuál es la fórmula para calcular la probabilidad de que dos documentos con similitud $s$ se conviertan en pares candidatos usando $b$ bandas y $r$ filas?
3. ¿Por qué la distancia de Jaccard ($1 - SIM$) satisface la desigualdad triangular?
4. ¿En qué se diferencia la distancia $L_1$ (Manhattan) de la distancia $L_2$ (Euclidiana)?
5. ¿Cómo se relaciona la distancia de edición con la subsecuencia común más larga (LCS)?
6. ¿Qué valores de $b$ y $r$ elegiría para un umbral de similitud aproximado de 0.5?
7. ¿Es la distancia del coseno una métrica válida en espacios no Euclidianos?
8. ¿Qué es un falso positivo en el contexto de LSH y cómo se mitiga?
9. ¿Cómo implementar LSH en un framework MapReduce según el ejercicio planteado?
10. ¿Por qué no se puede calcular el "promedio" de un conjunto de cadenas usando distancia de edición?

## 14. Acciones que la skill debería poder recomendar o ejecutar
1. **Configurar parámetros LSH:** Calcular $b$ y $r$ óptimos dado un tamaño de firma $n$ y un umbral de similitud deseado $t$.
2. **Seleccionar métrica:** Elegir entre Jaccard, Coseno o Euclidiana según el tipo de datos (conjuntos, vectores densos, coordenadas).
3. **Implementar Banding:** Codificar la partición de la matriz de firmas y la búsqueda de candidatos.
4. **Validar distancias:** Verificar si una función propuesta cumple los axiomas de medida de distancia.
5. **Optimizar flujo:** Decidir si es necesario verificar los documentos originales tras el filtrado LSH o si basta con la similitud de firmas.

## 15. Activos finales de conocimiento en formato compacto
| Concepto | Descripción | Referencia |
| :--- | :--- | :--- |
| **Prob. Candidato** | $1 - (1 - s^r)^b$ | Sección 3.4.2 |
| **Umbral LSH** | Aprox. $(1/b)^{1/r}$ | Sección 3.4.2 |
| **Dist. Jaccard** | $d = 1 - \frac{|A \cap B|}{|A \cup B|}$ | Sección 3.5.3 |
| **Dist. Euclidiana** | $L_2$ norm: $\sqrt{\sum (x_i - y_i)^2}$ | Sección 3.5.2 |
| **Dist. Manhattan** | $L_1$ norm: $\sum |x_i - y_i|$ | Sección 3.5.2 |
| **Dist. Coseno** | Ángulo $\theta$; $\cos \theta = \frac{x \cdot y}{\|x\|\|y\|}$ | Sección 3.5.4 |
| **Dist. Edición** | Inserciones/Borrados; $|x|+|y|-2|LCS|$ | Sección 3.5.5 |
| **Dist. Hamming** | Número de componentes distintas | Sección 3.5.6 |
| **Axiomas Dist.** | No negatividad, Identidad, Simetría, Desig. Triangular | Sección 3.5.1 |
| **Curva-S** | Comportamiento de filtro de LSH (paso de 0 a 1) | Sección 3.4.2 |
