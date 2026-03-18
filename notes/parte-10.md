# parte-10 — Mining-of-Massive-Datasets-Third-Edition-Jure-Leskovec-Anand-Rajaraman-etc-z-library-sk-1lib-sk-z-lib-parte-10.pdf

## 1. Metadatos del documento
- **Libro:** Mining of Massive Datasets, 3ª ed.
- **Fragmento/Parte:** Chapter 3. Finding Similar Items (Secciones 3.6, 3.7, Inicio 3.8)
- **Temas principales:** Locality-Sensitive Hashing (LSH), Familias sensibles a la localidad, Amplificación (AND/OR construction), Distancia de Hamming, Distancia del Coseno, Sketches, Distancia Euclidiana.
- **Tipo de contenido:** Teoría / Algoritmo

## 2. Resumen técnico de alto valor
El fragmento formaliza la teoría detrás de las Familias de Funciones Sensibles a la Localidad (LSH), generalizando la técnica de MinHash más allá de la distancia Jaccard. Se define una familia $F$ como $(d_1, d_2, p_1, p_2)$-sensitive, donde la probabilidad de colisión $f(x)=f(y)$ es al menos $p_1$ para puntos cercanos (distancia $\le d_1$) y a lo sumo $p_2$ para puntos lejanos (distancia $\ge d_2$). Se presentan métodos de amplificación mediante construcciones AND y OR para modificar la curva S (steepness), permitiendo reducir falsos positivos y negativos a costa de mayor cómputo. Se detallan implementaciones específicas de LSH para distancia de Hamming (selección de bit), distancia del Coseno (hiperplanos aleatorios y sketches) y distancia Euclidiana (proyección en líneas con cubetas), estableciendo los parámetros de sensibilidad para cada caso.

## 3. Conceptos y definiciones clave
- **Familia de funciones sensible a la localidad ($(d_1, d_2, p_1, p_2)$-sensitive)**: Una familia $F$ de funciones donde, para cualquier $f \in F$, si $d(x,y) \le d_1$ entonces $P(f(x)=f(y)) \ge p_1$, y si $d(x,y) \ge d_2$ entonces $P(f(x)=f(y)) \le p_2$.
- **Construcción AND**: Método para crear una nueva familia $F'$ donde cada función consiste en $r$ funciones de $F$. Declara candidato solo si todas las $r$ funciones coinciden. Efecto: reduce probabilidades ($p \to p^r$).
- **Construcción OR**: Método donde una función de $F'$ consta de $b$ funciones de $F$. Declara candidato si al menos una coincide. Efecto: aumenta probabilidades ($p \to 1-(1-p)^b$).
- **Sketch (para distancia del coseno)**: Representación compacta de un vector generada mediante el signo del producto punto con una serie de vectores aleatorios de componentes $\pm 1$. Permite estimar el ángulo entre vectores comparando la similitud de sus sketches.
- **Punto fijo (Fixed point)**: En una curva S generada por construcciones AND/OR, es el valor de probabilidad $p$ que permanece inalterado tras la transformación. Probabilidades bajo el punto fijo disminuyen, las sobre él aumentan.

## 4. Principios, reglas y heurísticas
- **Principio de independencia**: Las funciones en una familia LSH deben ser estadísticamente independientes para aplicar la regla del producto en construcciones AND/OR.
- **Regla de amplificación**: Para separar probabilidades $p_1$ y $p_2$, se puede aplicar una construcción AND seguida de una OR (o viceversa). Cuanto mayor sea la separación deseada, mayor será el número de funciones base requeridas.
- **Heurística de eficiencia**: Las funciones deben permitir identificar pares candidatos en tiempo proporcional al tamaño de los datos, no al cuadrado del número de pares.
- **Distancia Jaccard**: La familia MinHash es $(d_1, d_2, 1-d_1, 1-d_2)$-sensitive.
- **Distancia de Hamming**: La familia basada en la selección del $i$-ésimo bit es $(d_1, d_2, 1-d_1/d, 1-d_2/d)$-sensitive. Limitación: el tamaño de la familia está limitado por la dimensión $d$.
- **Distancia del Coseno**: La familia basada en hiperplanos aleatorios es $(d_1, d_2, (180-d_1)/180, (180-d_2)/180)$-sensitive (ángulos en grados).
- **Distancia Euclidiana**: Usando proyección en líneas con cubetas de ancho $a$, se logra una familia $(a/2, 2a, 1/2, 1/3)$-sensitive.

