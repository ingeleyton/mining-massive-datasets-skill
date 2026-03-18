# Parte 13 - Bloom, Flajolet-Martin, AMS, and DGIM

## 1. Metadatos del documento
- **Libro:** Mining of Massive Datasets, 3ª ed.
- **Fragmento/Parte:** Parte 13 - Bloom, Flajolet-Martin, AMS, and DGIM
- **Temas principales:** Filtrado de Flujos (Bloom Filter), Conteo de Elementos Distintos (Flajolet-Martin), Estimación de Momentos (Alon-Matias-Szegedy), Conteo en Ventanas (DGIM), Ventanas de Decaimiento.
- **Tipo de contenido:** Teoría / Algoritmo / Implementación

## 2. Resumen técnico de alto valor
El fragmento aborda el procesamiento de flujos de datos masivos bajo restricciones estrictas de memoria, presentando estructuras probabilísticas y algoritmos de aproximación para resolver problemas de membresía, cardinalidad y estadísticas de orden superior. Se introduce el **Filtro de Bloom** para filtrado eficiente con tolerancia a falsos positivos controlables mediante múltiples funciones hash. Para el conteo de elementos únicos, se detalla el algoritmo **Flajolet-Martin**, que explota la probabilidad de patrones de bits (ceros finales) en valores hash para estimar cardinalidad, proponiendo una combinación de promedios y medianas para mitigar sesgos. Se presenta el algoritmo **Alon-Matias-Szegedy (AMS)** para la estimación del segundo momento (número sorpresa) y momentos superiores, utilizando variables de muestra mantenidas con probabilidad uniforme a lo largo del tiempo. Finalmente, se describe el algoritmo **DGIM** para el conteo de unos en ventanas deslizantes binarias con un error máximo del 50% usando buckets de tamaño exponencial, y se introduce conceptualmente la ventana de decaimiento exponencial para ponderar la relevancia temporal de los datos.

## 3. Conceptos y definiciones clave
- **Filtro de Bloom (Bloom Filter):** Estructura de datos probabilística compuesta por un array de $n$ bits y $k$ funciones hash. Permite probar la membresía de un elemento en un conjunto $S$. Garantiza cero falsos negativos, pero permite falsos positivos.
- **Falso Positivo:** En el contexto de Bloom Filters, ocurre cuando un elemento no perteneciente al conjunto $S$ genera valores hash que corresponden a bits ya establecidos en 1 por otros elementos.
- **Longitud de cola (Tail Length):** En el algoritmo Flajolet-Martin, es el número de ceros consecutivos al final de la representación binaria del resultado de una función hash aplicada a un elemento del flujo.
- **Momento de orden $k$ ($k$-th moment):** Suma sobre todos los elementos $i$ de $(m_i)^k$, donde $m_i$ es el número de ocurrencias del elemento $i$ en el flujo.
- **Número Sorpresa (Surprise Number):** Nombre coloquial para el segundo momento ($\sum m_i^2$). Mide qué tan desigual es la distribución de elementos en el flujo.
- **Bucket (Cubeta):** En el algoritmo DGIM, estructura que representa un segmento del flujo con un timestamp de su extremo derecho y un tamaño (número de unos) que es potencia de 2.
- **Ventana de Decaimiento (Decaying Window):** Técnica para asignar pesos a los elementos del flujo que disminuyen exponencialmente con el tiempo, dando más importancia a los eventos recientes.

## 4. Principios, reglas y heurísticas
- **Regla de membresía Bloom:** Si un elemento hashea a un bit 0, el elemento definitivamente no está en el conjunto. Si hashea a todos 1s, probablemente está en el conjunto.
- **Optimización de Bloom:** La tasa de falsos positivos se minimiza eligiendo $k$ (número de funciones hash) óptimo en función de $n$ (bits) y $m$ (elementos en el conjunto). Fórmula de probabilidad: $(1 - e^{-km/n})^k$.
- **Estimación Flajolet-Martin:** La estimación de elementos distintos es $2^R$, donde $R$ es la máxima longitud de cola observada.
- **Combinación de estimadores (Flajolet-Martin):** No usar el promedio directo de $2^R$ (sesgado por sobrestimaciones grandes). No usar la mediana sola (solo devuelve potencias de 2). Usar **promedio de grupos pequeños, luego mediana de esos promedios**.
- **Reglas de invariante DGIM:**
    1. Los buckets no se superponen.
    2. Los tamaños de buckets son potencias de 2.
    3. Para cada tamaño $2^j$, hay uno o dos buckets (o $r-1$ a $r$ buckets para reducir error).
    4. Los buckets se ordenan por tamaño creciente hacia la izquierda (pasado).
