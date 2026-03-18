# parte-07 — Mining-of-Massive-Datasets-Third-Edition-Jure-Leskovec-Anand-Rajaraman-etc-z-library-sk-1lib-sk-z-lib-parte-07.pdf

## 1. Metadatos del documento
- **Libro:** Mining of Massive Datasets, 3ª ed.
- **Fragmento/Parte:** Chapter 3. Finding Similar Items (Secciones 3.1 - 3.2.1)
- **Temas principales:** Similitud de Jaccard, Locality-Sensitive Hashing (LSH), Shingling, Filtrado Colaborativo, Detección de duplicados, Similitud de conjuntos y bolsas.
- **Tipo de contenido:** Teoría / Caso de uso / Definiciones fundamentales

## 2. Resumen técnico de alto valor
El capítulo aborda el problema de la complejidad cuadrática $O(N^2)$ al buscar ítems similares en grandes volúmenes de datos ("massive datasets"), donde el enfoque naive de comparar todos los pares es inviable (ej. 1 millón de ítems genera medio billón de pares). Se introduce **Locality-Sensitive Hashing (LSH)** como la familia de técnicas para mitigar este costo, priorizando la comparación de pares candidatos (aquellos que colisionan en buckets específicos) a costa de tolerar falsos negativos, los cuales son controlables mediante ajuste de parámetros.

El flujo de trabajo fundamental presentado para documentos textuales es: Documento $\to$ Conjunto de Shingles $\to$ Minhashing (firmas comprimidas) $\to$ LSH. Se define la **Similitud de Jaccard** como la métrica central para conjuntos ($SIM(S, T) = |S \cap T| / |S \cup T|$) y se extiende a "bags" (multiconjuntos) para manejar datos con frecuencias o ratings. Se detallan aplicaciones críticas como detección de plagio, páginas espejo y filtrado colaborativo, diferenciando claramente entre similitud textual léxica y similitud semántica.

## 3. Conceptos y definiciones clave
- **Locality-Sensitive Hashing (LSH):** Técnica que utiliza funciones de hash especiales diseñadas para que ítems similares tengan alta probabilidad de colisionar en el mismo bucket, permitiendo filtrar pares no candidatos y reducir carga computacional.
- **Similitud de Jaccard (Conjuntos):** Ratio entre el tamaño de la intersección y la unión de dos conjuntos. Se denota $SIM(S, T)$.
- **k-Shingle (o k-grama):** Subcadena de longitud $k$ extraída de un documento. Es la unidad atómica para convertir documentos en conjuntos y medir similitud léxica.
- **Falso Negativo (en LSH):** Par de ítems que son similares pero no son identificados como candidatos por la función de hash (no colisionan).
- **Par Candidato:** Par de ítems que caen en el mismo bucket para al menos una de las funciones de hash utilizadas en LSH.
- **Minhashing:** Técnica (mencionada, detallada en sec. 3.3) para convertir grandes conjuntos en firmas pequeñas preservando la similitud de Jaccard.
- **Bag (Bolsa/Multiconjunto):** Estructura que permite múltiples ocurrencias de un elemento. La similitud de Jaccard para bolsas requiere lógica específica de conteo (mínimo para intersección, suma para unión).

## 4. Principios, reglas y heurísticas
- **Regla de escalabilidad:** Evitar la comparación exhaustiva de pares cuando $N$ es grande (ej. $N=10^6$). Utilizar LSH para reducir el espacio de búsqueda.
- **Trade-off LSH:** Existe un equilibrio directo entre la cantidad de pares candidatos examinados y la tasa de falsos negativos. Aumentar los candidatos reduce los falsos negativos pero incrementa el costo computacional.
- **Preprocesamiento de texto (Whitespace):** Reemplazar cualquier secuencia de caracteres de espacio en blanco (espacio, tab, newline) por un único espacio en blanco para preservar límites de palabras en los shingles.
- **Umbral de similitud en Filtrado Colaborativo:** A diferencia de páginas espejo (>90% similitud), en datos de usuarios (ej. Amazon, Netflix), similitudes bajas (ej. 20%) pueden ser estadísticamente significativas y útiles.
- **Selección de $k$ en Shingling:** Si $k$ es muy pequeño (ej. sin espacios), se detectan similitudes accidentales (ej. "touch down" vs "touchdown"). Se sugiere retener espacios o elegir $k$ adecuadamente para capturar frases, no solo palabras sueltas.

