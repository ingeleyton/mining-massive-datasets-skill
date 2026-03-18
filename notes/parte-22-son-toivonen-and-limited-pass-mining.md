# Parte 22 - SON, Toivonen, and Limited-Pass Mining

## 1. Metadatos del documento
- **Libro:** Mining of Massive Datasets, 3ª ed.
- **Fragmento/Parte:** Parte 22 - SON, Toivonen, and Limited-Pass Mining
- **Temas principales:** Algoritmos de paso limitado, Muestreo aleatorio, Algoritmo SON, MapReduce, Algoritmo de Toivonen, Frontera negativa, Minería de flujos de datos.
- **Tipo de contenido:** Mixto (Teoría / Algoritmo / Implementación Paralela)

## 2. Resumen técnico de alto valor
El fragmento aborda estrategias para minería de itemsets frecuentes cuando la memoria principal es insuficiente para los algoritmos clásicos de múltiples pasadas (como A-Priori puro), limitando el proceso a una o dos pasadas sobre los datos. Se presenta el **Algoritmo Simple Aleatorizado**, que sacrifica exactitud (permitiendo falsos negativos/positivos) por eficiencia de I/O mediante muestreo. Posteriormente, se detalla el **Algoritmo SON**, que garantiza resultados exactos en dos pasadas dividiendo el dataset en chunks, identificando candidatos locales y validándolos globalmente; su arquitectura lo hace idóneo para implementación en MapReduce. Finalmente, se expone el **Algoritmo de Toivonen**, que utiliza el concepto de **frontera negativa** (conjuntos no frecuentes en la muestra cuyos subconjuntos inmediatos sí lo son) para ofrecer una garantía probabilística de exactitud sin falsos negativos ni positivos, a costa de un pequeño riesgo de no terminar (requiriendo reinicio con nueva muestra). Se introduce brevemente la problemática de flujos infinitos (streams) donde el soporte se redefine como fracción de la ventana temporal.

## 3. Conceptos y definiciones clave
- **Falso Negativo (en muestreo):** Itemset que es frecuente en el dataset completo pero no en la muestra.
- **Falso Positivo (en muestreo):** Itemset que es frecuente en la muestra pero no en el dataset completo.
- **Algoritmo SON (Savasere, Omiecinski, Navathe):** Algoritmo de dos pasadas que divide el archivo en chunks, trata cada chunk como una muestra para encontrar candidatos, y luego valida los candidatos en una pasada completa. Elimina falsos negativos.
- **Frontera Negativa (Negative Border):** Conjunto de itemsets que no son frecuentes en la muestra, pero para los cuales todos sus subconjuntos inmediatos (obtenidos eliminando un item) sí son frecuentes en la muestra.
- **Subconjunto Inmediato:** Subconjunto de un itemset $S$ formado por la eliminación de exactamente un elemento.
- **Umbral de Soporte Escalado:** Ajuste del umbral de soporte $s$ a $p \cdot s$ (o menor) al trabajar con una muestra de proporción $p$.

## 4. Principios, reglas y heurísticas
- **Regla de escalado de umbral:** Si se toma una muestra de proporción $p$ del dataset, el umbral de soporte para la muestra debe escalarse a $p \cdot s$ para mantener la proporcionalidad.
- **Reducción de falsos negativos:** Para minimizar falsos negativos en el algoritmo simple, se recomienda usar un umbral en la muestra ligeramente inferior al proporcional (ej. $0.9 \cdot p \cdot s$), aunque esto aumenta el uso de memoria.
- **Condición de fallo de Toivonen:** Si cualquier itemset en la frontera negativa resulta ser frecuente en el dataset completo, el algoritmo debe reiniciarse con una nueva muestra; no puede producir una respuesta segura en esa iteración.
- **Elección de muestra:** Si los datos no están ordenados aleatoriamente (ej. por fecha o ubicación), tomar los primeros registros o chunks específicos introduce sesgo; se debe muestrear aleatoriamente a nivel de registro o chunk.

## 5. Procedimientos, métodos y workflows

### Algoritmo Simple Aleatorizado
1.  **Precondición:** Dataset grande, memoria limitada, tolerancia a errores.
2.  **Paso 1:** Seleccionar una muestra aleatoria de $p$ proporción del dataset.
3.  **Paso 2:** Ajustar umbral a $p \cdot s$ (o menor).
4.  **Paso 3:** Ejecutar algoritmo de minería (A-Priori, PCY, etc.) sobre la muestra en memoria.
5.  **Paso 4 (Opcional - Verificación):** Realizar una pasada completa para contar los itemsets frecuentes encontrados y eliminar falsos positivos.

### Algoritmo SON (2 Pasadas)
1.  **Pasada 1:** Dividir input en chunks. Para cada chunk (proporción $p$), encontrar itemsets frecuentes con umbral $p \cdot s$.
2.  **Intermedio:** Tomar la unión de todos los itemsets frecuentes de los chunks $\rightarrow$ **Conjunto Candidato**.
3.  **Pasada 2:** Contar ocurrencias de todos los candidatos en el dataset completo.
4.  **Postcondición:** Los itemsets con conteo $\ge s$ son el resultado exacto (sin falsos negativos).

