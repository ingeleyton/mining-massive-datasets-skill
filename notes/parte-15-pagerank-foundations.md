# Parte 15 - PageRank Foundations

## 1. Metadatos del documento
- **Libro:** Mining of Massive Datasets, 3ª ed.
- **Fragmento/Parte:** Parte 15 - PageRank Foundations
- **Temas principales:** PageRank, Matrices de Transición, Procesos de Markov, Spider Traps, Dead Ends, Taxation/Teleportación, Eficiencia computacional.
- **Tipo de contenido:** Teoría / Algoritmo

## 2. Resumen técnico de alto valor
El capítulo introduce PageRank como algoritmo fundamental para medir la importancia de páginas web, superando las limitaciones de los primeros motores de búsqueda vulnerables al *term spam*. PageRank modela el comportamiento de un "surfer aleatorio" que navega el grafo de la web siguiendo enlaces. Matemáticamente, se define como el vector estacionario de una cadena de Markov descrita por la matriz de transición $M$, donde $M_{ij} = 1/k$ si la página $j$ tiene $k$ enlaces salientes y uno apunta a $i$.
El algoritmo básico falla en estructuras reales de la web (modelo "bowtie"): *Dead Ends* (páginas sin enlaces salientes que disipan probabilidad) y *Spider Traps* (grupos de páginas que atrapan al surfer). La solución canónica es el método de "taxation" o teletransportación: en cada paso, el surfer tiene una probabilidad $1-\beta$ (típicamente $0.1-0.2$) de saltar a una página aleatoria en lugar de seguir un enlace. Esto modifica la ecuación iterativa a $v' = \beta Mv + (1-\beta)e/n$, garantizando convergencia y robustez frente a trampas. La implementación a escala requiere manejo de matrices dispersas y optimización en MapReduce debido al tamaño del grafo web.

## 3. Conceptos y definiciones clave
- **Term Spam:** Técnica maliciosa para engañar a motores de búsqueda mediante la inclusión repetida o invisible de términos irrelevantes en una página.
- **PageRank:** Función que asigna un número real a cada página web representando su importancia. Se calcula como la probabilidad límite de que un surfer aleatorio esté en esa página.
- **Surfer Aleatorio (Random Surfer):** Modelo de usuario que navega la web eligiendo enlaces salientes al azar. Si una página tiene $k$ enlaces, el surfer elige cada uno con probabilidad $1/k$.
- **Matriz de Transición ($M$):** Matriz de $n \times n$ donde el elemento $m_{ij}$ es la probabilidad de transitar de la página $j$ a la $i$. Es estocástica por columnas (cada columna suma 1) si no hay *dead ends*.
- **Dead End:** Página sin enlaces salientes. Causa que la matriz sea subestocástica y que la probabilidad total "se escape" del sistema, llevando el PageRank a 0 en iteraciones sucesivas.
- **Spider Trap:** Conjunto de nodos con enlaces salientes pero sin aristas hacia el resto del grafo. El surfer aleatorio queda atrapado, acumulando todo el PageRank en ese subconjunto.
- **Taxation / Teleportación:** Modificación del modelo básico donde el surfer tiene una probabilidad $1-\beta$ de saltar a una página aleatoria cualquiera. Soluciona *dead ends* y *spider traps*.
- **Componente Fuertemente Conexo (SCC):** Subgrafo donde existe un camino entre cualquier par de nodos. Estructura central de la web ("bowtie").

## 4. Principios, reglas y heurísticas
- **Votación implícita:** Un enlace de la página $A$ a la $B$ se interpreta como un voto de $A$ hacia la importancia de $B$.
- **Independencia del contenido:** PageRank evalúa la estructura del grafo, no el contenido textual (aunque Google combina ambos).
- **Convergencia:** La iteración $v_{i+1} = M v_i$ converge a un vector propio principal si el grafo es fuertemente conexo y no tiene *dead ends*.
- **Valor de $\beta$:** Típicamente se elige entre $0.8$ y $0.9$. Un $\beta$ más bajo hace al algoritmo más robusto frente a trampas pero menos sensible a la estructura real del grafo.
- **Iteraciones necesarias:** Para la web real, se requieren entre 50 y 75 iteraciones para converger a la precisión del punto flotante.
- **Eliminación recursiva:** Ante *dead ends*, se pueden eliminar nodos recursivamente, resolver el grafo reducido y calcular sus valores hacia atrás, aunque el método de *taxation* es más general y simple.

