# Parte 41 - Directed Graphs, Reachability, and SCC

## 1. Metadatos del documento
- **Libro:** Mining of Massive Datasets, 3ª ed.
- **Fragmento/Parte:** Parte 41 - Directed Graphs, Reachability, and SCC
- **Temas principales:** Grafos dirigidos, Vecindarios y Diámetro, Cierre Transitivo, Alcanzabilidad, MapReduce, Evaluación Seminaive, Componentes Fuertemente Conexos (SCC), Algoritmo ANF.
- **Tipo de contenido:** Mixto (Teoría / Algoritmo / Implementación)

## 2. Resumen técnico de alto valor
La sección aborda el análisis de propiedades estructurales de grafos masivos, específicamente la caracterización de vecindarios, el cálculo del diámetro y la computación del cierre transitivo. Se distingue entre el problema de alcanzabilidad (reachability) desde un nodo fuente y el cierre transitivo completo (todos los pares), destacando la inviabilidad computacional de este último en grafos de miles de millones de nodos debido a la cota $O(n^2)$.

Se presentan estrategias de implementación paralela mediante MapReduce. El enfoque ingenuo (BFS/TC lineal) requiere $d$ rondas (donde $d$ es el diámetro), mientras que la técnica de "Recursive Doubling" reduce esto a $\log_2 d$ rondas, aunque con mayor costo computacional por ronda. Se introduce la evaluación "Seminaive" para optimizar uniones iterativas evitando reprocesar hechos ya conocidos. Para grafos web, se propone la reducción del grafo mediante la identificación y colapso de Componentes Fuertemente Conexos (SCC). Finalmente, se detalla el algoritmo ANF (Approximate Neighborhood Function) que utiliza la técnica de Flajolet-Martin para estimar tamaños de vecindarios en espacio reducido, evitando el almacenamiento explícito de nodos.

## 3. Conceptos y definiciones clave
- **Grafo Dirigido:** Conjunto de nodos y arcos $u \rightarrow v$ (origen $u$, destino $v$). Un grafo no dirigido se representa como dos arcos por arista.
- **Camino:** Secuencia de nodos $v_0, v_1, \dots, v_k$ donde existen arcos $v_i \rightarrow v_{i+1}$. La longitud es $k$ (número de arcos).
- **Vecindario $N(v, d)$:** Conjunto de nodos alcanzables desde $v$ mediante caminos de longitud a lo sumo $d$. $N(v, 0) = \{v\}$.
- **Perfil del Vecindario:** Secuencia de tamaños $|N(v, 1)|, |N(v, 2)|, \dots$. Sirve para comparar la centralidad de nodos.
- **Diámetro:** El menor entero $d$ tal que para todo par de nodos $u, v$ existe un camino de longitud $\le d$. Solo definido en grafos fuertemente conexos (dirigidos) o conexos (no dirigidos).
- **Cierre Transitivo:** Conjunto de pares $(u, v)$ tales que existe un camino de longitud $\ge 1$ desde $u$ hasta $v$. Se denota $Path(u, v)$.
- **Alcanzabilidad (Reachability):** Problema de encontrar $N(v, \infty)$ para un nodo $v$ específico.
- **Evaluación Seminaive:** Optimización en algoritmos iterativos donde solo se utilizan los hechos nuevos descubiertos en la ronda anterior para realizar la unión, evitando trabajo redundante.
- **Componente Fuertemente Conexo (SCC):** Conjunto maximal de nodos $S$ donde cada nodo alcanza a todos los demás dentro de $S$.

## 4. Principios, reglas y heurísticas
- **Cálculo del Diámetro:** El diámetro es $\max_v (d(v))$, donde $d(v)$ es el menor radio tal que $|N(v, d)| = |N(v, d+1)|$. Si el grafo no es fuertemente conexo, no tiene diámetro finito.
- **Trade-off Rondas vs. Costo por Ronda:**
    - Algoritmos lineales (BFS/TC lineal): $d$ rondas, menor costo por ronda.
    - Recursive Doubling: $\log_2 d$ rondas, mayor costo por ronda (joins más grandes).
- **Regla de Optimización Seminaive:** Un hecho $Path(u, w)$ solo genera nueva información en la ronda inmediatamente posterior a su descubrimiento. Unir hechos antiguos con arcos ya procesados no aporta nuevos nodos.
- **Reducción de Grafos:** Los nodos dentro de un SCC son equivalentes para el cierre transitivo; colapsarlos reduce drásticamente el tamaño del problema.
- **Estimación ANF:** El tamaño estimado de un conjunto es $2^R$, donde $R$ es la longitud máxima de la cola de ceros (tail length) en los hashes de los miembros del conjunto.

