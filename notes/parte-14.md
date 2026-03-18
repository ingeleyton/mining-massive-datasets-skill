# parte-14 — Mining-of-Massive-Datasets-Third-Edition-Jure-Leskovec-Anand-Rajaraman-etc-z-library-sk-1lib-sk-z-lib-parte-14.pdf

## 1. Metadatos del documento
- **Libro:** Mining of Massive Datasets, 3ª ed.
- **Fragmento/Parte:** Mining-of-Massive-Datasets-Third-Edition-Jure-Leskovec-Anand-Rajaraman-etc-z-library-sk-1lib-sk-z-lib-parte-14.pdf (Secciones 4.6.7 final, 4.7, 4.8, 4.9)
- **Temas principales:** Ventanas de decaimiento exponencial, DGIM para suma de enteros, Elementos frecuentes en streams, Modelos de datos de flujo, Resumen de capítulo.
- **Tipo de contenido:** Teoría / Algoritmo / Mixto

## 2. Resumen técnico de alto valor
El fragmento introduce el modelo de **ventanas de decaimiento exponencial** como alternativa a las ventanas deslizantes de tamaño fijo para abordar el problema de la relevancia temporal en flujos de datos infinitos. A diferencia de las ventanas fijas que establecen una frontera brusca entre datos "viejos" y "nuevos", el decaimiento exponencial pondera los elementos recientes con mayor peso, reduciendo exponencialmente la influencia de los datos pasados sin eliminarlos abruptamente.

Se presenta un algoritmo eficiente para identificar **elementos populares recientes** (ej. películas, productos Amazon) en streams de alta cardinalidad. La solución evita almacenar contadores para todos los items mediante un umbral de poda ($1/2$), garantizando que el número de contadores activos no exceda $2/c$, donde $c$ es la constante de decaimiento. Esto permite mantener estadísticas actualizadas con complejidad espacial controlada, aplicable a escenarios donde el número de items únicos es masivo. Adicionalmente, se extiende el algoritmo DGIM para sumar enteros en un stream tratando cada bit como un stream binario independiente.

## 3. Conceptos y definiciones clave
- **Ventana de decaimiento exponencial (Exponentially Decaying Window):** Suma ponderada de todos los elementos vistos en el stream, donde el peso de un elemento decrece exponencialmente con su antigüedad. Formalmente, para un stream $a_1, \dots, a_t$ y constante $c$: $$\sum_{i=0}^{t-1} a_{t-i}(1-c)^i$$
- **Constante de decaimiento ($c$):** Pequeña constante (ej. $10^{-6}$ o $10^{-9}$) que determina la tasa de olvido. Un valor pequeño implica una "memoria" más larga (ventana efectiva de tamaño aproximado $1/c$).
- **Umbral de poda (Threshold):** Valor mínimo (ej. $1/2$) por debajo del cual se descartan los contadores de popularidad de items en una ventana de decaimiento. Debe ser estrictamente menor a 1.
- **Stream Binario Imaginario:** Abstracción utilizada para rastrear la popularidad de un item específico: se asigna un 1 si el elemento del stream coincide con el item, y 0 en caso contrario.
- **Suma de enteros mediante DGIM:** Técnica para estimar la suma de enteros en una ventana deslizante tratando cada bit del entero como un stream binario independiente y aplicando DGIM a cada bit.

## 4. Principios, reglas y heurísticas
- **Regla de actualización de decaimiento:** Cuando llega un nuevo elemento $a_{t+1}$ a una ventana de decaimiento, la nueva suma se calcula como: $\text{Suma}_{nueva} = \text{Suma}_{antigua} \times (1-c) + a_{t+1}$.
- **Límite de espacio en conteo de popularidad:** El número máximo de items rastreados simultáneamente está acotado por $2/c$. Esto se deriva de que la suma total de todos los scores es $1/c$ y cada score mantenido debe ser $\ge 1/2$.
- **Elección de $c$:** Si se desea una ventana efectiva de tamaño $N$ (ej. mil millones de tickets), seleccionar $c \approx 1/N$.
- **Condición de umbral:** El umbral para eliminar contadores debe ser menor a 1 para garantizar que la poda funcione correctamente bajo la lógica de la suma de decaimiento.
- **Error en suma de enteros con DGIM:** Al estimar la suma de enteros usando DGIM bit a bit, si cada bit tiene un error fraccional máximo de $\epsilon$, el error total de la suma es a lo sumo $\epsilon$.

## 5. Procedimientos, métodos y workflows

### 5.1. Mantenimiento de elementos frecuentes con ventanas de decaimiento
**Precondiciones:** Stream de elementos (ej. tickets de cine), constante de decaimiento $c$ pequeña, umbral definido (ej. $1/2$).

**Pasos:**
1. **Decaimiento global:** Multiplicar los scores de todos los items actualmente rastreados por $(1-c)$.
2. **Actualización del item actual:** Si el nuevo elemento del stream es el item $M$:
   - Si $M$ tiene un score registrado, sumar 1.
   - Si $M$ no tiene score, crear una entrada e inicializarla en 1.
