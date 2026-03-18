# parte-39 — Mining-of-Massive-Datasets-Third-Edition-Jure-Leskovec-Anand-Rajaraman-etc-z-library-sk-1lib-sk-z-lib-parte-39.pdf

## 1. Metadatos del documento
- **Libro:** Mining of Massive Datasets, 3ª ed.
- **Fragmento/Parte:** Chapter 10.5 - Finding Overlapping Communities & Chapter 10.6 - Simrank
- **Temas principales:** Comunidades solapadas, Estimación de Máxima Verosimilitud (MLE), Modelo de Grafo de Afiliación, Simrank, Random Walk with Restart (RWR), Conductancia, Densidad de grafos.
- **Tipo de contenido:** Mixto (Teoría / Algoritmo / Implementación)

## 2. Resumen técnico de alto valor
El fragmento aborda la detección de comunidades solapadas en grafos sociales, superando la limitación de las particiones disjuntas. Se introduce el **Modelo de Grafo de Afiliación**, donde la probabilidad de una arista entre dos nodos aumenta con el número de comunidades compartidas. La optimización de este modelo utiliza **Estimación de Máxima Verosimilitud (MLE)** para ajustar los parámetros de pertenencia y probabilidad de conexión.

Se presenta una evolución del modelo discreto (pertenencia binaria) al continuo (fuerza de pertenencia $F_{xC}$) para permitir el uso de **gradiente descendente** global, evitando los óptimos locales de la búsqueda heurística discreta.

Posteriormente, se introduce **Simrank**, una métrica de similitud estructural basada en la intuición de que "dos nodos son similares si están conectados a nodos similares". Para calcularla sin depender de la distribución estacionaria (que ignora el punto de inicio), se emplea **Random Walk with Restart (RWR)**, una variante de PageRank donde el caminante teletransporta siempre al nodo origen. Se detalla un algoritmo de **Simrank Aproximado** que optimiza el cálculo evitando operaciones sobre nodos con residual insignificante, y se aplica esta métrica para detectar comunidades mediante umbrales de densidad o minimización de conductancia.

## 3. Conceptos y definiciones clave
- **Comunidades Solapadas (Overlapping Communities):** Conjuntos de nodos donde la intersección entre comunidades presenta una densidad de aristas superior a las partes no solapadas.
- **Estimación de Máxima Verosimilitud (MLE):** Método para estimar los parámetros de un modelo generativo maximizando la probabilidad (verosimilitud) de observar el artifacto real (el grafo).
- **Modelo de Grafo de Afiliación (Affiliation-Graph Model):** Modelo generativo donde los nodos pertenecen a comunidades y la existencia de una arista $(u,v)$ depende probabilísticamente de las comunidades compartidas.
- **Fuerza de Pertenencia ($F_{xC}$):** Parámetro continuo no negativo que reemplaza la pertenencia discreta. Un valor de 0 indica no pertenencia. Permite optimización continua.
- **Simrank:** Medida de similitud basada en la estructura del grafo. Se calcula mediante la probabilidad de que un caminante aleatorio que reinicia frecuentemente en un nodo fuente $S$ visite otros nodos.
- **Random Walk with Restart (RWR):** Paseo aleatorio con probabilidad $\beta$ de moverse a un vecino y $1-\beta$ de teletransportarse de vuelta al nodo fuente $S$.
- **Conductancia:** Métrica de calidad de una comunidad $C$. Se define como la fracción de aristas que cortan el borde de $C$ dividida por el volumen (suma de grados) de $C$ o su complemento (el menor de los dos). Valores bajos indican buena comunidad.
- **Volumen de una comunidad:** Suma de los grados de los nodos dentro de la comunidad.