## 5. Procedimientos, métodos y workflows

### 5.1 Alcanzabilidad vía MapReduce (Iterativo)
1.  **Inicialización:** $Reach(X) = \{v\}$ (nodo origen).
2.  **Iteración:**
    - Join: $Reach(X) \bowtie Arc(X, Y)$.
    - Proyección sobre $Y$ y Unión con $Reach$ anterior.
    - Eliminación de duplicados.
3.  **Parada:** Cuando $Reach$ no cambia.

### 5.2 Cierre Transitivo Lineal (Seminaive)
1.  **Inicialización:** $Path = \emptyset$, $NewPath = Arc$.
2.  **Iteración:**
    - Insertar $NewPath$ en $Path$.
    - Calcular nuevo $NewPath$: Join entre $NewPath(X, Y)$ y $Arc(Y, Z)$.
    - Query SQL: `SELECT DISTINCT NewPath.X, Arc.Y FROM NewPath, Arc WHERE Arc.X = NewPath.Y;`
3.  **Parada:** $NewPath \subseteq Path$.

### 5.3 Cierre Transitivo por Recursive Doubling (Seminaive)
1.  **Inicialización:** $Path = \emptyset$, $NewPath = Arc$.
2.  **Iteración:**
    - Insertar $NewPath$ en $Path$.
    - Calcular nuevo $NewPath$: Join entre $Path(X, Y)$ y $NewPath(Y, Z)$.
    - Query SQL: `SELECT DISTINCT Path.X, NewPath.Y FROM Path, NewPath WHERE NewPath.X = Path.Y;`
3.  **Resultado:** Duplica la longitud de caminos conocidos en cada ronda.

### 5.4 Smart Transitive Closure
Evita descubrir el mismo camino múltiples veces dividiendo el camino en "cabeza" (potencia de 2) y "cola".
1.  Mantener $Q(X,Y)$ (caminos de longitud exacta $2^i$) y $Path(X,Y)$ (caminos de longitud $\le 2^{i+1}-1$).
2.  **Paso 1:** $Q_{new} = Q \bowtie Q$ (longitud $2^{i+1}$).
3.  **Paso 2:** Restar $Path$ a $Q_{new}$ para asegurar que sean caminos mínimos de esa longitud exacta.
4.  **Paso 3:** $Result = Q_{new} \bowtie Path$.
5.  **Paso 4:** Actualizar $Path$ uniendo $Result$, $Q_{new}$ y $Path$ viejo.

