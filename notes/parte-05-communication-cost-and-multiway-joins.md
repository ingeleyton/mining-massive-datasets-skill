# Parte 05 - Communication Cost and Multiway Joins

## 1. Metadatos del documento
- **Libro:** Mining of Massive Datasets, 3ª ed.
- **Fragmento/Parte:** Parte 05 - Communication Cost and Multiway Joins
- **Temas principales:** Communication-Cost Model, Multiway Joins, Star Joins, Optimización de Joins en MapReduce, Wall-Clock Time, Checkpointing en Pregel.
- **Tipo de contenido:** Teoría / Algoritmo / Optimización Matemática

## 2. Resumen técnico de alto valor
El fragmento establece el **modelo de costo de comunicación** como la métrica dominante para evaluar algoritmos en entornos de computación en clúster (MapReduce), priorizando el volumen de datos movidos sobre el tiempo de CPU. Se demuestra que el cuello de botella principal es la red (interconexión a 1Gbps) y la lectura de disco, no la velocidad del procesador. El texto profundiza en la optimización de **joins multiway** (uniones de múltiples vías), demostrando matemáticamente mediante multiplicadores de Lagrange que un join de tres tablas ejecutado en un solo trabajo MapReduce puede ser significativamente más eficiente que una cascada de joins de dos vías, al evitar la materialización de datos intermedios. Se presenta el caso específico del **Star Join** (tabla de hechos + tablas de dimensiones) y se derivan fórmulas para minimizar el costo de comunicación asignando correctamente el número de buckets (reductores) a los atributos de join.

## 3. Conceptos y definiciones clave
- **Communication-Cost of a Task:** Tamaño de la entrada de la tarea (en bytes o tuplas). Es la métrica principal de costo en sistemas distribuidos debido a la lentitud relativa de la red y disco frente a la CPU.
- **Communication-Cost of an Algorithm:** Suma de los costos de comunicación de todas las tareas que implementan el algoritmo.
- **Wall-Clock Time:** Tiempo real transcurrido desde el inicio hasta el fin de la ejecución. Es crucial para asegurar que la minimización del costo de comunicación no concentre todo el trabajo en una sola tarea (lo cual minimiza comunicación pero maximiza tiempo).
- **Multiway Join:** Unión de tres o más relaciones en una sola operación (ej. un solo trabajo MapReduce), en lugar de una cascada de joins binarios.
- **Star Join:** Patrón de consulta común en minería de datos donde una tabla central grande (tabla de hechos) se une con múltiples tablas pequeñas (tablas de dimensiones).
- **Checkpoint (Pregel):** Copia del estado completo de una tarea para recuperación ante fallos. El costo de crear checkpoints debe equilibrarse con la probabilidad de fallo para minimizar el tiempo esperado de ejecución.

## 4. Principios, reglas y heurísticas
- **Dominancia de la comunicación:** En clústeres, el tiempo de ejecución de algoritmos simples (lineales) suele ser despreciable comparado con el tiempo de mover datos entre nodos o de disco a memoria.
- **Tamaño de salida:** El tamaño de la salida final rara vez domina el costo porque los resultados masivos suelen agregarse o resumirse antes de ser útiles.
- **Trade-off Checkpoint vs. Fallo:** En Pregel, se debe hacer checkpoint cada $n$ superpasos tal que la probabilidad de fallo durante esos $n$ superpasos sea baja. El tiempo de recuperación debe ser mucho menor que el tiempo medio entre fallos.
- **Regla de optimización para 3-way Join:** Para minimizar el costo en un join $R(A,B) \bowtie S(B,C) \bowtie T(C,D)$ con $k$ reductores, el número de buckets para los atributos $B$ y $C$ debe ser proporcional a la raíz cuadrada de los tamaños de las relaciones opuestas:
  - Buckets para $B$ ($b$): $\approx \sqrt{kr/t}$
  - Buckets para $C$ ($c$): $\approx \sqrt{kt/r}$