## 5. Procedimientos, métodos y workflows
### 5.1 Conversión de Documento a Conjunto de k-Shingles
1.  **Entrada:** Documento como cadena de caracteres, parámetro $k$.
2.  **Preprocesamiento:** Normalizar espacios en blanco (colapsar secuencias a un solo espacio).
3.  **Extracción:** Deslizar una ventana de longitud $k$ sobre el documento.
4.  **Salida:** Conjunto de shingles únicos (o bolsa si se requieren frecuencias).

### 5.2 Cálculo de Similitud de Jaccard para Bolsas (Bags)
1.  **Intersección:** Para cada elemento común, contar el mínimo de sus ocurrencias en ambas bolsas. Sumar estos mínimos $\to$ tamaño intersección.
2.  **Unión:** Para cada elemento presente en ambas bolsas, sumar sus ocurrencias totales. Sumar estos totales $\to$ tamaño unión.
3.  **Cálculo:** Dividir tamaño intersección entre tamaño unión.
    *   *Nota:* Bajo esta definición, la similitud máxima de una bolsa consigo misma es 0.5, no 1.

### 5.3 Adaptación de Ratings a Conjuntos (Filtrado Colaborativo)
Dado un dataset de ratings usuario-ítem:
1.  **Opción 1 (Umbral):** Ignorar pares con baja puntuación (tratar como "no comprado/visto").
2.  **Opción 2 (Binario Separado):** Crear conjuntos separados para "liked" y "hated" por cada usuario/ítem.
3.  **Opción 3 (Ponderado/Bolsa):** Si el rating es de $n$ estrellas, insertar el ítem $n$ veces en la bolsa del usuario.

## 6. Problemas comunes y soluciones
- **Problema:** Complejidad $O(N^2)$ al buscar duplicados en webs crawleadas.
    - **Solución:** Aplicar pipeline Shingling $\to$ Minhashing $\to$ LSH.
- **Problema:** Falsos negativos en LSH (pares similares no detectados).
    - **Solución:** "Tuning" cuidadoso: aumentar el número de funciones de hash o ajustar la estructura de bandas/filas (concepto de LSH detallado más adelante en el libro).
- **Problema:** Detección errónea de similitud léxica por concatenación de palabras (ej. "touchdown" vs "touch down").
    - **Solución:** No eliminar espacios en blanco durante la tokenización; tratar el espacio como un carácter más dentro del shingle.
- **Problema:** Comparar documentos con contenido idéntico pero distinta estructura (ej. artículos sindicados con distinto layout/ads).
    - **Solución:** Usar shingling para ignorar el ruido estructural y enfocarse en el contenido textual superpuesto.

## 7. Implementación técnica y generación de código

```pseudocode
# No hay pseudocódigo explícito de algoritmos complejos en este fragmento,
# solo definiciones matemáticas y procedimientos conceptuales.
```