## 4. Principios, reglas y heurísticas
- **Principio de Densidad Creciente:** En comunidades solapadas, la densidad de aristas en la intersección de $k$ comunidades debe ser mayor que en la intersección de $k-1$ comunidades.
- **Regla de Probabilidad de Arista (Modelo Discreto):** Si $u$ y $v$ comparten comunidades $M$, la probabilidad de arista es $p_{uv} = 1 - \prod_{C \in M}(1 - p_C)$. Si no comparten comunidades, $p_{uv} = \epsilon$ (muy pequeño).
- **Regla de Probabilidad de Arista (Modelo Continuo):** $p_{uv} = 1 - e^{-\sum_C F_{uC}F_{vC}}$.
- **Heurística de Optimización Discreta:** Realizar pequeños cambios (añadir/eliminar un miembro) y aceptar si mejora la verosimilitud. Riesgo: óptimos locales.
- **Regla de Simrank Aproximado:** Distribuir solo la mitad del residual del nodo $U$ a sus vecinos para evitar oscilaciones en grafos bipartitos y acelerar la convergencia.
- **Criterio de Parada (Comunidades via Simrank):** Añadir nodos ordenados por Simrank hasta que la densidad caiga por debajo de un umbral o la conductancia alcance un mínimo local.

## 5. Procedimientos, métodos y workflows

### 5.1 Cálculo de MLE para Grafos Aleatorios (Ejemplo básico)
1.  Definir la función de verosimilitud $L(p)$ como el producto de probabilidades de las aristas existentes ($p$) y las no existentes ($1-p$).
2.  Derivar $L(p)$ respecto a $p$ e igualar a 0.
3.  Resultado: El valor óptimo $p$ es la fracción observada de aristas presentes en el grafo.

### 5.2 Algoritmo de Optimización para Comunidades Solapadas (Discreto)
1.  Iniciar con una asignación aleatoria de miembros a comunidades.
2.  Resolver los valores óptimos de $p_C$ (probabilidades de arista por comunidad) mediante gradiente descendente para la asignación actual.
3.  Probar pequeños cambios en la asignación (insertar/eliminar miembro).
4.  Si el cambio aumenta la verosimilitud máxima, aceptar el cambio.
5.  Repetir hasta que ningún cambio mejore la verosimilitud.

### 5.3 Algoritmo de Simrank Aproximado
**Precondiciones:** Grafo $G$, nodo fuente $S$, parámetros $\beta$ (continuidad) y $\epsilon$ (umbral de parada).
**Vectores:** $r$ (Simrank estimado), $q$ (Residual).
1.  Inicializar $r = [0, ..., 0]$, $q = [0, ..., 0]$ excepto $q_S = 1$.
2.  Mientras exista un nodo $U$ tal que $q_U > \epsilon \times \text{grado}(U)$:
    a. Seleccionar dicho nodo $U$.
    b. Actualizar $r_U \leftarrow r_U + (1-\beta)q_U$.
    c. Actualizar residual propio: $q_U \leftarrow \beta q_U / 2$.
    d. Distribuir la otra mitad a los vecinos $V$: $q_V \leftarrow q_V + (\beta q_U) / (2 \times \text{grado}(U))$.
3.  Devolver vector $r$.

### 5.4 Detección de Comunidades usando Simrank
1.  Calcular Simrank para el nodo fuente $S$.
2.  Ordenar el resto de nodos por valor de Simrank descendente.
3.  Iterativamente añadir nodos a la comunidad $C$.
4.  Calcular densidad o conductancia de $C$ en cada paso.
5.  Detenerse al alcanzar un umbral de densidad o un mínimo local de conductancia.

## 6. Problemas comunes y soluciones
- **Problema:** La optimización discreta de pertenencia a comunidades es NP-hard y propensa a óptimos locales.
    - **Solución:** Convertir el problema a continuo usando "fuerza de pertenencia" ($F_{xC}$) y aplicar gradiente descendente, o ejecutar múltiples reinicios aleatorios en el modelo discreto.
- **Problema:** El paseo aleatorio estándar en grafos conectados converge a la misma distribución independientemente del nodo inicial, inutilizando la medida de similitud.
    - **Solución:** Introducir probabilidad de reinicio (teletransporte) al nodo fuente $S$ (Random Walk with Restart).
- **Problema:** En grafos bipartitos, el algoritmo de Simrank aproximado puede oscilar (el residual "rebota" entre las dos partes del grafo).
    - **Solución:** Distribuir solo la mitad del residual a los vecinos y retener la otra mitad en el nodo actual.
