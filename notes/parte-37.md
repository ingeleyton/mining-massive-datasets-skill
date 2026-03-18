# parte-37 — Mining-of-Massive-Datasets-Third-Edition-Jure-Leskovec-Anand-Rajaraman-etc-z-library-sk-1lib-sk-z-lib-parte-37.pdf

## 1. Metadatos del documento
- **Libro:** Mining of Massive Datasets, 3ª ed.
- **Fragmento/Parte:** Capítulo 10.3 - Direct Discovery of Communities (y final de 10.2)
- **Temas principales:** Detección de comunidades, Grafos bipartitos completos, Mineria de itemsets frecuentes, Cliques, Centralidad de intermediación (optimización), Mapeo grafo-a-canasta.
- **Tipo de contenido:** Teoría / Algoritmo / Demostración Matemática

## 2. Resumen técnico de alto valor
El fragmento aborda la limitación de los métodos de particionamiento (como Girvan-Newman) donde un nodo no puede pertenecer a múltiples comunidades y todos deben ser asignados. Propone la **descubrimiento directo de comunidades** mediante la identificación de subgrafos bipartitos completos ($K_{s,t}$) en lugar de cliques, debido a la dificultad computacional (NP-completo) y la escasez de cliques grandes en grafos reales. La contribución central es el mapeo isomórfico entre la búsqueda de subgrafos $K_{s,t}$ y el problema de **Minería de Itemsets Frecuentes**: los nodos de la izquierda son "items", los de la derecha son "canastas", y las aristas son la presencia del item en la canasta. Se demuestra matemáticamente que, dada una densidad de aristas suficiente, la existencia de estos subgrafos está garantizada, y pueden descubrirse eficientemente utilizando algoritmos como A-priori. Adicionalmente, se menciona una técnica de aproximación para el cálculo de la centralidad de intermediación (betweenness) mediante muestreo aleatorio de nodos para reducir la complejidad de $O(ne)$.

## 3. Conceptos y definiciones clave
- **Clique (Camino completo):** Conjunto de nodos donde existe una arista entre cualquier par de ellos. Denotado como $K_s$ para un clique de tamaño $s$.
- **Grafo Bipartito Completo ($K_{s,t}$):** Subgrafo con $s$ nodos en un lado y $t$ en el otro, donde existen todas las posibles $st$ aristas entre ambos lados. También llamado "bi-clique".
- **Principio del Palomar (Pigeonhole Principle):** Principio combinatorio utilizado para demostrar que en un grafo con nodos divididos en $k$ residuos, no pueden existir cliques de tamaño $k+1$.
- **Núcleo de una comunidad (Community Nucleus):** Subgrafo (usualmente un bi-clique) denso que sirve como base para expandir una comunidad añadiendo nodos con muchas conexiones hacia el núcleo.
- **Mapeo Items-Canastas:** Transformación de un grafo bipartito $G$ en datos transaccionales:
    - **Items:** Nodos del lado izquierdo.
    - **Canastas:** Nodos del lado derecho.
    - **Contenido:** Vecinos de un nodo derecho son los items en esa canasta.
- **Soporte (Support):** En el contexto de grafos, número de nodos del lado derecho conectados a un conjunto de nodos del lado izquierdo.

## 4. Principios, reglas y heurísticas
- **Regla de particionamiento vs. descubrimiento directo:** Usar descubrimiento directo cuando se requiere solapamiento de comunidades o cuando no es necesario asignar todos los nodos a una comunidad.
- **Regla de eficiencia para $K_{s,t}$:** Al buscar $K_{s,t}$, asumir $t \le s$ y definir el soporte como $s$. Esto minimiza el tamaño del itemset a buscar ($t$), lo cual es computacionalmente más eficiente que buscar itemsets de tamaño $s$.
- **Heurística de partición aleatoria:** Para grafos generales (no bipartitos), dividir los nodos en dos grupos aleatorios permite buscar $K_{s,t}$ como proxy de comunidades densas, esperando que la comunidad se divida aproximadamente a la mitad.
- **Cota de existencia:** Si el grado promedio es $d$ y hay $n$ nodos por lado, un $K_{s,t}$ existe si la frecuencia promedio de itemsets de tamaño $t$ es al menos $s$.
- **Aproximación de Betweenness:** En grafos masivos ($O(ne)$ prohibitivo), calcular la centralidad de intermediación usando un subconjunto aleatorio de nodos como raíces de BFS en lugar de todos los nodos.

