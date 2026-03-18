# parte-40 — Mining-of-Massive-Datasets-Third-Edition-Jure-Leskovec-Anand-Rajaraman-etc-z-library-sk-1lib-sk-z-lib-parte-40.pdf

## 1. Metadatos del documento
- **Libro:** Mining of Massive Datasets, 3ª ed.
- **Fragmento/Parte:** Sección 10.7 (Counting Triangles) y Sección 10.8.1 (Directed Graphs and Neighborhoods)
- **Temas principales:** Conteo de triángulos, Análisis de redes sociales, Algoritmos de grafos optimizados, Heavy Hitters, MapReduce en grafos, Multiway Join, Propiedades de vecindad.
- **Tipo de contenido:** Mixto (Teoría / Algoritmo / Implementación)

## 2. Resumen técnico de alto valor
El fragmento aborda el problema del conteo de triángulos en grafos masivos como indicador de la estructura de redes sociales, contrastando la densidad de triángulos en redes reales frente a grafos aleatorios. Se presenta un algoritmo óptimo para un solo procesador con complejidad $O(m^{3/2})$ que distingue entre nodos "heavy hitters" (grado $\ge \sqrt{m}$) y nodos normales para evitar cuellos de botella computacionales. Posteriormente, se adapta este problema al paradigma MapReduce mediante una implementación de Multiway Join, optimizando la comunicación y el número de reducers mediante el uso de ordenamiento y hashing simétrico. Se demuestra la optimalidad asintótica del algoritmo y se introduce la representación de grafos dirigidos para el análisis de vecindades.

## 3. Conceptos y definiciones clave
- **Triángulo (Teoría de grafos):** Conjunto de tres nodos con aristas entre cada par. En redes sociales, indica cohesión social (ej: amigos comunes).
- **Heavy Hitter (Nodo pesado):** Nodo cuyo grado es al menos $\sqrt{m}$, donde $m$ es el número total de aristas. Son pocos en número (máx. $2\sqrt{m}$) pero concentran muchas conexiones.
- **Heavy-Hitter Triangle:** Triángulo donde los tres nodos son heavy hitters. Se cuentan mediante enumeración exhaustiva de combinaciones de estos nodos.
- **Grafo Aleatorio (Contexto):** Modelo base donde la probabilidad de una arista es independiente. El número esperado de triángulos es $\frac{4}{3}(\frac{m}{n})^3$.
- **Ordenamiento de Nodos ($\prec$):** Criterio para evitar doble conteo. $v \prec u$ si $degree(v) < degree(u)$, o si los grados son iguales y $v < u$ (numéricamente).
- **Multiway Join:** Operación de unión simultánea de tres relaciones (copias de la arista $E$) para encontrar triángulos: $E(X, Y) \bowtie E(X, Z) \bowtie E(Y, Z)$.
- **Grafo Dirigido:** Modelo con arcos $u \to v$ (origen y destino). Útil para web, citas o seguimientos (Twitter).

## 4. Principios, reglas y heurísticas
- **Umbral de Heavy Hitter:** Un nodo se considera pesado si su grado $k \ge \sqrt{m}$. Esto garantiza que el número de nodos pesados esté acotado por $2\sqrt{m}$.
- **Regla de conteo único:** Para contar triángulos no pesados, se procesa la arista $(v_1, v_2)$ solo si $v_1$ no es heavy hitter y $v_1 \prec v_2$. El triángulo se cuenta si el tercer nodo $u_i$ cumple $v_1 \prec u_i$.
- **Densidad y Madurez:** En redes sociales, una mayor densidad de triángulos respecto a un grafo aleatorio indica madurez de la comunidad; los triángulos se forman con el tiempo a medida que interactúan amigos de amigos.
- **Optimización MapReduce:** Al usar ordenamiento de buckets $(i, j, k)$ con $i \le j \le k$, se reduce el número de reducers necesarios en un factor de aproximadamente 6, comparado con la enumeración completa de buckets.
- **Cota inferior de complejidad:** Cualquier algoritmo de conteo de triángulos requiere tiempo $\Omega(m^{3/2})$ en el peor caso (ej: grafo completo), lo que prueba la optimalidad del algoritmo propuesto.

## 5. Procedimientos, métodos y workflows

### Algoritmo de Conteo de Triángulos (Single Processor)
**Precondiciones:** Grafo con $n$ nodos y $m$ aristas. Nodos identificados por enteros.
**Pasos:**
1.  **Preprocesamiento:**
    *   Calcular el grado de cada nodo recorriendo las aristas ($O(m)$).
    *   Crear índice de aristas (par de nodos $\to$ booleano) usando Hash Table ($O(m)$).
    *   Crear índice de adyacencia (nodo $\to$ lista de vecinos) usando Hash Table ($O(m)$).
