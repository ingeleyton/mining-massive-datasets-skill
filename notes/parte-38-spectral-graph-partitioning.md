# Parte 38 - Spectral Graph Partitioning

## 1. Metadatos del documento
- **Libro:** Mining of Massive Datasets, 3ª ed.
- **Fragmento/Parte:** Parte 38 - Spectral Graph Partitioning
- **Temas principales:** Partición espectral de grafos, Matriz Laplaciana, Corte normalizado, Valores propios, Comunidades solapadas, Estimación de máxima verosimilitud (MLE)
- **Tipo de contenido:** Teoría / Algoritmo

## 2. Resumen técnico de alto valor
El fragmento aborda la partición de grafos sociales mediante métodos espectrales, superando las limitaciones de minimizar el "corte" bruto (que favorece particiones triviales y desbalanceadas). Se introduce el **corte normalizado** como métrica que equilibra la minimización de aristas entre particiones con el tamaño (volumen) de las mismas. La solución se formaliza mediante álgebra lineal: la **Matriz Laplaciana** ($L = D - A$) del grafo. Se demuestra que el segundo vector propio más pequeño (asociado al segundo valor propio menor, distinto de cero) de $L$ proporciona la partición óptima: los nodos con componentes positivas se asignan a un grupo y los negativos al otro. Se discuten variantes como el uso de umbrales distintos a cero o múltiples vectores propios para particiones múltiples. Finalmente, se introduce brevemente el concepto de comunidades solapadas y la necesidad de MLE para modelarlas, aunque el contenido se interrumpe.

## 3. Conceptos y definiciones clave
- **Cut (Corte):** Conjunto de aristas que conectan nodos en dos conjuntos disjuntos $S$ y $T$. Minimizar el tamaño del corte es un objetivo ingenuo que lleva a particiones desbalanceadas.
- **Normalized Cut (Corte Normalizado):** Métrica que penaliza particiones desbalanceadas. Se define como:
  $$ \text{Normalized Cut}(S, T) = \frac{\text{Cut}(S, T)}{\text{Vol}(S)} + \frac{\text{Cut}(S, T)}{\text{Vol}(T)} $$
- **Volume (Volumen) $\text{Vol}(S)$:** Número de aristas con al menos un extremo en el conjunto de nodos $S$.
- **Adjacency Matrix (Matriz de Adyacencia $A$):** Matriz cuadrada donde $A_{ij} = 1$ si existe arista entre $i$ y $j$, y $0$ en caso contrario.
- **Degree Matrix (Matriz de Grado $D$):** Matriz diagonal donde la entrada $D_{ii}$ es el grado del nodo $i$.
- **Laplacian Matrix (Matriz Laplaciana $L$):** Definida como $L = D - A$. Es simétrica, sus filas y columnas suman cero, y los elementos fuera de la diagonal son $-1$ si hay conexión y $0$ si no.
- **Second-Smallest Eigenvalue (Segundo valor propio más pequeño):** También conocido como la conectividad algebraica. Su vector propio asociado minimiza la expresión cuadrática $\mathbf{x}^T L \mathbf{x}$ sujeto a restricciones de ortogonalidad y norma.
- **Maximum-Likelihood Estimation (MLE):** Técnica de modelado para estimar parámetros que maximizan la probabilidad de observar los datos generados por un modelo propuesto.

## 4. Principios, reglas y heurísticas
- **Regla de balanceo:** Al particionar un grafo, no basta con minimizar el número de aristas cortadas; se debe asegurar que los conjuntos resultantes tengan tamaños comparables.
- **Principio espectral:** El vector propio correspondiente al segundo valor propio más pequeño de la Matriz Laplaciana codifica la partición óptima del grafo en términos de corte normalizado.
- **Interpretación del signo:** En el vector propio óptimo, nodos conectados tienden a tener el mismo signo para minimizar $(x_i - x_j)^2$. La partición se realiza asignando nodos con componente positiva a un grupo y negativa al otro.
- **Restricción de ortogonalidad:** El vector de partición $\mathbf{x}$ debe ser ortogonal al vector $\mathbf{1}$ (vector de unos), lo que implica que la suma de sus componentes sea 0, forzando la existencia de valores positivos y negativos.
- **Densidad en intersecciones:** En comunidades solapadas, se espera que la densidad de aristas sea mayor en la intersección de múltiples comunidades que en una sola comunidad.

## 5. Procedimientos, métodos y workflows
**Método de Partición Espectral (Spectral Partitioning):**
1.  **Construcción de Matrices:** Dado un grafo, construir la Matriz de Adyacencia $A$ y la Matriz de Grado $D$.
2.  **Cálculo de Laplaciana:** Calcular $L = D - A$.
3.  **Descomposición Espectral:** Calcular valores y vectores propios de $L$.
4.  **Selección de Vector:** Identificar el vector propio correspondiente al segundo valor propio más pequeño (el primero es siempre 0 con vector $\mathbf{1}$).
5.  **Partición:** Asignar nodos a conjuntos $S$ y $T$ según el signo de su componente en el vector propio seleccionado ($x_i > 0 \to S$, $x_i < 0 \to T$).
6.  **Refinamiento (Opcional):** Ajustar el umbral de corte (en lugar de 0) o aplicar recursivamente para más de dos particiones.

