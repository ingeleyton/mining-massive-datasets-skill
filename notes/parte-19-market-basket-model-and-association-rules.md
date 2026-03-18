# Parte 19 - Market-Basket Model and Association Rules

## 1. Metadatos del documento
- **Libro:** Mining of Massive Datasets, 3ª ed.
- **Fragmento/Parte:** Parte 19 - Market-Basket Model and Association Rules
- **Temas principales:** Market-Basket Model, Frequent Itemsets, Association Rules, Support Threshold, Confidence, Interest
- **Tipo de contenido:** Teoría / Definiciones / Casos de uso

## 2. Resumen técnico de alto valor
El capítulo introduce el modelo "Market-Basket" como una representación de datos para relaciones muchos-a-muchos entre ítems y canastas (transacciones). El objetivo principal es la identificación de **Frequent Itemsets** (conjuntos de ítems que aparecen en un número de canastas superior a un umbral de soporte $s$), diferenciándose de la búsqueda de similitud (Cap. 3) al priorizar la frecuencia absoluta sobre la relativa. Se establece la base para las reglas de asociación ($I \rightarrow j$), definiendo métricas críticas: **Soporte** (frecuencia absoluta), **Confianza** (probabilidad condicional de aparición) e **Interés** (medida de correlación o causalidad). Se presenta el principio de monotonicidad: un conjunto grande no puede ser frecuente si sus subconjuntos no lo son, sentando las bases para el algoritmo A-Priori.

## 3. Conceptos y definiciones clave
- **Market-Basket Model**: Modelo de datos que representa una relación muchos-a-muchos entre "ítems" y "canastas" (baskets). Cada canasta es un conjunto de ítems (itemset). Se asume que el número de ítems por canasta es pequeño comparado con el total de ítems, pero el número de canastas es muy grande (mayor que la memoria principal).
- **Itemset**: Un conjunto de ítems. Puede ser un singleton (un ítem), doubleton (dos), etc.
- **Support (Soporte)**: Número de canastas que contienen un determinado itemset $I$. Formalmente, si $I$ es un conjunto de ítems, el soporte es el recuento de canastas $B$ tal que $I \subseteq B$.
- **Support Threshold ($s$)**: Umbral numérico predefinido. Un itemset $I$ se considera **frequent** (frecuente) si su soporte es $\ge s$.
- **Association Rule**: Una expresión de la forma $I \rightarrow j$, donde $I$ es un itemset y $j$ es un ítem. Implica que si los ítems en $I$ están presentes en una canasta, es "probable" que $j$ también lo esté.
- **Confidence (Confianza)**: Probabilidad condicional de encontrar $j$ dado $I$. Se define como la fracción de canastas que contienen $I$ y también contienen a $j$.
- **Interest (Interés)**: Diferencia entre la confianza de la regla y la fracción global de canastas que contienen $j$. Mide la "sorpresa" o correlación real, descontando la probabilidad aleatoria.

## 4. Principios, reglas y heurísticas
- **Principio de Monotonicidad (Downward Closure)**: Un itemset grande no puede ser frecuente a menos que todos sus subconjuntos lo sean. Ejemplo: Un doubleton no puede ser frecuente si sus singletons no lo son; un triple no puede ser frecuente si sus doubletons no lo son.
- **Umbral de Soporte Práctico**: En aplicaciones reales (ej. retail físico), un soporte "razonablemente alto" (ej. 1%) es necesario para que las acciones derivadas sean rentables.
- **Umbral de Confianza**: Se busca típicamente $\ge 50\%$ para que una regla tenga utilidad práctica.
- **Interpretación del Interés**:
    - Interés $\approx 0$: No hay correlación (independencia estadística).
    - Interés $> 0$: Correlación positiva (presencia de $I$ promueve $j$).
    - Interés $< 0$: Correlación negativa (presencia de $I$ desalienta $j$, ej. productos sustitutos).
- **Stop Words en Análisis de Texto**: Al buscar conceptos relacionados en documentos, las palabras comunes (stop words) dominarán los itemsets frecuentes y deben ignorarse para encontrar pares interesantes (ej. {Brad, Angelina}).

## 5. Procedimientos, métodos y workflows
**Procedimiento para encontrar reglas de asociación de alta confianza:**
1.  **Definir umbrales**: Establecer un soporte mínimo $s$ y una confianza mínima (ej. 50%).
2.  **Encontrar Itemsets Frecuentes**: Identificar todos los itemsets $J$ que cumplen $Support(J) \ge s$.
    - *Nota*: El texto menciona que esto es costoso y requiere algoritmos específicos (A-Priori), pero aquí se asume que se tienen estos conjuntos.
3.  **Generar Reglas**: Para cada itemset frecuente $J$ con $n$ ítems, generar las $n$ reglas posibles de la forma $J - \{j\} \rightarrow j$.
4.  **Calcular Confianza**: Para cada regla, calcular $\frac{Support(J)}{Support(J - \{j\})}$.
5.  **Filtrar**: Conservar solo las reglas que superan el umbral de confianza.

