# Parte 21 - PCY, Multistage, and Multihash

## 1. Metadatos del documento
- **Libro:** Mining of Massive Datasets, 3ª ed.
- **Fragmento/Parte:** Parte 21 - PCY, Multistage, and Multihash
- **Temas principales:** Algoritmo PCY, Algoritmo Multistage, Algoritmo Multihash, Optimización de memoria para Itemsets Frecuentes, Muestreo aleatorio.
- **Tipo de contenido:** Teoría / Algoritmo / Optimización

## 2. Resumen técnico de alto valor
El fragmento aborda la limitación de memoria del algoritmo A-Priori en su segunda pasada (conteo de pares candidatos $C_2$), proponiendo tres algoritmos optimizados que explotan la memoria no utilizada en la primera pasada para filtrar candidatos. El **Algoritmo PCY** (Park, Chen, Yu) introduce una tabla hash en la primera pasada para contar pares en "buckets"; solo los pares que caen en "buckets frecuentes" son candidatos en la segunda pasada, reduciendo $C_2$ a costa de prohibir el uso de matrices triangulares (forzando el uso de triples). El **Algoritmo Multistage** extiende PCY añadiendo pases intermedios con funciones hash adicionales para filtrar sucesivamente los candidatos, requiriendo verificar múltiples condiciones de "bucket frecuente". El **Algoritmo Multihash** paraleliza la idea de PCY usando múltiples tablas hash en una sola pasada, aunque con buckets más pequeños, aumentando el riesgo de falsos positivos si el umbral de soporte no es suficientemente mayor que el conteo promedio. Finalmente, se introduce el concepto de **Algoritmos de Pases Limitados** mediante muestreo aleatorio simple, ajustando el umbral de soporte proporcionalmente al tamaño de la muestra.

## 3. Conceptos y definiciones clave
- **Frequent Bucket (Cubo frecuente):** En PCY y variantes, un bucket de la tabla hash cuyo conteo total es mayor o igual al umbral de soporte $s$. Un par que hashea a un bucket no frecuente no puede ser frecuente.
- **Infrequent Bucket (Cubo infrecuente):** Bucket con conteo $< s$. Garantiza que ningún par que hashee a él es frecuente, permitiendo podar el espacio de búsqueda.
- **Bitmap (Mapa de bits):** Estructura compacta usada para representar el estado (frecuente/infrecuente) de los buckets de una tabla hash entre pasadas. Requiere 1 bit por bucket (vs 4 bytes del entero original), ocupando 1/32 del espacio.
- **Triples Method (Método de triples):** Estructura de datos para almacenar conteos de pares como una lista de tuplas `(i, j, count)`. Necesario en PCY porque los pares candidatos están dispersos y no se puede compactar una matriz triangular.
- **Triangular Matrix (Matriz triangular):** Método de almacenamiento denso para conteos de pares usado en A-Priori. No utilizable en PCY porque los pares a contar no son contiguos ni predecibles tras el filtrado hash.
- **Thrashing:** Degradación severa del rendimiento por movimiento excesivo de datos entre memoria principal y disco, ocurre cuando $C_2$ excede la memoria disponible.

## 4. Principios, reglas y heurísticas
- **Principio de filtrado PCY:** Si la suma de conteos de todos los pares que hashean a un bucket es menor que el soporte $s$, entonces ningún par individual en ese bucket puede ser frecuente.
- **Regla de ahorro de memoria en PCY:** PCY solo ofrece ventaja sobre A-Priori si permite evitar contar al menos 2/3 de los pares de items frecuentes. Esto se debe a que PCY fuerza el uso de triples (más costosos en memoria) en lugar de matrices triangulares.
- **Condición de candidato en PCY:** Un par $\{i, j\} \in C_2$ si y solo si: 1) $i$ y $j$ son items frecuentes, Y 2) $\{i, j\}$ hashea a un bucket frecuente.
- **Condición de candidato en Multistage:** Un par $\{i, j\} \in C_2$ si y solo si: 1) Items frecuentes, Y 2) Bucket frecuente en Pass 1, Y 3) Bucket frecuente en Pass 2.
- **Riesgo en Multihash:** Si se usan demasiadas tablas hash en una pasada, el conteo promedio por bucket superará el umbral de soporte, haciendo que la mayoría de buckets sean frecuentes y eliminando la capacidad de poda.
- **Ajuste de umbral en muestreo:** Si se toma una muestra de proporción $p$ del dataset, el umbral de soporte debe escalarse a $s \times p$.