## 5. Procedimientos, métodos y workflows
### Construcción de una familia LSH amplificada
1.  **Definición base**: Identificar una familia base $F$ que sea $(d_1, d_2, p_1, p_2)$-sensitive para la métrica deseada.
2.  **Construcción AND**: Definir $F_1$ tomando $r$ funciones de $F$. Un par es candidato en $F_1$ si todas las $r$ funciones hashean al mismo valor. Nueva probabilidad: $p^r$.
3.  **Construcción OR**: Definir $F_2$ tomando $b$ funciones de $F_1$ (o $F$). Un par es candidato si al menos una de las $b$ funciones lo declara candidato. Nueva probabilidad: $1-(1-p)^r$ (si se aplica sobre $F$) o $1-(1-p^r)^b$ (si se aplica AND luego OR).
4.  **Ajuste de curva**: Seleccionar $r$ y $b$ para ajustar la pendiente de la curva S y el punto fijo según los umbrales de distancia requeridos.

### Generación de Sketches para Distancia del Coseno
1.  Generar $n$ vectores aleatorios $v_1, \dots, v_n$ con componentes $+1$ o $-1$.
2.  Para cada vector de datos $x$, calcular el producto punto $v_i \cdot x$.
3.  Asignar $+1$ al sketch si el producto es $\ge 0$, y $-1$ si es $< 0$.
4.  El sketch resultante es una cadena de $n$ bits/símbolos.
5.  Estimar el ángulo entre $x$ e $y$ calculando la fracción de posiciones donde sus sketches coinciden.

## 6. Problemas comunes y soluciones
- **Problema**: La familia base tiene $p_1$ y $p_2$ demasiado cercanos, resultando en demasiados falsos positivos o negativos.
    - **Solución**: Aplicar cascadas de construcciones AND y OR. Una secuencia común es AND seguida de OR para reducir $p_2$ (falsos positivos) drásticamente mientras se mantiene $p_1$ alto.
- **Problema**: Limitación en el tamaño de la familia para distancia de Hamming (solo $d$ funciones posibles si la dimensión es $d$).
    - **Solución**: [VACÍO] El texto menciona la limitación pero no da una solución explícita más allá de notar que restringe la pendiente de la curva S.
- **Problema**: Estimación inexacta del ángulo usando sketches con pocos vectores aleatorios.
    - **Solución**: Aumentar el número de vectores aleatorios $n$ mejora la estimación del ángulo (ley de grandes números implícita).

## 7. Implementación técnica y generación de código

```pseudocode
# Algoritmo: Construcción AND-OR para LSH
# Input: Familia base F, parámetros r (AND), b (OR)
# Output: Nueva familia F'

Function CreateANDFunction(F, r):
    # Seleccionar r funciones f_1...f_r de F aleatoriamente
    selected_functions = RandomSample(F, r)
    Return function(x, y):
        For each f in selected_functions:
            If f(x) != f(y): Return False
        Return True

Function CreateORFunction(F_set, b):
    # Seleccionar b funciones g_1...g_b de F_set
    selected_constructors = RandomSample(F_set, b)
    Return function(x, y):
        For each g in selected_constructors:
            If g(x, y) == True: Return True
        Return False

# Workflow de amplificación
F_base = GetBaseFamily()
F_AND = { CreateANDFunction(F_base, r) for i in 1..N }
F_Final = { CreateORFunction(F_AND, b) for j in 1..M }
```

