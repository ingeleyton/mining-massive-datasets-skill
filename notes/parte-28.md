# parte-28 — Mining-of-Massive-Datasets-Third-Edition-Jure-Leskovec-Anand-Rajaraman-etc-z-library-sk-1lib-sk-z-lib-parte-28.pdf

## 1. Metadatos del documento
- **Libro:** Mining of Massive Datasets, 3ª ed.
- **Fragmento/Parte:** Chapter 8. Advertising on the Web (Secciones 8.1, 8.2, 8.3)
- **Temas principales:** Publicidad Online, Algoritmos Online, Algoritmos Voraces (Greedy), Ratio Competitivo, Matching Bipartito, Modelos de ingresos (Adwords)
- **Tipo de contenido:** Mixto (Teoría / Algoritmo / Caso de uso)

## 2. Resumen técnico de alto valor
El fragmento aborda la problemática de la asignación de publicidad en la web, distinguiendo entre modelos de colocación directa, display ads y search ads. Se centra en el modelo de "adwords" (subasta por clic), donde la asignación óptima de anuncios a consultas de búsqueda requiere algoritmos que operan bajo incertidumbre temporal. Se introduce formalmente el concepto de **Algoritmo Online**, el cual debe procesar entradas secuenciales sin conocimiento del futuro, contrastándolo con los algoritmos off-line. Para evaluar la calidad de estos algoritmos, se define el **Ratio Competitivo**, una métrica que compara el rendimiento del algoritmo online contra el óptimo off-line ($minimo \ge c \times \text{óptimo}$). Se demuestra que un algoritmo voraz (greedy) simple, que asigna la consulta al postor con mayor puja, tiene un ratio competitivo de $1/2$ en el peor caso. Finalmente, se introduce el problema del **Matching Bipartito** como una abstracción matemática para la asignación de anuncios, definiendo conceptos de matching, matching perfecto y maximal.

## 3. Conceptos y definiciones clave
- **Impresión:** Cada instancia de visualización de un anuncio en la descarga de una página. Una segunda descarga por el mismo usuario cuenta como una nueva impresión.
- **Adwords Model:** Modelo de publicidad donde los anunciantes pujan por términos de búsqueda y pagan solo si el usuario hace clic en el anuncio. Involucra términos de puja, cantidad ofertada, CTR y presupuesto total.
- **Algoritmo Off-line:** Algoritmo que tiene acceso a todos los datos necesarios antes de comenzar el procesamiento y puede acceder a ellos en cualquier orden.
- **Algoritmo On-line:** Algoritmo que debe procesar cada elemento de entrada secuencialmente y tomar decisiones inmediatas sin conocimiento de elementos futuros.
- **Algoritmo Greedy (Voraz):** Tipo de algoritmo que toma la decisión localmente óptima en cada paso basándose solo en la entrada actual y el estado pasado.
- **Ratio Competitivo:** Constante $c < 1$ tal que para cualquier entrada, el resultado del algoritmo online es al menos $c$ veces el resultado del algoritmo óptimo off-line.
- **Grafo Bipartito:** Grafo cuyos nodos se pueden dividir en dos conjuntos disjuntos (izquierdo y derecho) tales que toda arista conecta un nodo del conjunto izquierdo con uno del derecho.
- **Matching:** Subconjunto de aristas en un grafo tal que ningún nodo es extremo de dos o más aristas.
- **Matching Perfecto:** Matching donde todos los nodos del grafo aparecen exactamente una vez. Requiere conjuntos de igual tamaño.
- **Matching Maximal:** Matching de tamaño máximo posible para el grafo dado (no se pueden agregar más aristas sin violar la definición de matching).

