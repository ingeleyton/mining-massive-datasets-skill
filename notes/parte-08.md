# parte-08 — Mining-of-Massive-Datasets-Third-Edition-Jure-Leskovec-Anand-Rajaraman-etc-z-library-sk-1lib-sk-z-lib-parte-08.pdf

## 1. Metadatos del documento
- **Libro:** Mining of Massive Datasets, 3ª ed.
- **Fragmento/Parte:** Mining-of-Massive-Datasets-Third-Edition-Jure-Leskovec-Anand-Rajaraman-etc-z-library-sk-1lib-sk-z-lib-parte-08.pdf (Secciones 3.2 a 3.4 intro)
- **Temas principales:** Shingling de documentos, Selección de k-shingles, Minhashing, Matrices de firmas (Signature Matrix), Similitud de Jaccard, Optimización de Minhashing.
- **Tipo de contenido:** Mixto (Teoría / Algoritmo / Implementación)

## 2. Resumen técnico de alto valor
El fragmento aborda la representación de documentos como conjuntos para la detección de similitud léxica, introduciendo los **k-shingles** (subcadenas de longitud $k$) y su variante basada en palabras vacías (stop words) para priorizar contenido editorial sobre elementos circundantes. Se establecen criterios matemáticos para la selección de $k$ basados en la probabilidad de ocurrencia y la cardinalidad del alfabeto, proponiendo hashing para compactación de almacenamiento.
El núcleo técnico reside en **Minhashing**, una técnica para reducir grandes conjuntos en firmas compactas preservando la similitud de Jaccard. Se demuestra que la probabilidad de que dos conjuntos tengan el mismo valor minhash es igual a su similitud de Jaccard. Se detalla el algoritmo práctico para construir la matriz de firmas sin permutaciones físicas explícitas, utilizando funciones hash para simular el ordenamiento de filas, y se presentan estrategias de optimización que limitan el escaneo de filas para reducir la complejidad computacional.

## 3. Conceptos y definiciones clave
- **k-Shingle**: Cualquier subcadena de longitud $k$ encontrada dentro de un documento. Se asocia un documento con el conjunto de k-shingles que aparecen en él.
- **Matriz Característica (Characteristic Matrix)**: Representación de una colección de conjuntos donde las columnas son los conjuntos y las filas son los elementos del universo. La entrada $(r, c)$ es 1 si el elemento $r$ está en el conjunto $c$, y 0 en caso contrario. Es típicamente dispersa (sparse).
- **Minhash**: Función de hash definida sobre una permutación de filas. El valor minhash de una columna es el número de la primera fila (en orden permutado) en la que la columna tiene un 1.
- **Matriz de Firmas (Signature Matrix)**: Resultado de aplicar $n$ funciones minhash a las columnas de la matriz característica. Su tamaño es $n \times \text{número de conjuntos}$, mucho menor que la matriz original. Permite estimar la similitud de Jaccard.
- **Shingles basados en palabras vacías (Stop-word-based shingles)**: Técnica que define un shingle como una palabra vacía seguida de las dos palabras siguientes. Útil para detectar artículos de noticias similares ignorando anuncios o formato circundante.

## 4. Principios, reglas y heurísticas
- **Selección de $k$**: $k$ debe ser lo suficientemente grande para que la probabilidad de que un shingle dado aparezca en un documento dado sea baja.
    - Regla práctica: Asumir ~20 caracteres frecuentes. Estimar shingles posibles como $20^k$.
    - Emails: $k=5$ es adecuado ($27^5 \approx 14M$).
    - Artículos de investigación: $k=9$ es seguro.
- **Hashing de Shingles**: Es preferible usar shingles largos (ej. $k=9$) y hashearlos a 4 bytes, que usar shingles cortos ($k=4$) directamente, ya que esto aumenta la entropía y reduce colisiones no deseadas en el espacio de características.
- **Teorema Minhash-Jaccard**: La probabilidad de que el minhash de dos conjuntos $S_1$ y $S_2$ sea igual bajo una permutación aleatoria es exactamente su similitud de Jaccard: $P(h(S_1) = h(S_2)) = SIM(S_1, S_2)$.
- **Tratamiento de espacios en blanco**: Se recomienda reemplazar secuencias de espacios en blanco por un solo espacio para distinguir shingles que cruzan palabras de los que no.

