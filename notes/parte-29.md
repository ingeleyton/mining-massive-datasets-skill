# parte-29 — Mining-of-Massive-Datasets-Third-Edition-Jure-Leskovec-Anand-Rajaraman-etc-z-library-sk-1lib-sk-z-lib-parte-29.pdf

## 1. Metadatos del documento
- **Libro:** Mining of Massive Datasets, 3ª ed.
- **Fragmento/Parte:** Capítulo 8 - Advertising on the Web (Secciones 8.3 a 8.7)
- **Temas principales:** Algoritmos Online, Matching Bipartito, Problema Adwords, Algoritmo Balance, Ratio Competitivo, Implementación de Búsqueda de Anuncios
- **Tipo de contenido:** Mixto (Teoría / Algoritmo / Implementación / Caso de uso)

## 2. Resumen técnico de alto valor
El fragmento aborda la asignación eficiente de anuncios publicitarios en motores de búsqueda mediante algoritmos online. Se introduce el problema del **Matching Bipartito** como abstracción fundamental: dado un grafo con nodos izquierdos (anunciantes) y derechos (consultas), se busca un emparejamiento maximal. El algoritmo codicioso (Greedy) para este problema logra un ratio competitivo de exactamente $1/2$ respecto al óptimo offline.

Posteriormente, se define el **Problema Adwords**, donde los anunciantes tienen presupuestos y pujas por consultas específicas. Bajo un modelo simplificado (pujas 0/1, mismo presupuesto), el algoritmo Greedy obtiene ratio $1/2$, pero el **Algoritmo Balance** (asignar al postor con mayor presupuesto restante) mejora esto a $3/4$ para dos anunciantes y se aproxima a $1 - 1/e$ ($\approx 0.63$) para $N$ anunciantes. Para el caso generalizado (pujas y presupuestos arbitrarios), se presenta el **Algoritmo Balance Generalizado**, que utiliza una función de utilidad $\Psi_i = x_i(1 - e^{-f_i})$ para maximizar los ingresos, alcanzando el límite teórico de $1 - 1/e$.

Finalmente, se detalla la **implementación técnica** para hacer coincidir conjuntos de palabras (pujas) con documentos (emails, tweets), proponiendo una estructura de dos tablas hash y un ordenamiento de palabras por frecuencia ("rarest-first") para optimizar la memoria y la velocidad de procesamiento en streams de datos masivos.

## 3. Conceptos y definiciones clave
- **Algoritmo Online:** Algoritmo que debe procesar cada elemento de un stream de entrada inmediatamente, sin conocimiento de elementos futuros.
- **Algoritmo Offline:** Algoritmo que tiene acceso a todos los datos de entrada antes de producir una respuesta.
- **Ratio Competitivo:** Medida de calidad de un algoritmo online. Es el mínimo (sobre todas las entradas posibles) del cociente entre el valor obtenido por el algoritmo online y el valor obtenido por el algoritmo óptimo offline. $$RC = \min_{input} \left( \frac{\text{Valor Online}}{\text{Valor Óptimo Offline}} \right)$$
- **Grafo Bipartito:** Grafo cuyos nodos se dividen en dos conjuntos disjuntos (izquierdo y derecho) y todas las aristas conectan un nodo del conjunto izquierdo con uno del derecho.
- **Matching (Emparejamiento):** Subconjunto de aristas tal que ningún nodo es extremo de dos o más aristas.
- **Matching Perfecto:** Matching donde todos los nodos del grafo aparecen exactamente una vez. Requiere conjuntos de igual tamaño.
- **Matching Maximal:** Matching que contiene el mayor número posible de aristas para ese grafo.
- **Problema Adwords:** Asignación de anuncios a consultas de búsqueda maximizando ingresos, sujeta a pujas, tasas de clic (CTR) y presupuestos límite.
- **Click-Through Rate (CTR):** Probabilidad histórica de que un anuncio sea clicado al mostrarse.

## 4. Principios, reglas y heurísticas
- **Principio de decisión Greedy en Matching:** Al considerar una arista $(x, y)$, añádase al matching si ni $x$ ni $y$ están ya emparejados. Si no, se descarta.
- **Límite teórico Greedy Matching:** El ratio competitivo nunca supera $1/2$ en el peor caso (ejemplo de orden de aristas adversario).
- **Regla del Algoritmo Balance:** Ante una consulta, asignar el anuncio al postor que haya pujado por ella y tenga el mayor presupuesto restante.
- **Límite teórico Adwords:** Ningún algoritmo online para el problema Adwords (con presupuestos) puede superar un ratio competitivo de $1 - 1/e$.
- **Heurística de Implementación "Rarest-First":** Al indexar pujas y procesar documentos, ordenar las palabras de menor a mayor frecuencia global. Esto minimiza el tamaño de la tabla hash de coincidencias parciales, ya que las palabras raras discriminan más rápido.
- **Regla de valor de anuncio:** El valor esperado de un anuncio es el producto de la puja ($bid$) por la tasa de clics ($CTR$).

