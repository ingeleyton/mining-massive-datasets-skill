# Parte 17 - Topic-Sensitive PageRank and Link Spam

## 1. Metadatos del documento
- **Libro:** Mining of Massive Datasets, 3ª ed.
- **Fragmento/Parte:** Parte 17 - Topic-Sensitive PageRank and Link Spam
- **Temas principales:** Topic-Sensitive PageRank, Link Spam, Spam Farm, TrustRank, Spam Mass, Hubs and Authorities (HITS)
- **Tipo de contenido:** Mixto (Teoría / Algoritmo / Análisis matemático)

## 2. Resumen técnico de alto valor
El fragmento aborda la evolución del algoritmo PageRank para manejar contextos de usuario y combatir la manipulación de enlaces. Introduce el **Topic-Sensitive PageRank**, que modifica el vector de teletransporte para sesgar la caminata aleatoria hacia un conjunto de páginas semilla ($S$) relevantes para un tema, permitiendo personalizar resultados de búsqueda sin almacenar vectores por usuario. Seguidamente, detalla la arquitectura y análisis matemático de un **Spam Farm**, demostrando cómo una estructura de páginas controladas puede amplificar el PageRank de una página objetivo mediante la captura del factor de teletransporte aleatorio. Para contrarrestar esto, se presentan **TrustRank** (una variante de PageRank sensible a temas donde el tema es un conjunto de páginas confiables) y **Spam Mass** (una métrica para cuantificar la proporción de PageRank derivado de spam). Finalmente, se introduce el modelo **HITS** (Hubs and Authorities), que distingue entre páginas que proveen información valiosa (autoridades) y páginas que actúan como directorios de recursos (hubs).

## 3. Conceptos y definiciones clave
- **Topic-Sensitive PageRank**: Variante de PageRank donde el vector de teletransporte no es uniforme sobre todas las páginas, sino que se concentra en un conjunto $S$ de páginas pertenecientes a un tema específico.
- **Teleport Set ($S$)**: Conjunto de páginas seleccionadas como semillas para el vector de teletransporte en Topic-Sensitive PageRank o TrustRank.
- **Biased Random Walk (Caminata aleatoria sesgada)**: Modificación del proceso de PageRank donde los "surfers" aleatorios solo pueden teletransportarse a páginas dentro del conjunto $S$.
- **Link Spam**: Técnicas diseñadas para engañar al algoritmo PageRank y aumentar artificialmente el ranking de ciertas páginas mediante estructuras de enlaces manipuladas.
- **Spam Farm**: Colección de páginas controladas por un spammer diseñadas para maximizar el PageRank de una página objetivo (target page).
- **Target Page**: Página específica dentro de un spam farm que recibe el beneficio acumulado de la estructura de enlaces.
- **Supporting Pages**: Páginas dentro de un spam farm que enlazan a la página objetivo; su propósito es capturar y recircular el PageRank.
- **TrustRank**: Variante de Topic-Sensitive PageRank donde el teleport set consiste en páginas consideradas confiables (no spam), asumiendo que las páginas confiables raramente enlazan a spam.
- **Spam Mass**: Métrica calculada como la fracción del PageRank de una página que proviene de fuentes de spam. Se estima comparando el PageRank estándar con el TrustRank.
- **Hubs and Authorities**: Modelo de valor de página donde una **Autoridad** provee contenido valioso sobre un tema y un **Hub** provee enlaces a autoridades.

## 4. Principios, reglas y heurísticas
- **Principio de sesgo temático**: Para influir en el ranking hacia un tema, se debe modificar el vector de teletransporte $e_S$ para que tenga componentes no nulos solo en las páginas del tema $S$.
- **Regla de inferencia de temas**: Se puede clasificar una página en un tema calculando la similitud de Jaccard entre el conjunto de palabras de la página y conjuntos de palabras característicos de cada tema ($S_i$).
- **Heurística de confianza (TrustRank)**: Es difícil que una página confiable enlace a una página de spam. Por tanto, propagar el PageRank desde un conjunto de semillas confiables reduce el puntaje de spam.
- **Umbral de Spam Mass**: Un valor de spam mass cercano a 1 indica alta probabilidad de ser spam. Valores negativos o cercanos a 0 indican páginas legítimas.
- **Eficiencia de almacenamiento**: No es factible almacenar un vector de PageRank por usuario. La solución es almacenar vectores por tema y combinarlos según el perfil del usuario.

## 5. Procedimientos, métodos y workflows

### Cálculo de Topic-Sensitive PageRank
1.  **Definición del conjunto**: Identificar el conjunto $S$ de páginas pertenecientes al tema (ej. categoría "deportes" de Open Directory).
2.  **Construcción del vector base**: Crear el vector $e_S$ con 1 en las posiciones correspondientes a páginas en $S$ y 0 en el resto.
3.  **Iteración**: Aplicar la ecuación recursiva hasta la convergencia:
    $$v' = \beta M v + (1-\beta) \frac{e_S}{|S|}$$
    Donde $M$ es la matriz de transición y $\beta$ es el factor de amortiguación.