- **Problema:** Calcular Simrank exacto es costoso (multiplicación matriz-vector iterativa).
    - **Solución:** Usar el algoritmo aproximado que solo procesa nodos con residual significativo, reduciendo la complejidad a constante respecto al tamaño del grafo si $\epsilon$ es adecuado.

## 7. Implementación técnica y generación de código

```pseudocode
# Algoritmo: Simrank Aproximado (Sección 10.6.3)
# Entrada: Grafo G, Nodo fuente S, factor beta, umbral epsilon
# Salida: Vector r (Simrank aproximado)

Inicializar r = vector_ceros(n)
Inicializar q = vector_ceros(n)
q[S] = 1

Mientras exista U en G tal que q[U] > epsilon * grado(U):
    # Paso 1: Transferir parte del residual al resultado (tax)
    r[U] = r[U] + (1 - beta) * q[U]
    
    # Paso 2: Calcular cantidad a distribuir
    # Nota: Se distribuye solo la mitad para evitar oscilaciones
    residual_a_distribuir = (beta * q[U]) / 2
    
    # Paso 3: Actualizar residual del nodo U (se queda con la mitad)
    q[U] = residual_a_distribuir 
    
    # Paso 4: Distribuir la otra mitad a los vecinos
    Para cada V en vecinos(U):
        q[V] = q[V] + residual_a_distribuir / grado(U)

Retornar r
```

```python
import networkx as nx
import numpy as np

def approximate_simrank(G, source_node, beta=0.8, epsilon=0.01):
    """
    Calcula Simrank aproximado usando Random Walk with Restart.
    
    Args:
        G (nx.Graph): Grafo no dirigido.
        source_node: Nodo fuente para el reinicio.
        beta (float): Probabilidad de continuar el paseo (0.8 por defecto).
        epsilon (float): Umbral de convergencia relativo al grado.
        
    Returns:
        dict: Diccionario {nodo: simrank_score}.
    """
    nodes = list(G.nodes())
    node_index = {node: i for i, node in enumerate(nodes)}
    n = len(nodes)
    
    # Vectores r (resultado) y q (residual)
    r = np.zeros(n)
    q = np.zeros(n)
    
    # Inicialización
    source_idx = node_index[source_node]
    q[source_idx] = 1.0
    
    # Pre-calcular grados
    degrees = np.array([G.degree(node) for node in nodes])
    
    # Bucle principal
    while True:
        # Encontrar candidato U: q_u > epsilon * degree_u
        # Buscamos el índice en el vector q
        candidates = np.where(q > epsilon * degrees)[0]
        if len(candidates) == 0:
            break
            
        # Por eficiencia, procesamos uno a la vez (o podríamos procesar todos)
        # El libro sugiere elegir "cualquier" nodo. Elegimos el de mayor residual para convergencia rápida.
        u_idx = candidates[np.argmax(q[candidates])]
        
        u_node = nodes[u_idx]
        deg_u = degrees[u_idx]
        
        if deg_u == 0: # Nodo aislado
             q[u_idx] = 0
             continue

        # 1. Mover (1-beta)*q_u a r_u
        r[u_idx] += (1 - beta) * q[u_idx]
        
        # 2. Calcular cantidad a pasar
        # Distribuimos la mitad, nos quedamos con la mitad (según libro para evitar oscilación)
        # Nota: El libro dice: q_u = beta * q_u / 2 (se queda la mitad)
        # Y a los vecinos se les da beta * q_u / (2 * d)
        
        residual_val = q[u_idx]
        q[u_idx] = beta * residual_val / 2.0 # Se queda la mitad
        
        share_to_neighbors = (beta * residual_val / 2.0) / deg_u
        
        # 3. Distribuir a vecinos
        for v_node in G.neighbors(u_node):
            v_idx = node_index[v_node]
            q[v_idx] += share_to_neighbors

    # Retornar como diccionario
    return {nodes[i]: r[i] for i in range(n)}

# Ejemplo de uso con el grafo del libro (Fig 10.22)
# G = nx.Graph()
# G.add_edges_from([("P1", "Sky"), ("P1", "Tree"), ("P2", "Sky"), ("P3", "Sky"), ("P3", "Tree")])
# scores = approximate_simrank(G, "P1", beta=0.8, epsilon=0.01)
```