2.  **Clasificación:** Identificar nodos *heavy hitters* (grado $\ge \sqrt{m}$).
3.  **Conteo Heavy-Hitter Triangles:**
    *   Enumerar todas las combinaciones de 3 nodos entre los heavy hitters ($O(m^{3/2})$ combinaciones).
    *   Verificar existencia de las 3 aristas usando el índice de aristas ($O(1)$ cada una).
4.  **Conteo Otros Triángulos:**
    *   Iterar sobre cada arista $(v_1, v_2)$.
    *   Si $v_1$ es heavy hitter o $v_2 \prec v_1$, ignorar.
    *   Si no, obtener vecinos de $v_1$: $u_1, \dots, u_k$.
    *   Para cada $u_i$, verificar si existe arista $(u_i, v_2)$ Y si $v_1 \prec u_i$. Si ambos ciertos, contar triángulo.
**Postcondición:** Conteo exacto de triángulos en $O(m^{3/2})$.

### Algoritmo MapReduce (Multiway Join)
**Pasos:**
1.  **Preparación:** Representar aristas como $E(A, B)$ donde $A < B$.
2.  **Join:** Expresión $E(X, Y) \bowtie E(X, Z) \bowtie E(Y, Z)$.
3.  **Map:** Para cada arista $E(u, v)$, enviar a reducers:
    *   $(h(u), h(v), z)$ para todo $z$ (como $E(X,Y)$).
    *   $(h(u), y, h(v))$ para todo $y$ (como $E(X,Z)$).
    *   $(x, h(u), h(v))$ para todo $x$ (como $E(Y,Z)$).
4.  **Reduce:** Cada reducer recibe subconjunto de aristas y ejecuta algoritmo local de conteo.
**Optimización (Fewer Reducers):** Ordenar buckets destino $(i, j, k)$ tal que $i \le j \le k$. Reduce comunicación de $3mb$ a $mb$.

## 6. Problemas comunes y soluciones
- **Problema:** Conteo de triángulos ingenuo ($O(n^3)$ o verificación por arista) es inviable en grafos masivos con nodos de alto grado.
    - **Solución:** Estrategia de "Heavy Hitter". Aislar los nodos de alto grado y tratar sus triángulos aparte, limitando la búsqueda de vecinos a nodos de grado bajo ($< \sqrt{m}$).
- **Problema:** Doble conteo de triángulos (ej: triángulo ABC contado al procesar arista AB y luego al procesar BC).
    - **Solución:** Imponer un ordenamiento estricto $\prec$ y contar el triángulo solo cuando se procesa la arista conectada al nodo "menor" según el orden.
- **Problema:** Cuello de botella en MapReduce al unir relaciones secuencialmente (two-way joins genera productos cartesianos intermedios gigantes).
    - **Solución:** Usar Multiway Join en un solo paso MapReduce, distribuyendo las aristas a reducers específicos que poseen toda la información necesaria para ciertos subconjuntos de nodos.

## 7. Implementación técnica y generación de código

```pseudocode
# Algoritmo Single Processor para Conteo de Triángulos
# Basado en Sección 10.7.2

Función ContarTriangulos(Grafo G):
    m = número de aristas en G
    umbral = sqrt(m)
    
    # 1. Preprocesamiento
    grados = CalcularGrados(G)
    indice_aristas = CrearIndiceAristas(G) # Hash Set de pares
    adyacencia = CrearListaAdyacencia(G)
    
    # Definir orden v < u si (grado(v) < grado(u)) O (grado igual y v_id < u_id)
    
    contador = 0
    
    # 2. Heavy Hitter Triangles
    heavy_hitters = [nodo para nodo en G si grados[nodo] >= umbral]
    Para cada tripletas (u, v, w) en Combinaciones(heavy_hitters, 3):
        Si ExisteArista(u, v) Y ExisteArista(v, w) Y ExisteArista(u, w):
            contador += 1
            
    # 3. Other Triangles
    Para cada arista (v1, v2) en G:
        Si grados[v1] >= umbral: Continuar # Ya contado o se contará después
        Si NO (v1 < v2): Continuar # Asegurar orden para evitar doble conteo
        
        # v1 es nodo de bajo grado
        Para cada vecino u de v1 en adyacencia[v1]:
            Si (v1 < u) Y ExisteArista(u, v2):
                contador += 1
                
    Retornar contador
```