## 5. Procedimientos, métodos y workflows

### Cálculo de PageRank Básico (Sin Taxation)
1.  **Inicialización:** Crear vector $v_0$ con $1/n$ en cada componente.
2.  **Iteración:** Calcular $v_{i+1} = M v_i$.
3.  **Convergencia:** Repetir hasta que el cambio en el vector sea insignificante.
4.  **Precondición:** El grafo debe ser fuertemente conexo y sin *dead ends* (raro en la web real).

### Cálculo de PageRank con Taxation (Método Estándar)
1.  **Definición:** $\beta \in [0.8, 0.9]$, $n$ número de nodos, $e$ vector de unos.
2.  **Iteración:** Aplicar la fórmula $v' = \beta Mv + (1-\beta)e/n$.
3.  **Manejo de Dead Ends:** Si existen *dead ends*, la suma de componentes de $v$ puede ser menor que 1, pero el término de teletransportación $(1-\beta)e/n$ reintroduce probabilidad, evitando el colapso a 0.
4.  **Convergencia:** Iterar hasta estabilizar el vector.

### Manejo de Dead Ends por Eliminación Recursiva
1.  Identificar y eliminar nodos sin sucesores (*dead ends*).
2.  Repetir el paso 1 hasta que no queden *dead ends* (el grafo resultante puede ser el SCC).
3.  Calcular PageRank para el grafo reducido.
4.  Restaurar nodos eliminados en orden inverso: el PageRank de un nodo restaurado es la suma de los PageRanks de sus predecesores dividido por su número de sucesores.

## 6. Problemas comunes y soluciones
- **Problema:** *Term Spam* (repetir palabras clave para manipular relevancia).
    - **Solución:** Usar PageRank (importancia basada en enlaces) y analizar el texto de los enlaces entrantes (anchor text), que es más difícil de falsificar para el dueño de la página.
- **Problema:** *Dead Ends* (la probabilidad desaparece, $v \to 0$).
    - **Solución:** Método de *taxation* (teletransportación) o eliminación recursiva de nodos.
- **Problema:** *Spider Traps* (el PageRank se concentra en un subconjunto de nodos).
    - **Solución:** Método de *taxation*. Al permitir saltos aleatorios, el surfer eventualmente escapa de la trampa.
- **Problema:** Escalabilidad computacional (matrices de miles de millones de nodos).
    - **Solución:** Usar representación dispersa de la matriz $M$ (solo elementos no nulos) y algoritmos iterativos en lugar de eliminación Gaussiana ($O(n^3)$ es inviable).

## 7. Implementación técnica y generación de código

```pseudocode
# Algoritmo: PageRank Iterativo con Taxation
# Entrada: Matriz de transición M (dispersa), factor beta, iteraciones max_iter
# Salida: Vector v de PageRank

Función PageRank(M, beta, max_iter):
    n = tamaño_filas(M)
    v = vector_unos(n) / n  # Inicialización uniforme
    teleport = (1 - beta) / n

    Para i en rango(max_iter):
        v_nuevo = beta * (M @ v) + teleport * vector_unos(n)
        # Nota: Si M tiene dead ends, la suma de columnas no es 1.
        # La fórmula anterior asume que se maneja la probabilidad perdida implícitamente
        # o que M ha sido normalizada para tratar dead ends como saltos aleatorios.
        # Según el libro, la fórmula v' = beta*Mv + (1-beta)e/n funciona incluso con dead ends.
        
        Si convergencia(v, v_nuevo):
            retornar v_nuevo
        v = v_nuevo
    
    retornar v
```