### Implementación SON en MapReduce
- **Map 1:** Input: subconjunto de cestas. Output: Pares $(F, 1)$ para cada itemset frecuente $F$ encontrado localmente con umbral escalado.
- **Reduce 1:** Input: Itemsets como claves. Output: Lista de candidatos (unión de claves recibidas).
- **Map 2:** Input: Candidatos y porción del dataset. Output: $(C, v)$ donde $C$ es candidato y $v$ su soporte local.
- **Reduce 2:** Input: Itemsets como claves, lista de soportes. Output: Itemsets con suma total $\ge s$.

### Algoritmo de Toivonen
1.  **Paso 1:** Tomar muestra aleatoria.
2.  **Paso 2:** Encontrar itemsets frecuentes en la muestra usando umbral $< p \cdot s$ (ej. $0.9ps$).
3.  **Paso 3:** Construir la **frontera negativa**.
4.  **Paso 4:** Pasada completa: Contar itemsets frecuentes de la muestra Y itemsets de la frontera negativa.
5.  **Paso 5 (Decisión):**
    - Si ningún itemset de la frontera negativa es frecuente en el total $\rightarrow$ Éxito. Resultado: Itemsets frecuentes de la muestra que son frecuentes en el total.
    - Si algún itemset de la frontera negativa es frecuente en el total $\rightarrow$ Fallo. Repetir con nueva muestra.

## 6. Problemas comunes y soluciones
- **Sesgo en el muestreo:** Tomar los primeros registros de un archivo ordenado por fecha (ej. datos de ventas) puede omitir tendencias nuevas (ej. iPods en datos antiguos).
    - *Solución:* Muestreo aleatorio explícito o selección aleatoria de chunks en sistemas distribuidos.
- **Falsos Negativos en muestreo simple:** Itemsets con soporte cercano al umbral $s$ tienen ~50% de probabilidad de perderse.
    - *Solución:* Usar SON (garantiza ausencia de falsos negativos) o Toivonen.
- **Falso Positivos en muestreo simple:** El algoritmo reporta itemsets que no son frecuentes globalmente.
    - *Solución:* Realizar una pasada de verificación final sobre el dataset completo.
- **Fallo de Toivonen:** El algoritmo no produce respuesta si la frontera negativa contiene un frecuente global.
    - *Mitigación:* Reducir el umbral de la muestra (ej. de $ps$ a $0.8ps$) para ensanchar la frontera negativa y reducir la probabilidad de que un itemset de la frontera sea frecuente globalmente, a costa de más memoria.

## 7. Implementación técnica y generación de código

```pseudocode
# Algoritmo de Toivonen - Lógica de Frontera Negativa
# Entrada: Sample S, Threshold t
# Salida: FrequentItemsets, NegativeBorder

Function ToivonenLogic(S, t):
    FrequentSets = FindFrequent(S, t)
    NegativeBorder = empty set
    
    # Construcción de la frontera negativa
    # Para cada candidato posible (o nivel por nivel)
    For each itemset I not in FrequentSets:
        If all immediate subsets of I are in FrequentSets:
            Add I to NegativeBorder
            
    Return FrequentSets, NegativeBorder
```

```python
# Implementación Python: Cálculo de la Frontera Negativa
# Suponiendo que tenemos una función check_frequency y una lista de items

def get_immediate_subsets(itemset):
    """Retorna todos los subconjuntos eliminando un elemento."""
    subsets = []
    for i in range(len(itemset)):
        subsets.append(itemset[:i] + itemset[i+1:])
    return subsets

def find_negative_border(frequent_itemsets, all_items):
    """
    frequent_itemsets: set de tuplas ordenadas que son frecuentes en la muestra.
    all_items: lista de todos los items posibles.
    """
    negative_border = set()
    
    # Los candidatos a frontera negativa son itemsets no frecuentes
    # cuyos subconjuntos inmediatos son todos frecuentes.
    # Esto requiere una búsqueda nivelada (BFS) o verificar candidatos generados.
    
    # Simplificación: Verificar itemsets de tamaño k+1 formados por frecuentes de tamaño k
    # Esta es una lógica simplificada; una implementación real seguiría el principio de A-Priori.
    
    # Ejemplo para itemsets de tamaño 1 (singleton)
    # Si un item no es frecuente, su subconjunto inmediato es {} (vacío).
    # {} siempre es frecuente si hay datos. Por tanto, items no frecuentes están en la frontera.
    for item in all_items:
        singleton = (item,)
        if singleton not in frequent_itemsets:
            negative_border.add(singleton)
            
    # Para tamaños mayores, necesitaríamos generar candidatos basados en los frecuentes
    # y verificar la condición de los subconjuntos.
    # Nota: Una implementación completa requiere una estructura de niveles.
    
    return negative_border

# Nota: El código completo de Toivonen requiere manejo de la pasada de verificación global.
```

## 8. Funciones, métodos, librerías o comandos identificados
- **Map Function (SON):** Tarea que procesa subconjuntos de datos para emitir itemsets frecuentes locales o conteos de candidatos.
- **Reduce Function (SON):** Tarea que agrega claves para generar la unión de candidatos o sumar soportes totales.
- **Negative Border Check:** Verificación crítica en Toivonen para determinar la validez del resultado.