## 5. Procedimientos, métodos y workflows

### Aproximación del cálculo de Betweenness
1.  **Precondición:** Grafo grande donde $O(ne)$ es intratable.
2.  **Paso 1:** Seleccionar un subconjunto aleatorio de nodos.
3.  **Paso 2:** Ejecutar BFS desde cada nodo seleccionado.
4.  **Paso 3:** Calcular la betweenness de las aristas basándose solo en estos BFS.
5.  **Resultado:** Aproximación de la betweenness útil para la mayoría de aplicaciones.

### Algoritmo para encontrar $K_{s,t}$ mediante Itemsets Frecuentes
1.  **Precondición:** Grafo bipartito $G$ con lados Izquierdo ($L$) y Derecho ($R$). Parámetros $s$ (soporte) y $t$ (tamaño itemset), con $t \le s$.
2.  **Mapeo:**
    - Identificar $L$ como el universo de Items.
    - Identificar $R$ como el conjunto de Canastas.
    - Para cada nodo $v \in R$, crear una canasta conteniendo los vecinos de $v$ en $L$.
3.  **Minería:** Ejecutar algoritmo de itemsets frecuentes (ej. A-priori) con:
    - Umbral de soporte = $s$.
    - Tamaño de itemset = $t$.
4.  **Construcción:**
    - Si se encuentra un itemset frecuente $F$ de tamaño $t$ con soporte $s$.
    - Los $t$ items forman el lado izquierdo del $K_{s,t}$.
    - Las $s$ canastas que contienen $F$ forman el lado derecho del $K_{s,t}$.
5.  **Postcondición:** Se identifican instancias de $K_{s,t}$ de forma eficiente.

## 6. Problemas comunes y soluciones
- **Problema:** Encontrar cliques máximos es NP-completo y difícil de aproximar. Además, grafos densos pueden tener cliques sorprendentemente pequeños.
    - **Solución:** Buscar subgrafos bipartitos completos ($K_{s,t}$) en su lugar. Es un problema tractable vía itemsets frecuentes.
- **Problema:** Un grafo denso puede no tener cliques grandes debido a la estructura de residuos (Ejemplo 10.10).
    - **Solución:** Relajar el requisito de "todos contra todos" (clique) por "todos de un grupo conectados a todos del otro grupo" (bi-clique).
- **Problema:** Complejidad $O(ne)$ para calcular betweenness en grafos masivos.
    - **Solución:** Muestreo aleatorio de nodos iniciales para obtener una aproximación.

## 7. Implementación técnica y generación de código

```pseudocode
# Algoritmo: Hallar K_s,t en Grafo Bipartito G
# Entrada: Grafo G(L, R, E), Enteros s, t (t <= s)
# Salida: Lista de subgrafos K_s,t

# 1. Transformación a modelo de canastas
Baskets = []
Para cada nodo v en R:
    basket_v = Lista de vecinos de v en L
    Baskets.append(basket_v)

# 2. Ejecución de Minería de Itemsets (conceptual)
# Buscar itemsets de tamaño t con soporte >= s
FrequentItemsets = FindFrequentItemsets(Baskets, min_support=s, itemset_size=t)

# 3. Reconstrucción
Para cada itemset I en FrequentItemsets:
    # I es un conjunto de t nodos de L
    # Las canastas que contienen I son los nodos de R
    RightNodes = ObtenerCanastasContenedoras(I)
    Si |RightNodes| >= s:
        Retornar Subgrafo(I, RightNodes)
```