```python
# Implementación Python derivada del algoritmo de conteo optimizado
import math
from itertools import combinations

def count_triangles_optimized(edges):
    """
    Cuenta triángulos en un grafo no dirigido usando la estrategia de Heavy Hitters.
    edges: Lista de tuplas (u, v) donde u < v (enteros).
    Retorna: Número entero de triángulos.
    """
    # Preprocesamiento: Grados y Estructuras de datos
    degrees = {}
    adj = {}
    edge_set = set()
    
    for u, v in edges:
        degrees[u] = degrees.get(u, 0) + 1
        degrees[v] = degrees.get(v, 0) + 1
        adj.setdefault(u, []).append(v)
        adj.setdefault(v, []).append(u)
        edge_set.add((u, v) if u < v else (v, u))
        
    m = len(edges)
    threshold = math.sqrt(m)
    triangle_count = 0
    
    # Función auxiliar para verificar existencia de arista
    def has_edge(n1, n2):
        return (n1, n2) in edge_set if n1 < n2 else (n2, n1) in edge_set

    # Función de ordenamiento v < u
    # (grado menor) o (grado igual e id menor)
    def is_less(v, u):
        if degrees[v] < degrees[u]: return True
        if degrees[v] > degrees[u]: return False
        return v < u

    # Identificar Heavy Hitters
    heavy_hitters = {node for node, deg in degrees.items() if deg >= threshold}
    
    # 1. Conteo Heavy-Hitter Triangles
    # Combinaciones de 3 entre heavy hitters
    hh_list = list(heavy_hitters)
    for i in range(len(hh_list)):
        for j in range(i + 1, len(hh_list)):
            for k in range(j + 1, len(hh_list)):
                u, v, w = hh_list[i], hh_list[j], hh_list[k]
                if has_edge(u, v) and has_edge(v, w) and has_edge(u, w):
                    triangle_count += 1

    # 2. Conteo Otros Triángulos
    # Iterar sobre aristas (v1, v2)
    for v1, v2 in edges:
        # Asegurar que v1 es el nodo "menor" según el orden definido
        # Si v1 no es el menor, se omite (se contará cuando el menor sea procesado)
        # Nota: El algoritmo del libro itera sobre aristas y verifica si v1 es el menor.
        # Si v1 es heavy hitter, se omite aquí (ya contado en el paso anterior o irrelevante para el paso de bajo grado).
        
        if v1 in heavy_hitters or v2 in heavy_hitters:
            continue # La lógica del libro omite la arista si AMBOS son HH (caso ya tratado) 
                     # o si v1 es HH. Simplificación: Si v1 es HH, skip.
                     # El texto dice: "If both v1 and v2 are heavy hitters, ignore this edge."
                     # "Suppose... that v1 is not a heavy hitter".
        
        if not is_less(v1, v2):
            continue
            
        # Buscar triángulos donde v1 es el nodo "menor"
        # v1 tiene grado < sqrt(m), así que sus vecinos son pocos
        if v1 in adj:
            for ui in adj[v1]:
                # Condiciones: v1 < ui y existe arista (ui, v2)
                if is_less(v1, ui) and has_edge(ui, v2):
                    triangle_count += 1
                    
    return triangle_count
```

## 8. Funciones, métodos, librerías o comandos identificados
- **Hash Table / Hash Index:** Estructura central para índices de aristas y nodos. Permite búsqueda $O(1)$ esperado.
- **Multiway Join ($\bowtie$):** Operación relacional extendida a 3 o más tablas. En SQL equivale a un join de 3 tablas sobre claves compartidas.
- **Reduce Task:** Unidad de procesamiento en MapReduce que recibe claves hasheadas. En este contexto, identificada por terna de buckets $(x, y, z)$.
- **Combinatoria ($\binom{n}{k}$):** Usada para calcular conteos exactos y cotas superiores (ej: $\binom{n}{3}$ triángulos en grafo completo).

## 9. Snippets o plantillas reutilizables

```python
# Snippet: Cálculo de expectativa de triángulos en grafo aleatorio
def expected_triangles_random_graph(n, m):
    """
    Calcula el número esperado de triángulos en un grafo aleatorio
    según la fórmula del libro (Sección 10.7.1).
    n: número de nodos
    m: número de aristas
    """
    # Fórmula: (4/3) * (m/n)^3
    if n == 0: return 0
    ratio = m / n
    return (4.0 / 3.0) * (ratio ** 3)

# Snippet: Generación de buckets para MapReduce optimizado (Sección 10.7.5)
def generate_reducer_buckets(b):
    """
    Genera lista de buckets (i, j, k) tales que 1 <= i <= j <= k <= b.
    Esto reduce el número de reducers de b^3 a C(b+2, 3).
    """
    buckets = []
    for i in range(1, b + 1):
        for j in range(i, b + 1):
            for k in range(j, b + 1):
                buckets.append((i, j, k))
    return buckets
```

