# Parte 35 - Social Graphs and Locality

## 1. Metadatos del documento
- **Libro:** Mining of Massive Datasets, 3ª ed.
- **Fragmento/Parte:** Parte 35 - Social Graphs and Locality
- **Temas principales:** Grafos de redes sociales, Localidad (clustering de relaciones), Grafos k-partitos, Medidas de distancia en grafos, Clustering jerárquico, Comunidades.
- **Tipo de contenido:** Teoría / Definiciones / Análisis de problemas

## 2. Resumen técnico de alto valor
El fragmento establece los fundamentos teóricos para el análisis de redes sociales masivas, definiéndolas mediante tres pilares: entidades, relaciones y la propiedad crítica de **no-aleatoriedad o localidad**. Esta propiedad dicta que las conexiones tienden a agruparse; si el nodo $A$ conecta con $B$ y $C$, la probabilidad de que exista conexión entre $B$ y $C$ es significativamente superior a la probabilidad aleatoria (principio de cierre de triángulos).

Se modelan las redes mediante grafos (dirigidos o no), introduciendo variantes como los **grafos k-partitos** para representar entidades de múltiples tipos (ej. usuarios, tags, páginas web), donde las aristas solo conectan nodos de conjuntos distintos. El texto advierte sobre la inadecuación de las técnicas de clustering tradicionales (Capítulo 7) para estos grafos debido a la dificultad de definir medidas de distancia válidas: las distancias binarias (0/1 o $1/\infty$) violan la **desigualdad triangular**, y los métodos jerárquicos fallan al no poder distinguir estructuralmente qué aristas priorizar para fusionar clusters sin caer en aleatoriedad.

## 3. Conceptos y definiciones clave
- **Red Social (Social Network):** Estructura compuesta por entidades (típicamente personas, pero extensibles a documentos, genes, etc.), al menos una relación entre ellas y una asunción de no-aleatoriedad (localidad).
- **Localidad (Locality):** Propiedad estadística donde las relaciones se agrupan. Implica que la existencia de aristas $(X, Y)$ y $(X, Z)$ incrementa la probabilidad de la arista $(Y, Z)$ respecto a la media del grafo.
- **Grafo Social (Social Graph):** Representación matemática donde los nodos son entidades y las aristas son relaciones. Puede ser ponderado (grado de relación) o binario.
- **Grafo k-partito (k-partite graph):** Grafo con $k$ conjuntos disjuntos de nodos donde no existen aristas entre nodos del mismo conjunto. Caso particular: grafo bipartito ($k=2$).
- **Medida de distancia binaria:** Definición de distancia $d(x,y)$ basada en la existencia de arista (ej. $0$ si existe, $1$ si no). Se considera problemática para algoritmos tradicionales.
- **Desigualdad triangular:** Regla matemática $d(A,C) \le d(A,B) + d(B,C)$. En grafos sociales sin arista $(A,C)$ pero con camino $A-B-C$, una distancia binaria viola esta regla ($1 \not\le 0 + 0$ o $\infty \not\le 1 + 1$).

## 4. Principios, reglas y heurísticas
- **Regla de la Localidad:** Si la probabilidad condicional de conexión entre vecinos de un nodo excede la probabilidad de conexión global del grafo, el grafo exhibe localidad y es candidato para minería de comunidades.
- **Principio de representación de relaciones:** Si la relación tiene un "grado" (intensidad), esta debe representarse como etiqueta o peso en la arista; si es binaria ("amigos"), la arista no tiene peso.
- **Heurística de distancia:** Para grafos no ponderados, intentar forzar una medida de distancia usando valores como $1$ (conexión) y $1.5$ (no conexión) puede satisfacer la desigualdad triangular, pero sigue siendo insuficiente para distinguir estructuras significativas en clustering jerárquico.
- **Regla de construcción de grafos duales:** En la construcción dual (ejercicio propuesto), las aristas del grafo original se convierten en nodos del nuevo grafo, conectándose si comparten un nodo en el original.