## 5. Procedimientos, métodos y workflows

### 5.1 Construcción de k-Shingles
1.  Definir $k$ según el tamaño típico del documento.
2.  Recorrer el documento extrayendo todas las subcadenas de longitud $k$.
3.  (Opcional) Reemplazar espacios en blanco múltiples por uno solo antes de extraer.
4.  Almacenar como conjunto (únicos) o bolsa (repeticiones). El libro usa conjuntos.
5.  (Opcional) Aplicar función hash a cada shingle para compactar a enteros.

### 5.2 Cálculo de Matriz de Firmas (Minhashing Práctico)
*Precondición*: Matriz característica $M$ implícita o explícita, $n$ funciones hash $h_1, \dots, h_n$.
1.  Inicializar matriz de firmas $SIG$ con $\infty$ en todas las celdas.
2.  Para cada fila $r$ de la matriz característica:
    a. Calcular $h_1(r), \dots, h_n(r)$.
    b. Para cada columna $c$:
        i. Si $M[r, c] = 0$, no hacer nada.
        ii. Si $M[r, c] = 1$, actualizar $SIG(i, c) = \min(SIG(i, c), h_i(r))$ para todo $i$.
3.  *Resultado*: $SIG$ contiene las firmas minhash.

### 5.3 Estimación de Similitud desde Firmas
1.  Comparar dos columnas de la matriz de firmas.
2.  Calcular la fracción de filas donde los valores son idénticos.
3.  Esa fracción es la estimación de la similitud de Jaccard.

## 6. Problemas comunes y soluciones
- **Problema**: $k$ muy pequeño provoca que documentos no relacionados compartan muchos shingles comunes (falsos positivos).
    - **Solución**: Aumentar $k$. Usar la heurística $20^k$ para estimar el espacio de shingles.
- **Problema**: Permutar físicamente una matriz grande es computacionalmente imposible ($O(n!)$ o sorting costoso).
    - **Solución**: Simular la permutación usando funciones hash que mapean números de fila a "posiciones" virtuales.
- **Problema**: Columnas con todos 0s (conjunto vacío) en Minhashing.
    - **Solución**: El algoritmo deja el valor como $\infty$. Al comparar, si ambos son $\infty$, se ignora esa fila en la estimación. Si uno es $\infty$ y el otro no, cuentan como desiguales.
- **Problema**: Detección de artículos de noticias en páginas web con mucho "ruido" (anuncios, menús).
    - **Solución**: Usar shingles basados en "stop words". El texto editorial contiene más stop words, sesgando los shingles hacia el contenido real del artículo.

## 7. Implementación técnica y generación de código

```pseudocode
# Algoritmo: Cálculo de Minhash Signatures (Sección 3.3.5)
# Entrada: Matriz M (filas r, columnas c), n funciones hash
# Salida: Matriz de firmas SIG

Para cada fila r en M:
    Para cada función hash i en 1..n:
        Calcular h_i(r)
    
    Para cada columna c en M:
        Si M[r, c] == 1:
            Para cada i en 1..n:
                Si h_i(r) < SIG[i, c]:
                    SIG[i, c] = h_i(r)
```

