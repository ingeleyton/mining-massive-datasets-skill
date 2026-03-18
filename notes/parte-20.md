# parte-20 — Mining-of-Massive-Datasets-Third-Edition-Jure-Leskovec-Anand-Rajaraman-etc-z-library-sk-1lib-sk-z-lib-parte-20.pdf

## 1. Metadatos del documento
- **Libro:** Mining of Massive Datasets, 3ª ed.
- **Fragmento/Parte:** Sección 6.2 (Market Baskets and the A-Priori Algorithm) e inicio de 6.3 (Handling Larger Datasets in Main Memory).
- **Temas principales:** Algoritmo A-Priori, Itemsets frecuentes, Reglas de asociación, Estructuras de datos de conteo, Monotonicidad, Optimización de memoria.
- **Tipo de contenido:** Mixto (Teoría / Algoritmo / Implementación)

## 2. Resumen técnico de alto valor
El fragmento aborda la extracción de itemsets frecuentes en datasets masivos que exceden la memoria principal, centrando el costo computacional en la E/S de disco (número de pasadas). Se presenta el algoritmo **A-Priori** como solución para reducir el espacio de búsqueda mediante el principio de **monotonicidad**: si un conjunto de items es frecuente, todos sus subconjuntos también lo son. Esto permite un enfoque de "poda" en múltiples pasadas ($C_k \to L_k$), donde solo se cuentan candidatos de tamaño $k$ si todos sus subconjuntos de tamaño $k-1$ son frecuentes.

Se detallan dos estrategias críticas para el almacenamiento de conteos de pares en memoria: la **Matriz Triangular**, eficiente en espacio para grafos densos (>$1/3$ de pares posibles presentes), y el **Método de Triples** (hash table de tripletas), óptimo para datos dispersos. El texto destaca la "tiranía del conteo de pares": el cuello de botella de memoria ocurre al contar pares ($C_2$), ya que los singleton suelen caber y los conjuntos mayores son escasos. Finalmente, se introduce la motivación para algoritmos posteriores (PCY) que aprovechan la memoria ociosa durante la primera pasada.

## 3. Conceptos y definiciones clave
- **Market-Basket Data**: Modelo de datos donde cada "canasta" es un conjunto de items (itemsset). Archivo almacenado canasta por canasta.
- **Itemset Frecuente**: Conjunto de items que aparece en al menos $s$ canastas, donde $s$ es el umbral de soporte (support threshold).
- **Monotonicidad de Itemsets**: Principio fundamental que establece que si un conjunto $I$ es frecuente, entonces todo subconjunto $J \subseteq I$ también es frecuente. Implica que si un conjunto no es frecuente, ningún superconjunto suyo puede serlo.
- **Itemset Maximal Frecuente**: Itemset frecuente tal que ninguno de sus superconjuntos inmediatos es frecuente. Permite compactar la información de todos los itemsets frecuentes.
- **Thrashing**: Degradación severa del rendimiento que ocurre cuando el sistema operativo debe mover páginas de memoria a disco continuamente porque la estructura de datos de conteo excede la memoria RAM disponible.
- **Candidatos ($C_k$)**: Conjunto de itemsets de tamaño $k$ que potencialmente son frecuentes y deben ser contados en la pasada actual.
- **Frecuentes ($L_k$)**: Conjunto de itemsets de tamaño $k$ que superaron el umbral de soporte $s$ tras el conteo.

## 4. Principios, reglas y heurísticas
- **Regla de coste de E/S**: El tiempo de ejecución es proporcional al producto del número de pasadas por el tamaño del archivo. Minimizar pasadas es el objetivo principal.
- **Regla de memoria**: No se puede contar aquello que no cabe en memoria principal. Si la estructura de conteo excede la RAM, el algoritmo falla (thrashing).
- **Heurística de selección de estructura de datos**:
    - Usar **Matriz Triangular** si se espera que más de $1/3$ de los $\binom{n}{2}$ pares posibles aparezcan en los datos.
    - Usar **Método de Triples** si los datos son dispersos (significativamente menos de $1/3$ de los pares posibles ocurren).
- **Regla de poda A-Priori**: Un par $\{i, j\}$ es candidato en $C_2$ solo si ambos items $i$ y $j$ son frecuentes en $L_1$. Un triple es candidato en $C_3$ solo si todos sus subconjuntos de tamaño 2 están en $L_2$.
- **Umbral de soporte típico**: Suele fijarse alto (ej. 1% de las transacciones) para asegurar que el número de itemsets frecuentes sea manejable y el análisis tenga sentido estadístico.