## 5. Procedimientos, métodos y workflows
### Procedimiento: Validación estadística de localidad en un grafo pequeño
El libro describe un método para verificar si un grafo pequeño es una red social válida basándose en el cierre de triángulos.

1.  **Precondición:** Grafo $G$ con $N$ nodos y $E$ aristas.
2.  **Cálculo de probabilidad base:** Calcular la fracción de pares conectados: $P_{base} = \frac{2E}{N(N-1)}$.
3.  **Cálculo de probabilidad esperada (corregida):** Dado un nodo $X$ con vecinos $Y, Z$, calcular la probabilidad esperada de la arista $(Y, Z)$ asumiendo aleatoriedad (sin reemplazo).
    *   *Nota del texto:* Para grafos pequeños, la probabilidad esperada es ligeramente menor que $P_{base}$ debido a que las aristas $(X,Y)$ y $(X,Z)$ ya están "consumidas".
4.  **Cálculo de probabilidad real:** Contar todos los tríos $(X, Y, Z)$ donde existen aristas $(X, Y)$ y $(X, Z)$. Contar cuántos de estos tríos tienen la arista $(Y, Z)$ (ejemplos positivos) y cuántos no (negativos).
5.  **Comparación:** Si $P_{real} \gg P_{esperada}$, el grafo posee localidad.
6.  **Postcondición:** Confirmación de la idoneidad del grafo para análisis de comunidades.

### Procedimiento: Construcción de Grafo Dual (Ejercicio 10.1.1)
1.  Crear nodo $XY$ en $G'$ para cada arista $(X,Y)$ en $G$.
2.  Crear arista en $G'$ entre $XY$ y $XZ$ si las aristas originales comparten el nodo $X$.

## 6. Problemas comunes y soluciones
- **Problema:** Violación de la desigualdad triangular en medidas de distancia binaria.
    - *Contexto:* Si $A$ conoce a $B$ y $B$ conoce a $C$, pero $A$ no conoce a $C$, la distancia $d(A,C)$ es "larga", mientras que el camino $A-B-C$ es "corto".
    - *Solución propuesta:* Ajustar valores (ej. $d=1$ para arista, $d=1.5$ para no arista) para forzar la validez métrica, aunque esto no resuelve la utilidad semántica para clustering.
- **Problema:** Pérdida de información en representaciones graficas de relaciones ternarias.
    - *Contexto:* Sistemas como del.icio.us (Usuario, Tag, Página). Un grafo tripartito conecta usuarios con tags y tags con páginas, pero no registra qué usuario asignó qué tag a qué página específica.
    - *Solución:* El texto sugiere que se requiere una representación más compleja (ej. base de datos relacional o hipergrafo) para capturar la relación ternaria completa `[AMBIGUO]`.
- **Problema:** Clustering de grafos sociales con métodos jerárquicos estándar.
    - *Causa:* Al inicio, se fusionan nodos conectados aleatoriamente. En iteraciones posteriores, la elección de qué clusters fusionar se vuelve arbitraria debido a la falta de una métrica de distancia significativa entre clusters de nodos.

## 7. Implementación técnica y generación de código

```pseudocode
# Verificación de Localidad (Ejemplo 10.1 simplificado)
Función VerificarLocalidad(Grafo G):
    TotalAristas = G.numero_de_aristas()
    TotalParesPosibles = G.numero_de_nodos() * (G.numero_de_nodos() - 1) / 2
    ProbabilidadBase = TotalAristas / TotalParesPosibles

    Positivos = 0 # Veces que (Y,Z) existe dado (X,Y) y (X,Z)
    Negativos = 0 # Veces que (Y,Z) no existe dado (X,Y) y (X,Z)

    Para cada nodo X en G:
        Vecinos = G.obtener_vecinos(X)
        Para cada par (Y, Z) en Vecinos (combinaciones de 2):
            Si existe_arista(Y, Z):
                Positivos += 1
            Sino:
                Negativos += 1
    
    ProbabilidadReal = Positivos / (Positivos + Negativos)
    
    Si ProbabilidadReal > ProbabilidadBase:
        Retornar "Grafo exhibe localidad"
    Sino:
        Retornar "Grafo aleatorio o sin localidad detectable"
```

