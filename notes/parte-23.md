# parte-23 — Mining-of-Massive-Datasets-Third-Edition-Jure-Leskovec-Anand-Rajaraman-etc-z-library-sk-1lib-sk-z-lib-parte-23.pdf

## 1. Metadatos del documento
- **Libro:** Mining of Massive Datasets, 3ª ed.
- **Fragmento/Parte:** Sección 6.4.7 (Ejercicios), 6.5 (Counting Frequent Items in a Stream), 6.6 (Summary of Chapter 6), 6.7 (References).
- **Temas principales:** Minería de itemsets frecuentes en flujos de datos (streams), Ventana de decaimiento (decaying window), Métodos de muestreo para streams, Métodos híbridos, Resumen de algoritmos de itemsets frecuentes (A-Priori, PCY, SON, Toivonen).
- **Tipo de contenido:** Teoría / Algoritmo / Mixto

## 2. Resumen técnico de alto valor
El fragmento aborda la transición de la minería de itemsets frecuentes desde archivos estáticos a flujos de datos infinitos (streams), donde el soporte debe redefinirse como una fracción de las canastas observadas. Se presentan tres estrategias principales: **muestreo iterativo**, **ventanas de decaimiento** y **métodos híbridos**.

En el modelo de **muestreo**, se procesan segmentos del stream con algoritmos estándar, permitiendo la actualización periódica de los itemsets frecuentes o la adición de candidatos desde el borde negativo. El modelo de **ventana de decaimiento** asigna pesos exponenciales decrecientes a las transacciones antiguas, resolviendo el problema de la explosión combinatoria de candidatos mediante una adaptación del principio de A-Priori: un itemset solo se empieza a contabilizar si todos sus subconjuntos inmediatos ya están siendo monitorizados. El **método híbrido** inicializa puntuaciones basadas en una muestra inicial y actualiza conteos con decaimiento, aunque carece de un mecanismo eficiente para incorporar nuevos itemsets sin re-ejecutar el muestreo. El fragmento concluye con un resumen consolidado de los algoritmos del capítulo (A-Priori, PCY, Multistage, Multihash, SON, Toivonen), estableciendo sus relaciones y compromisos de memoria.

## 3. Conceptos y definiciones clave
- **Stream (Flujo de datos):** Secuencia de elementos (canastas) que llegan a alta velocidad, donde los datos no pueden almacenarse completamente para consulta aleatoria; a diferencia de un archivo, no tiene fin y evoluciona en el tiempo.
- **Soporte en Streams:** Dado que un stream es infinito, el soporte se define como la fracción de canastas en las que aparece un itemset, en lugar de un conteo absoluto, ya que cualquier itemset eventualmente superaría un umbral absoluto si se repite.
- **Ventana de decaimiento (Decaying Window):** Modelo donde se asigna un peso $(1-c)^i$ al $i$-ésimo elemento anterior al más reciente, siendo $c$ una constante pequeña. Aproxima una suma exponencialmente decreciente, dando más importancia a los datos recientes.
- **Puntuación (Score):** Suma de los pesos de las posiciones del stream donde un item (o itemset) aparece. Un itemset se considera frecuente si su puntuación supera un umbral (típicamente $1/2$).
- **Borde negativo (Negative Border):** Conjunto de itemsets que no son frecuentes, pero todos sus subconjuntos inmediatos sí lo son. Útil en algoritmos como Toivonen y para añadir candidatos en streams.
- **Cuello de botella del conteo de pares (Pair-Counting Bottleneck):** En memoria principal, el mayor consumo de recursos suele ocurrir al contar pares de items, lo que motiva estructuras como matrices triangulares o triples.
- **Monotonicidad:** Propiedad que establece que si un itemset es frecuente, todos sus subconjuntos también lo son. Su contrapositivo se usa para podar el espacio de búsqueda.