## 5. Procedimientos, métodos y workflows

### Algoritmo PCY (Park, Chen, Yu)
**Objetivo:** Reducir el tamaño de $C_2$ utilizando memoria ociosa en la primera pasada.
1.  **Pasada 1:**
    *   Contar items individuales (como A-Priori).
    *   Para cada cesta, generar todos los pares y hashearlos a una tabla hash de enteros, incrementando el conteo del bucket.
2.  **Entre Pasadas:**
    *   Identificar items frecuentes.
    *   Convertir la tabla hash en un bitmap (1 si bucket $\ge s$, 0 si no).
3.  **Pasada 2:**
    *   Contar solo los pares $\{i, j\}$ donde $i, j$ son frecuentes Y el bitmap indica que su bucket es frecuente.
    *   Almacenar conteos usando el método de triples.

### Algoritmo Multistage
**Objetivo:** Filtrar candidatos más agresivamente usando pasadas adicionales.
1.  **Pasada 1:** Idéntico a PCY (conteo items + Hash Table 1). Generar Bitmap 1.
2.  **Pasada 2:**
    *   No se cuentan pares todavía.
    *   Se usa una nueva Hash Table 2 con diferente función hash.
    *   Solo se hashea un par $\{i, j\}$ a la Hash Table 2 si: $i, j$ son frecuentes Y hashean a un bucket frecuente en Bitmap 1.
    *   Generar Bitmap 2.
3.  **Pasada 3:**
    *   Contar pares $\{i, j\}$ que cumplen: items frecuentes + frecuentes en Bitmap 1 + frecuentes en Bitmap 2.

### Algoritmo Multihash
**Objetivo:** Lograr filtrado similar a Multistage en una sola pasada.
1.  **Pasada 1:**
    *   Dividir memoria disponible en múltiples tablas hash (ej. 2 tablas).
    *   Para cada cesta, hashear cada par a TODAS las tablas hash simultáneamente.
    *   Generar múltiples Bitmaps.
2.  **Pasada 2:**
    *   Contar pares que son frecuentes en items Y hashean a buckets frecuentes en TODOS los Bitmaps.

## 6. Problemas comunes y soluciones
- **Problema:** A-Priori falla por falta de memoria en $C_2$ (Thrashing).
    - **Solución:** Usar PCY para reducir $C_2$ filtrando pares que caen en buckets infrecuentes.
- **Problema:** Error sutil en implementación de Multistage.
    - **Descripción:** Asumir que no es necesario verificar si el par hasheó a un bucket frecuente en la primera pasada (condición 2) durante el conteo final, bajo el razonamiento erróneo de que "si no pasó la primera, no se contó en la segunda".
    - **Solución:** Verificar rigurosamente las tres condiciones en la pasada final: items frecuentes, bitmap 1 activo, bitmap 2 activo. Un par podría no haber sido hasheado en la pasada 2 (porque falló la 1) pero podría haber tenido éxito si se hubiera probado, y la condición 3 por sí sola no garantiza la 2.
- **Problema:** PCY no permite usar matriz triangular.
    - **Causa:** Los pares candidatos están dispersos aleatoriamente según la función hash; no se pueden compactar índices.
    - **Solución:** Usar estructura de triples (item-item-count), asumiendo la penalización de memoria correspondiente.

## 7. Implementación técnica y generación de código