- **Eficiencia del Multiway Join:** Un join de tres vías es preferible a una cascada de dos joins binarios cuando el tamaño de la relación intermedia generada por el primer join es muy grande (ej. redes sociales con alta conectividad).

## 5. Procedimientos, métodos y workflows
### Procedimiento: Implementación de 3-way Join en MapReduce
**Objetivo:** Unir $R(A,B)$, $S(B,C)$ y $T(C,D)$ minimizando comunicación.
**Precondiciones:** $k$ reductores disponibles, funciones hash $h$ (para B) y $g$ (para C).
**Pasos:**
1. **Configuración:** Definir $b$ buckets para $B$ y $c$ buckets para $C$ tal que $b \cdot c = k$. Asignar cada reductor a un par $(i, j)$ donde $0 \le i < b$ y $0 \le j < c$.
2. **Map Phase (Distribución de tuplas):**
   - Tuplas $S(v, w)$: Enviar al reductor $(h(v), g(w))$. (1 destino).
   - Tuplas $R(u, v)$: Enviar a todos los reductores $(h(v), y)$ para todo $y \in [0, c)$. ($c$ destinos).
   - Tuplas $T(w, x)$: Enviar a todos los reductores $(z, g(w))$ para todo $z \in [0, b)$. ($b$ destinos).
3. **Reduce Phase:**
   - Cada reductor recibe subconjuntos de $R, S, T$.
   - Indexar localmente tuplas de $R$ por $B$ y tuplas de $T$ por $C$.
   - Para cada tupla $S(v,w)$, buscar coincidencias en índices locales y generar tuplas resultado.

### Procedimiento: Cálculo de Buckets Óptimos (Lagrange)
**Objetivo:** Minimizar costo $s + cr + bt$ sujeto a $bc = k$.
**Pasos:**
1. Plantear función Lagrangiana: $L = s + cr + bt - \lambda(bc - k)$.
2. Derivar respecto a $b$ y $c$ e igualar a 0.
3. Resolver el sistema para obtener $b$ y $c$ en función de $r, t, k$.

## 6. Problemas comunes y soluciones
- **Problema:** Cuello de botella en cascada de joins binarios ($R \bowtie S \bowtie T$). Si $R \bowtie S$ es muy grande (ej. producto cartesiano casi total o alta selectividad), el segundo job falla o es ineficiente.
  - **Solución:** Usar un solo job MapReduce con join multiway. El costo total se reduce de $O(r+s+t+prs)$ a $r + 2s + t + 2\sqrt{krt}$.
- **Problema:** Recuperación ante fallos en sistemas iterativos (Pregel).
  - **Solución:** Reiniciar todo el trabajo desde el último checkpoint. Es aceptable si el tiempo de re-computación es menor que el tiempo medio entre fallos.
- **Problema:** Minimizar costo de comunicación aumentando el tiempo de reloj (Wall-Clock Time).
  - **Solución:** Asegurar que el trabajo se distribuya equitativamente entre los nodos disponibles. El modelo asume que los algoritmos propuestos dividen el trabajo equitativamente.

## 7. Implementación técnica y generación de código

```pseudocode
# Algoritmo: 3-Way Join MapReduce Setup
# Input: Relaciones R(A,B), S(B,C), T(C,D), k reductores
# Output: Configuración de buckets b, c

b = round(sqrt(k * size(R) / size(T)))
c = round(sqrt(k * size(T) / size(R)))
# Ajuste para asegurar b*c <= k
if b * c > k:
    adjust b or c downwards

# Map Function Logic
def Map(tuple, relation_type):
    if relation_type == 'S':
        # S(B,C) -> key (h(B), g(C))
        emit_key = (hash_B(tuple.B) % b, hash_C(tuple.C) % c)
        emit(emit_key, tuple)
    elif relation_type == 'R':
        # R(A,B) -> keys (h(B), *) -> replicate to 'c' reducers
        for j in range(c):
            emit_key = (hash_B(tuple.B) % b, j)
            emit(emit_key, tuple)
    elif relation_type == 'T':
        # T(C,D) -> keys (*, g(C)) -> replicate to 'b' reducers
        for i in range(b):
            emit_key = (i, hash_C(tuple.C) % c)
            emit(emit_key, tuple)
```