## 5. Procedimientos, métodos y workflows

### 5.1 Algoritmo Balance Generalizado
**Precondiciones:** Llega una consulta $q$. Existen anunciantes $A_i$ con pujas $x_i$ (valor esperado) y fracción de presupuesto restante $f_i$.
**Pasos:**
1. Para cada anunciantes $A_i$ que puja por $q$:
   a. Calcular valor $\Psi_i = x_i [1 - \exp(-f_i)]$.
2. Seleccionar el anunciante $A_k$ con el máximo $\Psi_k$.
3. Asignar el anuncio a $A_k$ y actualizar su presupuesto restante.
**Postcondición:** Se maximiza la probabilidad de agotar presupuestos de forma equilibrada, garantizando ratio $1 - 1/e$.

### 5.2 Algoritmo de Matching de Documentos y Pujas
**Contexto:** Coincidencia de conjuntos de palabras (pujas) dentro de documentos grandes (emails, tweets).
**Precondiciones:** Tabla hash principal de pujas (clave: primera palabra de la puja ordenada). Tabla hash temporal para coincidencias parciales.
**Workflow:**
1. Ordenar palabras del documento entrante (orden "rarest-first"). Eliminar duplicados.
2. Para cada palabra $w$ en el documento ordenado:
   a. **Verificar coincidencias parciales:** Buscar $w$ en tabla de coincidencias parciales.
      - Si $w$ es la última palabra de una puja parcial $\to$ mover a lista de coincidencias completas (Output).
      - Si no es la última $\to$ incrementar estado de la puja y re-hashear usando la siguiente palabra como clave.
   b. **Iniciar nuevas coincidencias:** Buscar $w$ en tabla principal de pujas.
      - Si la puja tiene solo una palabra $\to$ mover a Output.
      - Si tiene más palabras $\to$ insertar en tabla de coincidencias parciales con estado 1, usando la segunda palabra como clave.
3. Devolver lista de pujas coincidentes.

## 6. Problemas comunes y soluciones
- **Problema:** El algoritmo Greedy simple en Adwords asigna consultas a los primeros postores, agotando sus presupuestos rápidamente y dejando consultas posteriores sin atender (ejemplo $xxyy$ con dos anunciantes).
  **Solución:** Usar **Algoritmo Balance**, que prioriza al postor con más presupuesto libre, logrando ratio $3/4$ en lugar de $1/2$.
- **Problema:** El Algoritmo Balance falla con pujas de valores diferentes (ej. puja pequeña con presupuesto enorme vs puja grande con presupuesto pequeño). Balance elegiría al de presupuesto grande, perdiendo ingresos.
  **Solución:** Usar **Balance Generalizado** que pondera la puja ($x_i$) con una función de penalización basada en el presupuesto restante $(1 - e^{-f_i})$.
- **Problema:** Búsqueda de coincidencias de pujas en documentos largos (no solo consultas exactas) es computacionalmente costosa ($O(2^n)$ subconjuntos).
  **Solución:** Implementar el sistema de dos tablas hash con ordenamiento "rarest-first" para descartar rápidamente pujas que no contienen las palabras más discriminatorias.

## 7. Implementación técnica y generación de código

```pseudocode
# Algoritmo Balance Generalizado para una consulta q
Función SeleccionarAnuncio(q, Anunciantes):
    max_psi = -infinito
    ganador = NULO
    
    Para cada A en Anunciantes:
        Si A.puja_por(q):
            x = A.valor_puja(q) * A.CTR(q)  # Valor esperado
            f = A.presupuesto_restante / A.presupuesto_total # Fracción restante
            psi = x * (1 - exp(-f))
            
            Si psi > max_psi:
                max_psi = psi
                ganador = A
                
    Retornar ganador
```