## 6. Problemas comunes y soluciones
- **Problema: Partición trivial.** Minimizar el corte bruto produce particiones como un solo nodo aislado vs. el resto del grafo.
    - **Solución:** Usar el corte normalizado que pondera por el volumen de los conjuntos.
- **Problema: Partición desbalanceada por umbral fijo.** El umbral en 0 puede generar grupos de tamaños muy diferentes.
    - **Solución:** Ajustar el umbral o utilizar múltiples vectores propios para particiones más complejas.
- **Problema: Partición en más de dos grupos.** El método base es bipartito.
    - **Solución:** Aplicar recursivamente el método a los subgrafos resultantes o usar múltiples vectores propios (ej. segundo y tercero) para dividir en $2^m$ grupos.

## 7. Implementación técnica y generación de código

```pseudocode
# Algoritmo de Partición Espectral Básico
Entrada: Grafo G = (V, E)
Salida: Dos conjuntos de nodos S, T

1. Construir Matriz de Adyacencia A
2. Construir Matriz de Grado D (diagonal con grados de nodos)
3. Calcular Matriz Laplaciana L = D - A
4. Calcular valores propios y vectores propios de L
5. Ordenar valores propios de menor a mayor (ignorar el primero que es 0)
6. Seleccionar el vector propio v2 asociado al segundo valor propio más pequeño
7. Para cada nodo i en V:
    Si v2[i] >= 0:
        Agregar i a S
    Sino:
        Agregar i a T
8. Retornar S, T
```

```python
import numpy as np
import networkx as nx

def spectral_partition(edges):
    """
    Implementación básica de partición espectral basada en el fragmento.
    Entrada: lista de tuplas (nodo1, nodo2)
    Salida: tuple (set_S, set_T)
    """
    # Crear grafo y asegurar orden de nodos
    G = nx.Graph()
    G.add_edges_from(edges)
    nodes = sorted(G.nodes())
    n = len(nodes)
    
    # 1. Matriz de Adyacencia (A)
    A = nx.adjacency_matrix(G, nodelist=nodes).toarray()
    
    # 2. Matriz de Grado (D)
    degrees = np.array([G.degree(n) for n in nodes])
    D = np.diag(degrees)
    
    # 3. Matriz Laplaciana (L = D - A)
    L = D - A
    
    # 4. Valores y vectores propios
    # np.linalg.eigh devuelve valores propios en orden ascendente para matrices simétricas
    eigenvalues, eigenvectors = np.linalg.eigh(L)
    
    # 5. Seleccionar el segundo vector propio (Fiedler vector)
    # El índice 0 es el valor propio ~0. El índice 1 es el segundo más pequeño.
    fiedler_vector = eigenvectors[:, 1]
    
    # 6. Partición por signo
    set_S = {nodes[i] for i, val in enumerate(fiedler_vector) if val >= 0}
    set_T = {nodes[i] for i, val in enumerate(fiedler_vector) if val < 0}
    
    return set_S, set_T

# Ejemplo basado en Fig 10.16 del libro
edges_example = [(1,2), (1,3), (1,4), (2,3), (3,6), (4,5), (4,6), (5,6)]
s, t = spectral_partition(edges_example)
print(f"Grupo S: {s}")
print(f"Grupo T: {t}")
```

## 8. Funciones, métodos, librerías o comandos identificados
- **Matriz Laplaciana ($L$):** Herramienta central para análisis espectral. Propiedad clave: filas y columnas suman 0.
- **Vector de Fiedler:** Nombre técnico del vector propio asociado al segundo valor propio más pequeño de la Laplaciana. Utilizado para la partición.
- **`np.linalg.eigh` (Python/NumPy):** Función recomendada para calcular valores propios de matrices simétricas (como la Laplaciana) de manera eficiente y ordenada.

## 9. Snippets o plantillas reutilizables

```python
def calculate_normalized_cut(graph, set_s, set_t):
    """
    Calcula el corte normalizado según la fórmula del libro.
    """
    # Vol(S): Aristas con al menos un extremo en S
    vol_s = sum(1 for u, v in graph.edges() if u in set_s or v in set_s)
    # Vol(T)
    vol_t = sum(1 for u, v in graph.edges() if u in set_t or v in set_t)
    
    # Cut(S, T): Aristas que conectan S y T
    cut_size = sum(1 for u, v in graph.edges() if (u in set_s and v in set_t) or (u in set_t and v in set_s))
    
    if vol_s == 0 or vol_t == 0:
        return float('inf')
        
    norm_cut = (cut_size / vol_s) + (cut_size / vol_t)
    return norm_cut
```