```pseudocode
# Algoritmo PCY - Visión General
# Pass 1
Initialize ItemCounts array
Initialize HashBuckets array of size N

for each basket in file:
    for each item i in basket:
        ItemCounts[i]++
    for each pair {i, j} in basket:
        bucket = hash(i, j) % N
        HashBuckets[bucket]++

# Inter-pass Processing
FrequentItems = {i | ItemCounts[i] >= s}
Bitmap = create_bitmap(HashBuckets, s)

# Pass 2
Initialize CandidatePairCounts (Triples structure)

for each basket in file:
    for each pair {i, j} in basket:
        if i in FrequentItems AND j in FrequentItems:
             bucket = hash(i, j) % N
             if Bitmap[bucket] == 1:
                 CandidatePairCounts[{i, j}]++

Output pairs with count >= s
```

```python
# Implementación Python conceptual para PCY (Paso 1 y conversión a Bitmap)
import numpy as np

def pcy_pass_one(baskets, num_buckets, hash_func):
    item_counts = {}
    bucket_counts = np.zeros(num_buckets, dtype=int)
    
    for basket in baskets:
        # Conteo de items
        for item in basket:
            item_counts[item] = item_counts.get(item, 0) + 1
            
        # Hashing de pares
        items = sorted(basket) # Asegurar pares únicos {i, j} donde i < j
        for i in range(len(items)):
            for j in range(i + 1, len(items)):
                pair = (items[i], items[j])
                bucket_idx = hash_func(pair) % num_buckets
                bucket_counts[bucket_idx] += 1
                
    return item_counts, bucket_counts

def pcy_create_bitmap(bucket_counts, support_threshold):
    # Convierte conteos de buckets a bitmap (1 si >= soporte, 0 si no)
    return (bucket_counts >= support_threshold).astype(np.int8)

# Nota: En Pass 2, solo se incrementan conteos para pares donde 
# bitmap[hash(pair)] == 1 Y ambos items son frecuentes.
```

## 8. Funciones, métodos, librerías o comandos identificados
- **Hash Function (Función Hash):** Función crítica para distribuir pares en buckets. Debe ser eficiente de computar. En PCY, define la granularidad del filtro.
- **Bitmap:** Estructura de datos compacta (array de bits) para transferir información de "frecuencia de bucket" entre pasadas sin ocupar la memoria de la tabla hash completa.
- **Triples Structure:** Lista o diccionario de pares-clave para conteo disperso. Necesario cuando la matriz triangular no es viable.

## 9. Snippets o plantillas reutilizables

```python
# Cálculo de cota superior para buckets frecuentes
# Útil para decidir si PCY merece la pena antes de implementar
def estimate_frequent_buckets(total_pairs_count, num_buckets, support_threshold):
    avg_bucket_count = total_pairs_count / num_buckets
    # Si avg_bucket_count > support_threshold, PCY es inútil (todos los buckets son frecuentes)
    if avg_bucket_count >= support_threshold:
        return num_buckets # Peor caso: todos son candidatos
    
    # Cota superior teórica
    max_frequent_buckets = total_pairs_count / support_threshold
    return max_frequent_buckets
```

## 10. Casos de uso y aplicaciones
- **Retail de gran escala:** Dataset con mil millones de cestas y 10 items por cesta. A-Priori falla en memoria para pares. PCY permite filtrar pares infrecuentes antes de almacenar estructuras de conteo complejas.
- **Detección de colisiones hash:** El ejemplo del libro demuestra cómo calcular si la distribución de pares (ej. $4.5 \times 10^{10}$ pares en $2.5 \times 10^8$ buckets) permite que la mayoría de buckets estén por debajo del umbral (ej. soporte 1000 vs promedio 180).

## 11. Limitaciones, riesgos y precauciones
- **Complejidad de Pases:** Multistage requiere 3 pasadas (más I/O) para encontrar pares, mientras A-Priori usa 2. Solo justificable si la memoria es el cuello de botella crítico.
- **Overhead de Triples:** PCY obliga a usar triples. Si la reducción de candidatos no es significativa (>66%), el overhead de memoria de los triples supera el ahorro de la poda.
- **Sensibilidad al Soporte:** Si el soporte $s$ es bajo (cercano al conteo promedio por bucket), los algoritmos basados en hash (PCY, Multihash) degeneran y no filtran nada.
- **Muestreo Simple:** El algoritmo aleatorio simple puede generar falsos positivos (itemsets que parecen frecuentes en la muestra pero no en el total) y falsos negativos (itemsets frecuentes que no aparecen en la muestra).