- **Muestreo uniforme en flujos infinitos (AMS):** Para mantener una muestra de tamaño $s$ con probabilidad uniforme $s/n$ en un flujo de longitud $n$, al llegar el elemento $n+1$, seleccionarlo con probabilidad $s/(n+1)$ y, si se selecciona, descartar uno existente aleatoriamente.

## 5. Procedimientos, métodos y workflows

### 5.1 Inicialización y Consulta de Filtro de Bloom
1.  **Inicialización:** Crear array de $n$ bits en 0. Para cada elemento $x \in S$, calcular $h_i(x)$ para $i=1 \dots k$ y poner esos bits a 1.
2.  **Consulta (Filtrado):** Llega elemento $y$ del flujo. Calcular $h_1(y), \dots, h_k(y)$.
    *   Si algún bit está en 0 $\rightarrow$ Rechazar $y$ (no está en $S$).
    *   Si todos los bits están en 1 $\rightarrow$ Aceptar $y$ (posiblemente en $S$).

### 5.2 Algoritmo Flajolet-Martin (Estimación Distintos)
1.  Definir múltiples funciones hash $h$ que mapeen elementos a cadenas de bits suficientemente largas.
2.  Mantener $R$: máxima longitud de cola vista para cada hash.
3.  Por cada elemento $a$ en el flujo: calcular hash, obtener longitud de cola $r$. Si $r > R$, actualizar $R = r$.
4.  Estimación final: Combinar estimaciones de múltiples hashes mediante promedio de grupos y mediana de promedios.

### 5.3 Algoritmo Alon-Matias-Szegedy (Segundo Momento)
1.  Mantener un conjunto de variables $X$ (tamaño $s$ limitado por memoria).
2.  Cada variable $X$ almacena: $X.element$ (valor del elemento) y $X.value$ (contador).
3.  **Inicialización/Mantenimiento:** A medida que fluye el stream, seleccionar posiciones aleatorias uniformemente (ver sección 4.4). Al encontrar el elemento elegido para $X$, iniciar $X.value = 1$. Por cada ocurrencia posterior del mismo elemento, incrementar $X.value$.
4.  **Estimación:** Para cada variable $X$, calcular $Est = n(2 \cdot X.value - 1)$.
5.  Promediar las estimaciones de todas las variables $X$ para obtener el segundo momento.

### 5.4 Algoritmo DGIM (Conteo de Unos en Ventana)
1.  **Estructura:** Mantener una lista de buckets ordenados por tiempo.
2.  **Llegada de bit 0:** No hacer nada (excepto limpiar buckets viejos).
3.  **Llegada de bit 1:**
    *   Crear bucket de tamaño 1 con timestamp actual.
    *   Si hay 3 buckets de tamaño 1, fusionar los dos más antiguos en un bucket de tamaño 2.
    *   Propagar fusiones: si hay 3 buckets de tamaño 2, fusionar en tamaño 4, etc.
    *   Eliminar buckets cuyo timestamp salga de la ventana $N$.
4.  **Respuesta a Query (últimos $k$ bits):**
    *   Sumar tamaños de buckets completamente dentro de la ventana.
    *   Sumar la mitad del tamaño del bucket parcialmente dentro (el más antiguo que toca la ventana).

## 6. Problemas comunes y soluciones
- **Problema:** Sobrecarga de memoria al almacenar un conjunto grande $S$ para filtrado.
    - **Solución:** Usar Filtro de Bloom. Acepta falsos positivos a cambio de usar espacio fijo $n$ bits.
- **Problema:** Sesgo en la estimación de elementos distintos usando promedios en Flajolet-Martin.
    - **Solución:** El valor esperado de $2^R$ es infinito (sesgado por valores altos). Usar mediana de promedios para estabilizar la estimación.
- **Problema:** Conteo exacto de unos en ventana deslizante requiere $O(N)$ bits.
    - **Solución:** DGIM usa $O(\log^2 N)$ bits con error máximo del 50%.
- **Problema:** Muestreo sesgado en flujos infinitos (los elementos tempranos dominan).
    - **Solución:** Técnica de "reservoir sampling" implícita en AMS: reemplazar muestras antiguas con probabilidad decreciente a medida que crece el flujo.

## 7. Implementación técnica y generación de código

### Pseudocódigo: Filtro de Bloom (Inicialización y Test)

```pseudocode
// n: tamaño del array de bits
// S: conjunto de elementos permitidos
// h1...hk: funciones hash independientes
Array bits[1..n] = 0

// Construcción
FOR each x IN S DO:
    FOR i = 1 TO k DO:
        bits[hi(x)] = 1
    END FOR
END FOR

// Filtrado de stream
FUNCTION test(y):
    FOR i = 1 TO k DO:
        IF bits[hi(y)] == 0 THEN:
            RETURN False // Definitivamente no está
        END IF
    END FOR
    RETURN True // Probablemente está
```