## 10. Casos de uso y aplicaciones
- **Redes Sociales:** Identificación de comunidades (ej. clubes de ajedrez vs. clubes de español) donde los miembros no son mutuamente excluyentes.
- **Diseño de VLSI:** Partición de circuitos en bloques con mínimas conexiones entre ellos.
- **Segmentación de Imágenes:** Tratar píxeles como nodos y particionar para separar objetos del fondo.
- **Detección de anomalías:** Nodos que no encajan claramente en ninguna partición o quedan aislados en cortes triviales.

## 11. Limitaciones, riesgos y precauciones
- **Complejidad computacional:** El cálculo de valores propios es costoso ($O(n^3)$ para métodos directos), aunque existen métodos iterativos para grafos grandes dispersos.
- **Partición binaria:** El método espectral básico solo divide en dos grupos. Para $k$ grupos se requiere recursión o métodos más avanzados (k-way spectral clustering).
- **Tamaño de particiones:** La partición por signo no garantiza tamaños exactamente iguales, aunque tiende a balancearlos.
- **[VACÍO]:** El fragmento sobre MLE y comunidades solapadas está incompleto, por lo que no se puede documentar el algoritmo completo para solapamiento.

## 12. Relaciones con otros temas del corpus
- **Teoría de Grafos:** Conceptos de grado, adyacencia, caminos.
- **Álgebra Lineal:** Valores propios, vectores propios, matrices simétricas, ortogonalidad.
- **PageRank (Capítulo 5):** Contraste importante. PageRank usa el vector propio *principal* (mayor valor propio) de la matriz de transición. La partición espectral usa el *segundo menor* valor propio de la Laplaciana.
- **Clustering (Capítulo 7):** La partición de grafos es una forma de clustering jerárquico o particional basado en estructura de grafo.

## 13. Preguntas que la skill debería poder responder
1. ¿Por qué minimizar el tamaño del corte ("cut size") no es una estrategia adecuada para particionar grafos sociales?
2. ¿Cómo se define la Matriz Laplaciana de un grafo y cuál es su relación con la matriz de adyacencia y de grado?
3. ¿Qué representa el segundo valor propio más pequeño de la Matriz Laplaciana y cómo se utiliza para particionar un grafo?
4. ¿Cuál es la fórmula del corte normalizado y qué problema resuelve respecto al corte simple?
5. ¿Cómo se puede utilizar el vector propio asociado al segundo valor propio para asignar nodos a comunidades?
6. ¿Qué estrategias existen para extender la partición espectral a más de dos grupos?
7. ¿Por qué el vector propio asociado al valor propio 0 es el vector de unos?
8. ¿Qué es la Estimación de Máxima Verosimilitud (MLE) en el contexto de grafos sociales?

## 14. Acciones que la skill debería poder recomendar o ejecutar
- Calcular la Matriz Laplaciana dado un conjunto de aristas.
- Implementar la partición de un grafo pequeño utilizando el vector de Fiedler.
- Evaluar la calidad de una partición existente calculando su corte normalizado.
- Decidir entre usar un corte simple o normalizado basándose en el balance deseado de los clústeres.
- Sugerir el uso de múltiples vectores propios si se requieren más de dos comunidades.

## 15. Activos finales de conocimiento en formato compacto
| Concepto | Descripción | Referencia |
|---|---|---|
| **Corte Normalizado** | Métrica $\frac{Cut}{Vol(S)} + \frac{Cut}{Vol(T)}$ que balancea tamaño de corte y tamaño de particiones. | Sec 10.4.2 |
| **Matriz Laplaciana ($L$)** | $L = D - A$. Matriz simétrica clave para partición espectral. Suma de filas/columnas es 0. | Sec 10.4.3 |
| **Vector de Fiedler** | Vector propio del 2º valor propio más pequeño de $L$. Sus signos definen la partición óptima. | Sec 10.4.4 |
| **Valor Propio 0** | Siempre presente en $L$. Vector propio asociado es $\mathbf{1}$ (todos unos). | Sec 10.4.4 |
| **Minimización Cuadrática** | $x^T L x = \sum_{(i,j) \in E} (x_i - x_j)^2$. Base teórica de la partición espectral. | Sec 10.4.4 |
| **Partición Recursiva** | Técnica para obtener $k > 2$ particiones aplicando el método iterativamente. | Sec 10.4.5 |
| **Comunidades Solapadas** | Modelo donde nodos pertenecen a múltiples comunidades; la densidad de aristas crece en intersecciones. | Sec 10.5.1 |
| **MLE** | Método para ajustar parámetros de un modelo generativo de grafo a datos observados. | Sec 10.5.2 |