## 12. Relaciones con otros temas del corpus
- **A-Priori (Cap 6.2):** Base sobre la que se construyen PCY, Multistage y Multihash. PCY modifica la pasada 1 y la definición de candidatos en la pasada 2.
- **Bloom Filter (Cap 4.3):** El texto menciona explícitamente que el array de buckets de PCY generaliza la idea de un Bloom Filter.
- **SON Algorithm (Cap 6.4.2):** Mencionado como algoritmo de dos pasadas exacto que se beneficia de computación paralela (MapReduce), a diferencia del muestreo simple.
- **Toivonen’s Algorithm (Cap 6.4):** Mencionado como algoritmo que usa muestreo pero garantiza exactitud (con riesgo de no terminar), a diferencia del muestreo simple.

## 13. Preguntas que la skill debería poder responder
1. ¿Por qué el algoritmo PCY no puede utilizar una matriz triangular para almacenar los conteos de pares candidatos en la segunda pasada?
2. ¿Cuál es la condición necesaria para que el algoritmo PCY sea más eficiente en memoria que A-Priori?
3. ¿Qué error sutil se debe evitar al implementar el algoritmo Multistage respecto a la verificación de condiciones en la pasada final?
4. ¿Cómo afecta el tamaño del soporte $s$ respecto al conteo promedio por bucket en la efectividad del algoritmo Multihash?
5. ¿Cómo se debe ajustar el umbral de soporte al aplicar un algoritmo de muestreo aleatorio simple?
6. ¿Qué estructura de datos se utiliza para comprimir la información de la tabla hash entre pasadas en PCY y cuánto espacio ahorra?
7. ¿En qué escenario el algoritmo Multistage es preferible sobre Multihash?
8. ¿Cuál es el trade-off principal entre A-Priori y los algoritmos PCY/Multistage en términos de uso de memoria y pases de datos?

## 14. Acciones que la skill debería poder recomendar o ejecutar
1. **Calcular viabilidad de PCY:** Estimar si el conteo promedio por bucket será menor que el soporte dado un tamaño de memoria disponible.
2. **Seleccionar estructura de datos:** Recomendar usar "Triples" en lugar de "Matriz Triangular" si se implementa PCY o Multistage.
3. **Configurar Multihash:** Determinar el número óptimo de tablas hash en una pasada para maximizar la poda sin llenar todos los buckets.
4. **Ajustar umbrales:** Escalar el umbral de soporte proporcionalmente al tamaño de la muestra en análisis preliminares.

## 15. Activos finales de conocimiento en formato compacto
| Concepto | Descripción | Referencia |
| :--- | :--- | :--- |
| **PCY** | Usa memoria libre Pass 1 para hashear pares y filtrar candidatos en Pass 2. | Sec 6.3.1 |
| **Frequent Bucket** | Bucket con suma de conteos $\ge s$. Necesario para que un par sea candidato. | Sec 6.3.1 |
| **Bitmap** | Compresión de tabla hash a 1 bit/bucket (1/32 de espacio) para pasar entre fases. | Sec 6.3.1 |
| **Multistage** | Múltiples pasadas con hashes distintos para filtrar candidatos incrementalmente. | Sec 6.3.2 |
| **Multihash** | Múltiples tablas hash en una sola pasada. Riesgo: buckets pequeños se saturan. | Sec 6.3.3 |
| **Regla 2/3** | PCY debe eliminar >66% de candidatos para compensar overhead de usar Triples. | Sec 6.3.1 |
| **Error Multistage** | Verificar siempre todas las condiciones de pasadas anteriores en el conteo final. | Sec 6.3.2 |
| **Muestreo Simple** | Ajustar soporte $s \to s \times p$. Rápido pero inexacto (falsos +/-). | Sec 6.4.1 |
| **Limitación Triangular** | Matriz triangular inutilizable en PCY por dispersión aleatoria de candidatos. | Sec 6.3.1 |
| **Thrashing** | Problema que resuelven estos algoritmos: exceso de datos en memoria limitada. | Sec 6.3 intro |