## 5. Procedimientos, métodos y workflows

### Algoritmo A-Priori (Visión General)
1.  **Pasada 1**: Leer archivo completo. Contar ocurrencias de items individuales.
2.  **Filtrado 1**: Identificar items frecuentes ($L_1$) que cumplen soporte $s$. Descartar el resto.
3.  **Renumeración**: Asignar nuevos enteros $1 \dots m$ a los items frecuentes para compactar espacio.
4.  **Pasada 2**: Leer archivo. Generar pares solo con items en $L_1$. Contar ocurrencias de estos pares candidatos ($C_2$).
5.  **Filtrado 2**: Identificar pares frecuentes ($L_2$).
6.  **Pasada k (Generalización)**: Construir candidatos $C_k$ basándose en $L_{k-1}$. Contar en una nueva pasada. Repetir hasta que $L_k$ sea vacío.

### Método de la Matriz Triangular
1.  Mapear items a enteros $1 \dots n$.
2.  Crear array unidimensional de tamaño $\binom{n}{2} \approx n^2/2$.
3.  Para contar un par $\{i, j\}$ con $1 \le i < j \le n$, calcular índice $k$ y aumentar contador en `a[k]`.

### Método de Triples
1.  Utilizar una tabla hash o estructura similar.
2.  Al encontrar un par $\{i, j\}$, buscar en la tabla.
3.  Si existe, incrementar contador $c$.
4.  Si no existe, crear entrada $[i, j, 1]$.
5.  Solo consume espacio para pares con cuenta $> 0$.

## 6. Problemas comunes y soluciones
- **Problema**: El conteo de todos los pares posibles ($n^2$) excede la memoria RAM.
    - **Solución**: A-Priori realiza dos pasadas. La primera poda items infrecuentes, reduciendo $n$ a $m$ (items frecuentes). La memoria necesaria para pares baja de $n^2$ a $m^2$.
- **Problema**: Cálculo de índices en matriz triangular es complejo o costoso.
    - **Solución**: Renumerar items frecuentes consecutivamente desde 1 permite usar la fórmula directa o una matriz triangular estándar optimizada.
- **Problema**: Generación de subconjuntos excesivamente costosa para canastas grandes.
    - **Solución**: En la práctica, las canastas son pequeñas (promedio 20 items). Si $k$ crece, se pueden eliminar items de la canasta que no participan en itemsets frecuentes de tamaño $k-1$ antes de generar subconjuntos de tamaño $k$.

## 7. Implementación técnica y generación de código

```pseudocode
# Algoritmo A-Priori para Pares Frecuentes
Algoritmo A-Priori(ArchivoCanastas, UmbralSoporte s):

  # Pasada 1: Contar items individuales
  ContadorItems = Map<Item, Entero>()
  Para cada canasta B en ArchivoCanastas:
    Para cada item i en B:
      ContadorItems[i] += 1
  
  # Filtrar items frecuentes y renumerar
  L1 = Conjunto de items donde ContadorItems[i] >= s
  MapaRenumeracion = Map<Item, Entero>() # Item -> 1..m
  idx = 1
  Para cada item i en L1 (ordenado):
    MapaRenumeracion[i] = idx
    idx += 1
  
  # Inicializar estructura para pares (Matriz Triangular o Triples)
  ContadorPares = EstructuraConteoPares(tamano = |L1|)
  
  # Pasada 2: Contar pares candidatos
  Para cada canasta B en ArchivoCanastas:
    # Filtrar items no frecuentes en esta canasta
    B_frecuentes = [i para i en B si i está en L1]
    # Generar pares ordenados
    Para cada par {i, j} en combinaciones(B_frecuentes, 2):
      # Traducir a índices compactos
      i_prima = MapaRenumeracion[i]
      j_prima = MapaRenumeracion[j]
      ContadorPares.incrementar(i_prima, j_prima)
      
  Retornar pares en ContadorPares con cuenta >= s
```