```python
import numpy as np

def generate_cosine_sketches(data_matrix, n_vectors):
    """
    Genera sketches para distancia del coseno usando hiperplanos aleatorios.
    
    Args:
        data_matrix (np.array): Matriz de datos (n_samples, n_features).
        n_vectors (int): Número de hiperplanos aleatorios (longitud del sketch).
        
    Returns:
        np.array: Matriz de sketches (n_samples, n_vectors) con valores +1/-1.
    """
    n_features = data_matrix.shape[1]
    # Generar vectores aleatorios de componentes +1/-1
    random_vectors = np.random.choice([-1, 1], size=(n_features, n_vectors))
    
    # Calcular producto punto: (n_samples, n_features) dot (n_features, n_vectors)
    dot_products = np.dot(data_matrix, random_vectors)
    
    # Asignar +1 si >= 0, -1 si < 0
    sketches = np.where(dot_products >= 0, 1, -1)
    return sketches

def estimate_angle_from_sketches(sketch1, sketch2):
    """
    Estima el ángulo (en grados) entre dos vectores basándose en sus sketches.
    """
    matches = np.sum(sketch1 == sketch2)
    total = len(sketch1)
    # Fracción de acuerdo
    fraction_agree = matches / total
    # Estimación del ángulo: (1 - acuerdo) * 180
    # Basado en P(acuerdo) = 1 - (theta/180)
    estimated_angle = (1 - fraction_agree) * 180
    return estimated_angle
```

## 8. Funciones, métodos, librerías o comandos identificados
- **MinHash**: Función hash basada en permutación para distancia Jaccard.
- **Random Hyperplane**: Función hash para distancia del coseno; define el hash según el lado del hiperplano donde cae el vector.
- **Dot Product ($v.x$)**: Operación clave para determinar el signo en LSH para distancia del coseno.
- **Bucketing**: Asignación de puntos a intervalos discretos (cubetas) en una línea para distancia Euclidiana.

## 9. Snippets o plantillas reutilizables

```python
# Cálculo de probabilidades tras amplificación AND-OR
def calculate_lsh_probability(p, r, b):
    """
    Calcula la probabilidad final de ser par candidato
    tras r-way AND seguido de b-way OR.
    """
    p_and = p ** r
    p_or = 1 - (1 - p_and) ** b
    return p_or

# Ejemplo de uso basado en el libro (Example 3.19)
# r=4, b=4
# p_base = 0.8
prob_final = calculate_lsh_probability(0.8, 4, 4) 
# Resultado esperado aprox 0.8785
```

## 10. Casos de uso y aplicaciones
- **Entity Resolution**: Identificar registros que se refieren a la misma entidad del mundo real (ej. misma persona) aunque los datos no coincidan exactamente. Mencionado en la introducción de la sección 3.8.
- **Matching Fingerprints**: Comparación de huellas dactilares representadas como conjuntos, utilizando familias LSH diferentes a MinHash estándar. Mencionado en 3.8.
- **Detección de documentos similares**: Uso de MinHash y LSH para encontrar documentos con alta similitud Jaccard (contexto implícito del capítulo).

## 11. Limitaciones, riesgos y precauciones
- **Costo computacional**: La amplificación excesiva (valores altos de $r$ y $b$) aumenta el tiempo de cómputo linealmente con el número de funciones base utilizadas.
- **Limitación de dimensión (Hamming)**: Para distancia de Hamming, solo existen $d$ funciones base posibles (una por dimensión), lo que limita la capacidad de amplificación en datos de baja dimensión.
- **Precisión del Sketch**: Los sketches para distancia del coseno son estimaciones. Pocos hiperplanos resultan en estimaciones de ángulo muy burdas.
- **Distancia Euclidiana**: La familia básica descrita requiere $d_1 < 4d_2$ para garantizar probabilidades específicas ($1/2, 1/3$), aunque el principio general aplica para cualquier $d_1 < d_2$.