## 6. Problemas comunes y soluciones
- **Falsa correlación por popularidad**: Un ítem muy popular (ej. "leche") puede generar reglas con alta confianza pero interés cercano a 0.
    - *Solución*: Usar la métrica de **Interés** para filtrar reglas donde la co-ocurrencia es simplemente azar estadístico.
- **Explosión de reglas**: Demasiados itemsets frecuentes generan demasiadas reglas para que un humano las analice.
    - *Solución*: Ajustar el umbral de soporte $s$ hacia arriba hasta que el número de resultados sea manejable.
- **Stop Words en texto**: En minería de texto, palabras como "and", "a", "the" generan itemsets frecuentes triviales.
    - *Solución*: Pre-procesamiento para eliminar palabras comunes antes de buscar itemsets.

## 7. Implementación técnica y generación de código
> *Sección no aplicable a este fragmento.* (El fragmento es teórico y de definiciones; el algoritmo A-Priori se detalla en secciones posteriores no incluidas aquí).

```python
# Implementación Python derivada de las definiciones matemáticas del fragmento

def calculate_support(baskets, itemset):
    """
    Calcula el soporte absoluto de un itemset.
    baskets: Lista de conjuntos (list of sets)
    itemset: Conjunto de items a buscar (set)
    """
    count = 0
    for basket in baskets:
        if itemset.issubset(basket):
            count += 1
    return count

def calculate_confidence(baskets, itemset_I, item_j):
    """
    Calcula la confianza de la regla I -> j.
    Confianza = Support(I U {j}) / Support(I)
    """
    # I U {j}
    union_set = itemset_I.union({item_j})
    
    support_I = calculate_support(baskets, itemset_I)
    support_union = calculate_support(baskets, union_set)
    
    if support_I == 0:
        return 0.0
    
    return support_union / support_I

def calculate_interest(baskets, itemset_I, item_j):
    """
    Calcula el interés de la regla I -> j.
    Interés = Confidence(I -> j) - Fraction_of_baskets_containing_j
    """
    confidence = calculate_confidence(baskets, itemset_I, item_j)
    
    # Fracción de canastas que contienen j (soporte relativo de j)
    support_j = calculate_support(baskets, {item_j})
    fraction_j = support_j / len(baskets)
    
    return confidence - fraction_j

# Ejemplo basado en Fig 6.1 del libro
baskets_example = [
    {'Cat', 'and', 'dog', 'bites'},
    {'Yahoo', 'news', 'claims', 'a', 'cat', 'mated', 'with', 'a', 'dog', 'and', 'produced', 'viable', 'offspring'},
    {'Cat', 'killer', 'likely', 'is', 'a', 'big', 'dog'},
    {'Professional', 'free', 'advice', 'on', 'dog', 'training', 'puppy', 'training'},
    {'Cat', 'and', 'kitten', 'training', 'and', 'behavior'},
    {'Dog', '&', 'Cat', 'provides', 'dog', 'training', 'in', 'Eugene', 'Oregon'},
    {'"Dog', 'and', 'cat"', 'is', 'a', 'slang', 'term', 'used', 'by', 'police', 'officers', 'for', 'a', 'male–female', 'relationship'},
    {'Shop', 'for', 'your', 'show', 'dog', 'grooming', 'and', 'pet', 'supplies'}
]

# Cálculo de ejemplo: {dog} -> cat
# Soporte dog: 7, Soporte cat: 6
# Interés esperado según texto: 5/7 - 3/4 = -0.036
interest_val = calculate_interest(baskets_example, {'dog'}, 'cat')
# print(f"Interés {{dog}} -> cat: {interest_val:.4f}")
```

## 8. Funciones, métodos, librerías o comandos identificados
- **Support Function**: Función matemática para recuento de ocurrencias.
- **Confidence Function**: Ratio de soportes $Support(I \cup \{j\}) / Support(I)$.
- **Interest Function**: Diferencia entre confianza y probabilidad marginal $P(j|I) - P(j)$.

## 9. Snippets o plantillas reutilizables
```python
# Plantilla para evaluación de reglas de asociación
def evaluate_association_rule(baskets, antecedent, consequent):
    s_antecedent = calculate_support(baskets, antecedent)
    s_consequent = calculate_support(baskets, {consequent})
    s_union = calculate_support(baskets, antecedent.union({consequent}))
    
    n_baskets = len(baskets)
    
    metrics = {
        "support_antecedent": s_antecedent,
        "support_consequent": s_consequent,
        "support_union": s_union,
        "confidence": s_union / s_antecedent if s_antecedent > 0 else 0,
        "interest": (s_union / s_antecedent) - (s_consequent / n_baskets) if s_antecedent > 0 else 0
    }
    return metrics
```