## 4. Principios, reglas y heurísticas
- **Regla de iniciación de conteo en streams (A-Priori trick):** Para evitar la explosión de candidatos en una ventana de decaimiento, **nunca** inicies el conteo de un itemset $I$ a menos que todos sus subconjuntos propios inmediatos ya estén siendo contados (tengan una puntuación activa).
- **Umbral de puntuación mínima:** En ventanas de decaimiento, no se puede usar un umbral de inicio $> 1$, ya que la primera aparición de un itemset tiene peso $1$ (peso actual). El umbral estándar para mantener un itemset activo es $\ge 1/2$.
- **Ajuste de umbral en muestreo:** Si se toma una muestra de $n/100$ canastas, el umbral de soporte debe escalarse a $s/100$ para mantener la proporcionalidad estadística.
- **Elección de la constante de decaimiento $c$:** Un valor de $c$ grande reduce la ventana efectiva y la memoria requerida, pero hace el sistema sensible a fluctuaciones locales. Un $c$ pequeño integra información histórica pero aumenta el número de itemsets a monitorizar.
- **Regla de eliminación en método híbrido:** Si la puntuación de un itemset cae por debajo del umbral mínimo deseado (ej. 10), se elimina de la colección de frecuentes.

## 5. Procedimientos, métodos y workflows

### 5.1 Método de Muestreo para Streams
1.  **Recolección:** Acumular un número de canastas del stream en un archivo.
2.  **Procesamiento:** Ejecutar un algoritmo de itemsets frecuentes (ej. A-Priori, PCY) sobre el archivo, ignorando momentáneamente las llegadas nuevas o almacenándolas para la siguiente iteración.
3.  **Actualización:**
    *   Opción A: Usar los itemsets resultantes y comenzar una nueva iteración inmediatamente con el archivo acumulado durante el paso 2.
    *   Opción B: Continuar contando ocurrencias de los itemsets frecuentes encontrados en el stream en tiempo real. Eliminar los que caigan por debajo del umbral. Añadir nuevos candidatos periódicamente (ej. desde el borde negativo).

### 5.2 Itemsets Frecuentes en Ventana de Decaimiento
1.  **Inicialización:** Mantener un diccionario de puntuaciones para items/itemsets activos.
2.  **Llegada de nueva canasta:**
    *   Multiplicar todas las puntuaciones actuales por $(1-c)$.
    *   Para cada item o itemset $I$ en la canasta:
        *   Si $I$ ya tiene puntuación: Sumar $1$ a su puntuación.
        *   Si $I$ no tiene puntuación: Verificar si todos sus subconjuntos inmediatos están siendo contados. Si es así, inicializar su puntuación en $1$.
3.  **Poda:** Eliminar cualquier itemset cuya puntuación sea menor que el umbral mínimo (ej. $1/2$).

### 5.3 Método Híbrido (Muestreo + Decaimiento)
1.  **Fase de arranque:** Tomar una muestra inicial de $b$ canastas.
2.  **Cálculo de umbral inicial:** Usar soporte $b \cdot c \cdot s$ (donde $s$ es la puntuación mínima deseada).
3.  **Inicialización de scores:** Si un itemset tiene soporte $t$ en la muestra, asignarle puntuación inicial $t/(b \cdot c)$.
4.  **Mantenimiento:** Aplicar el algoritmo de ventana de decaimiento (multiplicar por $1-c$, sumar 1 si aparece).
5.  **Reinicio:** Si se necesitan nuevos itemsets, realizar una nueva ejecución del algoritmo sobre una muestra fresca.

## 6. Problemas comunes y soluciones
- **Problema: Explosión de candidatos en la primera canasta.** Una canasta con 20 items tiene más de un millón de subconjuntos. Iniciar conteo para todos colapsaría la memoria.
    - **Solución:** Aplicar la restricción de "subconjuntos inmediatos activos". Esto asegura que solo se cuentan itemsets que tienen potencial de ser frecuentes basándose en la evidencia acumulada de sus partes.
- **Problema: Falsos negativos en muestreo simple.** Itemsets frecuentes en el stream global pueden no aparecer en la muestra.
    - **Solución:** Usar el algoritmo de Toivonen (bajar el umbral en la muestra y verificar el borde negativo) o métodos híbridos que re-muestrean periódicamente.