```python
import numpy as np

def compute_pagerank(M, beta=0.85, max_iter=100, tol=1e-6):
    """
    Calcula el vector PageRank usando el método de taxation.
    
    Args:
        M (np.array): Matriz de transición (columnas suman 1, excepto dead ends).
        beta (float): Factor de amortiguación (probabilidad de seguir enlace).
        max_iter (int): Número máximo de iteraciones.
        tol (float): Tolerancia para convergencia.
        
    Returns:
        np.array: Vector de PageRank normalizado.
    """
    n = M.shape[1]
    # Vector inicial: probabilidad uniforme
    v = np.ones(n) / n
    
    # Componente de teletransportación
    teleport = (1 - beta) / n
    
    for i in range(max_iter):
        v_prev = v
        # Ecuación: v' = beta * M * v + (1-beta)/n * e
        # Nota: En dead ends, la columna de M suma 0, por lo que parte de la masa 
        # se pierde en M*v. El término de teleport lo repone parcialmente.
        v = beta * (M @ v_prev) + teleport
        
        # Normalización opcional si se desea que la suma sea exactamente 1, 
        # aunque el modelo de taxation mantiene la masa automáticamente.
        # El libro indica que la suma puede ser < 1 con dead ends, pero el método funciona.
        
        if np.linalg.norm(v - v_prev, 1) < tol:
            print(f"Convergencia alcanzada en iteración {i+1}")
            break
            
    return v

# Ejemplo basado en la Figura 5.1 del libro
# A -> B, C, D
# B -> A, D
# C -> A
# D -> B, C
# Orden: A, B, C, D
M_example = np.array([
    [0,   1/2, 1,   0  ], # A recibe de B(1/2), C(1)
    [1/3, 0,   0,   1/2], # B recibe de A(1/3), D(1/2)
    [1/3, 0,   0,   1/2], # C recibe de A(1/3), D(1/2)
    [1/3, 1/2, 0,   0  ]  # D recibe de A(1/3), B(1/2)
]).T # Transpuesta para que columnas sean origen, filas destino (convención estándar M_ij: j->i)

# Nota: El ejemplo del libro define M_ij como probabilidad de ir de j a i.
# Si M_ij es fila i, columna j:
# Columna A (j=0): sale a B,C,D. M[1,0]=1/3, M[2,0]=1/3, M[3,0]=1/3. M[0,0]=0.
# La matriz en el libro está dada explícitamente.
M_book = np.array([
    [0,   1/2, 1,   0],
    [1/3, 0,   0,   1/2],
    [1/3, 0,   0,   1/2],
    [1/3, 1/2, 0,   0]
])

# Cálculo
pr = compute_pagerank(M_book, beta=0.8)
# Resultado esperado (aprox): A=0.101, B=0.128, C=0.128, D=0.128 (según ejemplo 5.2 sin taxation)
# Con taxation cambia ligeramente.
```

## 8. Funciones, métodos, librerías o comandos identificados
- **Matriz de Transición ($M$):** Estructura central. Representación dispersa recomendada (solo enlaces existentes).
- **Vector Propio Principal (Principal Eigenvector):** Concepto matemático equivalente al límite de PageRank.
- **MapReduce:** Paradigma sugerido para el cálculo distribuido del producto matriz-vector en la sección 5.2.
- **Sparse Matrix Representation:** Almacenar solo elementos no nulos para optimizar memoria y cómputo.

## 9. Snippets o plantillas reutilizables
> *Sección no aplicable a este fragmento.*

## 10. Casos de uso y aplicaciones
- **Motores de búsqueda (Google):** Ordenamiento de resultados de búsqueda combinando PageRank con relevancia textual.
- **Detección de Spam:** Identificación de granjas de enlaces (*spam farms*) que intentan manipular artificionalmente el PageRank.
- **Análisis de Redes Sociales:** Identificación de usuarios influyentes (nodos con alto PageRank) en grafos de seguimiento.
- **Sistemas de Recomendación:** Sugerencia de ítems basada en la estructura de un grafo bipartito usuario-ítem (variaciones de PageRank).

