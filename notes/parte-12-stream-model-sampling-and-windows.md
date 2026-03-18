# Parte 12 - Stream Model, Sampling, and Windows

## 1. Metadatos del documento
- **Libro:** Mining of Massive Datasets, 3ª ed.
- **Fragmento/Parte:** Parte 12 - Stream Model, Sampling, and Windows
- **Temas principales:** Modelo de datos de flujo (stream), muestreo de flujos, consultas permanentes vs ad-hoc, ventanas deslizantes, hashing para muestreo, sesgo de muestreo.
- **Tipo de contenido:** Mixto (Teoría / Algoritmo / Caso de uso)

## 2. Resumen técnico de alto valor
El capítulo introduce el modelo de procesamiento de flujos de datos (Data Streams), donde los datos llegan a alta velocidad y deben procesarse inmediatamente o perderse, a diferencia de las bases de datos tradicionales donde los datos persisten estáticamente. La limitación crítica es la incapacidad de almacenar el flujo completo en memoria activa, obligando al uso de algoritmos de resumen o aproximación.

Se presenta la arquitectura de un Sistema de Gestión de Flujos de Datos (DSMS), diferenciando entre almacén de archivo (lento, para auditoría) y almacén de trabajo (rápido, limitado, para consultas). Se detallan estrategias de muestreo representativo, destacando que el muestreo aleatorio simple de tuplas individuales introduce sesgo estadístico en consultas agregadas por usuario (ej. duplicados). La solución técnica propuesta es el muestreo basado en claves mediante funciones de hash, que garantiza la consistencia de la selección (un usuario siempre está dentro o fuera de la muestra) sin necesidad de mantener estado para cada elemento visto. Se introduce también el concepto de umbral variable para ajustar el tamaño de la muestra dinámicamente ante restricciones de almacenamiento.

## 3. Conceptos y definiciones clave
- **Data Stream (Flujo de datos):** Secuencia de datos que llega a alta velocidad y debe procesarse en tiempo real; si no se procesa o almacena inmediatamente, se pierde.
- **DSMS (Data-Stream-Management System):** Sistema análogo a un DBMS pero diseñado para procesar flujos. Distingue entre procesamiento de flujo (entrada no controlada) y consultas sobre datos almacenados.
- **Standing Query (Consulta permanente):** Consulta que se ejecuta continuamente sobre el flujo y produce resultados en momentos específicos (ej. alertas, promedios móviles).
- **Ad-hoc Query (Consulta ad-hoc):** Consulta puntual sobre el estado actual del flujo o su historial reciente. Requiere mecanismos como ventanas deslizantes para ser viable.
- **Sliding Window (Ventana deslizante):** Subconjunto del flujo definido por los últimos $n$ elementos o los elementos llegados en las últimas $t$ unidades de tiempo. Permite tratar una porción del flujo como una relación estática.
- **Key Component (Componente clave):** Atributo(s) de la tupla sobre los cuales se basa la decisión de muestreo para garantizar propiedades estadísticas específicas (ej. `user` para análisis de comportamiento de usuarios).
- **Hash-based Sampling:** Técnica de muestreo que utiliza una función hash sobre la clave para decidir la inclusión en la muestra. Simula un generador de números aleatorios determinista, evitando almacenar el estado de inclusión/exclusión de cada clave.

## 4. Principios, reglas y heurísticas
- **Regla de la velocidad de llegada:** Si la tasa de llegada de datos excede la capacidad de almacenamiento activo, se deben usar algoritmos de resumen o aproximación en lugar de almacenamiento exacto.
- **Regla del muestreo por clave:** Para consultas que involucran estadísticas de usuarios o entidades (ej. "fracción de consultas repetidas por usuario"), **no** se debe muestrear tuplas individuales aleatoriamente. Se debe muestrear el identificador de la entidad (clave) para incluir o excluir todas sus tuplas correlacionadas.
- **Principio de aproximación:** En procesamiento de flujos, una respuesta aproximada computable en memoria es preferible a una respuesta exacta que requiere acceso a disco o que es imposible de calcular por restricciones de tiempo.
- **Heurística de consistencia hash:** Usar funciones hash para muestreo permite reconstruir la decisión de muestreo "al vuelo" sin consultar una tabla externa, siempre que la función hash sea determinista.

