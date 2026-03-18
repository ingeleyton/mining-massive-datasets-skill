# Parte 11 - Entity Resolution and High-Similarity Search

## 1. Metadatos del documento
- **Libro:** Mining of Massive Datasets, 3ª ed.
- **Fragmento/Parte:** Parte 11 - Entity Resolution and High-Similarity Search
- **Temas principales:** Entity Resolution, Matching de Huellas Dactilares, Shingling basado en Stop Words, Detección de Alta Similitud, Indexación por Prefijo, Filtrado por Longitud
- **Tipo de contenido:** Mixto (Teoría, Algoritmo, Caso de uso)

## 2. Resumen técnico de alto valor
El fragmento aborda aplicaciones prácticas de Locality-Sensitive Hashing (LSH) y métodos alternativos para alta similitud. Se detalla **Entity Resolution** mediante un sistema de puntuación de registros y validación estadística usando campos independientes (ej. fechas) para estimar la probabilidad de coincidencia sin verdad de terreno. Se presenta una familia LSH específica para **huellas dactilares** basada en la coincidencia de minucias en cuadrículas, optimizando tasas de falsos positivos/negativos mediante construcciones AND-OR. Para **artículos de noticias**, se propone un shingling basado en "stop words" para diferenciar texto periodístico de anuncios publicitarios. Finalmente, se introducen **métodos exactos para alta similitud** (Jaccard cercano a 1) que evitan LSH: representación de conjuntos como cadenas ordenadas, filtrado por longitud, e indexación por prefijo (símbolo, posición y longitud de sufijo) para garantizar cero falsos negativos y reducir comparaciones.

## 3. Conceptos y definiciones clave
- **Entity Resolution (Resolución de Entidades):** Proceso de identificar registros en diferentes fuentes que se refieren a la misma entidad del mundo real (ej. la misma persona), manejando variaciones en nombres, direcciones y formatos.
- **Minutiae (Minucias):** En el contexto de huellas dactilares, son características específicas como bifurcaciones o terminaciones de crestas. Se representan como conjuntos de puntos en una cuadrícula.
- **Many-One vs. Many-Many Problem:** En matching, *Many-One* compara un elemento nuevo contra una base de datos existente; *Many-Many* busca pares duplicados dentro de toda la base de datos.
- **Stop Words (Palabras vacías):** Palabras muy frecuentes (ej. "the", "and", "you"). En el contexto de artículos de noticias, su presencia distingue prosa real de anuncios o encabezados, permitiendo crear shingles más robustos.
- **Prefix Indexing (Indexación por Prefijo):** Técnica para encontrar conjuntos con alta similitud de Jaccard. Se indexan los primeros $p$ elementos de la representación ordenada de un conjunto para generar candidatos.
- **Suffix Length (Longitud de Sufijo):** En indexación avanzada, el número de símbolos que siguen a una posición dada en una cadena. Se usa para refinar cotas de similitud y reducir comparaciones.

## 4. Principios, reglas y heurísticas
- **Validación de Matches sin Ground Truth:** Si se dispone de un campo no utilizado en el *scoring* (ej. fecha de creación), se puede estimar la fracción de verdaderos positivos. Si $x$ es la medida promedio para pares con score $s$, $h_0$ para matches perfectos y $h_1$ para pares aleatorios, la fracción de matches verdaderos $f$ es: $f = \frac{h_1 - x}{h_1 - h_0}$.
- **Diseño de LSH para Huellas:** La probabilidad de coincidencia aleatoria es $(0.2)^6$ (para 3 cuadrículas en dos huellas distintas). La probabilidad de coincidencia real es $(0.2)^3 \times (0.8)^3$. Se requieren construcciones OR para aumentar recall y AND para aumentar precisión.
- **Filtrado por Longitud:** Para que dos conjuntos tengan similitud Jaccard $\ge J$, sus longitudes deben cumplir: $L_t \le L_s / J$.
- **Cálculo del tamaño del Prefijo:** Para garantizar que dos conjuntos con similitud $\ge J$ compartan al menos un símbolo en el índice, la longitud del prefijo $p$ debe ser: $p = \lfloor (1-J)L_s \rfloor + 1$.
- **Shingling de Noticias:** Definir un shingle como una "stop word" seguida de las siguientes dos palabras. Esto filtra contenido publicitario con baja densidad de stop words.

## 5. Procedimientos, métodos y workflows

### Procedimiento: Entity Resolution con Validación Estadística
1.  **Scoring:** Asignar puntuación a pares de registros basada en similitud de campos (nombre, dirección, teléfono). Penalizar diferencias (ej. distancia de edición creciente cuadráticamente).
2.  **Generación de Candidatos (LSH simple):** Ordenar registros por campos individuales. Comparar solo registros adyacentes en estos ordenamientos (buckets implícitos).
3.  **Validación:** Usar un campo independiente (ej. diferencia de fechas). Calcular el promedio para matches perfectos ($h_0$) y para pares aleatorios ($h_1$). Para un score $s$ dado, medir el promedio observado $x$ y estimar la fracción de verdaderos matches.