## 12. Relaciones con otros temas del corpus
- **MinHashing (Sección 3.3-3.4)**: Es el caso base de LSH para distancia Jaccard. El fragmento actual generaliza la teoría presentada allí.
- **Medidas de distancia (Sección 3.5)**: El fragmento aplica LSH a las medidas definidas previamente (Jaccard, Hamming, Coseno, Euclidiana).
- **Shingling (Sección 3.2)**: Técnica previa para convertir documentos en conjuntos, necesaria antes de aplicar MinHash/LSH.

## 13. Preguntas que la skill debería poder responder
1. ¿Qué condiciones debe cumplir una familia de funciones para ser considerada "sensitive to locality"?
2. ¿Cómo afecta la construcción AND a la probabilidad de que un par sea candidato?
3. ¿Cómo se implementa una función LSH para la distancia del coseno utilizando hiperplanos aleatorios?
4. ¿Cuál es la principal limitación de la familia LSH para la distancia de Hamming respecto a su tamaño?
5. ¿Qué es un "sketch" en el contexto de la distancia del coseno y cómo se calcula?
6. ¿Por qué se suele combinar construcciones AND y OR en lugar de usar solo una?
7. ¿Qué representa el "punto fijo" en la curva S de una función LSH amplificada?
8. ¿Cómo se define la familia LSH para distancia Euclidiana usando proyecciones en líneas?
9. ¿Qué trade-off existe entre la pendiente de la curva S y el costo computacional en LSH?
10. ¿Cómo se estima el ángulo entre dos vectores a partir de sus sketches?

## 14. Acciones que la skill debería poder recomendar o ejecutar
- Seleccionar la familia LSH adecuada (MinHash, Hyperplanes, Bit-sampling) según la métrica de distancia del problema.
- Calcular los parámetros $r$ y $b$ necesarios para lograr una tasa deseada de falsos positivos/negativos.
- Implementar la generación de sketches para reducir dimensionalidad en problemas de similitud del coseno.
- Diagnosticar si una baja separación entre $p_1$ y $p_2$ requiere amplificación.
- Advertir sobre la limitación de funciones base disponibles si se usa distancia de Hamming en baja dimensión.

## 15. Activos finales de conocimiento en formato compacto
| Concepto | Descripción | Referencia |
|---|---|---|
| **Familia $(d_1, d_2, p_1, p_2)$-sensitive** | Marco teórico para funciones hash que preservan cercanía. | Sec 3.6.1 |
| **Construcción AND** | Reduce probabilidad: $p \to p^r$. Disminuye falsos positivos. | Sec 3.6.3 |
| **Construcción OR** | Aumenta probabilidad: $p \to 1-(1-p)^b$. Disminuye falsos negativos. | Sec 3.6.3 |
| **LSH para Jaccard** | Familia MinHash: $(d_1, d_2, 1-d_1, 1-d_2)$-sensitive. | Sec 3.6.2 |
| **LSH para Hamming** | Seleccionar bit $i$. Familia limitada a dimensión $d$. | Sec 3.7.1 |
| **LSH para Coseno** | Signo del producto punto con vector aleatorio. | Sec 3.7.2 |
| **Sketch** | Vector de signos $+1/-1$ para estimar ángulo/coseno. | Sec 3.7.3 |
| **LSH para Euclidiana** | Proyección en línea con cubetas de ancho $a$. Familia $(a/2, 2a, 1/2, 1/3)$. | Sec 3.7.4 |
| **Punto Fijo** | Valor $p$ que no cambia tras amplificación; umbral de decisión. | Sec 3.6.3 |
| **Entity Resolution** | Aplicación de LSH para unificar registros de entidades del mundo real. | Sec 3.8 |