## 11. Limitaciones, riesgos y precauciones
- **Complejidad Computacional:** El producto matriz-vector es $O(n^2)$ en matrices densas, pero $O(L)$ donde $L$ es el número de enlaces en matrices dispersas. Aún así, requiere iteraciones costosas para miles de millones de nodos.
- **Sensibilidad a $\beta$:** La elección de $\beta$ afecta la tasa de convergencia y la sensibilidad a la estructura local vs. global.
- **Link Spam:** Aunque PageRank mitiga el *term spam*, es vulnerable a *Link Spam* (crear redes de páginas artificiales que apuntan a la página objetivo). Esto se aborda posterioremente con TrustRank.
- **Dead Ends Implícitos:** Si no se usa *taxation*, los *dead ends* requieren preprocesamiento costoso (eliminación recursiva).

## 12. Relaciones con otros temas del corpus
- **Teoría de Grafos:** Conceptos de nodos, aristas, componentes fuertemente conexos.
- **Álgebra Lineal:** Valores y vectores propios, matrices estocásticas, métodos iterativos (potencia).
- **Computación Distribuida (MapReduce):** Necesario para la implementación práctica en Big Data (Sección 5.2 y Capítulo 2).
- **TrustRank y HITS:** Variaciones y evoluciones del concepto de análisis de enlaces mencionadas en la introducción del capítulo.
- **Minería de Texto:** Contrastado con *term spam* y uso de índices invertidos.

## 13. Preguntas que la skill debería poder responder
1. ¿Por qué fallaban los primeros motores de búsqueda ante el *term spam* y cómo lo soluciona PageRank?
2. ¿Cuál es la diferencia entre un *dead end* y un *spider trap* en el contexto de PageRank?
3. ¿Cómo afecta el parámetro $\beta$ (factor de amortiguación) al cálculo de PageRank y qué valor típico se utiliza?
4. ¿Por qué no es viable usar eliminación Gaussiana para calcular PageRank en la web real?
5. ¿Qué representa la matriz de transición $M$ y cómo se construye a partir de un grafo web?
6. ¿Cómo se relaciona el vector PageRank con los vectores propios de la matriz de transición?
7. ¿Qué es el modelo "bowtie" de la web y qué problemas plantea para el algoritmo básico de PageRank?
8. ¿Cómo permite el método de *taxation* escapar de las *spider traps*?

## 14. Acciones que la skill debería poder recomendar o ejecutar
- Implementar una iteración de PageRank en Python para un grafo pequeño.
- Diagnosticar si un grafo tiene *dead ends* o *spider traps* analizando su matriz de adyacencia.
- Sugerir el uso de representación dispersa si el número de nodos supera los miles.
- Calcular el PageRank manualmente para un sistema de 3-4 nodos.
- Recomendar el uso de *taxation* para garantizar convergencia en grafos arbitrarios.

## 15. Activos finales de conocimiento en formato compacto
| Concepto | Descripción | Referencia |
| :--- | :--- | :--- |
| **PageRank** | Probabilidad límite de visitar una página en un paseo aleatorio. | Sec 5.1.2 |
| **Matriz de Transición** | $M_{ij} = 1/k$ si $j \to i$ y $j$ tiene $k$ enlaces salientes. | Sec 5.1.2 |
| **Dead End** | Nodo sin enlaces salientes; disipa probabilidad ($v \to 0$). | Sec 5.1.4 |
| **Spider Trap** | Ciclo cerrado sin salida; atrapa toda la probabilidad. | Sec 5.1.5 |
| **Taxation** | $v' = \beta Mv + (1-\beta)e/n$. Soluciona trampas y dead ends. | Sec 5.1.5 |
| **Beta ($\beta$)** | Probabilidad de seguir un enlace. Rango típico: 0.8 - 0.9. | Sec 5.1.5 |
| **Convergencia** | Se alcanza en 50-75 iteraciones para la web real. | Sec 5.1.2 |
| **Term Spam** | Manipulación de texto para engañar relevancia. Combatido con enlaces. | Sec 5.1.1 |
| **Escalaridad** | Requiere matrices dispersas y MapReduce para $n$ grande. | Sec 5.2 |
| **Eigenvector** | PageRank es el vector propio principal de $M$ (valor propio 1). | Sec 5.1.2 |