## 4. Principios, reglas y heurísticas
- **Sesgo de posición en anuncios:** La probabilidad de clic disminuye exponencialmente conforme el anuncio baja posiciones en la lista. La primera posición tiene la probabilidad más alta.
- **Dilema de exploración vs explotación en anuncios:** Todos los anuncios merecen oportunidad de mostrarse para aproximar su probabilidad de clic; si se inicia con probabilidad 0, nunca se mostrarán y nunca se aprenderá su atractivo.
- **Heurística de asignación Greedy:** Asignar la consulta de búsqueda al postor con la puja más alta que aún tenga presupuesto restante.
- **Límite del Ratio Competitivo Greedy:** Para el problema de asignación de anuncios simplificado, el algoritmo greedy tiene un ratio competitivo de exactamente $1/2$.
- **Privacidad vs Efectividad:** La efectividad de los display ads aumenta con el uso de información del usuario (historial, emails, bookmarks), pero esto genera conflictos de privacidad.

## 5. Procedimientos, métodos y workflows
### Asignación de anuncios con algoritmo Greedy (Online)
1.  **Precondición:** Llega una consulta de búsqueda. Existe un conjunto de anunciantes con pujas y presupuestos.
2.  **Filtrado:** Identificar anunciantes interesados en los términos de la consulta.
3.  **Verificación de presupuesto:** Filtrar aquellos cuyo presupuesto se haya agotado.
4.  **Selección (Paso Greedy):** Seleccionar al anunciante con la puja más alta entre los candidatos restantes.
5.  **Postcondición:** Mostrar anuncio. Si hay clic, descontar importe del presupuesto del anunciante.

### Evaluación de Ratio Competitivo
1.  Definir el problema y el algoritmo online $A$.
2.  Calcular el resultado óptimo off-line $OPT$ (conocimiento total del futuro).
3.  Calcular el resultado de $A$ en el peor caso posible de entrada.
4.  Determinar $c$ tal que $Resultado(A) \ge c \times OPT$.

## 6. Problemas comunes y soluciones
- **Problema:** Abuso en ranking "más reciente primero" (anunciantes publican variaciones menores frecuentemente).
    - **Solución:** Usar tecnología de detección de similitud (Sección 3.4 del libro) para identificar anuncios casi idénticos.
- **Problema:** Ineficiencia de algoritmos Greedy en asignación de anuncios (Ejemplo 8.2).
    - **Situación:** Un anunciante $B$ puja alto por términos comunes y agota su presupuesto rápido, dejando sin atender términos específicos que otro anunciante $A$ podría haber cubierto.
    - **Consecuencia:** Pérdida de ingresos comparado con el óptimo off-line.
    - **Mitigación (implícita):** Necesidad de algoritmos más sofisticados que el Greedy puro (a desarrollar en secciones posteriores no incluidas en el fragmento).
- **Problema:** Evaluación de atractivo de anuncios nuevos.
    - **Solución:** Garantizar impresiones iniciales para estimar la tasa de clics (CTR), a pesar del sesgo de posición.

## 7. Implementación técnica y generación de código

```pseudocode
# Algoritmo Greedy para asignación de anuncios (Ejemplo 8.2)
# Entrada: Consulta Q, Conjunto de Anunciantes Advers
# Salida: Anunciante seleccionado o Null

Función SelectAdGreedy(Query Q, Advertisers A):
    Candidatos = FiltrarAnunciantesPorTermino(Q, A)
    CandidatosConPresupuesto = FiltrarPorPresupuestoDisponible(Candidatos)
    
    Si CandidatosConPresupuesto esta vacio:
        Retornar Null
    
    # Decisión Greedy: Maximizar ganancia inmediata
    MejorAnunciante = ObtenerMaximaPuja(CandidatosConPresupuesto)
    
    Retornar MejorAnunciante
```