```python
import math

def generalized_balance_algorithm(query_bidders, budgets_spent, budgets_total, bids_values):
    """
    Selecciona el mejor anunciante para una consulta según el algoritmo Balance Generalizado.
    
    :param query_bidders: Lista de IDs de anunciantes que pujan por la consulta actual.
    :param budgets_spent: Diccionario {id_anunciante: cantidad_gastada}.
    :param budgets_total: Diccionario {id_anunciante: presupuesto_total}.
    :param bids_values: Diccionario {id_anunciante: valor_puja} (bid * CTR).
    :return: ID del anunciante ganador o None.
    """
    best_bidder = None
    max_psi = -1.0
    
    for bidder_id in query_bidders:
        # Valor de la puja (x_i)
        x_i = bids_values.get(bidder_id, 0)
        
        # Fracción de presupuesto restante (f_i)
        total_b = budgets_total.get(bidder_id, 1) # Evitar división por cero
        spent = budgets_spent.get(bidder_id, 0)
        
        if total_b == 0: continue
        
        f_i = (total_b - spent) / total_b
        
        # Cálculo de la función Psi
        # Psi_i = x_i * (1 - e^(-f_i))
        psi = x_i * (1 - math.exp(-f_i))
        
        if psi > max_psi:
            max_psi = psi
            best_bidder = bidder_id
            
    return best_bidder
```

## 8. Funciones, métodos, librerías o comandos identificados
- **Hash Table / Diccionario:** Estructura central para el índice de pujas y para el estado temporal de matching.
- **`exp(-f)`**: Función exponencial utilizada en la fórmula de Balance Generalizado para suavizar la penalización por presupuesto gastado.
- **Sorting (Lexicográfico / Rarest-First):** Método de preprocesamiento para normalizar consultas y pujas.
- **Status (Estado):** Entero asociado a una puja en la tabla hash temporal que indica cuántas palabras se han emparejado secuencialmente.

## 9. Snippets o plantillas reutilizables

```python
# Snippet: Estructura de índice para matching de documentos (Rarest-First)
# Nota: Requiere una lista global de frecuencias de palabras para ordenar.

class AdIndex:
    def __init__(self):
        # Tabla principal: clave = primera palabra, valor = lista de objetos puja
        self.main_index = {} 
        # Tabla temporal para procesamiento de un documento
        self.partial_matches = {} 

    def add_bid(self, bid_words, bid_id):
        # Ordenar palabras según heurística 'rarest-first' (simulado aquí con sort simple)
        sorted_words = sorted(bid_words) 
        first_word = sorted_words[0]
        
        if first_word not in self.main_index:
            self.main_index[first_word] = []
        
        # Guardar la puja con su estructura ordenada y estado inicial 0
        self.main_index[first_word].append({
            'id': bid_id,
            'words': sorted_words,
            'status': 0 # Índice de la siguiente palabra a buscar
        })

    def process_document(self, doc_words):
        # Ordenar documento
        sorted_doc = sorted(set(doc_words))
        matches = []
        
        self.partial_matches.clear()
        
        for word in sorted_doc:
            # 1. Chequear coincidencias parciales existentes
            if word in self.partial_matches:
                bids_to_update = self.partial_matches[word]
                del self.partial_matches[word] # Se mueven o rehashean
                
                for bid in bids_to_update:
                    next_idx = bid['status'] + 1
                    if next_idx == len(bid['words']):
                        # Coincidencia completa
                        matches.append(bid['id'])
                    else:
                        # Mover a siguiente palabra
                        bid['status'] = next_idx
                        next_key = bid['words'][next_idx]
                        if next_key not in self.partial_matches:
                            self.partial_matches[next_key] = []
                        self.partial_matches[next_key].append(bid)
            
            # 2. Chequear nuevas coincidencias en índice principal
            if word in self.main_index:
                for bid in self.main_index[word]:
                    if len(bid['words']) == 1:
                        matches.append(bid['id'])
                    else:
                        # Iniciar coincidencia parcial
                        new_bid = bid.copy()
                        new_bid['status'] = 1
                        second_key = new_bid['words'][1]
                        if second_key not in self.partial_matches:
                            self.partial_matches[second_key] = []
                        self.partial_matches[second_key].append(new_bid)
                        
        return matches
```

## 10. Casos de uso y aplicaciones
- **Publicidad en Buscadores (Adwords):** Asignación de anuncios textuales a consultas de usuarios en tiempo real (Google, Bing).
- **Publicidad en Email:** Inserción de anuncios contextuales en servicios de correo electrónico basados en el contenido del mensaje.
- **Monitoreo de Redes Sociales (Twitter):** Detección de tweets que coinciden con conjuntos de palabras de interés (ej. "ipod free music") para alertas o publicidad.
- **Sistemas de Alertas de Noticias:** Notificación a usuarios cuando artículos contienen conjuntos específicos de términos.