```python
# Implementación Python: Transformación de Grafo Bipartito a Formato Transaccional
# Requiere networkx y itertools (para simulación simple de itemsets)

import networkx as nx
from itertools import combinations

def find_bicliques_via_itemsets(G, left_nodes, right_nodes, t_size, s_support):
    """
    Transforma un grafo bipartito en datos transaccionales y busca K_s,t.
    
    Args:
        G (nx.Graph): Grafo bipartito.
        left_nodes (list): Nodos del lado izquierdo (Items).
        right_nodes (list): Nodos del lado derecho (Baskets).
        t_size (int): Tamaño del itemset (lado izquierdo del bi-clique).
        s_support (int): Soporte mínimo (lado derecho del bi-clique).
        
    Returns:
        list: Lista de tuplas (left_set, right_set) representando K_s,t.
    """
    
    # Paso 1: Construir "Canastas"
    # Estructura: {nodo_derecho: set(vecinos_izquierdos)}
    baskets = {}
    for r_node in right_nodes:
        neighbors = set(G.neighbors(r_node))
        baskets[r_node] = neighbors
        
    # Paso 2: Contar itemsets de tamaño t (Fuerza bruta para demostración, 
    # en producción usar A-priori o FP-Growth)
    # Nota: Esto es O(|L|^t), solo para fines ilustrativos del mapeo.
    
    found_bicliques = []
    
    # Generar todas las combinaciones de tamaño t de los nodos izquierdos
    # Advertencia: En datasets masivos, esto requiere algoritmos de optimización como A-priori.
    possible_left_sets = combinations(left_nodes, t_size)
    
    for left_set in possible_left_sets:
        left_set = set(left_set)
        # Encontrar intersección de canastas que contienen TODOS los nodos en left_set
        # Es decir, nodos derechos conectados a todos los de left_set
        
        count = 0
        common_right_nodes = []
        
        for r_node, items_in_basket in baskets.items():
            if left_set.issubset(items_in_basket):
                count += 1
                common_right_nodes.append(r_node)
        
        if count >= s_support:
            found_bicliques.append((left_set, set(common_right_nodes)))
            
    return found_bicliques

# Ejemplo de uso basado en Fig 10.10
# G = nx.Graph()
# G.add_edges_from([(1,'a'), (4,'a'), (2,'b'), (3,'b'), (1,'c'), (3,'d')])
# left = [1,2,3,4]
# right = ['a','b','c','d']
# find_bicliques_via_itemsets(G, left, right, t_size=1, s_support=2)
# Salida esperada: [({1}, {'a', 'c'}), ({3}, {'b', 'd'})] -> K_2,1
```

## 8. Funciones, métodos, librerías o comandos identificados
- **BFS (Breadth-First Search):** Algoritmo base para el cálculo de centralidad y exploración de grafos.
- **A-priori Algorithm:** Referenciado como el método eficiente para encontrar los itemsets frecuentes una vez realizado el mapeo del grafo.
- **Binomial Coefficient ($\binom{n}{k}$):** Herramienta matemática clave para calcular el número de itemsets y demostrar la existencia de bi-cliques.
- **Pigeonhole Principle:** Principio lógico para demostrar límites en tamaños de cliques.

## 9. Snippets o plantillas reutilizables

**Cálculo de garantía de existencia de $K_{s,t}$:**
```python
import math

def check_kst_existence_guarantee(n, d, t, s):
    """
    Verifica si la fórmula aproximada garantiza la existencia de K_s,t.
    n: nodos por lado
    d: grado promedio
    t: tamaño del itemset (lado izquierdo)
    s: soporte (lado derecho)
    """
    # Fórmula aproximada: n * (d/n)^t >= s
    lhs = n * (d/n)**t
    
    # Fórmula exacta (usando coeficientes binomiales)
    # n * C(d, t) / C(n, t) >= s
    # Nota: math.comb disponible en Python 3.8+
    try:
        exact_lhs = n * math.comb(d, t) / math.comb(n, t)
    except ValueError:
        exact_lhs = 0 # Si d < t
        
    return {
        "approx_condition_met": lhs >= s,
        "approx_value": lhs,
        "exact_condition_met": exact_lhs >= s,
        "exact_value": exact_lhs
    }
```

## 10. Casos de uso y aplicaciones
- **Análisis de Redes Sociales:** Identificación de grupos de usuarios que interactúan intensamente con un conjunto común de contenido (ej. tags y páginas web).
- **Sistemas de Recomendación:** Descubrimiento de comunidades de usuarios y productos basado en patrones de compra completos (todos los usuarios compraron todos los productos del conjunto).
- **Detección de Comunidades Solapadas:** Permitir que un nodo (ej. una persona) pertenezca a múltiples comunidades (ej. trabajo, familia) mediante la búsqueda de núcleos bipartitos.
- **Grafos de Etiquetas Web:** Encontrar comunidades de tags y páginas web donde todas las páginas tienen todos los tags (o viceversa).