```python
# Simulación del Ejemplo 8.2 para demostrar el fallo del algoritmo Greedy
# y el cálculo del ratio competitivo.

def simulate_greedy_ad_allocation(queries, advertisers):
    """
    Simula la asignación de anuncios con un algoritmo Greedy.
    
    :param queries: Lista de strings representando consultas de búsqueda.
    :param advertisers: Dict {nombre: {'bid': float, 'budget': float, 'keywords': set}}
    :return: Ingresos totales generados.
    """
    total_revenue = 0.0
    
    for query in queries:
        candidates = []
        for name, data in advertisers.items():
            # Verificar si el anunciante puja por el término y tiene presupuesto
            if query in data['keywords'] and data['budget'] >= data['bid']:
                candidates.append((name, data['bid']))
        
        if candidates:
            # Greedy: Seleccionar al postor con la puja más alta
            # Ordenar por puja descendente
            candidates.sort(key=lambda x: x[1], reverse=True)
            winner_name, winning_bid = candidates[0]
            
            # Transacción
            advertisers[winner_name]['budget'] -= winning_bid
            total_revenue += winning_bid
            
    return total_revenue

# Datos del Ejemplo 8.2
# A: Puja 10 centavos en "chesterfield", Budget $100
# B: Puja 20 centavos en "chesterfield" y "sofa", Budget $100
advertisers_data = {
    'A': {'bid': 0.10, 'budget': 100.0, 'keywords': {'chesterfield'}},
    'B': {'bid': 0.20, 'budget': 100.0, 'keywords': {'chesterfield', 'sofa'}}
}

# Caso peor para Greedy: 500 "chesterfield" seguidos de 500 "sofa"
# Greedy asigna los primeros 500 a B (agota presupuesto B), luego no tiene postor para "sofa".
worst_case_queries = ['chesterfield'] * 500 + ['sofa'] * 500

# Copia profunda para no mutar el diccionario original en simulaciones repetidas
import copy
revenue_greedy = simulate_greedy_ad_allocation(worst_case_queries, copy.deepcopy(advertisers_data))

# Óptimo Off-line:
# Asignar 500 "chesterfield" a A ($50) + 500 "sofa" a B ($100) = $150
revenue_optimal = 150.0

print(f"Ingresos Greedy: ${revenue_greedy}")
print(f"Ingresos Óptimo: ${revenue_optimal}")
print(f"Ratio Competitivo observado: {revenue_greedy/revenue_optimal}") 
# Salida esperada: 0.66 (100/150), que es peor que el límite teórico de 0.5 para casos más extremos.
```

## 8. Funciones, métodos, librerías o comandos identificados
- **Inverted Index:** Estructura de datos usada para recuperar anuncios que contienen palabras específicas de una consulta (mismo método que motores de búsqueda).
- **Click-Through Rate (CTR):** Métrica calculada como la fracción de veces que un anuncio es clicado respecto a las veces que se muestra. Usada para evaluar el "atractivo" del anuncio.
- **Pull-down menus:** Método alternativo a índices invertidos para consultas estructuradas (ej. buscar autos por modelo/año), almacenado en bases de datos relacionales.

## 9. Snippets o plantillas reutilizables
> *Sección no aplicable a este fragmento.*