## 11. Limitaciones, riesgos y precauciones
- **Límite de $1 - 1/e$:** Es imposible superar este ratio competitivo para el problema Adwords online básico. Cualquier optimización adicional requiere conocimiento previo (histórico) o relajación de restricciones.
- **Dependencia del Historial:** El algoritmo asume que la frecuencia histórica de consultas es estable. Un adversario que controle la secuencia de consultas puede explotar debilidades si se relaja la función $\Psi$ basada en predicciones de demanda futura.
- **Memoria Principal:** La implementación eficiente requiere mantener índices hash en memoria RAM. Para volúmenes masivos (>10GB), se requiere sharding (fragmentación) entre múltiples máquinas.
- **Matching Exacto vs Broad Matching:** El modelo descrito asume coincidencia exacta de conjuntos de palabras. El "Broad Matching" (sinónimos, subconjuntos) complica la implementación y requiere fórmulas de precio más sofisticadas no detalladas completamente en el algoritmo principal.

## 12. Relaciones con otros temas del corpus
- **Teoría de Grafos:** El problema de matching se fundamenta en grafos bipartitos.
- **Hashing (Capítulo 1):** Uso de tablas hash para índices invertidos y búsqueda eficiente.
- **Análisis de Streams (Capítulo 4):** Los algoritmos online son inherentemente algoritmos de procesamiento de streams.
- **PageRank (Capítulo 5):** Mencionado como criterio para ordenar resultados orgánicos, distinguiéndolos de los anuncios pagados.
- **Subastas (Economía/Teoría de Juegos):** El modelo de "Second-Price Auction" se menciona como práctica real del mercado, contrastando con el modelo de "First-Price" simplificado del texto.

## 13. Preguntas que la skill debería poder responder
1. ¿Cuál es el ratio competitivo del algoritmo Greedy para el problema de Matching Bipartito y por qué?
2. ¿Cómo mejora el Algoritmo Balance al algoritmo Greedy simple en el contexto del problema Adwords?
3. ¿Qué fórmula se utiliza en el Algoritmo Balance Generalizado para calcular la prioridad de un anunciante?
4. ¿Por qué el ratio competitivo de Balance tiende a $1 - 1/e$ cuando el número de anunciantes crece?
5. ¿Qué estrategia de ordenamiento de palabras se recomienda para implementar el matching de pujas en documentos largos y por qué?
6. ¿Cuál es la diferencia principal entre el modelo de subasta de primer precio y el de segundo precio mencionado en el texto?
7. ¿Cómo se gestiona el estado de las pujas parcialmente coincidentes en el algoritmo de implementación propuesto?

## 14. Acciones que la skill debería poder recomendar o ejecutar
1. **Seleccionar algoritmo:** Elegir entre Greedy, Balance o Balance Generalizado según la complejidad de las pujas (binarias vs arbitrarias).
2. **Diseñar índice:** Implementar una estructura de índice basada en hash para pujas publicitarias.
3. **Optimizar memoria:** Aplicar ordenamiento "rarest-first" para reducir el footprint de memoria en tablas de coincidencias parciales.
4. **Calcular ingresos:** Estimar el rendimiento peor caso de un sistema de publicidad usando ratios competitivos teóricos.
5. **Procesar streams:** Diseñar un pipeline que acepte consultas y devuelva anuncios asignados en tiempo real.

## 15. Activos finales de conocimiento en formato compacto

| Concepto | Descripción | Referencia |
| :--- | :--- | :--- |
| **Ratio Competitivo** | Mide el peor caso de un algoritmo online vs el óptimo offline. | Sec 8.3.3 |
| **Greedy Matching** | Ratio competitivo $1/2$. Suficiente para casos simples. | Sec 8.3.2 |
| **Algoritmo Balance** | Maximiza presupuesto restante. Ratio $3/4$ (2 agentes) o $1-1/e$ (N agentes). | Sec 8.4.4 |
| **Balance Generalizado** | Usa $\Psi = x(1-e^{-f})$. Óptimo para pujas variables. Ratio $1-1/e$. | Sec 8.4.7 |
| **Rarest-First Ordering** | Ordenar palabras por frecuencia ascendente para optimizar hashing. | Sec 8.5.3 |
| **Matching Bipartito** | Base teórica: emparejar nodos izquierda (anunciantes) y derecha (consultas). | Sec 8.3.1 |
| **Adwords Problem** | Asignar anuncios maximizando ingresos bajo restricciones de presupuesto. | Sec 8.4.2 |
| **Two-Hash-Table Method** | Técnica para matching de subconjuntos en documentos (parciales vs índice). | Sec 8.5.3 |