```python
# Implementación Python: Cálculo de índice para Matriz Triangular
def get_triangular_index(i, j, n):
    """
    Calcula el índice k en un array unidimensional para el par {i, j}
    donde 1 <= i < j <= n.
    Fórmula basada en el texto: k = (i-1)(n - i/2) + j - i
    Nota: El texto presenta una fórmula con posible ambigüedad tipográfica.
    La fórmula estándar equivalente derivada es:
    k = (i-1) * n - (i * (i-1)) // 2 + (j - i)
    """
    if i >= j:
        raise ValueError("Se requiere i < j")
    
    # Aproximación directa del texto (asumiendo división flotante o contexto matemático)
    # k = (i-1) * (n - i/2) + j - i
    
    # Implementación robusta estándar para índice base 0 o 1 según necesidad.
    # Aquí calculamos el offset lógico.
    # Número de elementos antes de la fila i: (i-1)*n - sumatoria de 1 a i-1
    # Simplificando:
    return (i - 1) * (n - i / 2) + (j - i)

# Implementación Python: Estructura Triples simplificada
class TriplesCounter:
    def __init__(self):
        self.counts = {} # Clave: (i, j), Valor: cuenta
    
    def add_pair(self, i, j):
        # Asegurar orden para evitar duplicados {i,j} vs {j,i}
        if i > j:
            i, j = j, i
        key = (i, j)
        self.counts[key] = self.counts.get(key, 0) + 1
        
    def get_frequent_pairs(self, threshold):
        return {k: v for k, v in self.counts.items() if v >= threshold}
```

## 8. Funciones, métodos, librerías o comandos identificados
- **Triangular-Matrix Method**: Técnica de almacenamiento que usa un array 1D para representar una matriz de adyacencia simétrica sin diagonal, ahorrando ~50% de espacio vs matriz completa.
- **Triples Method**: Técnica de almacenamiento disperso usando tripletas `[i, j, c]` y tablas hash.
- **Frequent-items table**: Array de tamaño $n$ que mapea IDs originales a IDs compactados (1 a $m$) de items frecuentes, o 0 si no es frecuente.
- **Thrashing**: Término de sistema operativo referenciado como fallo de rendimiento crítico a evitar.

## 9. Snippets o plantillas reutilizables

```python
# Snippet: Lógica de poda de candidatos en Pasada k (A-Priori General)
# Dado un conjunto de items frecuentes de tamaño k-1 (L_previo) y una canasta actual
def get_candidates_in_basket(basket, L_previo, k):
    """
    basket: lista de items en la canasta actual
    L_previo: conjunto (set) de itemsets frecuentes de tamaño k-1 (congelados como tuplas)
    k: tamaño del itemset candidato a generar
    """
    # 1. Filtrar items que podrían formar parte de un candidato
    # (Optimización no detallada totalmente en texto pero implícita en la lógica de subconjuntos)
    
    # 2. Generar combinaciones de tamaño k
    from itertools import combinations
    candidates = []
    
    for candidate in combinations(basket, k):
        # 3. Verificar propiedad de A-Priori: todos los subconjuntos de tamaño k-1 deben ser frecuentes
        is_valid = True
        # Generar subconjuntos de tamaño k-1 del candidato
        # Nota: combinations produce tuplas ordenadas si la entrada está ordenada
        for subset in combinations(candidate, k-1):
            if subset not in L_previo:
                is_valid = False
                break
        if is_valid:
            candidates.append(candidate)
            
    return candidates
```

## 10. Casos de uso y aplicaciones
- **Análisis de Supermercados**: Identificar productos que se compran juntos (ej. pan y leche). El texto usa el ejemplo de "Creamy Caesar Salad Dressing" como item infrecuente vs "Coke/Pepsi".
- **Procesamiento Distribuido**: El texto menciona que los datos pueden estar en un sistema de archivos distribuido (como HDFS), aunque el algoritmo A-Priori básico se centra en una sola máquina o requiere coordinación compleja para conteo exacto global (referencia a Sección 6.4.4).
- **Detección de patrones en logs web**: Implícito en el modelo de "canastas" (sesiones de usuario) e "items" (páginas visitadas).

## 11. Limitaciones, riesgos y precauciones
- **Limitación de Memoria**: A-Priori falla si el número de pares candidatos ($m^2$) excede la memoria RAM disponible.
- **Pasadas múltiples**: Requiere $k$ pasadas completas al disco para encontrar itemsets de tamaño $k$, lo cual es costoso en E/S.
- **Dispersión de datos**: Si los datos son muy dispersos pero el umbral es bajo, el número de candidatos puede crecer exponencialmente.
- **Complejidad de generación**: Generar todos los subconjuntos de tamaño $k$ para verificar la condición de candidatura puede ser costoso si las canastas son grandes, aunque el texto asume canastas pequeñas.