## 5. Procedimientos, métodos y workflows

### Método: Muestreo de flujos con tamaño fijo (Hash-based)
**Objetivo:** Obtener una muestra de fracción $a/b$ de las claves presentes en el flujo.
**Precondiciones:** Definir la clave $K$ de la tupla y la fracción deseada $a/b$.
**Pasos:**
1. Definir una función hash $h$ que mapee valores de clave a buckets $0, \dots, b-1$.
2. Por cada tupla entrante con clave $K$:
3. Calcular $bucket = h(K)$.
4. Si $bucket < a$, añadir la tupla a la muestra.
5. Si no, descartar la tupla.

### Método: Muestreo con tamaño variable (Threshold-based)
**Objetivo:** Mantener una muestra que se ajuste a un presupuesto de memoria máximo, permitiendo que la fracción de muestreo disminuya con el tiempo.
**Precondiciones:** Función hash $h$ que mapea a un rango grande $0 \dots B-1$, umbral inicial $t = B-1$.
**Pasos:**
1. Por cada tupla entrante con clave $K$:
2. Si $h(K) \le t$, añadir tupla a la muestra.
3. Si el tamaño de la muestra excede el límite de almacenamiento:
    a. Reducir el umbral $t$ (ej. $t = t - 1$).
    b. Eliminar de la muestra todas las tuplas existentes cuya clave $K$ satisfaga $h(K) > t$.
4. Mantener un índice sobre los valores hash para agilizar la eliminación en el paso 3b.

## 6. Problemas comunes y soluciones
- **Problema: Sesgo en el cálculo de duplicados.**
    - **Descripción:** Al muestrear tuplas individuales con probabilidad $1/10$, la probabilidad de que un par de consultas duplicadas aparezca dos veces en la muestra es $1/100$, no $1/10$. Esto altera la estadística de "consultas repetidas".
    - **Solución:** Muestrear basándose en el usuario (clave). Si un usuario es seleccionado, se guardan todas sus consultas; si no, ninguna. Esto preserva la proporción de duplicados dentro del usuario.
- **Problema: Gestión de estado para muestreo.**
    - **Descripción:** Mantener una lista explícita de usuarios "dentro/fuera" de la muestra consume memoria excesiva.
    - **Solución:** Usar una función hash determinista. La decisión se "recalcula" para cada tupla, eliminando la necesidad de almacenar el estado de inclusión.

## 7. Implementación técnica y generación de código

```pseudocode
# Algoritmo: Muestreo Representativo de Flujos
# Input: Flujo de tuplas T, Fracción a/b
# Output: Muestra representativa S

Para cada tupla t en el flujo:
    clave = extraer_clave(t)  # ej. user_id
    # Hash a b buckets
    bucket = hash_function(clave) mod b
    
    Si bucket < a:
        agregar t a la muestra S
    Sino:
        descartar t
```

```python
import mmh3 # Librería MurmurHash3, común para hashing eficiente en streams

class StreamSampler:
    def __init__(self, fraction_numerator, fraction_denominator):
        """
        Inicializa el muestreador de flujos.
        fraction_numerator: numerador 'a'
        fraction_denominator: denominador 'b' (muestreo a/b)
        """
        self.a = fraction_numerator
        self.b = fraction_denominator
        self.sample = []

    def process_tuple(self, tuple_data, key_attribute):
        """
        Procesa una tupla y decide si se almacena.
        key_attribute: el valor de la clave (ej. user_id) sobre el que se hashea.
        """
        # Convertir clave a string si es necesario, hashear y modular
        # Usamos mmh3 para obtener un entero distribuido uniformemente
        hash_val = mmh3.hash(str(key_attribute))
        
        # Normalizamos el hash a un rango positivo antes de mod, o usamos abs
        # Nota: Python mod puede dar negativo si el hash es negativo, abs() es seguro aquí
        bucket = abs(hash_val) % self.b
        
        if bucket < self.a:
            self.sample.append(tuple_data)
            return True # Retenido
        return False # Descartado

# Ejemplo de uso basado en el caso del libro (Sección 4.2.1)
# Queremos guardar 1/10 de los usuarios
sampler = StreamSampler(1, 10)
# stream = [("user1", "query1", "t1"), ("user2", "query2", "t2"), ...]
```