3. **Poda:** Eliminar cualquier item cuyo score haya caído por debajo del umbral ($< 1/2$).

**Postcondición:** Se mantienen contadores solo para items "recientemente populares", con un límite superior de $2/c$ items activos.

### 5.2. Estimación de suma de enteros en ventana deslizante (Extensión DGIM)
**Precondiciones:** Stream de enteros, tamaño de ventana $N$.

**Pasos:**
1. Descomponer cada entero entrante en sus $m$ bits.
2. Tratar cada posición de bit ($i$-ésimo bit) como un stream binario independiente.
3. Aplicar el método DGIM para contar los 1's en cada stream de bits, obteniendo conteos $c_i$.
4. Calcular la suma estimada: $$\sum_{i=0}^{m-1} c_i 2^i$$

## 6. Problemas comunes y soluciones
- **Problema:** Las ventanas deslizantes de tamaño fijo requieren almacenar elementos exactos o usar aproximaciones complejas (DGIM) para manejar la salida de elementos antiguos.
  - **Solución:** Usar ventanas de decaimiento exponencial. La "salida" se maneja implícitamente mediante la multiplicación por $(1-c)$, que reduce el peso de los elementos antiguos hasta hacerlos insignificantes, sin necesidad de eliminarlos explícitamente de una estructura de datos.
- **Problema:** Encontrar elementos populares cuando el universo de items es masivo (ej. productos Amazon, usuarios Twitter), haciendo inviable mantener un contador por item.
  - **Solución:** Aplicar el algoritmo de ventanas de decaimiento con umbral de poda. Los items impopulares caen naturalmente por debajo del umbral y se eliminan, limitando el espacio de almacenamiento a $O(1/c)$.
- **Problema:** Distinguir popularidad actual vs. popularidad histórica acumulada (ej. "Star Wars" vendió muchas entradas hace décadas).
  - **Solución:** El decaimiento exponencial penaliza las ventas antiguas, favoreciendo ventas recientes y continuas.

## 7. Implementación técnica y generación de código

```pseudocode
# Algoritmo: Mantenimiento de Elementos Populares con Decaimiento
# Entrada: Stream de items S, constante c, umbral threshold
# Salida: Diccionario de scores actuales

Inicializar diccionario scores = {}

Para cada item M en S:
    # 1. Aplicar decaimiento a todos los scores existentes
    Para cada key en scores:
        scores[key] = scores[key] * (1 - c)
    
    # 2. Actualizar el item actual
    Si M existe en scores:
        scores[M] = scores[M] + 1
    Sino:
        scores[M] = 1
        
    # 3. Poda de elementos irrelevantes
    Para cada key en scores:
        Si scores[key] < threshold:
            eliminar scores[key]

Retornar scores
```

```python
from collections import defaultdict

class DecayingWindowCounter:
    def __init__(self, c=1e-6, threshold=0.5):
        """
        Inicializa el contador de ventana de decaimiento.
        :param c: Constante de decaimiento (ej. 1e-6 para ventana ~1M).
        :param threshold: Umbral mínimo para mantener un contador.
        """
        self.c = c
        self.threshold = threshold
        self.scores = defaultdict(float)

    def update(self, item):
        """
        Procesa un nuevo item del stream.
        """
        # 1. Decaimiento global
        # Nota: En implementaciones reales con millones de keys, 
        # esto es costoso. Optimizaciones existen (lazy updates), 
        # pero aquí se sigue el algoritmo básico del libro.
        decay_factor = 1 - self.c
        keys_to_remove = []
        
        for key in self.scores:
            self.scores[key] *= decay_factor
            if self.scores[key] < self.threshold:
                keys_to_remove.append(key)
        
        # Poda
        for key in keys_to_remove:
            del self.scores[key]
            
        # 2. Actualización del item actual
        self.scores[item] += 1

    def get_top_k(self, k):
        """Retorna los k items más populares."""
        return sorted(self.scores.items(), key=lambda x: x[1], reverse=True)[:k]

# Ejemplo de uso basado en el caso del libro (tickets de cine)
stream = ['Star Wars', 'Avatar', 'Avatar', 'Star Wars', 'Titanic'] * 100
counter = DecayingWindowCounter(c=0.1, threshold=0.5) # c grande para demostración

for movie in stream:
    counter.update(movie)

print(counter.get_top_k(3))
```

## 8. Funciones, métodos, librerías o comandos identificados
- **`defaultdict` (Python):** Estructura útil para implementar los contadores de scores, manejando automáticamente la inicialización de nuevos items.
- **Factor de decaimiento $(1-c)$:** Operación escalar clave aplicada iterativamente a los contadores.
- **Poda (Pruning):** Técnica de limpieza de memoria basada en umbral para controlar la complejidad espacial.

## 9. Snippets o plantillas reutilizables

```python
# Función auxiliar para calcular el límite teórico de memoria
def calculate_max_items(c):
    """Calcula el límite máximo de items activos según la constante c."""
    return 2 / c

# Ejemplo: Si c = 10^-9 (ventana de mil millones)
# max_items = 2,000,000,000 items posibles en el peor caso teórico.
# En la práctica, la distribución de popularidad (ley de potencias) 
# reduce drásticamente este número.
```

