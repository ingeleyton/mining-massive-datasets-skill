# parte-18 — Mining-of-Massive-Datasets-Third-Edition-Jure-Leskovec-Anand-Rajaraman-etc-z-library-sk-1lib-sk-z-lib-parte-18.pdf

## 1. Metadatos del documento
- **Libro:** Mining of Massive Datasets, 3ª ed.
- **Fragmento/Parte:** Capítulo 5. Link Analysis (Secciones 5.5 Hubs and Authorities, 5.6 Summary of Chapter 5, 5.7 References)
- **Temas principales:** Algoritmo HITS, Hubs y Autoridades, PageRank, Estructura de la Web, Spam de enlaces, TrustRank, Spam Mass, Matrices de transición.
- **Tipo de contenido:** Mixto (Teoría / Algoritmo / Resumen / Referencias)

## 2. Resumen técnico de alto valor
El fragmento introduce el algoritmo HITS (Hyperlink-Induced Topic Search) como una dualidad al PageRank. Mientras PageRank define la importancia unidimensional basada en la recursividad "una página es importante si páginas importantes enlazan a ella", HITS descompone la importancia en dos vectores mutuamente dependientes: **Hubs** (acumuladores de enlaces salientes hacia recursos valiosos) y **Authorities** (fuentes de contenido valioso referenciadas por buenos hubs). La formalización utiliza la matriz de enlaces $L$ (binaria) y su transpuesta $L^T$, a diferencia de la matriz de transición estocástica $M$ de PageRank. Un hallazgo crítico es que HITS no requiere esquemas de "taxation" (factor $\beta$) para manejar *dead ends* o *spider traps*, ya que la iteración mutua converge sin la pérdida de masa de probabilidad característica de PageRank.

Adicionalmente, el resumen del capítulo consolida la arquitectura de PageRank: la necesidad de eliminación recursiva de nodos finales (*dead ends*), el modelo del surfista aleatorio con teletransportación ($\beta \approx 0.85$) para evitar trampas, y la optimización computacional mediante representación dispersa por bloques (block-stripe). Se cierra con estrategias anti-spam: TrustRank (PageRank sesgado por semillas de confianza) y Spam Mass (proporción de PageRank derivado de spam vs. total).

## 3. Conceptos y definiciones clave
- **Authority (Autoridad):** Página web que contiene información valiosa sobre un tema específico. Su puntuación se basa en la suma de las puntuaciones "hub" de las páginas que la enlazan.
- **Hub:** Página que actúa como directorio o lista de recursos, enlazando a múltiples páginas de autoridad. Su valor radica en señalar hacia contenido útil, no en contenerlo.
- **Matriz de Enlaces ($L$):** Matriz $n \times n$ donde $L_{ij} = 1$ si existe un enlace de la página $i$ a la $j$, y $0$ en caso contrario. Es la base del cálculo en HITS.
- **Matriz de Transición ($M$):** Usada en PageRank. Si hay $k$ enlaces salientes de la página $j$, cada entrada $M_{ij} = 1/k$ (probabilidad uniforme de transición).
- **Dead End (Callejón sin salida):** Página sin enlaces salientes. En PageRank causa fuga de probabilidad; en HITS no impide la convergencia.
- **Spider Trap (Trampa de araña):** Conjunto de nodos que enlazan internamente sin salida hacia el resto del grafo. En PageRank absorben todo el rank; en HITS no requieren mitigación especial.
- **Taxation Scheme (Esquema de tributación):** Mecanismo en PageRank donde en cada paso, con probabilidad $1-\beta$, el surfista aleatorio salta a una página aleatoria en lugar de seguir un enlace. Previene la acumulación en spider traps.
- **TrustRank:** Variante de PageRank sensible al tema donde el conjunto de teletransportación ("teleport set") se restringe a páginas de confianza (ej. universidades) para combatir el spam.
- **Spam Mass:** Métrica para detectar granjas de spam. Se calcula comparando el PageRank estándar contra el TrustRank; una gran discrepancia indica que la página recibe la mayoría de su rank de fuentes no confiables.

## 4. Principios, reglas y heurísticas
- **Principio de Recursividad Mutua (HITS):** Un buen hub enlaza a buenas autoridades; una buena autoridad es enlazada por buenos hubs.
- **Escalado de Vectores (HITS):** Tras cada multiplicación de vector, los valores deben escalarse (ej. componente más grande = 1) para evitar la divergencia, ya que las matrices $L$ y $L^T$ no son estocásticas.
- **Manejo de Estructuras Problemáticas:** A diferencia de PageRank, HITS es robusto ante *dead ends* y *spider traps* sin necesidad de modificar la estructura del grafo ni introducir factores de amortiguación.
- **Valor de $\beta$ en PageRank:** El valor típico es $0.85$. Esto significa que hay un $15\%$ de probabilidad de teletransportarse en cada paso, suficiente para evitar trampas pero mantener la estructura de enlaces.
- **Detección de Spam:** Si `PageRank >> TrustRank`, la página es sospechosa de participar en una granja de enlaces.