## 8. Funciones, métodos, librerías o comandos identificados
- **`hash(key) % b`**: Operación fundamental para asignar claves a buckets en muestreo.
- **`SELECT COUNT(DISTINCT(name))`**: Consulta SQL estándar mencionada para ventanas deslizantes sobre la relación `Logins`.
- **Working Store**: Concepto de almacenamiento volátil o de capacidad limitada para consultas rápidas.
- **Archival Store**: Almacenamiento masivo para respaldo histórico, no apto para consultas en tiempo real.

## 9. Snippets o plantillas reutilizables

**Snippet SQL para Ventana Deslizante Temporal:**
```sql
-- Consulta para usuarios únicos en el último mes (Sección 4.1.3)
-- Asume una relación Logins(name, time) mantenida en el Working Store
SELECT COUNT(DISTINCT(name))
FROM Logins
WHERE time >= t; -- t es la marca de tiempo de hace un mes
```

**Snippet Python para Muestreo con Tamaño Variable (Umbral):**
```python
class VariableSampler:
    def __init__(self, max_size, B=2**32):
        self.max_size = max_size
        self.B = B
        self.threshold = B - 1 # Inicialmente aceptamos todo
        self.sample = {} # Diccionario o estructura indexada por hash

    def add_tuple(self, tuple_data, key):
        h = abs(mmh3.hash(str(key))) % self.B
        
        if h <= self.threshold:
            # Almacenar con índice de hash para limpieza eficiente
            if h not in self.sample: self.sample[h] = []
            self.sample[h].append(tuple_data)
            
            # Verificar límite de capacidad
            self._check_capacity()

    def _check_capacity(self):
        # Si la memoria excede el límite, reducimos el umbral
        # Nota: Implementación real requeriría conteo de tamaño en bytes
        current_size = sum(len(v) for v in self.sample.values())
        
        if current_size > self.max_size:
            # Reducir umbral (ej. a la mitad o decrementalmente)
            # Eliminar buckets con hash mayor al nuevo umbral
            old_threshold = self.threshold
            self.threshold = self.threshold // 2 # Heurística de reducción
            
            # Limpieza de buckets excedidos
            for h in list(self.sample.keys()):
                if h > self.threshold:
                    del self.sample[h]
```

## 10. Casos de uso y aplicaciones
- **Sensores Oceánicos:** Procesamiento de millones de sensores reportando altura de superficie (3.5 TB/día). Necesita resumen para detectar patrones sin almacenar todo.
- **Cámaras de Seguridad (Londres):** 6 millones de cámaras generando streams de imágenes. Imposible almacenar todo en tiempo real; se requiere filtrado o muestreo.
- **Análisis de Clicks en Web (Yahoo/Google):** Detección de noticias emergentes (incremento súbito de clicks en un enlace) o propagación de virus (incremento de consultas "sore throat").
- **Enrutamiento de Red:** Detección de ataques DoS en nodos de conmutación IP basándose en patrones de flujo de paquetes.

## 11. Limitaciones, riesgos y precauciones
- **Pérdida de datos:** La naturaleza del flujo implica que si el procesamiento no es lo suficientemente rápido, los datos se pierden irremediablemente.
- **Precisión en muestreo simple:** El muestreo aleatorio simple destruye la estructura de duplicados y correlaciones dentro de las entidades (usuarios), invalidando ciertas consultas estadísticas.
- **Capacidad de Working Store:** Las consultas ad-hoc están limitadas por lo que quepa en la ventana deslizante o el resumen almacenado. No se pueden responder consultas arbitrarias sobre el historial total.
- **Dependencia de la función Hash:** La calidad del muestreo depende de la uniformidad de la función hash. Una mala distribución puede sesgar la muestra.