```python
import numpy as np

def generate_minhash_signature(matrix, num_hashes):
    """
    Genera una matriz de firmas Minhash a partir de una matriz característica.
    
    :param matrix: Matriz numpy de forma (num_filas, num_columnas) con 0s y 1s.
    :param num_hashes: Número de funciones hash (filas en la firma final).
    :return: Matriz de firmas (num_hashes, num_columnas).
    """
    num_rows, num_cols = matrix.shape
    # Inicializar firma con infinito
    signature = np.full((num_hashes, num_cols), np.inf)
    
    # Generar coeficientes para funciones hash lineales: h(x) = (a*x + b) % p
    # Asumimos p primo grande o similar al número de filas
    # Simplificación didáctica basada en el ejemplo del libro
    a_coeffs = np.random.randint(1, num_rows, size=num_hashes)
    b_coeffs = np.random.randint(0, num_rows, size=num_hashes)
    
    # Iterar sobre las filas de la matriz característica
    for r in range(num_rows):
        # Calcular valores hash para la fila actual r
        # h(r) = (a*r + b) % num_rows
        hash_values = (a_coeffs * r + b_coeffs) % num_rows
        
        # Iterar sobre columnas para actualizar firma donde haya 1s
        # Optimización vectorial: solo actualizar donde matrix[r, :] == 1
        ones_indices = np.where(matrix[r, :] == 1)[0]
        
        if len(ones_indices) > 0:
            for i in range(num_hashes):
                # Para cada función hash i, actualizar columnas con 1s
                # Tomamos el mínimo entre el valor actual y el nuevo hash
                current_vals = signature[i, ones_indices]
                signature[i, ones_indices] = np.minimum(current_vals, hash_values[i])
                
    return signature

# Ejemplo de uso basado en Fig 3.4 del libro
# Matriz: S1={a,d}, S2={c}, S3={b,d,e}, S4={a,c,d}
# Filas: a=0, b=1, c=2, d=3, e=4
M = np.array([
    [1, 0, 0, 1], # a
    [0, 0, 1, 0], # b
    [0, 1, 0, 1], # c
    [1, 0, 1, 1], # d
    [0, 0, 1, 0]  # e
])

# Nota: El libro usa h1(x)=x+1 mod 5, h2(x)=3x+1 mod 5.
# La implementación arriba usa aleatorios, pero el principio es idéntico.
sig = generate_minhash_signature(M, 2)
print("Matriz de Firmas (Ejemplo):\n", sig)
```

## 8. Funciones, métodos, librerías o comandos identificados
- **Función Hash $h(x)$**: Mapea enteros (filas) a enteros (buckets). Usada para simular permutaciones.
- **Operador Módulo (`mod`)**: Fundamental en la definición de funciones hash simples en el libro (ej. $x+1 \mod 5$).
- **Conjunto (Set)**: Estructura de datos base para almacenar shingles (elementos únicos).
- **Bolsa (Bag/Multiset)**: Variante mencionada donde se cuentan repeticiones, aunque el enfoque principal usa conjuntos.

## 9. Snippets o plantillas reutilizables

```python
def get_shingles(text, k, use_hash=False, hash_range=None):
    """
    Genera k-shingles de un texto.
    
    :param text: String del documento.
    :param k: Tamaño del shingle.
    :param use_hash: Si True, devuelve hashes de los shingles.
    :param hash_range: Rango para el hash (ej. 2^32).
    :return: Conjunto de shingles (strings o enteros).
    """
    # Normalización básica: colapsar espacios en blanco
    text = ' '.join(text.split())
    shingles = set()
    
    for i in range(len(text) - k + 1):
        shingle = text[i:i+k]
        if use_hash:
            # Simulación de hash simple
            shingles.add(hash(shingle) % hash_range if hash_range else hash(shingle))
        else:
            shingles.append(shingle)
            
    return shingles

def jaccard_similarity(set1, set2):
    """
    Calcula la similitud de Jaccard entre dos conjuntos.
    """
    intersection = len(set1.intersection(set2))
    union = len(set1.union(set2))
    return intersection / union if union != 0 else 0.0
```

## 10. Casos de uso y aplicaciones
- **Detección de plagio**: Identificar documentos que comparten frases o sentencias, incluso si el orden ha sido alterado.
- **Agregación de noticias**: Identificar artículos de noticias idénticos o similares que aparecen en diferentes sitios web con distinto entorno HTML (anuncios, menús).
- **Deduplicación de correos electrónicos**: Filtrar correos masivos similares.
- **Indexación web**: Agrupar páginas web similares para evitar indexar contenido redundante.

## 11. Limitaciones, riesgos y precauciones
- **Complejidad computacional**: El cálculo de Minhashing requiere escanear toda la matriz característica (aunque sea dispersa). Para datasets masivos, incluso el escaneo es costoso.
- **Precisión vs. Tamaño**: La precisión de la estimación de Jaccard depende del número de filas en la firma ($n$). Firmas pequeñas tienen mayor varianza.
- **Colisiones de Hash**: Al usar funciones hash para simular permutaciones, las colisiones (dos filas mapeando al mismo valor) introducen un error pequeño pero existente. El libro asume que es despreciable si el espacio de hash es grande.
- **Falsos Negativos en Optimización**: Al escanear solo las primeras $m$ filas (Sección 3.3.6), si un conjunto no tiene 1s en esas filas, su minhash es $\infty$. Esto puede reducir la precisión si $m$ es muy pequeño.
- **Dependencia del Idioma**: La heurística de $k=5$ o $k=9$ y los shingles de stop-words son específicos para inglés. Otros idiomas requieren recalibración.