## 9. Snippets o plantillas reutilizables
> *Sección no aplicable a este fragmento.* (El fragmento es teórico-algorítmico y no contiene código de software específico reutilizable directamente, más allá de la lógica de pseudocódigo ya presentada).

## 10. Casos de uso y aplicaciones
- **Supermercados (Retail):** Identificación de la mayoría de itemsets frecuentes para promociones, donde no es crítico encontrar el 100% exacto (Algoritmo Simple).
- **Procesamiento Distribuido:** Análisis de grandes volúmenes de datos distribuidos en clústeres (Hadoop/Spark) donde SON es ideal debido a su compatibilidad con MapReduce.
- **Detección de Fraude/Anomalías:** Escenarios donde se requiere exactitud completa pero con restricciones de memoria (Toivonen).

## 11. Limitaciones, riesgos y precauciones
- **Algoritmo Simple:** No garantiza exactitud. Inadecuado si los itemsets cercanos al umbral son críticos.
- **SON:** Requiere dos pasadas completas. La comunicación de red en MapReduce puede ser un cuello de botella si el conjunto de candidatos es masivo.
- **Toivonen:** Riesgo de no terminación (bucle infinito teórico si la muestra es desafortunada repetidamente). Requiere suficiente memoria para almacenar la frontera negativa además de los frecuentes.
- **Streams:** La definición de "frecuencia" cambia a una fracción de la ventana de tiempo, no un conteo absoluto.

## 12. Relaciones con otros temas del corpus
- **A-Priori, PCY, Multihash:** Son los algoritmos base que se ejecutan dentro de las muestras o chunks de SON y Toivonen.
- **MapReduce (Capítulo 2):** Framework de implementación para SON.
- **Minería de Flujos de Datos (Capítulo 4):** Sección 6.5 conecta directamente con técnicas de ventanas deslizantes y decaying windows.
- **Teoría de Probabilidad y Muestreo:** Base matemática para ajustar umbrales y calcular errores esperados.

## 13. Preguntas que la skill debería poder responder
1. ¿Cómo ajustar el umbral de soporte al trabajar con una muestra de proporción $p$?
2. ¿Qué es la frontera negativa en el algoritmo de Toivonen y por qué es crucial?
3. ¿Cómo garantiza el algoritmo SON que no existan falsos negativos?
4. ¿Cuál es la diferencia principal entre el algoritmo simple de muestreo y el algoritmo de Toivonen en términos de garantías de resultado?
5. ¿Cómo se estructura el flujo MapReduce para el algoritmo SON?
6. ¿Qué condiciones causan que el algoritmo de Toivonen falle y deba reiniciarse?
7. ¿Por qué es riesgoso tomar los primeros registros de un archivo como muestra?
8. ¿Qué estrategia se puede usar para reducir los falsos negativos en el algoritmo simple de muestreo?

## 14. Acciones que la skill debería poder recomendar o ejecutar
- **Selección de Algoritmo:** Recomendar SON sobre A-Priori si el dataset no cabe en memoria y se dispone de un clúster MapReduce.
- **Ajuste de Parámetros:** Sugerir reducir el umbral de la muestra a $0.9ps$ si la memoria disponible lo permite y se desean menos falsos negativos.
- **Validación de Resultados:** Implementar una pasada de verificación sobre el dataset completo si se usó muestreo simple y se requieren eliminar falsos positivos.
- **Diseño de Workflow:** Definir las funciones Map y Reduce específicas para una tarea de minería de itemsets frecuentes distribuida.

## 15. Activos finales de conocimiento en formato compacto
| Concepto | Descripción | Referencia |
| :--- | :--- | :--- |
| **SON** | 2 pasadas, exacto, paralelizable (MapReduce). Divide en chunks, busca candidatos locales, valida global. | Sec 6.4.3 |
| **Toivonen** | Muestreo + Frontera Negativa. Exacto (probabilístico). Riesgo de no terminar si la frontera negativa tiene frecuentes globales. | Sec 6.4.5 |
| **Frontera Negativa** | Itemsets no frecuentes en muestra cuyos subconjuntos inmediatos sí lo son. Indicador de fallo en Toivonen. | Sec 6.4.5 |
| **Umbral Muestra** | Escalar $s \to ps$. Para reducir falsos negativos usar $< ps$ (ej. $0.9ps$). | Sec 6.4.2 |
| **Falso Negativo** | Itemset frecuente global perdido en la muestra. Se elimina con SON o Toivonen. | Sec 6.4.2 |
| **MapReduce SON** | Map1/Reduce1 generan candidatos (unión). Map2/Reduce2 cuentan soporte global. | Sec 6.4.4 |
| **Sesgo de Muestreo** | Evitar tomar datos secuenciales si hay orden temporal o geográfico. Usar selección aleatoria. | Sec 6.4.1 |
| **Streams** | Soporte redefinido como fracción de la ventana; los conteos absolutos pierden sentido. | Sec 6.5 |