## 10. Casos de uso y aplicaciones
- **Detección de Comunidades:** La densidad de triángulos es un indicador de la madurez y cohesión de una comunidad en redes sociales.
- **Detección de Anomalías:** Comparar el conteo real de triángulos contra el esperado en un grafo aleatorio ($\frac{4}{3}(\frac{m}{n})^3$). Si es significativamente mayor, el grafo tiene estructura social real; si es similar, podría ser ruido o spam.
- **Análisis de Madurez de Red:** Comunidades nuevas tienen pocos triángulos (amigos traídos por un solo nodo), mientras que comunidades maduras completan los triángulos (interacción entre amigos de amigos).
- **Sistemas de Recomendación:** Sugerir amistades basadas en triángulos abiertos (2 aristas existentes, 1 faltante), aunque este fragmento se centra en el conteo, no en la predicción.

## 11. Limitaciones, riesgos y precauciones
- **Complejidad $\Omega(m^{3/2})$:** Aunque óptimo, sigue siendo costoso para grafos extremadamente densos. No es lineal.
- **Dependencia de Hashing:** El algoritmo MapReduce asume una distribución uniforme del hash. Malas funciones hash pueden causar desbalanceo en los reducers.
- **Memoria en Single Processor:** Requiere índices en memoria ($O(m)$). Para grafos masivos que exceden RAM, la implementación single-processor falla, obligando el uso de MapReduce.
- **Supuesto de Grafo Simple:** El algoritmo asume sin bucles (loops) y aristas únicas. El preprocesamiento debe limpiar duplicados y auto-referencias.

## 12. Relaciones con otros temas del corpus
- **MinHashing / LSH:** Relacionado con la búsqueda de similitudes, pero el conteo de triángulos se centra en la estructura local de cohesión (clustering coefficient).
- **PageRank:** Mientras PageRank mide importancia global basada en caminos, el conteo de triángulos mide cohesión local.
- **Joins en MapReduce (Capítulo 2):** Este fragmento aplica directamente la teoría de multiway joins explicada anteriormente en el libro.
- **Grafos Dirigidos (Sección 10.8.1):** Extensión del modelo para representar relaciones asimétricas (Twitter, Web), base para algoritmos de camino más corto o reachability.

## 13. Preguntas que la skill debería poder responder
1. ¿Por qué el conteo de triángulos es relevante para distinguir una red social de un grafo aleatorio?
2. ¿Cuál es la complejidad temporal del algoritmo óptimo de conteo de triángulos y por qué es $\Omega(m^{3/2})$?
3. ¿Qué es un "heavy hitter" en el contexto de grafos y cómo afecta la estrategia de conteo?
4. ¿Cómo se implementa el conteo de triángulos en MapReduce usando un Multiway Join?
5. ¿Qué mejora se obtiene al ordenar los buckets de reducers como $i \le j \le k$?
6. ¿Cuál es la fórmula para el número esperado de triángulos en un grafo aleatorio con $n$ nodos y $m$ aristas?
7. ¿Cómo se relaciona la edad de una comunidad con la densidad de triángulos?
8. ¿Qué estructuras de datos se requieren para el preprocesamiento eficiente del grafo?

## 14. Acciones que la skill debería poder recomendar o ejecutar
- **Seleccionar algoritmo:** Recomendar el algoritmo single-processor si el grafo cabe en memoria, o MapReduce si excede la memoria de un nodo.
- **Configurar MapReduce:** Calcular el número óptimo de buckets $b$ y reducers para minimizar comunicación.
- **Validar datos:** Verificar si el grafo tiene densidad de triángulos anómala antes de usarlo para modelos de predicción social.
- **Optimizar código:** Implementar la poda de vecinos usando el ordenamiento de grados para evitar conteo duplicado.

## 15. Activos finales de conocimiento en formato compacto

| Concepto | Descripción | Referencia |
| :--- | :--- | :--- |
| **Heavy Hitter** | Nodo con grado $\ge \sqrt{m}$. Máximo $2\sqrt{m}$ nodos en el grafo. | Sec 10.7.2 |
| **Cota Inferar** | Tiempo mínimo requerido para conteo: $\Omega(m^{3/2})$. | Sec 10.7.3 |
| **Expectativa Aleatoria** | Triángulos esperados en grafo aleatorio: $\frac{4}{3}(\frac{m}{n})^3$. | Sec 10.7.1 |
| **Ordenamiento $\prec$** | Criterio para evitar doble conteo: menor grado primero, luego ID menor. | Sec 10.7.2 |
| **Multiway Join** | $E(X,Y) \bowtie E(X,Z) \bowtie E(Y,Z)$. Detecta triángulos en un paso. | Sec 10.7.4 |
| **Optimización Reducers** | Usar orden $i \le j \le k$ reduce reducers por factor ~6. | Sec 10.7.5 |
| **Madurez Comunidad** | Mayor densidad de triángulos implica comunidad más antigua/madura. | Sec 10.7.1 |
| **Grafo Dirigido** | Modelo con arcos $u \to v$. Base para análisis de caminos y vecindad. | Sec 10.8.1 |