## 10. Casos de uso y aplicaciones
- **Retail Físico (Brick-and-Mortar)**: Análisis de tickets de compra para diseñar promociones cruzadas (ej. hot dogs y mostaza, pañales y cerveza). Se busca volumen absoluto alto.
- **Retail Online**: Uso de similitud (Cap. 3) para la "larga cola" (long tail), pero uso de itemsets frecuentes para productos populares.
- **Minería de Texto / Conceptos Relacionados**: Ítems = palabras, Canastas = documentos. Permite descubrir asociaciones semánticas (ej. {Brad, Angelina}) tras filtrar stop words.
- **Detección de Plagio**: Ítems = documentos, Canastas = oraciones. Un par de documentos que aparecen juntos en varias "canastas de oraciones" indica copia.
- **Biomarcadores**: Ítems = genes/proteínas + enfermedades, Canastas = historiales de pacientes. Permite sugerir pruebas diagnósticas.

## 11. Limitaciones, riesgos y precauciones
- **Escalabilidad**: El número de canastas suele exceder la memoria principal, requiriendo algoritmos específicos (A-Priori, MapReduce) que no son triviales.
- **Complejidad Computacional**: Encontrar todos los itemsets frecuentes es computacionalmente costoso si el umbral $s$ es bajo o si los datos son densos.
- **Falsa Causalidad**: Alta confianza no implica causalidad. El ejemplo "diapers $\rightarrow$ beer" es una correlación, no una regla lógica estricta.
- **Independencia**: En datos generados aleatoriamente con independencia total, las reglas de asociación tienen interés 0 y son inútiles.

## 12. Relaciones con otros temas del corpus
- **Similarity Search (Cap. 3)**: Contrastado directamente. Similaridad busca fracción alta (Jaccard), Itemsets Frecuentes busca recuento absoluto alto.
- **A-Priori Algorithm (Sección 6.2)**: Este fragmento establece la necesidad (muchos datos, principio de monotonicidad) que A-Priori resuelve.
- **MapReduce (Cap. 2)**: Mencionado como método para paralelizar la búsqueda de itemsets frecuentes.
- **Data Streams**: Mencionado como contexto para algoritmos aproximados al final de la introducción.

## 13. Preguntas que la skill debería poder responder
1. ¿Cuál es la diferencia fundamental entre la búsqueda de itemsets frecuentes y la búsqueda de similitud (Jaccard)?
2. ¿Cómo se calcula la confianza de una regla de asociación $I \rightarrow j$?
3. ¿Por qué es insuficiente la métrica de "confianza" para determinar si una regla es útil? ¿Qué métrica complementaria se propone?
4. ¿Qué es el principio de monotonicidad y por qué es crucial para la eficiencia de los algoritmos de itemsets frecuentes?
5. ¿Cómo se aplica el modelo Market-Basket a la detección de plagio?
6. ¿Qué valor de interés indica que dos ítems son mutuamente excluyentes?
7. ¿Por qué las tiendas físicas (brick-and-mortar) prefieren itemsets frecuentes mientras las online usan similitud?

## 14. Acciones que la skill debería poder recomendar o ejecutar
- Calcular el soporte, confianza e interés de un conjunto de datos pequeño proporcionado por el usuario.
- Determinar si un itemset es candidato a frecuente basándose en la frecuencia de sus subconjuntos (principio de monotonicidad).
- Sugerir la eliminación de "stop words" en un proyecto de minería de texto antes de buscar itemsets frecuentes.
- Recomendar el ajuste del umbral de soporte si el número de reglas generadas es inmanejable.

## 15. Activos finales de conocimiento en formato compacto
| Concepto | Descripción | Referencia |
| :--- | :--- | :--- |
| **Soporte ($s$)** | Umbral mínimo de frecuencia absoluta para considerar un itemset. | Sec. 6.1.1 |
| **Itemset Frecuente** | Conjunto $I$ tal que $Support(I) \ge s$. | Sec. 6.1.1 |
| **Monotonicidad** | Si $I$ es frecuente, todo $S \subset I$ es frecuente. Inverso: si $S$ no es frecuente, $I$ no puede serlo. | Sec. 6.1.1 |
| **Confidence** | $P(j \mid I) = Support(I \cup \{j\}) / Support(I)$. Mide probabilidad condicional. | Sec. 6.1.3 |
| **Interest** | $P(j \mid I) - P(j)$. Mide desviación de la independencia estadística. | Sec. 6.1.3 |
| **Market-Basket** | Relación muchos-a-muchos entre Ítems y Canastas (transacciones). | Sec. 6.1 |
| **Regla Asociación** | $I \rightarrow j$. Implicación probabilística derivada de itemsets frecuentes. | Sec. 6.1.3 |
| **Stop Words** | Ítems (palabras) de alta frecuencia que enmascaran patrones interesantes en texto. | Sec. 6.1.2 |


