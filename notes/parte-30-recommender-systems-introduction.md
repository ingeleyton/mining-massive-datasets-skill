# Parte 30 - Recommender Systems Introduction

## 1. Metadatos del documento
- **Libro:** Mining of Massive Datasets, 3ª ed.
- **Fragmento/Parte:** Parte 30 - Recommender Systems Introduction
- **Temas principales:** Sistemas de recomendación, Matriz de utilidad, Long Tail, Filtrado colaborativo vs. basado en contenido, Obtención de datos implícitos/explícito.
- **Tipo de contenido:** Teoría / Modelo Conceptual / Caso de uso

## 2. Resumen técnico de alto valor
El capítulo introduce los sistemas de recomendación como mecanismos para predecir respuestas de usuarios ante opciones, fundamentalmente bajo el modelo de la **matriz de utilidad**. Esta matriz, dispersa por naturaleza, relaciona usuarios e ítems mediante valores de preferencia (ratings o inferencias conductuales). Se distingue entre sistemas **basados en contenido** (propiedades del ítem) y **filtrado colaborativo** (similitud entre usuarios/ítems).

El fragmento establece el fenómeno del **"Long Tail"** como justificación económica y técnica: mientras el comercio físico se limita a ítems populares por restricciones de espacio, el comercio online ofrece un inventario masivo donde la recomendación es indispensable para la descubribilidad. El objetivo técnico no es necesariamente completar toda la matriz, sino identificar entradas de alto valor para cada usuario. Se identifican dos fuentes de datos para poblar la matriz: **ratings explícitos** (sesgados y escasos) y **datos implícitos** (inferidos de comportamiento, binarios y más abundantes).

## 3. Conceptos y definiciones clave
- **Sistema de Recomendación:** Clase de aplicaciones web que predice respuestas de usuarios a opciones, sugiriendo ítems de alto valor esperado.
- **Matriz de Utilidad (Utility Matrix):** Estructura de datos central que almacena las preferencias conocidas. Filas = Usuarios, Columnas = Ítems. Celdas = Valor de preferencia (escalar o binario). Es inherentemente dispersa (sparse).
- **Long Tail (Larga Estela):** Fenómeno donde la distribución de popularidad permite a minoristas online ofrecer un inventario vastamente superior al físico. La recomendación es crítica para navegar la "cola" de baja popularidad pero alta diversidad.
- **Sistemas Basados en Contenido (Content-based):** Recomiendan ítems basándose en atributos intrínsecos (ej: género, director) comparados con el historial del usuario.
- **Filtrado Colaborativo (Collaborative Filtering):** Recomienda ítems basándose en la similitud entre usuarios o entre ítems, independientemente de su contenido. Reiere medidas de similitud y clustering.
- **Rating Explícito:** Preferencia provista activamente por el usuario (ej: 1-5 estrellas). Problemático por baja tasa de respuesta y sesgo.
- **Rating Implícito:** Preferencia inferida de la conducta observada (ej: compra, visualización, click). Generalmente binario (1 = interacción, 0/blank = sin interacción).

## 4. Principios, reglas y heurísticas
- **Principio de dispersión (Sparsity):** Asumir que la mayoría de las entradas en la matriz de utilidad son desconocidas ("blanks"), no cero.
- **Objetivo de predicción:** No es obligatorio predecir cada celda en blanco. El objetivo principal es descubrir un subconjunto de ítems con alta calificación esperada para recomendar.
- **Sesgo de respuesta:** En ratings explícitos, los datos provienen de usuarios dispuestos a calificar, lo que introduce un sesgo inherente en la muestra.
- **Interpretación de datos implícitos:**
    - Un "1" indica preferencia (compra, visualización).
    - Un "0" (o ausencia de dato) en datos implícitos no significa "no me gusta", significa "sin información". No es una calificación negativa.
- **Dependencia tecnológica:** El filtrado colaborativo se apoya en técnicas de búsqueda de similitud (Capítulo 3) y clustering (Capítulo 7) del mismo libro.