## 12. Relaciones con otros temas del corpus
- **PCY Algorithm (Sección 6.3)**: Evolución directa de A-Priori que utiliza memoria ociosa en la pasada 1 para hashear pares y reducir $C_2$.
- **MapReduce / Parallel Processing (Sección 6.4)**: Mencionado como el siguiente paso para escalar A-Priori a clusters, aunque con dificultades para combinar conteos exactos.
- **Bloom Filters (Sección 4.3)**: Mencionado como concepto análogo al array de hashes usado en PCY.
- **Association Rules**: Los itemsets frecuentes son la base para generar reglas con alta confianza y soporte.

## 13. Preguntas que la skill debería poder responder
1. ¿Por qué el algoritmo A-Priori requiere múltiples pasadas sobre el archivo de datos?
2. ¿Cuál es la diferencia fundamental entre el método de Matriz Triangular y el Método de Triples para almacenar conteos de pares?
3. ¿Bajo qué condiciones de densidad de datos es preferible usar una Matriz Triangular?
4. ¿Qué es la propiedad de monotonicidad y cómo permite podar el espacio de búsqueda en A-Priori?
5. ¿Cómo afecta el tamaño de la memoria principal a la elección del umbral de soporte o la viabilidad del algoritmo?
6. ¿Por qué se considera que el conteo de pares es el cuello de botella principal ("Tyranny of Counting Pairs")?
7. ¿Cómo se realiza la renumeración de items entre la primera y segunda pasada y por qué es necesaria?
8. ¿Qué es un itemset maximal frecuente y qué utilidad tiene?
9. ¿Qué riesgos existen si intentamos contar pares sin verificar primero que los items individuales son frecuentes?
10. ¿Cómo se generaliza A-Priori para encontrar itemsets de tamaño $k > 2$?

## 14. Acciones que la skill debería poder recomendar o ejecutar
- Calcular el requisito de memoria para almacenar conteos de pares dado un número de items $n$.
- Decidir entre implementar `Triangular Matrix` o `Triples Method` basándose en la estimación de pares únicos.
- Implementar la lógica de filtrado de candidatos para la pasada $k$.
- Estimar el número de pasadas de disco necesarias para un análisis específico.
- Identificar si un dataset causará *thrashing* dada una memoria RAM específica.

## 15. Activos finales de conocimiento en formato compacto

| Concepto | Descripción | Referencia |
| :--- | :--- | :--- |
| **Monotonicidad** | Si $I$ es frecuente, todo $J \subseteq I$ es frecuente. Base de la poda. | Sec 6.2.3 |
| **Matriz Triangular** | Array 1D para pares $\{i,j\}$. Eficiente si $>1/3$ pares existen. Índice $k=(i-1)(n-i/2)+j-i$. | Sec 6.2.2 |
| **Método Triples** | Hash table de $[i, j, c]$. Eficiente para datos dispersos ($<1/3$ pares). | Sec 6.2.2 |
| **A-Priori Pasada 1** | Cuenta items, genera $L_1$ (items frecuentes). Renumeración $1..m$. | Sec 6.2.5 |
| **A-Priori Pasada 2** | Cuenta pares de items en $L_1$. Reduce espacio de $n^2$ a $m^2$. | Sec 6.2.5 |
| **Thrashing** | Fallo de rendimiento por exceso de swapping a disco si conteos no caben en RAM. | Sec 6.2.2 |
| **Itemset Maximal** | Itemset frecuente sin superconjuntos frecuentes. Compacta la salida. | Sec 6.2.3 |
| **Coste E/S** | Tiempo $\propto$ (Nº Pasadas) $\times$ (Tamaño Archivo). Minimizar pasadas es clave. | Sec 6.2.1 |
| **Candidatos $C_k$** | Itemsets de tamaño $k$ donde todos los subconjuntos $k-1$ están en $L_{k-1}$. | Sec 6.2.6 |
| **PCY** | Algoritmo mejorado que usa memoria libre en Pasada 1 para hashear pares. | Sec 6.3 |