```python
# Implementación de Similitud de Jaccard y Shingling basada en las definiciones del texto

def jaccard_similarity_set(set_a, set_b):
    """
    Calcula la similitud de Jaccard para dos conjuntos.
    SIM(S, T) = |S intersección T| / |S unión T|
    """
    intersection = len(set_a.intersection(set_b))
    union = len(set_a.union(set_b))
    if union == 0:
        return 0.0
    return intersection / union

def jaccard_similarity_bag(bag_a, bag_b):
    """
    Calcula la similitud de Jaccard para dos bolsas (multisets).
    Intersección: suma de los mínimos de conteos.
    Unión: suma de los conteos totales.
    Nota: Según el texto, esto da un máximo de 0.5 para una bolsa consigo misma.
    """
    from collections import Counter
    
    counter_a = Counter(bag_a)
    counter_b = Counter(bag_b)
    
    # Intersección: suma de mínimos
    intersection_count = 0
    common_elements = set(counter_a.keys()) | set(counter_b.keys())
    # Nota: La intersección real son solo las claves comunes, pero iteramos sobre todas para la lógica de unión
    # Corrección: Iterar solo sobre claves comunes para la intersección
    common_keys = set(counter_a.keys()) & set(counter_b.keys())
    for key in common_keys:
        intersection_count += min(counter_a[key], counter_b[key])
        
    # Unión: suma de todos los conteos
    union_count = sum(counter_a.values()) + sum(counter_b.values())
    
    if union_count == 0:
        return 0.0
        
    return intersection_count / union_count

def get_k_shingles(text, k):
    """
    Genera el conjunto de k-shingles de un texto.
    Aplica la regla de normalización de espacios en blanco mencionada en el texto.
    """
    import re
    # Reemplazar secuencias de whitespace por un solo espacio
    clean_text = re.sub(r'\s+', ' ', text)
    
    shingles = set()
    for i in range(len(clean_text) - k + 1):
        shingles.add(clean_text[i:i+k])
    return shingles

# Ejemplo de uso basado en el texto (Example 3.3)
doc_d = "abcdabd"
k = 2
print(f"Shingles para '{doc_d}' con k={k}: {get_k_shingles(doc_d, k)}")
# Output esperado: {'ab', 'bc', 'cd', 'da', 'bd'}
```

## 8. Funciones, métodos, librerías o comandos identificados
- **`SIM(S, T)`**: Notación estándar del libro para la similitud de Jaccard.
- **`k-shingle`**: Operación de extracción de subcadenas.
- **`Set` vs `Bag`**: Distinción de tipos de datos para representación de documentos o preferencias.
- **Whitespace normalization**: Paso crítico de preprocesamiento (regex `\s+` $\to$ espacio simple).

## 9. Snippets o plantillas reutilizables

```python
# Plantilla para detección de documentos similares usando Jaccard y Shingling
# (Concepto básico sin optimización LSH)

def find_similar_documents(docs_list, k_shingle=9, threshold=0.8):
    """
    docs_list: lista de strings (documentos).
    Retorna pares de documentos con similitud > threshold.
    Advertencia: Este método es O(N^2), solo para demostración del concepto.
    """
    signatures = {}
    
    # 1. Convertir a Shingles
    for doc_id, text in enumerate(docs_list):
        signatures[doc_id] = get_k_shingles(text, k_shingle)
    
    results = []
    doc_ids = list(signatures.keys())
    
    # 2. Comparación Naive (Prohibitiva para grandes N según el libro)
    for i in range(len(doc_ids)):
        for j in range(i + 1, len(doc_ids)):
            id1, id2 = doc_ids[i], doc_ids[j]
            sim = jaccard_similarity_set(signatures[id1], signatures[id2])
            if sim >= threshold:
                results.append((id1, id2, sim))
                
    return results
```

## 10. Casos de uso y aplicaciones
- **Detección de Plagio:** Identificar documentos que comparten frases o párrafos, incluso si el orden varía o hay pequeñas modificaciones.
- **Páginas Espejo (Mirror Pages):** Detectar sitios web replicados para balanceo de carga que difieren solo en información del host o enlaces internos.
- **Agregadores de Noticias (ej. Google News):** Agrupar artículos de distintas fuentes que provienen del mismo reportaje original (Associated Press), filtrando logos y anuncios locales.
- **Filtrado Colaborativo (Amazon/Netflix):** Recomendar productos basados en la similitud de Jaccard entre conjuntos de compra de usuarios o conjuntos de "likes" de películas.
- **Deduplicación de Resultados de Búsqueda:** Evitar mostrar dos páginas casi idénticas en la primera página de resultados.

## 11. Limitaciones, riesgos y precauciones
- **Complejidad Naive:** El enfoque directo de comparar todos los pares es inviable para $N > 10^6$.
- **Falsos Negativos en LSH:** Riesgo inherente de perder pares similares. Requiere ajuste fino.
- **Similitud Léxica vs Semántica:** Jaccard y Shingling detectan similitud de caracteres/palabras, NO de significado. Documentos con sinónimos no serán detectados como similares.
- **Elección de $k$:** Un $k$ muy pequeño genera muchas colisiones falsas (falsos positivos). Un $k$ muy grande hace que pequeñas variaciones rompan la similitud (falsos negativos).
- **Limitación de la definición estándar de Jaccard para Bolsas:** La definición estándar (unión como suma de conteos) limita la similitud máxima a 0.5, lo que puede requerir normalización o definiciones alternativas (unión como máximo de conteos) según el caso de uso.