### Pseudocódigo: Mantenimiento DGIM

```pseudocode
// N: tamaño de la ventana
// current_time: timestamp actual
ON new_bit(b):
    IF b == 1 THEN:
        create_bucket(size=1, time=current_time)
        // Fusionar buckets si hay 3 del mismo tamaño
        current_size = 1
        WHILE count_buckets(size=current_size) > 2 DO:
            merge_oldest_two(size=current_size) // Crea bucket size*2
            current_size = current_size * 2
        END WHILE
    END IF
    
    // Limpiar buckets fuera de ventana
    IF oldest_bucket.time < current_time - N THEN:
        drop_oldest_bucket()
```

### Implementación Python: Filtro de Bloom Básico

```python
import mmh3 # Librería común para hashing MurmurHash3
from bitarray import bitarray

class BloomFilter:
    def __init__(self, size, hash_count):
        """
        size: Tamaño del array de bits (n)
        hash_count: Número de funciones hash (k)
        """
        self.size = size
        self.hash_count = hash_count
        self.bit_array = bitarray(size)
        self.bit_array.setall(0)

    def add(self, string):
        for seed in range(self.hash_count):
            result = mmh3.hash(string, seed) % self.size
            self.bit_array[result] = 1

    def lookup(self, string):
        for seed in range(self.hash_count):
            result = mmh3.hash(string, seed) % self.size
            if self.bit_array[result] == 0:
                return False # No falso negativo
        return True # Puede ser falso positivo
```

## 8. Funciones, métodos, librerías o comandos identificados
- **Funciones Hash ($h_1 \dots h_k$):** Críticas para Bloom y Flajolet-Martin. Deben ser independientes y distribuir uniformemente.
- **Bit Array:** Estructura de datos fundamental para Bloom Filter y DGIM (representación de buckets).
- **Timestamp (mod N):** Usado en DGIM para gestionar la expiración de buckets en la ventana deslizante.
- **Tail Length:** Función auxiliar para contar ceros finales en binario (Flajolet-Martin).

## 9. Snippets o plantillas reutilizables

### Cálculo de probabilidad de Falso Positivo en Bloom Filter
```python
import math

def calculate_false_positive_rate(n, m, k):
    """
    n: número de bits en el array
    m: número de elementos insertados
    k: número de funciones hash
    """
    # Probabilidad de que un bit específico siga siendo 0: (1 - 1/n)^(km)
    # Aproximación: e^(-km/n)
    prob_bit_zero = math.exp(-k * m / n)
    prob_bit_one = 1 - prob_bit_zero
    # Falso positivo: todos los k bits son 1
    return prob_bit_one ** k
```

### Estimación del Segundo Momento (AMS) en Python
```python
import random

class AMSSketch:
    def __init__(self, num_variables):
        self.variables = [None] * num_variables # {'element': val, 'count': int}
        self.n = 0 # Total de elementos vistos

    def process(self, element):
        self.n += 1
        # Lógica simplificada de muestreo: con probabilidad 1/n reemplazar
        # (En implementación real se usa la lógica de reemplazo probabilístico descrita en 4.5.5)
        
        # Actualizar contadores de variables existentes
        for var in self.variables:
            if var is not None and var['element'] == element:
                var['count'] += 1

    def estimate_second_moment(self):
        estimates = []
        for var in self.variables:
            if var:
                # Formula: n * (2 * value - 1)
                estimates.append(self.n * (2 * var['count'] - 1))
        return sum(estimates) / len(estimates) if estimates else 0
```

## 10. Casos de uso y aplicaciones
- **Filtro de Spam:** Permitir correos de remitentes en lista blanca (Bloom Filter). El filtro elimina la mayoría del spam, y los falsos positivos (spam permitido) se pueden verificar en disco si es necesario.
- **Estadísticas de Web:** Contar usuarios únicos mensuales en sitios de alto tráfico (Google, Amazon) sin almacenar todos los IDs (Flajolet-Martin).
- **Detección de Anomalías:** Calcular el "número sorpresa" (segundo momento) para detectar cambios bruscos en la distribución de ataques de red o popularidad de temas (AMS).
- **Agregación en Tiempo Real:** Mantener conteos de clics o vistas en los últimos $N$ minutos/segundos con recursos limitados (DGIM).

## 11. Limitaciones, riesgos y precauciones
- **Bloom Filter:**
    - No permite eliminar elementos (poner un bit a 0 podría afectar a otros elementos).
    - Tasa de falsos positivos crece a medida que se llena el array.
    - Requiere conocimiento previo aproximado del tamaño del conjunto $m$ para dimensionar $n$.
