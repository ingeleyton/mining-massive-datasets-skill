# parte-36 — Mining-of-Massive-Datasets-Third-Edition-Jure-Leskovec-Anand-Rajaraman-etc-z-library-sk-1lib-sk-z-lib-parte-36.pdf

## 1. Metadatos del documento
- **Libro:** Mining of Massive Datasets, 3ª ed.
- **Fragmento/Parte:** Chapter 10.2 - Clustering of Social-Network Graphs
- **Temas principales:** Clustering de grafos, Detección de comunidades, Betweenness (intermediación), Algoritmo Girvan-Newman, Medidas de distancia en grafos, BFS en redes sociales.
- **Tipo de contenido:** Mixto (Teoría / Algoritmo / Limitaciones)

## 2. Resumen técnico de alto valor
El fragmento aborda la ineficacia de los métodos de clustering tradicionales (jerárquico y de asignación de puntos) aplicados a grafos de redes sociales debido a la incapacidad de definir medidas de distancia métricas válidas en aristas no etiquetadas. Se introduce el concepto de **Betweenness** (intermediación) de aristas como métrica alternativa para identificar límites entre comunidades. Se detalla el **Algoritmo Girvan-Newman (GN)**, que utiliza búsquedas BFS (Breadth-First Search) para calcular la contribución de cada arista a los caminos más cortos, permitiendo identificar y eliminar aristas "puente" para descomponer el grafo en comunidades. Se presenta también una técnica de aproximación por muestreo para reducir la complejidad computacional en grafos masivos.

## 3. Conceptos y definiciones clave
- **Comunidades en redes sociales:** Grupos de entidades conectadas por muchas aristas (ej. grupos de amigos, investigadores en un mismo tema).
- **Medida de distancia en grafos:** Intento de definir cercanía entre nodos. En grafos sin etiquetas, la propuesta binaria (0 si existe arista, 1 si no) viola la desigualdad triangular, invalidando los clustering tradicionales.
- **Betweenness (Intermediación) de una arista:** Número de pares de nodos $(x, y)$ tal que la arista $(a, b)$ se encuentra en el camino más corto entre ellos. Si hay múltiples caminos más cortos, se acredita la fracción correspondiente. Un valor alto indica que la arista conecta comunidades distintas.
- **Aristas DAG (Directed Acyclic Graph):** En el contexto del algoritmo GN, son las aristas que conectan nodos de diferentes niveles en un BFS. Solo estas aristas pueden ser parte de un camino más corto desde la raíz.
- **Padre e Hijo (en DAG de BFS):** Si existe una arista DAG $(Y, Z)$ donde $Y$ está en el nivel superior (más cerca de la raíz), $Y$ es padre de $Z$. Un nodo puede tener múltiples padres.
- **Crédito (en Algoritmo GN):** Valor asignado a nodos y aristas durante el cálculo de betweenness. Representa la contribución de los caminos más cortos que pasan por ese elemento.

## 4. Principios, reglas y heurísticas
- **Inviableidad de distancia binaria:** No utilizar medidas de distancia 0/1 o $1/\infty$ para clustering en grafos sociales, ya que violan la desigualdad triangular cuando existen caminos de longitud 2 sin conexión directa.
- **Interpretación de Betweenness:** Una arista con alta betweenness es candidata a ser eliminada, ya que actúa como puente entre comunidades distintas.
- **Construcción de comunidades por eliminación:** Las comunidades se forman eliminando iterativamente las aristas de mayor betweenness; los componentes conectados restantes forman las comunidades.
- **Aproximación en grafos grandes:** Si $O(ne)$ es prohibitivo, calcular betweenness utilizando un subconjunto aleatorio de nodos como raíces en lugar de todos los nodos.
- **Detección de "traidores":** Nodos que conectan comunidades distintas (ej. nodo B conectando {A, B, C} con D) pueden ser identificados porque sus aristas hacia fuera del cluster tienen alta betweenness.

## 5. Procedimientos, métodos y workflows