## 12. Relaciones con otros temas del corpus
- **Minhashing (Sección 3.3):** Técnica necesaria para comprimir los conjuntos de shingles antes de aplicar LSH. Es el paso intermedio clave mencionado en este fragmento.
- **LSH para otros tipos de datos (Sección 3.6-3.7):** Generalización del concepto introducido aquí para conjuntos.
- **Distancias y Medidas de Similitud (Sección 3.5):** Fundamento teórico para definir qué significa "similar" más allá de Jaccard.
- **Clustering (Capítulo 7):** Mencionado como técnica complementaria al filtrado colaborativo para agrupar ítems (ej. libros de ciencia ficción) antes de calcular similitudes.

## 13. Preguntas que la skill debería poder responder
1. ¿Por qué no es viable comparar todos los pares de documentos en un dataset masivo?
2. ¿Qué es un k-shingle y cómo afecta el valor de $k$ a la detección de similitudes?
3. ¿Cuál es la fórmula de la similitud de Jaccard para conjuntos y para bolsas?
4. ¿Cómo maneja LSH el trade-off entre eficiencia y falsos negativos?
5. ¿Qué diferencia existe entre similitud textual léxica y similitud semántica en el contexto de este capítulo?
6. ¿Cómo se puede adaptar un sistema de ratings (1-5 estrellas) para usar similitud de Jaccard?
7. ¿Por qué es importante normalizar los espacios en blanco antes de hacer shingling?
8. ¿Qué son los "pares candidatos" en el contexto de LSH?

## 14. Acciones que la skill debería poder recomendar o ejecutar
1. **Recomendar LSH:** Si el usuario tiene $>10^6$ ítems y necesita encontrar duplicados, sugerir LSH en lugar de comparación exhaustiva.
2. **Preprocesamiento:** Aplicar normalización de espacios en blanco (`\s+` $\to$ ` `) antes de generar shingles.
3. **Selección de Parámetros:** Sugerir un valor de $k$ para shingling basado en el tamaño típico de los documentos (ej. $k=9$ para frases cortas).
4. **Transformación de Datos:** Convertir datasets de ratings a representaciones de conjuntos o bolsas para aplicar métricas de similitud.
5. **Alerta de Complejidad:** Advertir al usuario si intenta implementar una búsqueda de similitud mediante bucles anidados sobre datasets grandes.

## 15. Activos finales de conocimiento en formato compacto

| Concepto | Descripción | Referencia |
| :--- | :--- | :--- |
| **Jaccard Set** | $SIM(A,B) = \frac{|A \cap B|}{|A \cup B|}$. Rango [0, 1]. | Sec. 3.1.1 |
| **Jaccard Bag** | Intersección = suma de mínimos; Unión = suma de totales. Max 0.5. | Sec. 3.1.3 |
| **k-Shingle** | Subcadena de longitud $k$. Unidad base para similitud léxica. | Sec. 3.2.1 |
| **LSH** | Hashing probabilístico para filtrar pares candidatos similares. | Intro Cap. 3 |
| **Complejidad Naive** | $N$ items $\to$ $\frac{N(N-1)}{2}$ pares. Inviable para $N$ grande. | Intro Cap. 3 |
| **Falso Negativo** | Par similar que no colisiona en el bucket hash. Controlable. | Intro Cap. 3 |
| **Whitespace** | Colapsar a un espacio para distinguir límites de palabras. | Sec. 3.2.1 |
| **Colab. Filtering** | Usuarios/Items similares por intersección de compras/ratings. | Sec. 3.1.3 |
| **Minhashing** | Compresión de sets grandes a firmas pequeñas (preserva Jaccard). | Sec. 3.3 (ref) |
| **Pipeline** | Doc $\to$ Shingles $\to$ Minhash $\to$ LSH. | Sec. 3.0 |