```python
# Implementación Python: Cálculo de buckets óptimos y simulación de distribución
import math

def optimize_multiway_join_buckets(size_r, size_s, size_t, k):
    """
    Calcula el número óptimo de buckets para los atributos B y C
    en un join R(A,B) |><| S(B,C) |><| T(C,D).
    
    Args:
        size_r (int): Tamaño (cardinalidad) de R.
        size_s (int): Tamaño de S.
        size_t (int): Tamaño de T.
        k (int): Número total de reductores disponibles.
        
    Returns:
        tuple: (b, c) número de buckets para B y C.
    """
    if k <= 0: raise ValueError("k debe ser > 0")
    
    # Derivación matemática del libro:
    # Minimizar s + c*r + b*t sujeto a b*c = k
    # Solución: c = sqrt(k*t/r), b = sqrt(k*r/t)
    
    c = math.sqrt(k * size_t / size_r) if size_r > 0 else k
    b = math.sqrt(k * size_r / size_t) if size_t > 0 else k
    
    # Redondeo y ajuste
    b = int(math.ceil(b))
    c = int(math.ceil(c))
    
    # Ajuste fino para no exceder k reductores
    while b * c > k:
        if b > c: b -= 1
        else: c -= 1
        
    return b, c

def calculate_communication_cost(size_r, size_s, size_t, b, c):
    """
    Calcula el costo de comunicación teórico para la fase Reduce.
    Costo = s + c*r + b*t
    """
    return size_s + c * size_r + b * size_t

# Ejemplo de uso basado en el libro (Facebook friends)
# r = 3x10^11, k variable
r_size = 3e11
s_size = 3e11 # Asumiendo R=S
t_size = 3e11 # Asumiendo R=T
k_reducers = 1000

b_opt, c_opt = optimize_multiway_join_buckets(r_size, s_size, t_size, k_reducers)
print(f"Buckets óptimos: b={b_opt}, c={c_opt}, Total Reductores={b_opt*c_opt}")
```

## 8. Funciones, métodos, librerías o comandos identificados
- **Hash Function ($h$, $g$):** Funciones para distribuir valores de atributos en $b$ y $c$ buckets respectivamente.
- **Lagrange Multipliers:** Técnica matemática usada para optimización con restricciones (minimizar costo sujeto a $bc=k$).
- **Reducer Vector:** Identificador de reductor como par $(i, j)$ donde $i$ es el bucket del atributo $B$ y $j$ el bucket del atributo $C$.

## 9. Snippets o plantillas reutilizables
> *Sección no aplicable a este fragmento.*

## 10. Casos de uso y aplicaciones
- **Redes Sociales (Facebook):** Cálculo de amigos de amigos de amigos ($R \bowtie R \bowtie R$). El join multiway evita generar la tabla intermedia de "amigos de amigos" que sería 30 veces más grande que la original.
- **Data Warehousing (Retail/Walmart):** Star Joins. Unir una tabla de hechos de ventas (miles de millones de tuplas) con tablas de dimensiones (productos, tiendas, fechas). El join multiway es casi siempre más eficiente que joins binarios sucesivos.
- **Marketing:** Identificación de usuarios con círculos sociales extendidos para campañas de muestras gratuitas.

## 11. Limitaciones, riesgos y precauciones
- **Supuesto de simplicidad algorítmica:** El modelo asume que la tarea realiza cómputo simple (lineal). Si el algoritmo del reducer es cuadrático o exponencial, el costo de cómputo puede dominar sobre la comunicación.
- **Tamaño de salida:** El modelo desestima el tamaño de la salida. Si el resultado del join es masivo y no se agrega, el costo de comunicación real será mayor al estimado.
- **Complejidad de implementación:** El join multiway requiere lógica de replicación compleja en el Map (enviar tuplas a múltiples reductores), lo que aumenta la complejidad del código frente a un join binario estándar.
- **Balanceo de carga:** La distribución óptima teórica asume uniformidad en las funciones hash. Sesgos en los datos (data skew) pueden causar que algunos reductores reciban mucha más información.