## 8. Funciones, métodos, librerías o comandos identificados
- **Log-Likelihood:** Función objetivo a maximizar en MLE. Preferible usar logaritmo para convertir productos en sumas y evitar underflow numérico.
- **Gradient Descent:** Método de optimización para encontrar $p_C$ o $F_{xC}$.
- **Transition Matrix ($M$):** Matriz estocástica donde $M_{ij} = 1/k$ si $j$ tiene grado $k$ e $i$ es vecino.
- **Teleport Vector ($e_S$):** Vector con 1 en la posición del nodo fuente $S$ y 0 en el resto.

## 9. Snippets o plantillas reutilizables

**Cálculo de Densidad y Conductancia para selección de comunidad:**

```python
def calculate_community_metrics(G, community_nodes):
    """
    Calcula densidad y conductancia de un subconjunto de nodos.
    """
    subgraph = G.subgraph(community_nodes)
    n_nodes = len(community_nodes)
    
    # Densidad
    possible_edges = n_nodes * (n_nodes - 1) / 2
    if possible_edges == 0: density = 0
    else: density = subgraph.number_of_edges() / possible_edges
    
    # Conductancia
    # Volumen: suma de grados internos + externos (grado total en G)
    vol_c = sum(G.degree(n) for n in community_nodes)
    vol_not_c = sum(G.degree(n) for n in G.nodes() if n not in community_nodes)
    
    # Aristas cortantes: aristas con un extremo en C y otro fuera
    cut_edges = nx.edge_boundary(G, community_nodes)
    cut_size = len(list(cut_edges))
    
    volume = min(vol_c, vol_not_c)
    conductance = cut_size / volume if volume > 0 else 0
    
    return density, conductance
```

## 10. Casos de uso y aplicaciones
- **Análisis de Redes Sociales:** Identificar grupos de interés múltiple (ej: usuarios que pertenecen tanto al club de ajedrez como al de español).
- **Sistemas de Recomendación (Grafos Bipartitos):** Calcular similitud entre ítems (fotos) basándose en usuarios o etiquetas comunes, o viceversa.
- **Detección de Comunidades "Nido":** Encontrar comunidades que contienen a un usuario específico, permitiendo que un usuario pertenezca a múltiples comunidades.
- **Análisis de Etiquetado Web:** Determinar la similitud entre etiquetas (tags) basándose en su co-ocurrencia en páginas web o uso por etiquetadores.

## 11. Limitaciones, riesgos y precauciones
- **Complejidad Computacional (MLE):** El modelo de afiliación requiere optimizar tanto membresías como probabilidades, lo cual es costoso en grafos grandes.
- **Suposición de Independencia:** El modelo asume que las comunidades inducen aristas de forma independiente, lo cual puede no ser cierto en redes sociales complejas (efectos de saturación).
- **Elección de $\epsilon$:** En Simrank aproximado, un $\epsilon$ muy pequeño aumenta la precisión pero también el tiempo de cómputo. Se sugiere $\epsilon \approx 0.01 / \text{num\_edges}$.
- **Interpretación de Simrank:** Mide similitud estructural, no necesariamente similitud de contenido. Dos nodos pueden tener alto Simrank por estar en la misma posición estructural aunque sus atributos sean distintos.
- **Grafos Disconexos:** El método estándar de paseo aleatorio requiere grafos conectados (o componentes fuertemente conectados en dirigidos). El reinicio (teleport) mitiga esto parcialmente permitiendo alcanzar nodos en la misma componente.