## 10. Casos de uso y aplicaciones
- **Tendencias en Redes Sociales:** Identificar hashtags o temas de tendencia en Twitter, donde la relevancia decae rápidamente.
- **Sistemas de Recomendación:** ponderar compras o vistas recientes de productos en Amazon más que las antiguas para perfiles de usuario dinámicos.
- **Monitoreo de Tráfico de Red:** Detectar direcciones IP o puertos con actividad inusualmente alta en tiempos recientes (detección de anomalías/DDoS).
- **Análisis de taquilla:** Determinar películas populares "actualmente" versus películas clásicas con ventas históricas acumuladas.

## 11. Limitaciones, riesgos y precauciones
- **Costo computacional por actualización:** El algoritmo básico requiere multiplicar *todos* los contadores activos en cada paso del stream. Si hay muchos items activos (cercanos a $2/c$), la operación es $O(N)$ por elemento, lo cual puede ser prohibitivo para streams de alta velocidad.
  - *Mitigación no explícita en el texto:* Se requieren optimizaciones de implementación (ej. actualización diferida o "lazy").
- **Sensibilidad a $c$:** Una elección incorrecta de $c$ puede hacer que la "memoria" sea demasiado corta (olvida rápido) o demasiado larga (reacciona lento a cambios).
- **Aproximación:** Los resultados son aproximados y dependen del umbral. Items con popularidad real ligeramente inferior al umbral serán ignorados.

## 12. Relaciones con otros temas del corpus
- **DGIM (Sección 4.6):** Técnica predecesora para ventanas de tamaño fijo. El fragmento conecta DGIM con la suma de enteros y contrasta DGIM con ventanas de decaimiento.
- **Filtros de Bloom (Sección 4.3):** Mencionados en el resumen como técnica para filtrar membresía en streams.
- **Muestreo de Streams (Sección 4.2):** Técnica base para manejar volúmenes de datos, relacionada con la selección de subconjuntos.
- **Conteo de Elementos Distintos (Sección 4.4):** Problema fundamental de streams mencionado en el resumen.

## 13. Preguntas que la skill debería poder responder
1. ¿Cuál es la diferencia fundamental entre una ventana deslizante de tamaño fijo y una ventana de decaimiento exponencial?
2. ¿Cómo se actualiza el score de un item en una ventana de decaimiento cuando llega un nuevo elemento al stream?
3. ¿Por qué el número de items rastreados en el algoritmo de elementos populares está limitado a $2/c$?
4. ¿Qué valor debe tener el umbral de poda en relación a 1 y por qué?
5. ¿Cómo se puede utilizar DGIM para estimar la suma de enteros en un stream?
6. ¿Qué problema resuelve la ventana de decaimiento que el conteo simple no puede resolver en el contexto de popularidad de películas?
7. ¿Cuál es el trade-off entre precisión y uso de memoria al elegir la constante $c$?
8. ¿Qué sucede con el score de un item que no recibe nuevas menciones en el stream a medida que pasa el tiempo?

## 14. Acciones que la skill debería poder recomendar o ejecutar
- **Seleccionar modelo de ventana:** Recomendar "Decaying Window" sobre "Fixed Sliding Window" cuando se requiere suavidad temporal y no hay una frontera clara de relevancia.
- **Configurar parámetros:** Calcular un valor inicial para $c$ basado en el tamaño de ventana efectiva deseado ($N \approx 1/c$).
- **Implementar contador:** Proveer la estructura de código para un sistema de trending topics en tiempo real.
- **Optimizar memoria:** Sugerir el uso de poda por umbral para limitar el crecimiento de la tabla de hash en streams de alta cardinalidad.

## 15. Activos finales de conocimiento en formato compacto

| Concepto | Descripción | Referencia |
| :--- | :--- | :--- |
| **Decaimiento Exponencial** | Pondera datos recientes con peso 1 y antiguos con $(1-c)^i$, evitando bordes duros. | Sec 4.7.2 |
| **Actualización de Score** | $S_{new} = S_{old}(1-c) + a_{t+1}$. Simple y $O(1)$ si se ignora la poda masiva. | Sec 4.7.2 |
| **Límite de Items Activos** | Cota superior $2/c$ para el número de contadores en memoria. | Sec 4.7.3 |
| **Umbral de Poda** | Valor $< 1$ (ej. $1/2$) para eliminar items impopulares y ahorrar espacio. | Sec 4.7.3 |
| **Suma Enteros (DGIM)** | $\sum c_i 2^i$ usando DGIM bit a bit. Error máximo $\epsilon$. | Sec 4.6.7 |
| **Ventana Efectiva** | Tamaño aproximado de la ventana "equivalente" es $1/c$. | Sec 4.7.2 |
| **Caso de Uso** | Trending topics (Twitter/Películas) donde la cardinalidad de items es alta. | Sec 4.7.1 |