### Procedimiento: Detección de Alta Similitud mediante Indexación de Prefijos
1.  **Representación:** Convertir conjuntos a cadenas ordenadas según un orden fijo del universo.
2.  **Filtrado Longitud:** Ordenar cadenas por longitud. Comparar $s$ solo con cadenas $t$ posteriores donde $L_t \le L_s/J$.
3.  **Indexación:** Para cada cadena $s$, indexar sus primeros $p$ símbolos en buckets.
4.  **Consulta:** Para una cadena $s$, buscar en los buckets de sus primeros $p$ símbolos. Comparar con los candidatos encontrados.
5.  **Refinamiento (Posición/Sufijo):** Indexar por triplas (símbolo, posición, longitud de sufijo). Al consultar, verificar restricciones de desigualdad para minimizar comparaciones.

## 6. Problemas comunes y soluciones
- **Problema:** Comparar $N^2$ pares en Entity Resolution es inviable ($10^{12}$ pares).
    - **Solución:** Usar LSH simple ordenando por campos individuales; solo se comparan registros que coinciden exactamente en al menos un campo.
- **Problema:** Falsos positivos en matching de huellas dactilares (examinar mucho de la BD).
    - **Solución:** Usar construcción AND de dos grupos OR. Ejemplo: 2 grupos de 1024 funciones OR. Reduce falsos positivos al cuadrado ($0.063^2$) con pequeña pérdida de recall.
- **Problema:** Shingling tradicional detecta similitud en "ruido" (anuncios) en vez de contenido en artículos de noticias.
    - **Solución:** Usar shingles definidos por stop words. Los anuncios tienen baja densidad de stop words, por lo que generan pocos shingles y se ignoran.
- **Problema:** LSH introduce falsos negativos.
    - **Solución:** Para alta similitud ($J > 0.9$), usar métodos basados en cadenas y prefijos (Sección 3.9), que son exactos (sin falsos negativos).

## 7. Implementación técnica y generación de código

```pseudocode
# Algoritmo: Cálculo de longitud de prefijo para indexación
# Entrada: Longitud del string L_s, Umbral de similitud J
# Salida: Longitud del prefijo p

Función CalcularPrefijo(L_s, J):
    p = floor((1 - J) * L_s) + 1
    Retornar p
```

```python
# Implementación Python: Estimación de verdaderos matches en Entity Resolution
def estimate_true_match_fraction(avg_measure_score_s, avg_measure_perfect, avg_measure_random):
    """
    Estima la fracción de pares que son verdaderos matches basándose en una medida auxiliar.
    Fórmula: f = (h1 - x) / (h1 - h0)
    
    Args:
        avg_measure_score_s (float): Promedio de la medida auxiliar para pares con score s (x).
        avg_measure_perfect (float): Promedio para matches perfectos (h0).
        avg_measure_random (float): Promedio para pares aleatorios (h1).
        
    Returns:
        float: Fracción estimada de verdaderos matches.
    """
    numerator = avg_measure_random - avg_measure_score_s
    denominator = avg_measure_random - avg_measure_perfect
    
    if denominator == 0:
        return 0.0 # Evitar división por cero si no hay varianza
        
    return numerator / denominator

# Ejemplo del libro (Sección 3.8.3)
# h0 (perfecto) = 10 días
# h1 (random) = 45 días
# x (score s) = variable
# Si x = 20 días:
fraction = estimate_true_match_fraction(20, 10, 45)
# Resultado: (45 - 20) / (45 - 10) = 25 / 35 = 0.714
```

```python
# Implementación Python: Generación de Shingles basados en Stop Words
def get_stop_word_shingles(text, stop_words, k=3):
    """
    Genera shingles de longitud k donde la primera palabra es una stop word.
    Útil para diferenciar prosa de anuncios en noticias.
    """
    words = text.lower().split()
    shingles = set()
    
    for i in range(len(words) - k + 1):
        if words[i] in stop_words:
            # Crear shingle: stop_word + siguientes k-1 palabras
            shingle = " ".join(words[i:i+k])
            shingles.add(shingle)
            
    return shingles
```

## 8. Funciones, métodos, librerías o comandos identificados
- **Edit Distance (Distancia de Edición):** Usada como penalización en scoring de Entity Resolution.
- **Jaccard Similarity:** Métrica base para comparación de conjuntos (huellas, documentos).
- **LSH Family $F$ (Huellas):** Función definida por 3 cuadrículas. Retorna "sí" si ambas huellas tienen minucias en las 3 cuadrículas.
- **Construcción OR ($F_1$):** Combinar muchas funciones base para aumentar probabilidad de coincidencia (recall).
- **Construcción AND:** Combinar resultados de construcciones OR para exigir coincidencia en múltiples grupos (precisión).

## 9. Snippets o plantillas reutilizables

```python
# Plantilla: Filtrado de candidatos por longitud para alta similitud Jaccard
def filter_by_length(candidates, s_length, J_threshold):
    """
    Filtra candidatos cuya longitud impide alcanzar el umbral de Jaccard.
    Regla: L_t <= L_s / J
    """
    max_len_t = s_length / J_threshold
    valid_candidates = [t for t in candidates if len(t) <= max_len_t]
    return valid_candidates
```