## 5. Procedimientos, métodos y workflows

### Algoritmo HITS (Hubs and Authorities)
**Precondiciones:** Grafo dirigido de $n$ páginas.
**Procedimiento:**
1. Inicializar el vector $h$ con todos sus componentes en 1.
2. **Iterar hasta convergencia:**
   a. Calcular el vector de autoridad: $a = L^T h$.
   b. Escalar el vector $a$ (normalizar el componente máximo a 1).
   c. Calcular el vector hub: $h = L a$.
   d. Escalar el vector $h$ (normalizar el componente máximo a 1).
**Postcondición:** Vectores $h$ y $a$ convergen a los valores límite que representan la "hubbiness" y autoridad de cada página.

### Cálculo de PageRank con Taxation
1. Iniciar con vector de probabilidad $v$.
2. Iterar: $v' = \beta M v + \frac{1-\beta}{n} \mathbf{1}$, donde $\mathbf{1}$ es un vector de unos y $n$ es el número total de páginas.
3. Repetir hasta que la diferencia entre $v$ y $v'$ sea despreciable.

## 6. Problemas comunes y soluciones
- **Problema:** Divergencia o crecimiento ilimitado en HITS.
  - **Solución:** Escalar los vectores $a$ y $h$ en cada iteración (normalización).
- **Problema:** *Dead ends* en PageRank causan que el PageRank total se escape a 0.
  - **Solución:** Eliminar recursivamente los nodos sin enlaces salientes antes de construir la matriz de transición.
- **Problema:** *Spider traps* en PageRank absorben todo el rank.
  - **Solución:** Implementar el modelo de "taxation" (teletransportación aleatoria con probabilidad $1-\beta$).
- **Problema:** Enlaces spam inflan artificialmente el PageRank.
  - **Solución:** Implementar TrustRank usando un conjunto de semillas confiables y calcular Spam Mass para identificar nodos sospechosos.

## 7. Implementación técnica y generación de código

```pseudocode
# Algoritmo HITS simplificado basado en el libro
Input: Matriz de enlaces L, número de iteraciones k
Output: Vectores h (hubs), a (authorities)

Inicializar h = vector de unos de longitud n

FOR i = 1 to k DO
    # Calcular autoridad: suma de hubs que apuntan a la página
    a = L_transpuesta * h
    
    # Normalizar a (componente máximo = 1)
    a = a / max(a)
    
    # Calcular hub: suma de autoridades a las que apunta la página
    h = L * a
    
    # Normalizar h (componente máximo = 1)
    h = h / max(h)
END FOR

RETURN h, a
```

```python
import numpy as np

def hits_algorithm(L, iterations=50, tolerance=1e-6):
    """
    Implementación del algoritmo HITS.
    L: Matriz de adyacencia binaria (numpy array). L[i,j] = 1 si i -> j.
    """
    n = L.shape[0]
    h = np.ones(n) # Vector inicial de hubs
    
    # Precomputar transpuesta para eficiencia
    L_T = L.T
    
    for _ in range(iterations):
        # Paso 1: Calcular autoridades
        a_new = L_T.dot(h)
        
        # Escalar autoridades (norma infinito: max componente = 1)
        max_a = np.max(a_new)
        if max_a == 0: break # Evitar división por cero en grafo vacío
        a_new = a_new / max_a
        
        # Paso 2: Calcular hubs
        h_new = L.dot(a_new)
        
        # Escalar hubs
        max_h = np.max(h_new)
        if max_h > 0:
            h_new = h_new / max_h
            
        # Check convergencia (opcional)
        if np.linalg.norm(h_new - h) < tolerance:
            break
            
        h = h_new
        
    # Calcular autoridad final consistente con el último h
    a = L_T.dot(h)
    a = a / np.max(a) if np.max(a) > 0 else a
    
    return h, a

# Ejemplo basado en Fig 5.18 del libro
# Nodos: A, B, C, D, E
# Enlaces: A->B, A->C, A->D; B->A, B->D; C->E; D->B, D->C
L = np.array([
    [0, 1, 1, 1, 0], # A
    [1, 0, 0, 1, 0], # B
    [0, 0, 0, 0, 1], # C
    [0, 1, 1, 0, 0], # D
    [0, 0, 0, 0, 0]  # E
])

h, a = hits_algorithm(L)
# Salida esperada (aprox): h=[1, 0.358, 0, 0.716, 0], a=[0.208, 1, 1, 0.791, 0]
```

## 8. Funciones, métodos, librerías o comandos identificados
- **$L$ (Link Matrix):** Matriz binaria de adyacencia. Usada en HITS.
- **$L^T$ (Transposed Link Matrix):** Usada para propagar valor de hub a autoridad.
- **$M$ (Transition Matrix):** Matriz estocástica columna-normalizada. Usada en PageRank.
- **$\beta$ (Beta):** Factor de amortiguación (damping factor), típicamente 0.85.
- **Teleport Set:** Subconjunto de nodos usados para reiniciar el surfista aleatorio en Topic-Sensitive PageRank y TrustRank.