### Algoritmo Girvan-Newman (GN)
**Objetivo:** Calcular la betweenness de todas las aristas para identificar comunidades.
**Precondiciones:** Grafo $G$ no dirigido.

**Paso 1: BFS desde una raíz $X$**
1. Realizar un recorrido BFS desde el nodo $X$.
2. Definir niveles de nodos según la distancia a $X$.
3. Identificar aristas DAG (conectan niveles distintos) y descartar aristas entre nodos del mismo nivel (no son caminos más cortos desde $X$).

**Paso 2: Etiquetado de caminos más cortos**
1. Etiquetar la raíz $X$ con 1.
2. Descendentemente, etiquetar cada nodo $Y$ con la suma de las etiquetas de sus padres.

**Paso 3: Cálculo de créditos (Bottom-Up)**
1. Asignar crédito 1 a cada nodo hoja (sin hijos DAG).
2. Para nodos no hoja: Crédito = 1 + suma de créditos de aristas DAG que llegan desde niveles inferiores.
3. Para cada arista $(Y_i, Z)$ donde $Z$ es el nodo inferior:
    *   Sea $p_i$ la etiqueta del padre $Y_i$ (caminos más cortos hasta $Y_i$).
    *   Crédito de la arista = Crédito de $Z \times \frac{p_i}{\sum_{j=1}^k p_j}$.

**Paso 4: Agregación**
1. Repetir Pasos 1-3 para cada nodo como raíz.
2. Sumar los créditos de cada arista.
3. Dividir el total por 2 (cada camino se cuenta dos veces, una por cada extremo).

**Paso 5: Clustering**
1. Eliminar la arista con mayor betweenness.
2. Recalcular betweenness (o actualizar) y repetir hasta obtener el número deseado de componentes conectados.

## 6. Problemas comunes y soluciones
- **Problema:** Clustering jerárquico une nodos equivocados (ej. B y D) por azar porque todas las distancias son iguales.
    *   **Solución:** Usar betweenness (Girvan-Newman) en lugar de distancia euclidiana/geométrica.
- **Problema:** K-means asigna nodos a clusters incorrectos debido a equidistancia de aristas.
    *   **Solución:** Usar asignación basada en promedio de distancias o diferir la asignación de nodos ambiguos, aunque el método GN es más robusto.
- **Problema:** Complejidad $O(ne)$ muy alta para grafos de millones de nodos.
    *   **Solución:** Utilizar muestreo aleatorio de nodos raíz para aproximar la betweenness.

## 7. Implementación técnica y generación de código

```pseudocode
# Algoritmo Girvan-Newman (Cálculo de Betweenness para una raíz)
Function CalculateBetweennessFromRoot(Graph G, Node root):
    # Paso 1: BFS y construcción de DAG
    Perform BFS from root
    Assign levels to nodes
    Identify DAG edges (edges between levels)
    
    # Paso 2: Conteo de caminos más cortos (Top-Down)
    root.label = 1
    For each level from 1 to max_level:
        For each node in level:
            node.label = sum(parent.label for parent in node.parents)
            
    # Paso 3: Asignación de créditos (Bottom-Up)
    Initialize node.credit = 1 for all nodes
    For each level from max_level down to 1:
        For each node in level:
            If node is not leaf:
                node.credit = 1 + sum(edge.credit for edges from children)
            
            For each parent of node:
                edge_credit = node.credit * (parent.label / sum(all_parents_labels))
                Store edge credit
    
    Return edge_credits
```