### Workflow de integración en buscador
1.  Decidir los temas para los cuales se precomputarán vectores.
2.  Calcular el vector de Topic-Sensitive PageRank para cada tema.
3.  Determinar el tema de interés del usuario (por menú, historial de navegación o bookmarks).
4.  Ordenar los resultados usando el vector del tema inferido.

### Cálculo de Spam Mass
1.  Calcular el PageRank estándar ($r$) para la página $p$.
2.  Calcular el TrustRank ($t$) para la página $p$ usando un teleport set de páginas confiables.
3.  Calcular la masa de spam: $\frac{r - t}{r}$.

## 6. Problemas comunes y soluciones
- **Problema**: Ambigüedad en consultas de búsqueda (ej. "jaguar" puede ser animal o auto).
    - **Solución**: Usar Topic-Sensitive PageRank para sesgar los resultados hacia el interés inferido del usuario.
- **Problema**: Link Spam inflando artificialmente el ranking.
    - **Solución**: Implementar TrustRank para reducir la puntuación de páginas no respaldadas por fuentes confiables y calcular Spam Mass para identificar y penalizar granjas de enlaces.
- **Problema**: Identificar páginas confiables para TrustRank.
    - **Solución**: Usar dominios controlados como `.edu`, `.gov` o sus equivalentes internacionales, o usar inspección humana de páginas con alto PageRank (ya que es difícil que el spam llegue a la cima sin confianza).
- **Problema**: Páginas confiables que permiten comentarios de usuarios (blogs, periódicos).
    - **Solución**: Estas páginas no pueden considerarse completamente confiables para el teleport set, ya que los spammers pueden insertar enlaces en los comentarios.

## 7. Implementación técnica y generación de código

```pseudocode
# Algoritmo: Topic-Sensitive PageRank Iteration
# Entrada: Matriz de transición M, Conjunto S, Factor beta, Vector inicial v
# Salida: Vector v convergido

Mientras no converja:
    Para cada pagina i en el grafo:
        suma_entrantes = 0
        Para cada pagina j que enlaza a i:
            suma_entrantes += v[j] * M[j][i] # M[j][i] es probabilidad de transición
        
        # Componente de teletransporte sesgado
        si i pertenece a S:
            teleport = (1 - beta) / |S|
        sino:
            teleport = 0
            
        v_nuevo[i] = beta * suma_entrantes + teleport
    v = v_nuevo
Retornar v
```

```python
import numpy as np

def topic_sensitive_pagerank(M, S_indices, beta=0.85, max_iter=100, tol=1e-6):
    """
    Calcula el vector de Topic-Sensitive PageRank.
    
    :param M: Matriz de transición (numpy array n x n), columnas normalizadas.
    :param S_indices: Lista de índices de páginas en el Teleport Set.
    :param beta: Factor de amortiguación (default 0.85).
    :param max_iter: Iteraciones máximas.
    :param tol: Tolerancia para convergencia.
    :return: Vector de PageRank.
    """
    n = M.shape[0]
    # Vector de teletransporte sesgado e_S / |S|
    e_S = np.zeros(n)
    e_S[S_indices] = 1.0 / len(S_indices)
    
    # Vector inicial (puede ser uniforme o sesgado hacia S)
    v = np.zeros(n)
    v[S_indices] = 1.0 / len(S_indices)
    
    teleport_component = (1 - beta) * e_S
    
    for i in range(max_iter):
        v_new = beta * M.dot(v) + teleport_component
        # Verificar convergencia (norma L1 de la diferencia)
        if np.linalg.norm(v_new - v, 1) < tol:
            return v_new
        v = v_new
        
    return v

def calculate_spam_mass(pagerank, trustrank):
    """
    Calcula el Spam Mass para cada página.
    
    :param pagerank: Vector de PageRank estándar.
    :param trustrank: Vector de TrustRank.
    :return: Vector de Spam Mass.
    """
    # Evitar división por cero
    with np.errstate(divide='ignore', invalid='ignore'):
        mass = (pagerank - trustrank) / pagerank
        mass[np.isnan(mass)] = 0.0 # Manejar casos donde pagerank es 0
    return mass
```

## 8. Funciones, métodos, librerías o comandos identificados
- **$e_S$**: Vector indicador binario para el conjunto de teletransporte.
- **Similitud de Jaccard**: Métrica utilizada para inferir el tema de una página comparando conjuntos de palabras ($|A \cap B| / |A \cup B|$).
- **Open Directory (DMOZ)**: Fuente de datos mencionada para clasificación humana de temas (contexto histórico).
- **Matriz de Transición ($M$)**: Estructura central para el cálculo de PageRank.

## 9. Snippets o plantillas reutilizables
> *Sección no aplicable a este fragmento.*