## 12. Relaciones con otros temas del corpus
- **Hashing (Capítulo 3):** El uso de funciones hash para muestreo es una aplicación directa de las técnicas de hashing vistas previamente.
- **Min-Hashing / LSH:** Al igual que en Jaccard Similarity, aquí se usa hash para "fijar" una decisión aleatoria de manera determinista.
- **Sliding Windows (Sección 4.1.3, desarrollado en 4.3+):** Concepto introducido aquí como mecanismo para consultas ad-hoc, profundizado en secciones posteriores para conteo de bits (DGIM).
- **Big Data Architectures:** Este modelo es la base teórica de sistemas como Apache Storm, Flink o Spark Streaming.

## 13. Preguntas que la skill debería poder responder
1. ¿Por qué el muestreo aleatorio simple de tuplas falla al calcular la fracción de consultas duplicadas por usuario?
2. ¿Cómo se puede mantener una muestra del 10% de los usuarios de un flujo de búsqueda sin almacenar una lista de todos los usuarios vistos?
3. ¿Cuál es la diferencia fundamental entre una "Standing Query" y una "Ad-hoc Query" en el contexto de streams?
4. ¿Qué estrategia se utiliza para reducir el tamaño de una muestra cuando esta excede la capacidad de almacenamiento disponible?
5. ¿Cómo se define una ventana deslizante (sliding window) en términos de elementos o tiempo?
6. ¿Por qué se prefiere obtener respuestas aproximadas en minería de flujos en lugar de respuestas exactas?
7. ¿Qué rol juega el "Working Store" frente al "Archival Store" en un DSMS?

## 14. Acciones que la skill debería poder recomendar o ejecutar
1. **Diseñar esquema de muestreo:** Identificar la "clave" correcta (usuario, sesión, query) antes de implementar un muestreador para asegurar la validez estadística de las métricas objetivo.
2. **Implementar muestreo por hash:** Recomendar el uso de `hash(key) % n` en lugar de `random()` para asegurar consistencia y reproducibilidad en streams distribuidos.
3. **Ajuste dinámico de umbral:** Implementar lógica de reducción de umbral (`threshold lowering`) cuando el uso de memoria se acerca al límite en aplicaciones de streaming en tiempo real.
4. **Selección de ventana:** Elegir entre ventana basada en tiempo o en conteo según la naturaleza de la consulta (ej. "últimas 24 horas" vs "últimos 1000 eventos").

## 15. Activos finales de conocimiento en formato compacto

| Concepto | Descripción | Referencia |
| :--- | :--- | :--- |
| **Stream Model** | Datos ilimitados, alta velocidad, procesamiento único o pérdida. | Sec 4.1 |
| **Sesgo de Muestreo** | Muestrear tuplas rompe correlaciones internas (ej. duplicados). Usar muestreo por clave. | Sec 4.2.1 |
| **Hash Determinista** | Reemplaza tablas de estado para decidir inclusión en muestra. Clave: `h(key) < umbral`. | Sec 4.2.2 |
| **Sliding Window** | Mecanismo para consultas ad-hoc sobre historial reciente ($n$ elementos o $t$ tiempo). | Sec 4.1.3 |
| **Standing Query** | Consulta permanente que se ejecuta continuamente sobre el flujo. | Sec 4.1.3 |
| **Variable Sample** | Ajuste dinámico del umbral de hash para respetar límites de memoria. | Sec 4.2.4 |
| **DSMS** | Arquitectura con Archival Store (lento) y Working Store (rápido/limitado). | Sec 4.1.1 |
| **Aproximación** | Trade-off fundamental: memoria limitada implica respuestas aproximadas. | Sec 4.1.4 |