### 5.5 Reducción de Grafo (SCC)
1.  Seleccionar nodo $v$ aleatorio.
2.  Calcular $N_G(v, \infty)$ (hacia adelante).
3.  Calcular $N_{G'}(v, \infty)$ (hacia atrás en el grafo con arcos invertidos).
4.  $SCC = N_G(v, \infty) \cap N_{G'}(v, \infty)$.
5.  Colapsar el SCC en un único nodo representativo.

### 5.6 Algoritmo ANF (Approximate Neighborhood Function)
1.  Definir $K$ funciones hash $h_i$.
2.  Para cada nodo $v$ y radio $d$, mantener $R_i(v, d)$ (máxima longitud de cola de ceros en $N(v, d)$).
3.  **Base:** $R_i(v, 0)$ es la cola de $h_i(v)$.
4.  **Inducción:** $R_i(v, d+1) = \max(R_i(v, d), \max_{u: v \rightarrow u} R_i(u, d))$.
5.  **Estimación:** Combinar los $R_i$ (promedios de grupos, luego mediana) para estimar $|N(v, d)|$.

## 6. Problemas comunes y soluciones
- **Problema:** El cierre transitivo completo es intratable ($O(n^2)$ pares) para grafos masivos (ej. Web).
    - **Solución:** Calcular alcanzabilidad por demanda o reducir el grafo mediante SCCs antes de calcular el cierre.
- **Problema:** Recursive Doubling descubre el mismo hecho $Path(x, y)$ múltiples veces (ej. uniendo diferentes segmentos del mismo camino).
    - **Solución:** Utilizar *Smart Transitive Closure* que fuerza una estructura de cabeza/cola específica para evitar redundancia.
- **Problema:** El diámetro $d$ puede ser muy grande (cientos) en ciertos grafos (ej. blogs lineales), haciendo inviables los algoritmos lineales.
    - **Solución:** Usar Recursive Doubling ($\log_2 d$ rondas) o aproximaciones (ANF).
- **Problema:** Almacenar los conjuntos de vecinos $N(v, d)$ explícitamente consume demasiada memoria.
    - **Solución:** Usar ANF para almacenar solo estimaciones (valores $R$) en lugar de listas de nodos.

## 7. Implementación técnica y generación de código

### Pseudocódigo: Evaluación Seminaive para Cierre Transitivo Lineal

```pseudocode
# Basado en Sección 10.8.6
Algoritmo LinearTransitiveClosure(Arc):
  Path = vacío
  NewPath = Arc
  
  Mientras NewPath no sea subconjunto de Path:
    # Paso 1: Mover nuevos hallazgos a Path
    Path = Path U NewPath
    
    # Paso 2: Calcular siguientes nuevos caminos
    # Query: SELECT DISTINCT NewPath.X, Arc.Y FROM NewPath, Arc WHERE Arc.X = NewPath.Y
    Temp = Join(NewPath, Arc) sobre atributo intermedio Y
    NewPath = Proyección(Temp, X, Y) - Path
    
  Retornar Path
```

### Implementación Python: Algoritmo ANF (Concepto simplificado)

```python
import numpy as np

def tail_length(value, max_bits=64):
    """Calcula el número de ceros al final de la representación binaria."""
    if value == 0: return max_bits
    binary = bin(value)[2:][::-1] # Invertir para contar ceros al inicio
    return binary.find('1')

def anf_step(graph, R_prev, hash_functions):
    """
    Realiza un paso de expansión del vecindario usando ANF.
    graph: dict {node: [neighbors]}
    R_prev: dict {node: [tail_lengths]} para cada función hash
    hash_functions: lista de funciones hash
    """
    nodes = list(graph.keys())
    k = len(hash_functions)
    R_next = {v: list(R_prev[v]) for v in nodes}
    
    # Iterar sobre arcos: para cada v->u, propagar R
    for v in nodes:
        for u in graph[v]:
            for i in range(k):
                # R_i(v, d+1) = max(R_i(v, d), R_i(u, d))
                R_next[v][i] = max(R_next[v][i], R_prev[u][i])
    return R_next

def estimate_size(R_values):
    """Estima el tamaño del conjunto usando la técnica de Flajolet-Martin."""
    # Promedio de grupos y mediana (simplificado aquí como promedio directo)
    return 2 ** np.mean(R_values)

# Ejemplo de uso conceptual
# h = [lambda x: hash(str(x) + str(i)) for i in range(20)]
# R_init = {v: [tail_length(h_i(v)) for h_i in h] for v in nodes}
# R_d1 = anf_step(graph, R_init, h)
```

## 8. Funciones, métodos, librerías o comandos identificados
- **SQL `SELECT DISTINCT ... JOIN`:** Operación fundamental para la expansión de vecindarios en entornos paralelos.
- **MapReduce Join (Sección 2.3.7):** Mecanismo subyacente para implementar las consultas SQL de unión.
- **Flajolet-Martin (Sección 4.4.2):** Técnica de streaming para estimar elementos distintos, base del algoritmo ANF.
- **Operación `max(R_i(v), R_i(u))`:** Función de agregación clave en ANF para propagar estimaciones de vecindario sin almacenar conjuntos.

## 9. Snippets o plantillas reutilizables

### SQL para Recursive Doubling (Seminaive)
```sql
-- Iteración para calcular NewPath
SELECT DISTINCT Path.X, NewPath.Y 
FROM Path, NewPath 
WHERE NewPath.X = Path.Y;

-- Actualización de Path (Unión)
-- En un entorno real, esto sería una operación de unión de conjuntos
```

### SQL para Smart Transitive Closure (Paso de unión)
```sql
-- Paso 3: Unir Q (caminos de longitud potencia de 2) con Path
SELECT DISTINCT Q.X, Path.Y 
FROM Q, Path 
WHERE Q.Y = Path.X;
```

## 10. Casos de uso y aplicaciones
- **Análisis de Redes Sociales:** Determinar la centralidad de un usuario comparando perfiles de vecindario. Un perfil que domina a otros indica mayor centralidad.
- **Web Mining:** Estructura "bowtie" de la web. Identificación del SCC central, componentes "in" y "out".
- **Sistemas de Recomendación:** Identificar usuarios alcanzables dentro de cierta distancia social.
- **Detección de Comunidades:** Uso de la reducción de grafos para simplificar la estructura antes de aplicar algoritmos de clustering.

## 11. Limitaciones, riesgos y precauciones
- **Cierre Transitivo Completo:** Imposible de almacenar para $n=10^9$ (requeriría $10^{18}$ pares).
- **Complejidad Recursive Doubling:** Aunque reduce rondas, el costo computacional por ronda es $O(n^3)$ en el peor caso, comparado con $O(ne)$ del lineal. Puede ser ineficiente para grafos dispersos con diámetro pequeño.
- **Suposición de Diámetro Pequeño:** Los algoritmos de alcanzabilidad asumen "Six Degrees of Separation". En estructuras lineales (ej. cadenas de blogs, tutoriales secuenciales), el diámetro puede ser cientos, degradando el rendimiento de BFS.
- **Aproximación ANF:** Es una estimación probabilística. La precisión depende del número de funciones hash y el tamaño del bit string.

## 12. Relaciones con otros temas del corpus
- **MinHashing / LSH:** Relación conceptual con Flajolet-Martin (estimación de similitud/distintos).
- **PageRank (Capítulo 5):** La estructura del grafo web (SCC central) es un prerequisito para entender la convergencia y el "bowtie model".
- **MapReduce (Capítulo 2):** Implementación práctica de las uniones y agrupaciones descritas.
- **Grafos Sociales (Capítulo 10 previo):** Este fragmento profundiza en la estructura de caminos, mientras que secciones anteriores tratan sobre comunidades y aristas.

## 13. Preguntas que la skill debería poder responder
1.  ¿Cuál es la diferencia fundamental entre el problema de alcanzabilidad y el cálculo del cierre transitivo en términos de complejidad espacial?
2.  ¿Cómo reduce la técnica de "Recursive Doubling" el número de rondas de MapReduce necesarias?
3.  ¿Qué problema resuelve la evaluación "Seminaive" en los algoritmos iterativos de grafos?
4.  ¿Por qué es útil colapsar Componentes Fuertemente Conexos (SCC) antes de calcular el cierre transitivo?
5.  ¿Cómo se aplica la técnica de Flajolet-Martin en el algoritmo ANF para estimar el tamaño de los vecindarios?
6.  ¿Qué representa el diámetro de un grafo y cómo se calcula a partir de los vecindarios?
7.  ¿Cuándo es preferible usar Smart Transitive Closure sobre Recursive Doubling estándar?

## 14. Acciones que la skill debería poder recomendar o ejecutar
- **Seleccionar algoritmo de cierre transitivo:** Recomendar Recursive Doubling si el diámetro es grande y el grafo es denso; Linear TC si el grafo es disperso y el diámetro pequeño.
- **Optimizar consultas iterativas:** Aplicar el patrón Seminaive automáticamente en consultas SQL iterativas para evitar recomputación.
- **Estimar recursos:** Calcular si es factible almacenar el cierre transitivo basándose en $n$ (si $n > 10^6$, recomendar no calcular el cierre completo).
- **Implementar ANF:** Proveer el código para estimar el tamaño de la "bola de nieve" social de un usuario sin almacenar IDs.

## 15. Activos finales de conocimiento en formato compacto

| Concepto | Descripción | Referencia |
| :--- | :--- | :--- |
| **Vecindario $N(v, d)$** | Nodos alcanzables desde $v$ en $\le d$ pasos. | Sec 10.8.1 |
| **Diámetro** | Mínimo $d$ donde $N(v, d)$ cubre todo el grafo conexo. | Sec 10.8.2 |
| **Evaluación Seminaive** | Optimización: unir solo hechos nuevos en cada iteración. | Sec 10.8.5 |
| **Recursive Doubling** | Estrategia para reducir rondas a $O(\log_2 d)$ uniendo Path consigo mismo. | Sec 10.8.7 |
| **Smart TC** | Variante de Recursive Doubling que evita descubrir el mismo camino múltiples veces. | Sec 10.8.8 |
| **SCC Reduction** | Colapsar componentes conexas para reducir el tamaño del grafo antes del análisis. | Sec 10.8.10 |
| **ANF** | Algoritmo para aproximar tamaño de vecindarios usando hashes y colas de ceros. | Sec 10.8.11 |
| **Complejidad Linear TC** | $O(ne)$ computación total, $d$ rondas. | Sec 10.8.9 |
| **Complejidad Recursive D.** | $O(n^3)$ computación total, $\log_2 d$ rondas. | Sec 10.8.9 |
| **Tail Length ($R$)** | Número de ceros al final de un hash; usado en ANF para estimar $2^R$ elementos. | Sec 10.8.11 |