## 5. Procedimientos, métodos y workflows
### Poblado de la Matriz de Utilidad
1.  **Identificación de Entidades:** Definir el conjunto de Usuarios ($U$) e Ítems ($I$).
2.  **Captura de Datos:**
    *   *Método A (Explícito):* Solicitar calificación al usuario post-interacción. (Limitado por voluntad del usuario).
    *   *Método B (Implícito):* Observar comportamiento (compras, clicks, tiempo de lectura). Mapear interacción a valor binario (1).
3.  **Construcción de la Matriz:** Crear estructura $M_{|U| \times |I|}$. Marcar celdas desconocidas como vacías (no cero).
4.  **Predicción/Recomendación:** Aplicar algoritmo (contenido o colaborativo) para estimar valores en celdas vacías o extraer Top-K ítems.

## 6. Problemas comunes y soluciones
- **Problema: Escasez de datos (Sparsity).** La matriz tiene demasiados huecos para hacer predicciones confiables.
    - *Solución sugerida:* Usar datos implícitos para poblar más celdas, aunque sea con menor granularidad (binario vs escalar).
- **Problema: Sesgo en ratings explícitos.** Solo califican usuarios muy satisfechos o muy insatisfechos.
    - *Solución sugerida:* Complementar con datos implícitos de navegación para obtener una visión más neutral del interés.
- **Problema: Ambigüedad del "0" en datos implícitos.** Tratar la no-compra como "no me gusta".
    - *Solución:* Tratar la no-interacción como "desconocido" (blank), no como un valor numérico cero en el algoritmo de predicción.

## 7. Implementación técnica y generación de código
> *Sección no aplicable a este fragmento.*

```python
# Implementación Python derivada: Estructura básica de Matriz de Utilidad dispersa
import numpy as np
from scipy.sparse import csr_matrix

# Datos de ejemplo (Usuario, Item, Rating)
# Usuarios: A=0, B=1, C=2, D=3
# Items: HP1=0, HP2=1, HP3=2, TW=3, SW1=4, SW2=5, SW3=6
data = {
    'user_item': [(0,0,4), (0,1,5), (0,4,1), # A: HP1, HP2, SW1
                  (1,0,5), (1,1,5), (1,5,4), # B: HP1, HP2, SW2
                  (2,3,2), (2,4,4), (2,5,5), # C: TW, SW1, SW2
                  (3,2,3), (3,3,3)],         # D: HP3, TW
}

# Crear matriz dispersa (CSR - Compressed Sparse Row)
rows = [x[0] for x in data['user_item']]
cols = [x[1] for x in data['user_item']]
vals = [x[2] for x in data['user_item']]

utility_matrix = csr_matrix((vals, (rows, cols)), shape=(4, 7))

print("Matriz de Utilidad (densa para visualización):")
print(utility_matrix.toarray())
# Nota: Los ceros en la salida son 'blanks' desconocidos, no calificaciones bajas.
```

## 8. Funciones, métodos, librerías o comandos identificados
- **Utility Matrix:** Estructura de datos fundamental.
- **RMSE (Root-Mean-Square Error):** Métrica mencionada para evaluar precisión de predicción (caso Netflix Prize).
- **CSR (Compressed Sparse Row):** Formato eficiente para almacenar la matriz de utilidad en memoria (derivado de la naturaleza dispersa descrita).

## 9. Snippets o plantillas reutilizables

```python
def infer_implicit_rating(user_actions, action_weights=None):
    """
    Convierte eventos implícitos en un valor para la matriz de utilidad.
    """
    if action_weights is None:
        action_weights = {'view': 0.2, 'cart': 0.5, 'purchase': 1.0}
    
    score = 0
    for action in user_actions:
        score += action_weights.get(action, 0)
    
    # Normalizar o mantener como ponderación de confianza
    return min(score, 1.0) # Ejemplo: normalizar a 1
```

## 10. Casos de uso y aplicaciones
- **Retail Online (Amazon):** Recomendación de productos basada en historial de compras y búsquedas. Aprovecha el Long Tail para vender ítems de nicho.
- **Streaming de Películas (Netflix):** Predicción de ratings de películas. Caso de estudio: Netflix Prize ($1M por mejorar RMSE en 10%).
- **Agregadores de Noticias:** Sugerencia de artículos basada en lecturas previas o similitud de contenido.
- **Efecto "Touching the Void":** Caso de libro de nicho que se volvió best-seller gracias a recomendaciones automáticas basadas en similitud con "Into Thin Air".