## 12. Relaciones con otros temas del corpus
- **PageRank & Topic-Sensitive PageRank:** Simrank es una aplicación directa de PageRank sensible a tópicos donde el "tópico" es el nodo fuente.
- **MinHash / LSH:** Mientras MinHash mide similitud de conjuntos (Jaccard), Simrank mide similitud estructural en grafos.
- **Clustering Espectral:** Alternativa para encontrar comunidades (sección 10.4), pero asume particiones disjuntas, a diferencia del modelo de afiliación.
- **Gradient Descent:** Herramienta fundamental para la optimización de los modelos generativos (Capítulo 9 y 12).

## 13. Preguntas que la skill debería poder responder
1. ¿Por qué las comunidades en redes sociales reales suelen tener intersecciones densas?
2. ¿Cómo se aplica MLE para encontrar la probabilidad óptima de conexión en un modelo generativo de grafos?
3. ¿Cuál es la diferencia entre el modelo de afiliación discreto y el de fuerza de pertenencia continua?
4. ¿Por qué es necesario el reinicio (restart) en el paseo aleatorio para calcular Simrank?
5. ¿Cómo evita el algoritmo de Simrank aproximado la multiplicación matriz-vector completa?
6. ¿Qué problema resuelve distribuir solo la mitad del residual en Simrank aproximado?
7. ¿Cómo se utiliza la conductancia para determinar el límite de una comunidad?
8. ¿Qué representa el parámetro $\beta$ en el cálculo de Simrank?
9. ¿Cómo se calcula la probabilidad de una arista entre dos nodos que comparten múltiples comunidades?
10. ¿Cuál es la relación entre Simrank y PageRank?

## 14. Acciones que la skill debería poder recomendar o ejecutar
- **Seleccionar modelo de comunidad:** Recomendar el modelo de afiliación continua si se dispone de recursos para gradiente descendente, o discreto con múltiples reinicios si el espacio de búsqueda es pequeño.
- **Configurar Simrank:** Ajustar el parámetro $\epsilon$ basándose en el tamaño del grafo para equilibrar precisión y tiempo de ejecución.
- **Evaluar comunidades:** Calcular la conductancia de un conjunto de nodos para validar su cohesión.
- **Implementar detector de comunidades:** Escribir un script que use Simrank aproximado + umbral de conductancia para encontrar la comunidad de un usuario específico.
- **Optimizar verosimilitud:** Transformar una función de verosimilitud de producto a suma de logaritmos antes de derivar.

## 15. Activos finales de conocimiento en formato compacto

| Concepto | Descripción | Referencia |
| :--- | :--- | :--- |
| **Probabilidad Arista ($p_{uv}$)** | $1 - \prod (1-p_C)$ para comunidades compartidas $C$. | Sec. 10.5.3 |
| **Fuerza Pertenencia ($F_{xC}$)** | Variable continua $\ge 0$ que permite optimización global por gradiente. | Sec. 10.5.5 |
| **Simrank (RWR)** | Paseo aleatorio con probabilidad $1-\beta$ de teletransporte al nodo fuente $S$. | Sec. 10.6.2 |
| **Distribución Residual** | En Simrank aprox., se distribuye $\beta q_U / 2$ a vecinos y se retiene $\beta q_U / 2$. | Sec. 10.6.3 |
| **Conductancia ($\phi$)** | $\frac{\text{corte}(C)}{\min(\text{vol}(C), \text{vol}(\bar{C}))}$. Mide cuán aislada está la comunidad. | Sec. 10.6.5 |
| **Log-Likelihood** | Preferible sobre Likelihood directo para evitar errores de redondeo (underflow). | Sec. 10.5.5 |
| **MLE** | Principio: los parámetros que maximizan la probabilidad de observar el grafo son los correctos. | Sec. 10.5.2 |
| **Densidad de Intersección** | La densidad de aristas crece con el número de comunidades solapadas. | Sec. 10.5.1 |
| **Complejidad Simrank Aprox.** | Limitado por $1/(\epsilon(1-\beta))$ iteraciones, independiente del tamaño del grafo. | Sec. 10.6.4 |
| **Matriz de Transición** | $M_{ij} = 1/\text{grado}(j)$ si $i$ es vecino de $j$. Columnas suman 1. | Sec. 10.6.2 |