```python
# Implementación Python simplificada del cálculo de créditos para un nodo raíz
# Requiere networkx para estructura de grafo básica o estructura similar
import networkx as nx

def gn_betweenness_single_root(G, root):
    # Paso 1: BFS para obtener niveles y predecesores (padres)
    levels = {root: 0}
    parents = {root: []}
    queue = [root]
    nodes_by_level = {0: [root]}
    
    # BFS traversal
    while queue:
        v = queue.pop(0)
        for w in G.neighbors(v):
            if w not in levels:
                levels[w] = levels[v] + 1
                parents[w] = [v]
                queue.append(w)
                if levels[w] not in nodes_by_level: nodes_by_level[levels[w]] = []
                nodes_by_level[levels[w]].append(w)
            elif levels[w] == levels[v] + 1:
                parents[w].append(v)

    # Paso 2: Calcular pesos de nodos (número de caminos más cortos)
    node_weights = {root: 1}
    max_level = max(levels.values())
    
    for l in range(1, max_level + 1):
        for w in nodes_by_level.get(l, []):
            node_weights[w] = sum(node_weights[p] for p in parents[w])

    # Paso 3: Calcular créditos de aristas (Bottom-Up)
    # Inicializar créditos de nodos a 1
    node_credits = {n: 1 for n in G.nodes()}
    edge_contributions = {}
    
    # Procesar desde el nivel más bajo hacia arriba
    for l in range(max_level, 0, -1):
        for w in nodes_by_level.get(l, []):
            # Distribuir crédito de w a sus padres
            total_parent_weights = sum(node_weights[p] for p in parents[w])
            for p in parents[w]:
                # Fracción de caminos que pasan por p
                fraction = node_weights[p] / total_parent_weights
                credit_to_give = node_credits[w] * fraction
                
                # Acumular crédito en el padre y registrar contribución de arista
                node_credits[p] += credit_to_give
                edge_contributions[(w, p)] = credit_to_give
                edge_contributions[(p, w)] = credit_to_give # No dirigido
                
    return edge_contributions
```

## 8. Funciones, métodos, librerías o comandos identificados
- **BFS (Breadth-First Search):** Algoritmo fundamental para recorrer el grafo y establecer niveles jerárquicos desde la raíz.
- **DAG (Directed Acyclic Graph):** Estructura auxiliar derivada del BFS usada para modelar los caminos más cortos únicos.
- **Labeling (Etiquetado):** Proceso de asignar pesos a nodos basados en la suma de caminos entrantes.
- **Credit Propagation:** Técnica de paso de mensajes desde las hojas hacia la raíz para distribuir la importancia de las aristas.

## 9. Snippets o plantillas reutilizables

```python
# Plantilla para cálculo aproximado de Betweenness en grafos grandes
import random

def approximate_betweenness(G, sample_size):
    edge_betweenness = {e: 0 for e in G.edges()}
    nodes = list(G.nodes())
    
    # Seleccionar una muestra aleatoria de nodos raíz
    if len(nodes) > sample_size:
        roots = random.sample(nodes, sample_size)
    else:
        roots = nodes
    
    for root in roots:
        contributions = gn_betweenness_single_root(G, root) # Ver función en sección 7
        for e, val in contributions.items():
            # Normalizar orden de aristas para evitar duplicados (u,v) vs (v,u)
            edge_key = tuple(sorted(e))
            edge_betweenness[edge_key] += val
            
    # Dividir por 2 porque cada camino se contó dos veces (una por cada extremo)
    # Nota: En la aproximación, no dividimos por 2 si solo iteramos sobre una muestra
    # pero la lógica interna de gn_betweenness_single_root ya asigna crédito a ambas direcciones.
    # Ajuste: La implementación exacta depende de si se suman contribuciones parciales.
    # Según el libro: "divide the credit for each edge by 2".
    
    for e in edge_betweenness:
        edge_betweenness[e] /= 2
        
    return edge_betweenness
```

## 10. Casos de uso y aplicaciones
- **Identificación de grupos de investigación:** Detección de comunidades en grafos de citas o colaboración.
- **Detección de "Traidores":** Identificar nodos que conectan comunidades distintas (ej. nodo B conectando su grupo con un nodo externo D).
- **Segmentación de usuarios:** En redes sociales tipo "amigos", encontrar grupos densamente conectados sin usar atributos de perfil.
- **Análisis estructural:** Visualización de jerarquías y puentes críticos en la comunicación organizacional.