## 12. Relaciones con otros temas del corpus
- **Jaccard Similarity (Sección 3.1)**: Fundamento teórico que Minhashing busca preservar.
- **Locality-Sensitive Hashing (LSH) (Sección 3.4)**: Paso siguiente lógico. Las firmas Minhash se usan como entrada para LSH para encontrar pares candidatos similares sin comparar todos contra todos.
- **Matrices Dispersas (Sparse Matrices)**: Concepto estructural clave para la eficiencia.
- **MapReduce**: Mencionado en ejercicios (3.3.7) como marco de ejecución paralela para Minhashing.

## 13. Preguntas que la skill debería poder responder
1. ¿Cómo se determina el valor óptimo de $k$ para el shingling de un corpus de documentos?
2. ¿Por qué es preferible hashear shingles largos en lugar de usar shingles cortos directamente?
3. ¿Cuál es la relación matemática entre el Minhash y la similitud de Jaccard?
4. ¿Cómo se simula una permutación aleatoria de filas en la práctica sin reordenar físicamente la matriz?
5. ¿Qué estrategia se utiliza para detectar artículos de noticias similares ignorando el contenido publicitario circundante?
6. ¿Cómo se maneja el caso de columnas con todos ceros (conjunto vacío) en el algoritmo de Minhashing?
7. ¿Qué trade-off existe entre el tamaño de la firma Minhash y la precisión de la estimación?
8. ¿Cómo se puede optimizar el cálculo de Minhashing para reducir el tiempo de ejecución?

## 14. Acciones que la skill debería poder recomendar o ejecutar
- Calcular la similitud de Jaccard entre dos documentos dados sus conjuntos de shingles.
- Implementar una función de generación de firmas Minhash para una matriz de datos dada.
- Sugerir un valor de $k$ para shingling basándose en la longitud promedio del documento y el tamaño del alfabeto.
- Diagnosticar por qué dos documentos considerados similares tienen baja similitud de Jaccard (posible error en la elección de $k$ o preprocesamiento).
- Transformar un conjunto de documentos de texto en una matriz de firmas lista para LSH.

## 15. Activos finales de conocimiento en formato compacto

| Concepto | Descripción | Referencia |
| :--- | :--- | :--- |
| **k-Shingle** | Subcadena de longitud $k$ usada como elemento base del conjunto documento. | Sec 3.2.1 |
| **Minhash** | Valor de la primera fila con '1' tras una permutación aleatoria. Estima Jaccard. | Sec 3.3.2 |
| **Teorema Jaccard-Minhash** | $P(h(S_1) = h(S_2)) = SIM(S_1, S_2)$. Base teórica de las firmas. | Sec 3.3.3 |
| **Matriz de Firmas** | Estructura compacta $n \times C$ que resume conjuntos para comparación eficiente. | Sec 3.3.4 |
| **Hashing de Shingles** | Técnica para reducir almacenamiento: $shingle \to entero$ (ej. 4 bytes). | Sec 3.2.3 |
| **Stop-word Shingles** | Shingle formado por stop-word + 2 palabras siguientes. Útil para noticias. | Sec 3.2.4 |
| **Simulación de Permutación** | Uso de $h(r)$ en lugar de permutar filas físicamente para eficiencia. | Sec 3.3.5 |
| **Optimización $m$ filas** | Escanear solo primeras $m$ filas para acelerar Minhash; introduce símbolo $\infty$. | Sec 3.3.6 |
| **Regla $20^k$** | Heurística para estimar espacio de shingles y elegir $k$ adecuado. | Sec 3.2.2 |
| **Tipos de Filas (X,Y,Z)** | Clasificación para demostrar teorema Minhash: X(1,1), Y(1,0/0,1), Z(0,0). | Sec 3.3.3 |