## 11. Limitaciones, riesgos y precauciones
- **Escalabilidad:** La matriz crece con $|Users| \times |Items|$. Para datasets masivos, requiere representaciones dispersas y algoritmos escalables.
- **Cold Start:** El texto implica dificultad para recomendar a nuevos usuarios o ítems nuevos sin historial (aunque no define explícitamente el término "Cold Start", describe el problema de poblar la matriz desde cero).
- **Validez de la predicción:** Predecir ratings no es lo mismo que satisfacer al usuario; un error en la predicción puede llevar a una mala experiencia.
- **Granularidad de datos implícitos:** Se pierde información sobre el grado de gusto (no se sabe si le encantó o solo le gustó, solo que interactuó).

## 12. Relaciones con otros temas del corpus
- **Similitud (Capítulo 3):** Base técnica para el filtrado colaborativo (Jaccard, Coseno, MinHash).
- **Clustering (Capítulo 7):** Usado para agrupar usuarios similares o ítems similares en sistemas de recomendación.
- **Minería de Texto:** Relevante para sistemas basados en contenido (analizar propiedades del texto de los ítems).
- **Publicidad Online:** Contexto relacionado donde también se predicen respuestas de usuarios (clics).

## 13. Preguntas que la skill debería poder responder
1. ¿Cuál es la diferencia fundamental entre un sistema de recomendación basado en contenido y uno de filtrado colaborativo?
2. ¿Por qué se considera que la matriz de utilidad es dispersa y qué implicaciones tiene esto?
3. ¿Qué es el fenómeno del "Long Tail" y cómo justifica la inversión en sistemas de recomendación?
4. ¿Qué problemas presenta el uso de ratings explícitos para poblar la matriz de utilidad?
5. ¿Cómo se debe interpretar un "0" en un sistema basado en datos implícitos?
6. ¿Es necesario predecir todas las entradas vacías de la matriz para tener un sistema útil?
7. ¿Qué métrica se utilizó para evaluar el rendimiento en el Netflix Prize?
8. ¿Qué tipo de datos es más adecuado para detectar interés en un producto si el usuario no lo compra?

## 14. Acciones que la skill debería poder recomendar o ejecutar
- **Diseño de esquema:** Definir si el problema de negocio se modela mejor con ratings explícitos o implícitos.
- **Selección de enfoque:** Elegir entre filtrado colaborativo o basado en contenido según la disponibilidad de atributos de ítems y datos de usuarios.
- **Preprocesamiento:** Convertir logs de comportamiento (clicks, compras) en una matriz dispersa para entrenamiento.
- **Evaluación:** Calcular RMSE si se tienen datos de prueba para validar predicciones.

## 15. Activos finales de conocimiento en formato compacto
| Concepto | Descripción | Referencia |
|---|---|---|
| **Matriz de Utilidad** | Estructura $User \times Item$ con preferencias; mayormente vacía. | Sec. 9.1.1 |
| **Long Tail** | Inventario ilimitado online vs. limitación física; requiere recomendación. | Sec. 9.1.2 |
| **Filtrado Colaborativo** | Recomienda usando similitud entre usuarios/ítems (usa Caps. 3 y 7). | Intro |
| **Content-based** | Recomienda usando atributos intrínsecos de los ítems. | Intro |
| **Dato Implícito** | Inferencia de preferencia por comportamiento (ej. compra). Binario. | Sec. 9.1.4 |
| **Dato Explícito** | Rating activo del usuario (ej. estrellas). Sesgado y escaso. | Sec. 9.1.4 |
| **Objetivo de Sistema** | Encontrar ítems de alto valor, no necesariamente llenar toda la matriz. | Sec. 9.1.1 |
| **Netflix Prize** | Competencia por mejorar RMSE en un 10%. Ganado en 2009. | Sec. 9.1.3 |
| **Sparsity** | Propiedad de tener mayoría de entradas desconocidas ("blanks"). | Sec. 9.1.1 |
| **Sesgo de Voluntad** | Usuarios que califican activamente no son representativos de la población. | Sec. 9.1.4 |