```python
# Implementación Python para calcular la localidad (cierre de triángulos)
import networkx as nx
from itertools import combinations

def calcular_localidad_social(G):
    """
    Calcula la probabilidad de cierre de triángulos vs probabilidad base
    para determinar si un grafo exhibe propiedades de red social.
    """
    nodes = list(G.nodes())
    num_nodes = len(nodes)
    num_edges = G.number_of_edges()
    
    # Probabilidad base de que exista una arista entre dos nodos cualesquiera
    total_pairs = (num_nodes * (num_nodes - 1)) / 2
    prob_base = num_edges / total_pairs if total_pairs > 0 else 0
    
    positive_examples = 0
    negative_examples = 0
    
    # Iterar sobre cada nodo como el "vértice" X del triángulo potencial
    for x in nodes:
        neighbors = list(G.neighbors(x))
        # Generar todos los pares de vecinos (Y, Z)
        for y, z in combinations(neighbors, 2):
            # Verificar si el tercer lado del triángulo existe
            if G.has_edge(y, z):
                positive_examples += 1
            else:
                negative_examples += 1
                
    total_triplets = positive_examples + negative_examples
    prob_real = positive_examples / total_triplets if total_triplets > 0 else 0
    
    return {
        "probabilidad_base": prob_base,
        "probabilidad_cierre_real": prob_real,
        "exhibe_localidad": prob_real > prob_base,
        "ejemplos_positivos": positive_examples,
        "ejemplos_negativos": negative_examples
    }

# Ejemplo de uso con el grafo del libro (Figura 10.1)
# G = nx.Graph()
# G.add_edges_from([('A','B'), ('A','C'), ('B','C'), ('B','D'), ('C','D'), 
#                   ('D','E'), ('D','F'), ('D','G'), ('E','F'), ('F','G')])
# print(calcular_localidad_social(G))
```

## 8. Funciones, métodos, librerías o comandos identificados
- **NetworkX (Python):** Librería implícita para manejo de grafos (`Graph`, `nodes`, `edges`, `neighbors`, `has_edge`).
- **Combinaciones de 2:** Concepto matemático usado para iterar sobre pares de vecinos sin repetición ($\binom{n}{2}$).
- **Clustering Jerárquico Aglomerativo:** Método mencionado como problemático para este tipo de datos (referencia al Capítulo 7).

## 9. Snippets o plantillas reutilizables
> *Sección no aplicable a este fragmento.*

## 10. Casos de uso y aplicaciones
- **Redes de Colaboración:** Análisis de grafos bipartitos (Autores - Papers) para identificar comunidades de investigación. Se pueden proyectar a grafos de un solo tipo (Autores conectados si comparten papers).
- **Detección de Spam en Email:** Uso de grafos dirigidos donde las aristas bidireccionales son "fuerza fuerte" y unidireccionales "fuerza débil" para filtrar relaciones spammer-víctima.
- **Sistemas de Recomendación:** Modelado como grafos bipartitos (Usuarios - Productos). La localidad indica que usuarios que compran productos similares tienden a ser similares entre sí.
- **Análisis de Infraestructura:** Aplicación de conceptos de localidad a redes de agua, electricidad o transporte para identificar puntos críticos de conexión.

## 11. Limitaciones, riesgos y precauciones
- **Escala:** El método de conteo de triángulos para verificar localidad es computacionalmente costoso ($O(nd^2)$ donde $d$ es el grado promedio) y puede ser inviable para grafos masivos sin optimización (muestreo).
- **Simplificación de relaciones:** Convertir relaciones complejas (llamadas telefónicas con duración) a aristas simples pierde información valiosa para la definición de comunidades.
- **Grafos Pequeños:** Las pruebas de localidad estadística son menos fiables en grafos con pocos nodos debido a la varianza.
- **Representación k-partita:** Limitada para relaciones que involucran más de 2 entidades simultáneamente (relaciones n-arias), requiriendo modelos de datos alternos a grafos simples.