## 12. Relaciones con otros temas del corpus
- **MapReduce (Capítulo 2.3):** Este fragmento extiende los algoritmos básicos de MapReduce (joins 2-way) hacia optimizaciones avanzadas.
- **Relational Algebra:** Fundamento teórico de las operaciones de Join.
- **Pregel (Capítulo 2.4):** El fragmento menciona estrategias de checkpoint y recuperación de fallos en sistemas iterativos.
- **Data Mining:** El concepto de Star Join es fundamental para arquitecturas de Data Warehousing y OLAP.

## 13. Preguntas que la skill debería poder responder
1. ¿Por qué se prioriza el costo de comunicación sobre el costo de CPU en modelos de clúster como MapReduce?
2. ¿Cuál es la fórmula para calcular el número óptimo de buckets en un join de tres vías $R(A,B) \bowtie S(B,C) \bowtie T(C,D)$?
3. ¿En qué escenario es preferible un join multiway sobre una cascada de joins binarios?
4. ¿Cómo se distribuyen las tuplas de las relaciones $R$, $S$ y $T$ en la fase Map de un join multiway?
5. ¿Qué es un Star Join y por qué el modelo de costo de comunicación recomienda replicar las tablas de dimensiones?
6. ¿Cómo afecta el tiempo de reloj (wall-clock time) a la decisión de minimizar el costo de comunicación?
7. ¿Cuál es la estrategia de recuperación ante fallos en Pregel y cómo se decide la frecuencia de los checkpoints?

## 14. Acciones que la skill debería poder recomendar o ejecutar
1. **Evaluar estrategia de Join:** Comparar costo estimado de join multiway vs. cascada de joins binarios dados los tamaños de las tablas $r, s, t$.
2. **Configurar Reductores:** Calcular los parámetros $b$ y $c$ para configurar un trabajo MapReduce de join multiway.
3. **Diseñar flujo ETL:** Sugerir la estructura de un flujo de trabajo para procesar consultas analíticas sobre tablas de hechos grandes.
4. **Análisis de cuello de botella:** Identificar si un trabajo es ineficiente debido a la materialización de datos intermedios excesivos.

## 15. Activos finales de conocimiento en formato compacto
| Concepto | Descripción | Referencia |
|---|---|---|
| **Costo de Comunicación** | Suma del tamaño de entrada de todas las tareas; métrica dominante en clústeres. | Sec 2.5.1 |
| **Join Multiway** | Unión simultánea de $N$ relaciones en un solo paso para evitar datos intermedios. | Sec 2.5.3 |
| **Optimización Buckets** | $b = \sqrt{kr/t}$, $c = \sqrt{kt/r}$ para minimizar costo en 3-way join. | Sec 2.5.3 |
| **Star Join** | Join de tabla de hechos grande con dimensiones pequeñas; replicar dimensiones es eficiente. | Box p.60 |
| **Wall-Clock Time** | Tiempo real de ejecución; previene concentrar trabajo en un solo nodo para minimizar comunicación. | Sec 2.5.2 |
| **Checkpoint Pregel** | Copia de estado para recuperación; frecuencia óptima depende de probabilidad de fallo. | Sec 2.4.6/2.4.7 |
| **Distribución R-Tuple** | En 3-way join, tuplas de $R$ se envían a $c$ reductores (columna completa en la matriz de reducers). | Sec 2.5.3 |
| **Distribución T-Tuple** | En 3-way join, tuplas de $T$ se envían a $b$ reductores (fila completa). | Sec 2.5.3 |
| **Cuello de botella** | Interconexión de red (1Gbps) y transferencia disco-memoria vs. velocidad CPU. | Sec 2.5.1 |
| **Costo 3-way vs 2-way** | Multiway preferible si tamaño intermedio ($prs$ o $pst$) es muy grande (ej. redes sociales). | Ex 2.16 |