- **Problema: Imposibilidad de iniciar nuevos itemsets en método híbrido.** Un itemset nuevo aparece con score $1$, pero si el umbral mínimo es $10$, se descarta inmediatamente.
    - **Solución:** No existe una solución incremental perfecta. La recomendación es ejecutar cálculos periódicos sobre muestras para "inyectar" nuevos candidatos con puntuaciones iniciales válidas.

## 7. Implementación técnica y generación de código

```pseudocode
# Algoritmo: Actualización de Itemsets en Ventana de Decaimiento
# Entrada: Nueva canasta B, Constante de decaimiento c, Umbral min_score
# Estructura: Diccionario scores (itemset -> score)

Para cada itemset I en scores:
    scores[I] = scores[I] * (1 - c)

Para cada itemset I en B:
    Si I existe en scores:
        scores[I] = scores[I] + 1
    Sino:
        # Verificar principio A-Priori para nuevos candidatos
        Si todos los subconjuntos propios inmediatos de I existen en scores:
            scores[I] = 1

Eliminar entradas en scores donde valor < min_score
```

```python
# Implementación Python: Ventana de Decaimiento para Itemsets
from itertools import combinations

class DecayingWindowFrequentItems:
    def __init__(self, decay_constant_c, min_score=0.5):
        self.c = decay_constant_c
        self.min_score = min_score
        self.scores = {}  # Almacena {frozenset(itemset): score}

    def process_basket(self, basket):
        # Paso 1: Decaimiento de todos los scores existentes
        decay_factor = 1 - self.c
        # Usamos list() para evitar error de modificación durante iteración
        for itemset in list(self.scores.keys()):
            self.scores[itemset] *= decay_factor
            # Poda inmediata para ahorrar memoria
            if self.scores[itemset] < self.min_score:
                del self.scores[itemset]

        # Paso 2: Actualización e Inicialización
        # Ordenamos la canasta para manejar combinaciones consistentes
        items = sorted(list(basket))
        
        # Generar todos los subconjuntos posibles (limitado por lógica A-Priori)
        # Nota: En implementación real, esto se optimizaría para no generar todos los subconjuntos
        # si los padres no existen, pero aquí ilustramos la lógica del libro.
        
        # Verificamos items individuales primero (caso base)
        for item in items:
            self._update_or_init(frozenset([item]))

        # Verificamos itemsets de tamaño > 1
        # Solo iniciamos si los subconjuntos inmediatos existen
        for k in range(2, len(items) + 1):
            for itemset in combinations(items, k):
                self._update_or_init(frozenset(itemset))

    def _update_or_init(self, itemset):
        if itemset in self.scores:
            self.scores[itemset] += 1
        else:
            # Lógica de iniciación conservadora (A-Priori trick)
            # Si es un singleton, se puede iniciar si aparece (score implícito 0 -> 1)
            if len(itemset) == 1:
                self.scores[itemset] = 1
            else:
                # Verificar si todos los subconjuntos de tamaño len-1 están siendo contados
                all_subsets_monitored = True
                # Generar subconjuntos inmediatos (tamaño k-1)
                # Un itemset de tamaño k tiene k subconjuntos inmediatos
                for item in itemset:
                    subset = itemset - frozenset([item])
                    if subset not in self.scores:
                        all_subsets_monitored = False
                        break
                
                if all_subsets_monitored:
                    self.scores[itemset] = 1

    def get_frequent_items(self):
        return {k: v for k, v in self.scores.items() if v >= self.min_score}
```