## 12. Relaciones con otros temas del corpus
- **Capítulo 7 (Clustering):** Este fragmento actúa como una corrección o advertencia sobre la aplicación directa de algoritmos como K-means o Jerárquico a datos de grafos.
- **Capítulo 9 (Recommender Systems):** Conexión directa a través de grafos bipartitos Usuarios-Items y filtrado colaborativo.
- **Capítulo 5 (Link Analysis):** Conceptos de grafos dirigidos y autoridad (PageRank) son aplicables a las redes sociales definidas aquí.
- **Concepto futuro:** El texto introduce "SimRank" y conteo de triángulos como técnicas avanzadas a desarrollar en secciones posteriores del mismo capítulo.

## 13. Preguntas que la skill debería poder responder
1. ¿Qué tres características esenciales definen una red social según el modelo teórico?
2. ¿Por qué la distancia binaria (0 o 1) viola la desigualdad triangular en el contexto de grafos sociales?
3. ¿Cómo se representa una relación ternaria (ej. usuario, tag, página) en un grafo y cuál es la limitación de esta representación?
4. ¿Qué es la "localidad" en un grafo social y cómo se calcula empíricamente en el ejemplo del libro?
5. ¿Por qué los algoritmos de clustering jerárquico estándar fallan al intentar detectar comunidades en grafos de amigos?
6. ¿Qué es un grafo k-partito y cómo difiere de un grafo estándar?
7. ¿Cómo se diferencia una red de colaboración de autores de una red de citas de papers en términos de estructura de grafo?
8. ¿Qué ajuste numérico propone el libro para intentar cumplir la desigualdad triangular en distancias de grafos?

## 14. Acciones que la skill debería poder recomendar o ejecutar
- **Modelado de datos:** Decidir si un dataset de interacciones debe modelarse como grafo dirigido, no dirigido, ponderado o k-partito.
- **Validación de grafo:** Ejecutar un análisis de coeficiente de clustering o cierre de triángulos para verificar si un grafo extraído es una red social válida antes de aplicar algoritmos de comunidad.
- **Selección de algoritmo:** Descartar K-means o clustering jerárquico basado en distancias euclidianas para grafos de amistad; recomendar algoritmos basados en cortes de grafos o modularidad (implícito para secciones posteriores).
- **Preprocesamiento:** Filtrar aristas débiles o unidireccionales en redes de comunicación para reducir ruido antes del análisis.

## 15. Activos finales de conocimiento en formato compacto
| Concepto | Descripción | Referencia |
| :--- | :--- | :--- |
| **Localidad** | Tendencia de los nodos a formar grupos densos (triángulos); $P(Y,Z) > P_{base}$ dado $(X,Y)$ y $(X,Z)$. | Sec. 10.1.1 |
| **Grafo k-partito** | Grafo con $k$ tipos de nodos donde las aristas solo conectan nodos de tipos distintos. | Sec. 10.1.4 |
| **Desigualdad Triangular** | Obstáculo matemático para usar distancias binarias en grafos: $d(A,C) \not\le d(A,B) + d(B,C)$. | Sec. 10.2.1 |
| **Distancia Binaria** | Métrica defectuosa para clustering social: asigna distancia corta a aristas y larga a no-aristas. | Sec. 10.2.1 |
| **Red de Colaboración** | Grafo bipartito proyectado: Autores conectados por papers comunes o papers conectados por autores comunes. | Sec. 10.1.3 |
| **Clustering Jerárquico** | Método inadecuado para grafos sociales porque fusiona nodos aleatoriamente tras el primer paso. | Sec. 10.2.2 |
| **Relación Ternaria** | Limitación de grafos: No capturan qué usuario asignó qué tag a qué página sin representación adicional. | Sec. 10.1.4 |
| **Probabilidad Base** | Ratio $\frac{\text{Aristas}}{\text{Pares Totales}}$; línea base para detectar desviaciones de aleatoriedad. | Sec. 10.1.2 |