- **Flajolet-Martin:**
    - Estimación muy variable; requiere muchas funciones hash para precisión.
    - La estimación $2^R$ tiene varianza alta.
- **DGIM:**
    - Error garantizado $\le 50\%$. Para reducir error, se necesita aumentar el número permitido de buckets por tamaño ($r$), lo que aumenta el costo computacional.
    - Solo funciona para flujos binarios o enteros positivos pequeños (no para enteros negativos o de rango amplio sin modificaciones).
- **AMS:**
    - Requiere que el flujo tenga una longitud definida o un mecanismo de muestreo robusto para flujos infinitos.

## 12. Relaciones con otros temas del corpus
- **Hashing:** Todos los algoritmos presentados dependen fuertemente de propiedades de funciones hash uniformes e independientes (tema tratado en capítulos previos sobre MinHash/LSH).
- **Muestreo (Sampling):** El algoritmo AMS es una forma de muestreo aleatorio uniforme del flujo. Relacionado con técnicas de reservoir sampling.
- **Teoría de la Probabilidad:** Uso de aproximaciones como $(1 - \epsilon)^{1/\epsilon} \approx 1/e$ para análisis de rendimiento.
- **Minería de Grafos:** El conteo de elementos distintos es fundamental para análisis de grafos (nodos únicos), aunque este capítulo se centra en flujos genéricos.

## 13. Preguntas que la skill debería poder responder
1. ¿Cómo puedo verificar si un usuario pertenece a una lista blanca de mil millones de elementos usando solo 1GB de RAM?
2. ¿Cuál es la probabilidad exacta de un falso positivo en un Filtro de Bloom con $n$ bits, $m$ elementos y $k$ funciones hash?
3. ¿Por qué no se debe usar el promedio simple de las estimaciones $2^R$ en el algoritmo Flajolet-Martin?
4. ¿Qué estructura de datos permite estimar el número de usuarios únicos en un stream sin almacenar los IDs?
5. ¿Cómo se calcula el "número sorpresa" (segundo momento) de un flujo de datos y qué indica?
6. ¿Cuál es la complejidad espacial del algoritmo DGIM para una ventana de tamaño $N$?
7. ¿Cómo maneja el algoritmo AMS el muestreo en flujos infinitos para mantener la uniformidad?
8. ¿Es posible reducir el error del DGIM por debajo del 50%? ¿Cómo?
9. ¿Por qué el algoritmo DGIM estándar no funciona para sumar enteros positivos y negativos en una ventana?
10. ¿Qué es una ventana de decaimiento exponencial y en qué se diferencia de una ventana deslizante fija?

## 14. Acciones que la skill debería poder recomendar o ejecutar
- Dimensionar un Filtro de Bloom: Calcular $n$ y $k$ óptimos dada una tasa de error deseada y cardinalidad esperada.
- Implementar un contador de usuarios únicos aproximado para dashboards en tiempo real.
- Diseñar un sistema de alerta temprana basado en el segundo momento (cambios de distribución) usando variables AMS.
- Configurar buckets DGIM para monitoreo de logs en ventanas de tiempo deslizantes.
- Decidir entre usar un Filtro de Bloom o una estructura exacta (HashSet) basándose en la tolerancia a falsos positivos y restricciones de memoria.

## 15. Activos finales de conocimiento en formato compacto

| Concepto | Descripción | Referencia |
| :--- | :--- | :--- |
| **Bloom Filter** | Array de bits + $k$ hashes. Falsos positivos posibles, cero falsos negativos. | Sec 4.3 |
| **Prob. Falso Positivo** | $(1 - e^{-km/n})^k$. Depende de carga $m/n$ y hashes $k$. | Sec 4.3.3 |
| **Flajolet-Martin** | Estima elementos distintos como $2^R$ (max ceros finales en hash). | Sec 4.4.2 |
| **Combinación FM** | Usar mediana de promedios para corregir sesgo de $2^R$. | Sec 4.4.3 |
| **Momento $k$** | $\sum (m_i)^k$. $k=0$ (distintos), $k=1$ (longitud), $k=2$ (varianza). | Sec 4.5.1 |
| **AMS Estimate** | Para $k=2$: $n(2v-1)$, donde $v$ es el conteo de un elemento muestreado. | Sec 4.5.2 |
| **DGIM** | Conteo de unos en ventana con $O(\log^2 N)$ espacio. Error $\le 50\%$. | Sec 4.6.2 |
| **Regla DGIM** | Mantener 1 o 2 buckets de cada tamaño potencia de 2. | Sec 4.6.2 |
| **Extensión DGIM** | Permitir $r$ buckets por tamaño reduce error a $1/(r-1)$. | Sec 4.6.6 |
| **Decaying Window** | Asigna peso exponencialmente decreciente a datos antiguos. | Sec 4.7 |