## 11. Limitaciones, riesgos y precauciones
- **Complejidad Computacional:** El algoritmo completo es $O(ne)$ (n nodos, e aristas). Para $n=1,000,000$, es computacionalmente costoso.
- **Dependencia de la estructura:** El método asume que las comunidades se definen por la densidad de aristas internas frente a aristas externas. No funciona bien si las comunidades están altamente solapadas.
- **Nodos solapados:** El algoritmo no permite que un nodo pertenezca a dos comunidades simultáneamente (particionamiento estricto).
- **Recálculo:** La versión estricta requiere recalcular betweenness tras cada eliminación de arista, aunque existen optimizaciones no detalladas en este fragmento.

## 12. Relaciones con otros temas del corpus
- **Chapter 7 (Clustering):** Este fragmento es una extensión/corrección de los métodos de clustering tradicionales (Jerárquico y K-means) aplicados a datos no métricos (grafos).
- **Chapter 6 (Frequent Itemsets):** El final del fragmento menciona que la siguiente técnica para descubrir comunidades ("Direct Discovery") utiliza la búsqueda de itemsets frecuentes, conectando la teoría de grafos con la minería de reglas de asociación.
- **Teoría de Grafos:** Uso intensivo de BFS y propiedades de caminos más cortos (Shortest Paths).

## 13. Preguntas que la skill debería poder responder
1. ¿Por qué falla el clustering jerárquico estándar en grafos de redes sociales con aristas binarias?
2. ¿Qué representa una arista con alta "betweenness" en el contexto de comunidades sociales?
3. ¿Cuáles son los tres pasos principales dentro de la iteración del algoritmo Girvan-Newman para un nodo raíz dado?
4. ¿Cómo se calcula el crédito de una arista que conecta un nodo con múltiples padres en el algoritmo GN?
5. ¿Qué estrategia se recomienda para aplicar Girvan-Newman en grafos masivos donde $O(ne)$ es inaceptable?
6. ¿Cómo se relaciona la desigualdad triangular con la definición de distancia en grafos de amigos?
7. ¿Es posible que un nodo pertenezca a dos comunidades diferentes utilizando el enfoque de Girvan-Newman?
8. ¿Qué es un "DAG edge" en el contexto del BFS realizado por Girvan-Newman?

## 14. Acciones que la skill debería poder recomendar o ejecutar
- **Recomendar algoritmo:** Sugerir Girvan-Newman sobre K-means cuando el dataset sea un grafo no ponderado de relaciones sociales.
- **Implementar optimización:** Aplicar muestreo de nodos raíz si el grafo supera los cientos de miles de nodos.
- **Interpretar resultados:** Identificar aristas críticas para eliminar y separar comunidades en un grafo dado.
- **Validar métricas:** Verificar si una medida de distancia propuesta viola la desigualdad triangular antes de aplicar clustering geométrico.

## 15. Activos finales de conocimiento en formato compacto
| Concepto | Descripción | Referencia |
| :--- | :--- | :--- |
| **Betweenness** | Métrica para detectar aristas "puente" entre comunidades; cuenta caminos más cortos que pasan por la arista. | Sec 10.2.3 |
| **Girvan-Newman** | Algoritmo de clustering por eliminación iterativa de aristas de alta betweenness. | Sec 10.2.4 |
| **BFS en GN** | Define niveles y aristas DAG; solo las aristas DAG pueden ser parte de caminos más cortos. | Sec 10.2.4 |
| **Crédito de Arista** | $Crédito_Z \times \frac{peso\_padre}{\sum pesos\_padres}$. Distribuye importancia de caminos. | Sec 10.2.4 |
| **Complejidad GN** | $O(ne)$. Prohibitivo para grafos muy grandes sin aproximación. | Box p.367 |
| **Aproximación** | Usar subconjunto aleatorio de nodos como raíces BFS para estimar betweenness. | Box p.367 |
| **Fallo de Distancia** | Distancia binaria (0/1) viola desigualdad triangular: $d(A,C) > d(A,B) + d(B,C)$. | Sec 10.2.1 |
| **Comunidad** | Componente conectado resultante tras eliminar aristas de alta betweenness. | Sec 10.2.5 |