## 11. Limitaciones, riesgos y precauciones
- **Complejidad del Clique:** Intentar encontrar cliques máximos es inviable para grafos grandes; siempre preferir bi-cliques para este propósito.
- **Aproximación de Fórmula:** La fórmula simplificada $n(d/n)^t \ge s$ da una cota superior para $s$ ligeramente más alta que la fórmula exacta. Puede sobreestimar la garantía de existencia si no se corrige con los coeficientes binomiales exactos.
- **Supuestos de Densidad:** La garantía de existencia depende fuertemente de que el grado promedio $d$ sea alto relativo a $n$.
- **Partición Aleatoria:** En grafos no bipartitos, la división aleatoria de nodos en dos grupos puede fragmentar comunidades pequeñas, reduciendo la probabilidad de detección.

## 12. Relaciones con otros temas del corpus
- **Chapter 6 (Frequent Itemsets):** Dependencia directa. El algoritmo de descubrimiento de comunidades presentado es una aplicación práctica de A-priori o FP-Growth.
- **Section 10.2 (Betweenness):** Contraste metodológico. 10.2 usa particionamiento jerárquico (costoso), 10.3 usa descubrimiento directo (basado en densidad local).
- **Section 8.3 (Bipartite Graphs):** Fundamento teórico sobre la estructura de grafos bipartitos.
- **Graph Theory:** Conceptos de NP-completitud y aproximación.

## 13. Preguntas que la skill debería poder responder
1. ¿Por qué es preferible buscar subgrafos bipartitos completos ($K_{s,t}$) en lugar de cliques para descubrir comunidades?
2. ¿Cómo se mapea un grafo bipartito al problema de minería de itemsets frecuentes?
3. ¿Cuál es la complejidad computacional de calcular la centralidad de intermediación exacta y cómo se puede optimizar?
4. ¿Qué condiciones matemáticas garantizan la existencia de un subgrafo $K_{s,t}$ en un grafo bipartito aleatorio?
5. ¿Cómo permite el descubrimiento directo de comunidades que un nodo pertenezca a múltiples grupos?
6. ¿Qué representa el "soporte" en el contexto de transformar un grafo en transacciones?
7. ¿Por qué se recomienda asumir $t \le s$ al buscar $K_{s,t}$?
8. ¿Cómo aplicar el principio del palomar para demostrar límites en el tamaño de cliques?

## 14. Acciones que la skill debería poder recomendar o ejecutar
- **Seleccionar estrategia:** Si el grafo es masivo y se necesitan comunidades solapadas, recomendar "Direct Discovery" sobre "Girvan-Newman".
- **Transformar datos:** Convertir una lista de aristas de un grafo bipartito en una lista de transacciones (canastas) para ingestión en algoritmos de itemsets.
- **Configurar parámetros:** Sugerir valores de soporte $s$ y tamaño $t$ basados en el grado promedio $d$ y el número de nodos $n$ usando la fórmula de existencia.
- **Validar resultados:** Verificar si los itemsets frecuentes encontrados forman realmente un bi-clique completo.
- **Optimizar cálculos:** Sugerir muestreo de nodos para cálculos de betweenness si $n > 10^6$.

## 15. Activos finales de conocimiento en formato compacto

| Concepto | Descripción | Referencia |
| :--- | :--- | :--- |
| **Mapeo Grafo-Itemset** | Lado izq. = Items, Lado der. = Canastas, Aristas = Contenido. | Sec 10.3.3 |
| **Existencia $K_{s,t}$** | Garantizada si $n \binom{d}{t} / \binom{n}{t} \ge s$. | Sec 10.3.4 |
| **Clique vs Bi-clique** | Cliques son NP-completo; Bi-cliques son tratables vía A-priori. | Sec 10.3.1/2 |
| **Betweenness Aprox.** | Usar muestreo aleatorio de raíces BFS para reducir coste. | Sec 10.2 |
| **Comunidad Solapada** | Direct Discovery permite nodos en múltiples $K_{s,t}$. | Sec 10.3 intro |
| **Principio Palomar** | Limita tamaño de clique si nodos se agrupan en $k$ residuos. | Sec 10.3.1 |
| **Núcleo Comunidad** | $K_{s,t}$ encontrado sirve como base para agregar nodos periféricos. | Sec 10.3.2 |
| **Eficiencia $t \le s$** | Buscar itemsets pequeños con alto soporte es más rápido. | Sec 10.3.3 |