## 10. Casos de uso y aplicaciones
- **Motores de búsqueda (Google, Bing):** Asignación de anuncios patrocinados en resultados de búsqueda (Search Ads).
- **Marketplaces (eBay, Craig's List):** Colocación directa de anuncios clasificados con ranking por recencia o relevancia.
- **E-commerce (Amazon):** Publicidad de productos propios o de terceros optimizada para probabilidad de interés (mencionado para Capítulo 9).
- **Display Advertising:** Segmentación de usuarios basada en comportamiento (historial de navegación, emails) para mostrar anuncios en páginas web genéricas.

## 11. Limitaciones, riesgos y precauciones
- **Limitación fundamental de Algoritmos Online:** Nunca pueden superar al óptimo off-line. El ratio competitivo define qué tan "malo" puede ser el resultado en el peor caso.
- **Riesgo de privacidad:** El uso de datos de usuario (emails, grupos sociales, historial) para display ads plantea riesgos éticos y de privacidad significativos.
- **Complejidad del modelo real:** El modelo simplificado asume un clic por impresión y presupuesto fijo. En la realidad, el CTR es probabilístico y los presupuestos se consumen solo si hay clic, no por impresión (en search ads).
- **Dependencia de datos históricos:** La evaluación de atractivo de anuncios nuevos requiere datos que no existen al inicio (problema de arranque en frío).

## 12. Relaciones con otros temas del corpus
- **Capítulo 5 (Indexing):** Uso de índices invertidos para recuperación de anuncios.
- **Capítulo 3 (Finding Similar Items):** Detección de anuncios casi duplicados para evitar abuso del ranking por recencia.
- **Capítulo 4 (Mining Data Streams):** Los algoritmos online son un caso extremo de minería de flujos de datos donde se debe responder tras cada elemento.
- **Capítulo 9 (Recommendation Systems):** Conexión directa con "Collaborative Filtering" para anuncios en tiendas online.
- **Teoría de Grafos:** Matching Bipartito como fundamento matemático para la asignación de anuncios.

## 13. Preguntas que la skill debería poder responder
1. ¿Cuál es la diferencia fundamental entre un algoritmo online y uno off-line en el contexto de publicidad web?
2. ¿Cómo se define el "ratio competitivo" y por qué es importante para evaluar algoritmos online?
3. ¿Por qué un algoritmo greedy simple tiene un ratio competitivo de $1/2$ en el problema de asignación de anuncios?
4. ¿Qué factores influyen en la probabilidad de clic de un anuncio además de su contenido?
5. ¿Cómo se relaciona el problema de "matching bipartito" con la asignación de anuncios?
6. ¿Qué estrategias existen para rankear anuncios en sistemas de colocación directa (como eBay) y cuáles son sus riesgos?
7. ¿Qué es el sesgo de posición en anuncios y cómo afecta la evaluación del atractivo de un anuncio?
8. ¿Cuáles son las diferencias técnicas entre "search ads" y "display ads"?

## 14. Acciones que la skill debería poder recomendar o ejecutar
- Calcular el ratio competitivo de un algoritmo online dado un escenario de peor caso.
- Implementar un algoritmo greedy básico para asignación de recursos con presupuesto.
- Diseñar un esquema de base de datos para anuncios con parámetros estructurados (ej. autos usados).
- Identificar cuándo un problema de optimización requiere un enfoque online vs off-line.
- Diagnosticar pérdidas de ingresos en asignación greedy debido a agotamiento prematuro de presupuestos.

## 15. Activos finales de conocimiento en formato compacto
| Concepto | Descripción | Referencia |
| :--- | :--- | :--- |
| **Ratio Competitivo** | Cota inferior $c$ tal que $AlgoOnline \ge c \times OptimoOffline$. | Sec 8.2.3 |
| **Algoritmo Online** | Procesa entrada secuencial sin conocimiento del futuro; decisión irreversible por elemento. | Sec 8.2.1 |
| **Algoritmo Greedy** | Heurística que maximiza la función objetivo local en cada paso. | Sec 8.2.2 |
| **Matching Bipartito** | Subconjunto de aristas sin nodos compartidos; modelo abstracto para asignación ads-queries. | Sec 8.3.1 |
| **Search Ad** | Modelo de pago por clic (PPC) con puja, presupuesto y términos de búsqueda. | Sec 8.1.1 |
| **Display Ad** | Modelo de pago por impresión (CPM), a menudo segmentado por perfil de usuario. | Sec 8.1.3 |
| **Sesgo de Posición** | Caída exponencial de probabilidad de clic según la posición del anuncio en la lista. | Sec 8.1.2 |
| **Problema Ski-Buying** | Ejemplo canónico de diseño de algoritmos online para minimizar ratio competitivo. | Ejercicio 8.2.1 |
| **Límite Greedy** | El algoritmo greedy simple nunca rinde menos de la mitad del óptimo ($c=1/2$). | Sec 8.2.3 |
| **Inverted Index** | Estructura usada para recuperar anuncios relevantes basados en palabras clave. | Sec 8.1.2 |