## 8. Funciones, métodos, librerías o comandos identificados
- **Matriz Triangular:** Estructura de datos para almacenar conteos de pares $(i, j)$ con $i < j$ en un array unidimensional, optimizando espacio respecto a una matriz 2D.
- **Triples $(i, j, c)$:** Estructura alternativa para conteo de pares cuando la densidad es baja (menos de 1/3 de los pares posibles ocurren). Requiere tabla hash o índice.
- **A-Priori:** Algoritmo de múltiples pasadas que usa monotonicidad para reducir candidatos.
- **PCY (Park-Chen-Yu):** Mejora de A-Priori usando una tabla hash en la primera pasada para contar pares en buckets, reduciendo candidatos en la segunda pasada.
- **Multistage / Multihash:** Variantes de PCY con múltiples pasadas hash o tablas hash independientes.
- **SON (Savasere-Omiecinski-Navathe):** Algoritmo basado en segmentos y MapReduce. Divide el archivo, encuentra frecuentes locales y valida globalmente.
- **Toivonen:** Algoritmo de muestreo con borde negativo. Si el borde negativo no tiene frecuentes en el dataset completo, el resultado es exacto.

## 9. Snippets o plantillas reutilizables

```python
# Cálculo de umbral de soporte para muestra inicial en método híbrido
def calculate_sample_threshold(b_sample_size, decay_c, min_score_target):
    """
    Calcula el soporte mínimo requerido en la muestra inicial.
    Fórmula del libro: support_threshold = b * c * s
    """
    return b_sample_size * decay_c * min_score_target

# Ejemplo del Libro (Ejemplo 6.13)
b = 10**8       # Tamaño muestra
c = 10**-6      # Constante decaimiento
s = 10          # Score mínimo deseado
threshold = calculate_sample_threshold(b, c, s)
# Resultado: 1000

# Cálculo de score inicial para un itemset encontrado en la muestra
def calculate_initial_score(t_support_in_sample, b_sample_size, decay_c):
    """
    Fórmula: initial_score = t / (b * c)
    """
    return t_support_in_sample / (b_sample_size * decay_c)

# Ejemplo: Itemset con soporte 2000
t = 2000
init_score = calculate_initial_score(t, b, c)
# Resultado: 20
```

## 10. Casos de uso y aplicaciones
- **Análisis de cesta de la compra en tiempo real:** Detectar tendencias de compra que cambian a lo largo del día (ej. café en la mañana, cerveza en la noche) usando ventanas de decaimiento.
- **Detección de tendencias en redes sociales:** Identificar pares de hashtags o temas que se vuelven frecuentes repentinamente y decaen en popularidad.
- **Sistemas de recomendación dinámicos:** Actualizar reglas de asociación basadas en el comportamiento reciente del usuario sin reprocesar todo el historial histórico.
- **Procesamiento distribuido (MapReduce):** Uso del algoritmo SON para datasets masivos estáticos, paralelizando la búsqueda de candidatos.

## 11. Limitaciones, riesgos y precauciones
- **Complejidad de actualización:** En ventanas de decaimiento, cada nueva canasta requiere multiplicar *todos* los scores actuales por $(1-c)$. Si el número de itemsets frecuentes es masivo, esto es costoso (aunque el libro sugiere que es "trabajo limitado", implica $O(N)$ donde $N$ es el número de itemsets activos).
- **Sensibilidad al parámetro $c$:** Una elección incorrecta de $c$ puede hacer que el sistema reaccione demasiado al ruido ($c$ alto) o que retenga itemsets obsoletos por demasiado tiempo ($c$ bajo).
- **Falsos Negativos en Streams:** Los métodos de muestreo simple pueden perder itemsets frecuentes globales si no aparecen en la muestra.
- **Falsos Positivos:** El muestreo puede identificar itemsets como frecuentes cuando no lo son en el total. El algoritmo SON mitiga esto con una segunda pasada de verificación.
- **Memoria en Streams:** Aunque se poda, el número de itemsets con score $\ge 1/2$ puede crecer indefinidamente si el stream es estable y grande.

## 12. Relaciones con otros temas del corpus
- **MinHashing / LSH (Capítulos precedentes):** Relacionado con la búsqueda de similitudes, mientras que los itemsets frecuentes se centran en co-ocurrencia exacta o umbral de soporte.
- **PageRank:** Similar conceptualmente en el uso de iteraciones y estructuras de grafos, pero aquí el grafo es implícito (items como nodos, co-ocurrencia como aristas).
- **Flujos de datos (Capítulo 4):** Este fragmento extiende los conceptos de ventanas deslizantes y decaimiento (sección 4.7) al problema específico de itemsets.
- **A-Priori (Sección 6.2):** Fundamento teórico indispensable. Sin entender la monotonicidad y el cuello de botella de pares, la adaptación a streams no es comprensible.