## 10. Casos de uso y aplicaciones
- **Resolución de Clientes (Caso A vs B):** Dos compañías con 1M de registros cada una. Se usó scoring de 300 puntos y validación por fecha para resolver disputas legales sobre clientes referidos.
- **Identificación Forense:** Comparar una huella encontrada (Many-One) contra una base de datos masiva usando LSH de minucias.
- **Deduplicación de Noticias:** Agrupar artículos del mismo evento de diferentes periódicos, ignorando el "ruido" del sitio web (ads, menús) mediante shingles de stop words.

## 11. Limitaciones, riesgos y precauciones
- **Dependencia de Umbrales:** Los métodos de alta similitud (Sección 3.9) solo funcionan eficientemente cuando el umbral de Jaccard es alto (ej. $>0.9$).
- **Supuestos en Huellas:** El método LSH para huellas asume normalización perfecta (escala/orientación) y probabilidades fijas de minucias (20% aleatorio, 80% match real).
- **Falsos Negativos en LSH:** A diferencia de los métodos de indexación por prefijo, LSH estándar puede perder matches reales (falsos negativos), aunque se puede ajustar para minimizarlos.
- **Calidad de Datos en Entity Resolution:** Nombres mal escritos o campos faltantes requieren penalizaciones adaptativas y tablas de lookup (ej. "Bill" = "William").

## 12. Relaciones con otros temas del corpus
- **MinHashing (Sección 3.3-3.4):** Técnica base de la que parten las aplicaciones LSH, aunque para huellas se propone una familia LSH distinta a MinHash.
- **Shingling (Sección 3.2):** Técnica base modificada en 3.8.6 para usar stop words.
- **Distancias (Sección 3.5):** Se menciona la distancia de edición y coseno como base para scoring y comparaciones.
- **Indexación en Espacios Euclidianos (Sección 3.7):** Contexto previo de LSH antes de las aplicaciones prácticas.

## 13. Preguntas que la skill debería poder responder
1.  ¿Cómo estimar la cantidad de verdaderos matches en Entity Resolution si no se dispone de datos etiquetados?
2.  ¿Qué técnica de shingling es más efectiva para comparar artículos de noticias ignorando la publicidad circundante?
3.  ¿Cuándo es preferible usar métodos de indexación por prefijo sobre LSH estándar?
4.  ¿Cómo se calcula la longitud del prefijo necesario para indexar un conjunto y garantizar no perder candidatos con similitud $J$?
5.  ¿Cómo se puede reducir la tasa de falsos positivos en un esquema LSH para huellas dactilares sin aumentar excesivamente los falsos negativos?
6.  ¿Qué relación debe existir entre las longitudes de dos conjuntos para que puedan tener una similitud Jaccard superior a un umbral $J$?

## 14. Acciones que la skill debería poder recomendar o ejecutar
- **Recomendar:** Usar indexación por prefijo en lugar de LSH si el requisito es encontrar items casi idénticos ($J > 0.9$) y no se toleran falsos negativos.
- **Implementar:** Un sistema de scoring con penalizaciones cuadráticas por distancia de edición para Entity Resolution.
- **Calcular:** La probabilidad de falsos positivos/negativos al combinar funciones LSH con construcciones AND y OR.
- **Diseñar:** Un esquema de shingling personalizado usando stop words para análisis de contenido web.

## 15. Activos finales de conocimiento en formato compacto
| Concepto | Descripción | Referencia |
| :--- | :--- | :--- |
| **Validación de Matches** | Estimar fracción de matches reales $f = (h_1 - x)/(h_1 - h_0)$ usando campo auxiliar. | Sec 3.8.3 |
| **Stop Word Shingling** | Shingle = stop word + 2 palabras siguientes. Filtra anuncios, preserva prosa. | Sec 3.8.6 |
| **Filtro Longitud** | Cota superior para longitud de candidato: $L_t \le L_s / J$. | Sec 3.9.3 |
| **Longitud de Prefijo** | $p = \lfloor (1-J)L_s \rfloor + 1$. Garantiza intersección no vacía en índice. | Sec 3.9.4 |
| **LSH Huellas (F)** | Función basada en 3 cuadrículas. Match si minucia en las 3. | Sec 3.8.5 |
| **Construcción AND-OR** | Combinar grupos OR mediante AND para reducir falsos positivos drásticamente. | Sec 3.8.5 |
| **Indexación por Posición** | Bucket (símbolo, posición). Reduce candidatos vs indexar solo símbolo. | Sec 3.9.5 |
| **Indexación por Sufijo** | Bucket (símbolo, pos, long. sufijo). Máxima optimización para alta similitud. | Sec 3.9.6 |
| **Scoring Entity Res.** | 100 pts/campo. Penalización cuadrática por distancia de edición. | Sec 3.8.2 |
| **Alta Similitud** | Usar métodos de string exactos (no LSH) para $J \approx 1$. | Sec 3.9.1 |