## 9. Snippets o plantillas reutilizables
> *Sección no aplicable a este fragmento.*

## 10. Casos de uso y aplicaciones
- **Motores de búsqueda (Ask.com):** El libro menciona que el motor Ask utiliza una variante del enfoque HITS para ranking.
- **Listas de cursos universitarios:** Ejemplo clásico del libro. La página del departamento es un **Hub** (lista de cursos), y las páginas de cada curso son **Authorities** (contenido del curso).
- **Detección de Spam:** Uso de TrustRank para identificar granjas de enlaces que intentan manipular PageRank.
- **Análisis de redes sociales:** Identificación de influencers (Authorities) y curadores de contenido (Hubs).

## 11. Limitaciones, riesgos y precauciones
- **Complejidad Computacional en HITS:** Las matrices $LL^T$ y $L^TL$ son menos dispersas que $M$, lo que hace que la multiplicación directa sea costosa para grafos masivos si no se optimiza. Se recomienda recursión mutua ($L$ y $L^T$) en lugar de calcular los autovectores directamente.
- **Sensibilidad al Tema:** HITS fue diseñado originalmente para ejecutarse sobre un subconjunto de resultados de búsqueda, no sobre toda la web, debido a la mezcla de temas no relacionados ("topic drift").
- **Dependencia de Semillas:** TrustRank depende en gran medida de la calidad del conjunto de páginas confiables inicial; si las semillas son sesgadas, el ranking también lo será.

## 12. Relaciones con otros temas del corpus
- **PageRank:** HITS se presenta como una alternativa/complemento. Ambos usan multiplicación matriz-vector iterativa.
- **Eigenvectores:** Tanto PageRank (autovector principal de $M$) como HITS (autovectores de $L^TL$ y $LL^T$) son problemas de álgebra lineal.
- **MapReduce:** La sección de resumen menciona la multiplicación matriz-vector a gran escala por bloques, conectando con temas de computación distribuida.
- **Spam:** Relación directa con técnicas de detección de anomalías y grafos.

## 13. Preguntas que la skill debería poder responder
1. ¿Cuál es la diferencia fundamental entre la definición de importancia en PageRank y en HITS?
2. ¿Por qué HITS no requiere un factor de "taxation" ($\beta$) a diferencia de PageRank?
3. ¿Cómo se calcula el vector de autoridad a partir del vector hub en el algoritmo HITS?
4. ¿Qué es un "dead end" y cómo afecta al cálculo iterativo de PageRank?
5. ¿Cómo se utiliza el TrustRank para combatir el link spam?
6. ¿Qué representa la métrica "Spam Mass" y cómo se interpreta?
7. ¿Cuál es la diferencia entre la matriz de enlaces $L$ (HITS) y la matriz de transición $M$ (PageRank)?
8. ¿Cómo se representa eficientemente una matriz de transición dispersa para cálculo distribuido?

## 14. Acciones que la skill debería poder recomendar o ejecutar
- Implementar el bucle iterativo de HITS para un grafo pequeño usando operaciones matriciales.
- Calcular el Spam Mass de un nodo dado su PageRank y TrustRank.
- Decidir entre usar PageRank o HITS según el objetivo: ranking global vs. análisis de estructura temática (hubs/authorities).
- Aplicar poda de nodos "dead end" recursivamente antes de calcular PageRank.
- Configurar el vector de teletransportación para un Topic-Sensitive PageRank.

## 15. Activos finales de conocimiento en formato compacto
| Concepto | Descripción | Referencia |
|---|---|---|
| **HITS** | Algoritmo que calcula puntuaciones de Hub y Autoridad mediante recursión mutua. | Sec 5.5 |
| **Hub** | Página que enlaza a muchas autoridades. Valor proporcional a la suma de autoridades a las que apunta. | Sec 5.5.1 |
| **Authority** | Página enlazada por muchos hubs. Valor proporcional a la suma de hubs que la apuntan. | Sec 5.5.2 |
| **Link Matrix ($L$)** | Matriz binaria $n \times n$; $L_{ij}=1$ si existe enlace $i \to j$. | Sec 5.5.2 |
| **Taxation ($\beta$)** | Mecanismo de escape aleatorio en PageRank ($\beta \approx 0.85$) para evitar spider traps. | Sec 5.6 |
| **Dead End** | Nodo sin enlaces salientes; causa fuga de PageRank si no se elimina. | Sec 5.6 |
| **TrustRank** | PageRank sesgado donde la teletransportación ocurre solo hacia nodos de confianza. | Sec 5.6 |
| **Spam Mass** | Métrica $(PR - TR) / PR$ para estimar el porcentaje de rank proveniente de spam. | Sec 5.6 |
| **Convergencia HITS** | Asegurada sin modificación de grafo; requiere escalado de vectores en cada paso. | Sec 5.5.2 |
| **Sparse Representation** | Almacenar matriz por columnas: conteo de no-ceros + lista de filas. | Sec 5.6 |