## 13. Preguntas que la skill debería poder responder
1. ¿Por qué el soporte en streams se define como una fracción en lugar de un conteo absoluto?
2. ¿Cómo evita el algoritmo de ventana de decaimiento la explosión combinatoria al procesar una canasta con 20 items?
3. ¿Cuál es la fórmula para calcular el umbral de soporte en la muestra inicial de un método híbrido?
4. ¿Qué es el "borde negativo" y qué rol juega en el algoritmo de Toivonen?
5. ¿Qué ventaja ofrece el algoritmo SON en un entorno MapReduce?
6. ¿Cómo se actualiza la puntuación de un itemset existente cuando llega una nueva canasta en el modelo de decaimiento?
7. ¿Cuál es el trade-off al elegir una constante de decaimiento $c$ muy grande?
8. ¿Por qué el método híbrido tiene dificultades para iniciar el conteo de nuevos itemsets que no estaban en la muestra inicial?
9. ¿Cuándo es preferible usar una matriz triangular frente a una estructura de triples para contar pares?
10. ¿Qué condición debe cumplirse para empezar a contar un itemset de tamaño $k$ en una ventana de decaimiento?

## 14. Acciones que la skill debería poder recomendar o ejecutar
- **Seleccionar estructura de datos:** Recomendar usar triples sobre matriz triangular si la densidad de pares es menor al 33%.
- **Configurar stream processing:** Sugerir un valor de $c$ basado en la velocidad del stream y la memoria disponible.
- **Implementar poda:** Ejecutar la eliminación de itemsets con score $< 1/2$ para evitar fugas de memoria.
- **Validar candidatos:** En un entorno distribuido, aplicar la lógica de SON (candidatos locales -> conteo global) para garantizar exactitud.
- **Diagnóstico de fallos:** Identificar si un algoritmo de muestreo está devolviendo resultados incorrectos debido a un umbral no escalado correctamente.

## 15. Activos finales de conocimiento en formato compacto
| Concepto | Descripción | Referencia |
| :--- | :--- | :--- |
| **Monotonicidad** | Si un itemset es frecuente, todos sus subconjuntos también lo son. Usado para poda. | Sec 6.6 |
| **Ventana de Decaimiento** | Asigna peso $(1-c)^i$ a datos antiguos; permite detectar tendencias actuales olvidando el pasado. | Sec 6.5.2 |
| **Truco A-Priori en Streams** | Solo iniciar conteo de itemset $I$ si todos sus subconjuntos inmediatos ya se están contando. | Sec 6.5.2 |
| **Borde Negativo** | Itemsets no frecuentes cuyos subconjuntos sí lo son; clave para Toivonen y adición de candidatos. | Sec 6.4.5, 6.5.1 |
| **SON Algorithm** | Divide el dataset, encuentra frecuentes locales y valida globalmente; ideal para MapReduce. | Sec 6.6 |
| **Cuello de botella de Pares** | El conteo de pares suele ser la parte que más memoria consume; justifica PCY y Multihash. | Sec 6.6 |
| **Umbral Híbrido** | Soporte en muestra = $b \cdot c \cdot s$. Score inicial = $t / (b \cdot c)$. | Sec 6.5.3 |
| **Matriz Triangular** | Array 1D para pares $(i,j)$ con $i<j$. Eficiente si la matriz de pares es densa. | Sec 6.6 |
| **Triples $(i,j,c)$** | Almacenamiento de pares como (item1, item2, conteo). Eficiente si hay pocos pares $(<1/3)$. | Sec 6.6 |
| **PCY Algorithm** | Usa tabla hash en pasada 1 para filtrar pares candidatos en pasada 2. | Sec 6.6 |