## 10. Casos de uso y aplicaciones
- **Motores de búsqueda personalizados**: Un usuario que navega frecuentemente páginas de medicina recibe resultados de "jaguar" sesgados hacia la enfermedad y no hacia el auto o animal.
- **Detección de fraude web**: Identificación de granjas de enlaces mediante el análisis de estructuras circulares y cálculo de Spam Mass para filtrar resultados.
- **Clasificación de contenido**: Uso de conjuntos de palabras características para asignar categorías a páginas nuevas basándose en la frecuencia relativa de términos.

## 11. Limitaciones, riesgos y precauciones
- **Dependencia de la clasificación humana**: Topic-Sensitive PageRank requiere conjuntos $S$ definidos, a menudo dependientes de taxonomías humanas (como DMOZ) que pueden estar desactualizadas o incompletas.
- **Vulnerabilidad de TrustRank**: Páginas confiables que permiten contenido generado por usuarios (blogs, comentarios) pueden ser explotadas por spammers para obtener enlaces desde dominios de confianza.
- **Complejidad computacional**: Se debe calcular y almacenar un vector de PageRank por cada tema, lo que multiplica el costo de preprocesamiento.
- **Precisión en la inferencia de temas**: La inferencia basada en palabras clave puede fallar si los conjuntos de palabras $S_i$ son pequeños o ambiguos.

## 12. Relaciones con otros temas del corpus
- **PageRank básico**: Es el requisito previo; Topic-Sensitive PageRank es una generalización del modelo básico.
- **Matrices dispersas (Sparse Matrices)**: Mencionado en los ejercicios introductorios, crucial para la implementación eficiente de $M$ en gran escala.
- **Similitud de Jaccard**: Concepto de capítulos anteriores (MinHashing) reutilizado aquí para clasificación de documentos.
- **HITS**: Algoritmo alternativo a PageRank presentado al final del fragmento, que introduce el concepto dual de Hubs y Authorities.

## 13. Preguntas que la skill debería poder responder
1. ¿Cómo difiere la ecuación de iteración de Topic-Sensitive PageRank de la de PageRank estándar?
2. ¿Qué es un "Teleport Set" y cómo influye en los resultados de búsqueda?
3. ¿Cómo se calcula el Spam Mass de una página y qué indica un valor cercano a 1?
4. ¿Por qué es ineficiente almacenar un vector de PageRank por usuario y cómo soluciona esto el enfoque "Topic-Sensitive"?
5. ¿Qué estructura define un "Spam Farm" básico y cómo amplifica el PageRank?
6. ¿Qué es TrustRank y qué supuesto fundamental hace sobre las páginas confiables?
7. ¿Cómo se utiliza la similitud de Jaccard en la inferencia de temas para Topic-Sensitive PageRank?
8. ¿Cuál es la diferencia fundamental entre un "Hub" y una "Authority" en el modelo HITS?
9. ¿Por qué los dominios como .edu o .gov son candidatos ideales para el Teleport Set de TrustRank?
10. ¿Qué limitaciones presenta TrustRank en sitios web con comentarios de usuarios?

## 14. Acciones que la skill debería poder recomendar o ejecutar
- Implementar la iteración de PageRank con un vector de teletransporte personalizado.
- Calcular la métrica de Spam Mass dado un conjunto de datos de PageRank y TrustRank.
- Diseñar una estrategia de selección de semillas para TrustRank (mezcla de dominios controlados y verificación humana).
- Configurar un sistema de inferencia de temas basado en frecuencia de palabras y similitud de Jaccard.
- Evaluar si una estructura de enlaces corresponde a un Spam Farm simple.

## 15. Activos finales de conocimiento en formato compacto
| Concepto | Descripción | Referencia |
| :--- | :--- | :--- |
| **Topic-Sensitive PR** | PageRank con teletransporte restringido a un conjunto $S$ de páginas temáticas. | Sec 5.3 |
| **Ecuación TSPR** | $v' = \beta M v + (1-\beta)e_S/|S|$ | Sec 5.3.2 |
| **Spam Farm** | Estructura de $m$ páginas soporte enlazando a una página objetivo $t$ para capturar rank. | Sec 5.4.1 |
| **Amplificación Spam** | El spam farm amplifica el rank externo $x$ por factor $1/(1-\beta^2)$. | Sec 5.4.2 |
| **TrustRank** | Topic-Sensitive PR donde $S$ son páginas confiables (no spam). | Sec 5.4.4 |
| **Spam Mass** | Métrica $(r-t)/r$ para estimar la fracción de rank proveniente de spam. | Sec 5.4.5 |
| **Inferencia de Tema** | Clasificación de páginas usando similitud de Jaccard con conjuntos de palabras temáticas. | Sec 5.3.4 |
| **HITS** | Modelo que distingue páginas que enlazan (Hubs) de páginas enlazadas (Authorities). | Sec 5.5 |
| **Authority** | Página valiosa por su contenido informativo sobre un tema. | Sec 5.5.1 |
| **Hub** | Página valiosa por actuar como directorio de enlaces a autoridades. | Sec 5.5.1 |


