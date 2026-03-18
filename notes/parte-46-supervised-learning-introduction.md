# Parte 46 - Supervised Learning Introduction

## 1. Metadatos del documento
- **Libro:** Mining of Massive Datasets, 3ª ed.
- **Fragmento/Parte:** Parte 46 - Supervised Learning Introduction
- **Temas principales:** Aprendizaje Supervisado, Conjuntos de Entrenamiento, Perceptrón, Clasificación Binaria, Regresión, Arquitecturas de Aprendizaje (Batch/Online)
- **Tipo de contenido:** Teoría / Definiciones / Introducción a Algoritmos

## 2. Resumen técnico de alto valor
El capítulo introduce el aprendizaje automático (ML) como el proceso de extraer un modelo o clasificador de datos para predecir valores futuros, distinguiéndolo de algoritmos de resumen de datos (como itemsets frecuentes). Se define formalmente el **conjunto de entrenamiento** como pares $(x, y)$, donde $x$ es un vector de características y $y$ la etiqueta. La naturaleza de $y$ dicta el tipo de problema: regresión ($y$ real), clasificación binaria ($y$ booleana $\pm 1$) o multiclase ($y$ finito).

Se presentan cinco enfoques algorítmicos principales: Árboles de decisión, Perceptrones, Redes neuronales, Aprendizaje basado en instancias (k-NN) y Máquinas de vectores de soporte (SVM). El fragmento detalla la arquitectura de aprendizaje, enfatizando la necesidad de separar datos en conjuntos de entrenamiento, validación y prueba para mitigar el **overfitting** (sobreajuste). Se contrasta el aprendizaje **Batch** (procesamiento completo del dataset estático) frente al **On-line** (flujo continuo, actualización dinámica del modelo), crucial para datos masivos. Finalmente, se introduce el **Perceptrón** como un clasificador lineal binario que busca un hiperplano separador, limitado a datos linealmente separables.

## 3. Conceptos y definiciones clave
- **Training Set (Conjunto de Entrenamiento):** Conjunto de pares $(x, y)$ usados para entrenar el modelo. $x$ es el vector de características (features) y $y$ es la etiqueta (label) o salida correcta.
- **Feature Vector (Vector de Características):** Vector $x$ cuyos componentes pueden ser categóricos (discretos) o numéricos. En textos, suele ser un vector booleano de alta dimensión representando presencia de palabras.
- **Regression (Regresión):** Problema de ML donde $y$ es un número real.
- **Binary Classification (Clasificación Binaria):** Problema donde $y$ es un valor booleano, típicamente representado como $+1$ (verdadero) y $-1$ (falso).
- **Overfitting (Sobreajuste):** Fenómeno donde el modelo aprende artefactos específicos del conjunto de entrenamiento que no generalizan a la población general. Se detecta cuando el error en el set de prueba es significativamente mayor que en el de entrenamiento.
- **Perceptrón:** Clasificador lineal binario definido por un vector de pesos $w$ y un umbral $\theta$. La salida es $+1$ si $w \cdot x > \theta$ y $-1$ en caso contrario.
- **Linear Separability (Separabilidad Lineal):** Propiedad de un dataset donde existe un hiperplano que separa perfectamente los puntos positivos de los negativos. Condición necesaria para la convergencia del Perceptrón.
- **Cross-Validation (Validación Cruzada):** Técnica para medir el rendimiento dividiendo los datos en $k$ trozos, usando iterativamente uno como prueba y el resto como entrenamiento.
- **On-line Learning (Aprendizaje En-línea):** Arquitectura donde el entrenamiento ocurre sobre un flujo de datos, permitiendo adaptación continua y manejo de datasets masivos sin almacenarlos completamente.

## 4. Principios, reglas y heurísticas
- **Regla de definición de problema:** Si $y$ es real $\rightarrow$ Regresión. Si $y$ es booleano $\rightarrow$ Clasificación Binaria. Si $y$ es un conjunto finito $\rightarrow$ Clasificación Multiclase.
- **Regla de Overfitting:** Si el error en el conjunto de prueba es mucho peor que el error en el conjunto de entrenamiento, el modelo está sobreajustado.
- **Heurística de Feature Selection para Texto:** Eliminar "stop words" y considerar solo palabras con alto score TF.IDF para reducir ruido y dimensión.
- **Regla de Perceptrón:** Un perceptrón converge a un separador perfecto solo si los datos son linealmente separables. Si no lo son, no converge.
- **Diferencia PCA vs Regresión Lineal:** PCA minimiza la distancia de proyección ortogonal al eje; la Regresión Lineal minimiza la distancia vertical (error en $y$).

## 5. Procedimientos, métodos y workflows
### Workflow de Entrenamiento y Prueba (Train-and-Test)
1.  **Partición:** Separar una fracción pequeña de los datos disponibles como *Test Set*. El resto forma el *Training Set* (y opcionalmente un *Validation Set*).
2.  **Modelado:** Construir el modelo/clasificador usando el Training Set.
3.  **Validación:** Alimentar el Test Set al modelo.
4.  **Evaluación:** Comparar la tasa de error del modelo en el Test Set vs Training Set. Si son comparables, el modelo es válido. Si el error de Test es mucho mayor, hay overfitting.

### Clasificación con Perceptrón (Inferencia)
1.  **Input:** Recibir vector de características $x$.
2.  **Cálculo:** Calcular el producto punto $w \cdot x$.
3.  **Decisión:** Comparar con el umbral $\theta$.
    - Si $w \cdot x > \theta \rightarrow$ Clase $+1$.
    - Si $w \cdot x < \theta \rightarrow$ Clase $-1$.

## 6. Problemas comunes y soluciones
- **Problema:** Overfitting detectado en el set de validación/prueba.
    - **Solución:** Restringir el algoritmo de aprendizaje (ej. limitar niveles del árbol de decisión) o simplificar el modelo.
- **Problema:** Datos no son linealmente separables.
    - **Solución:** El Perceptrón simple no es adecuado. Usar Support-Vector Machines (SVM) o redes neuronales, que buscan el mejor separador posible aunque no sea perfecto.
- **Problema:** Etiquetado de datos costoso o imposible.
    - **Solución:** Usar fuentes implícitas (ej. enlaces de Wikipedia para tópicos, estrellas en reviews para sentimiento) o Crowdsourcing (Mechanical Turk) con sistemas de votación para asegurar calidad.

## 7. Implementación técnica y generación de código

```pseudocode
# Algoritmo de decisión del Perceptrón (Sección 12.2)
# w: vector de pesos, x: vector de características, theta: umbral
Function PerceptronDecision(w, x, theta):
    dot_product = 0
    For i from 1 to length(w):
        dot_product = dot_product + w[i] * x[i]
    
    If dot_product > theta:
        Return +1
    Else:
        Return -1
```

```python
# Implementación Python: Ejemplo de Regresión Lineal Simple (Ejemplo 12.2 del libro)
# Objetivo: Minimizar RMSE para f(x) = ax + b
import numpy as np

def solve_linear_regression(points):
    """
    Resuelve la regresión lineal para un conjunto de puntos (x, y)
    minimizando el error cuadrático medio (RMSE).
    Puntos del ejemplo: (1,2), (2,1), (3,4), (4,3)
    """
    # Extraer X y Y
    X = np.array([p[0] for p in points])
    Y = np.array([p[1] for p in points])
    
    # Construir matriz para forma Ax = b -> [x_i, 1] [a, b]^T = y_i
    # Matriz A: columna 1 es X, columna 2 es unos (bias)
    A = np.vstack([X, np.ones(len(X))]).T
    
    # Resolver mediante mínimos cuadrados: (A^T A)^-1 A^T Y
    # np.linalg.lstsq hace esto directamente
    a, b = np.linalg.lstsq(A, Y, rcond=None)[0]
    
    return a, b

# Datos del Ejemplo 12.2
training_data = [(1, 2), (2, 1), (3, 4), (4, 3)]
a, b = solve_linear_regression(training_data)

# Salida esperada según libro: a = 3/5 = 0.6, b = 1
print(f"Pendiente (a): {a}") # 0.6
print(f"Intersección (b): {b}") # 1.0
```

## 8. Funciones, métodos, librerías o comandos identificados
- **RMSE (Root Mean Square Error):** Métrica para evaluar la calidad de un modelo de regresión. Minimizar la suma de cuadrados de las diferencias verticales.
- **TF.IDF:** Técnica de ponderación de términos para selección de características en texto (referenciada en Ejemplo 12.3).
- **Dot Product ($w \cdot x$):** Operación fundamental en Perceptrones y SVMs para definir hiperplanos.
- **Mechanical Turk:** Herramienta de Crowdsourcing mencionada para etiquetado de datos (Active Learning).

## 9. Snippets o plantillas reutilizables

```python
# Plantilla: Clase básica de Perceptrón para inferencia
class Perceptron:
    def __init__(self, weights, threshold):
        self.weights = np.array(weights)
        self.threshold = threshold
    
    def predict(self, x):
        """
        Predice la clase (+1 o -1) para un vector de entrada x.
        """
        x = np.array(x)
        if np.dot(self.weights, x) > self.threshold:
            return 1
        else:
            return -1

# Uso basado en la lógica del libro
# Ejemplo: Separar Beagles de otros perros por altura > 7 pulgadas
# Feature vector: [height, weight]
# Hiperplano: height = 7 -> w=[1, 0], theta=7
# Nota: El libro usa lógica if/else, aquí traducido a geometría del perceptrón
p = Perceptron(weights=[1, 0], threshold=7)
# Perro de 8 pulgadas
print(p.predict([8, 5])) # Debería ser +1 (Beagle según ejemplo simplificado)
```

## 10. Casos de uso y aplicaciones
- **Detección de Spam:** Clasificación binaria de emails. Vector de características booleano indicando presencia de palabras clave. $y = +1$ (spam), $y = -1$ (no spam). Requiere aprendizaje online para adaptarse a nuevos tipos de spam.
- **Clasificación de Razas de Perros:** Uso de vectores [altura, peso] para clasificar en Beagle, Chihuahua, Dachshund. Ilustra clasificación multiclase mediante múltiples hiperplanos o árboles de decisión.
- **Análisis de Sentimiento:** Uso de reviews con estrellas como training set implícito para deducir sentimiento (positivo/negativo) de textos sin etiquetar.
- **Clasificación de Tópicos Web:** Uso de DMOZ o Wikipedia como fuentes de datos etiquetados implícitamente para entrenar clasificadores de páginas web.

## 11. Limitaciones, riesgos y precauciones
- **Perceptrón:** No converge si los datos no son linealmente separables. No garantiza el "mejor" separador si existen muchos, solo "uno" que funcione.
- **Regresión Lineal (RMSE):** Minimiza el error vertical, no es lo mismo que PCA (minimiza error de proyección). Supone una relación funcional $y=f(x)$.
- **Validación:** La selección del test set es arbitraria. Se recomienda validación cruzada para robustecer la evaluación.
- **Feature Engineering:** La inclusión de características irrelevantes (ej. stop words) o la omisión de características críticas (ej. host origen en spam) degrada el modelo.

## 12. Relaciones con otros temas del corpus
- **Capítulo 6 (Frequent Itemsets):** Contrastado como método de resumen de datos vs ML que busca predicción.
- **Capítulo 7 (Clustering):** Definido como "Aprendizaje No Supervisado", contrapuesto al "Aprendizaje Supervisado" de este capítulo.
- **Capítulo 11 (Dimensionality Reduction):** El Ejemplo 12.2 compara explícitamente Regresión Lineal con PCA (Sección 11.2.1), destacando la diferencia en la minimización de errores.
- **Capítulo 12.3 (SVM):** Presentado como la evolución del Perceptrón para manejar datos no linealmente separables y maximizar márgenes.
- **Capítulo 12.4 (k-NN):** Mencionado como método de aprendizaje basado en instancias.

## 13. Preguntas que la skill debería poder responder
1. ¿Cuál es la diferencia fundamental entre un algoritmo de clustering (no supervisado) y un algoritmo de clasificación (supervisado)?
2. ¿Cómo se define matemáticamente la salida de un perceptrón dado un vector de entrada $x$ y un umbral $\theta$?
3. ¿Qué condición debe cumplir un dataset para que un perceptrón converja a una solución perfecta?
4. ¿Por qué es peligroso usar todo el dataset disponible para entrenar un modelo sin reservar un test set?
5. ¿Cuál es la diferencia entre minimizar el error vertical (Regresión) y minimizar la distancia de proyección (PCA)?
6. ¿En qué escenarios es preferible el aprendizaje en línea (on-line) frente al aprendizaje por lotes (batch)?
7. ¿Cómo se puede obtener un conjunto de entrenamiento etiquetado sin recurrir a etiquetado manual costoso?
8. ¿Qué representa el vector de pesos $w$ en un perceptrón geométricamente?
9. ¿Cómo se detecta el overfitting comparando conjuntos de entrenamiento y prueba?
10. ¿Qué tipo de problemas de ML se aplican si la variable objetivo $y$ es un número real vs un valor booleano?

## 14. Acciones que la skill debería poder recomendar o ejecutar
- **Dividir datos:** Recomendar dividir el dataset en entrenamiento, validación y prueba antes de modelar.
- **Selección de características:** Sugerir eliminación de stop words y uso de TF.IDF para tareas de NLP.
- **Elección de modelo:** Si el problema es clasificación binaria lineal, sugerir Perceptrón o SVM; si es regresión, sugerir mínimos cuadrados.
- **Mitigación de Overfitting:** Si se detecta gran brecha de error entre sets, sugerir simplificar el modelo o aplicar regularización.
- **Estrategia de etiquetado:** Si faltan etiquetas, sugerir fuentes implícitas (Wikipedia, metadata) o Crowdsourcing.

## 15. Activos finales de conocimiento en formato compacto
| Concepto | Descripción | Referencia |
| :--- | :--- | :--- |
| **Training Set** | Conjunto de pares $(x, y)$ usados para aprender el modelo $f(x) \approx y$. | Sec 12.1.1 |
| **Perceptrón** | Clasificador binario lineal. Salida $+1$ si $w \cdot x > \theta$. | Sec 12.2 |
| **Overfitting** | Modelo aprende ruido del entrenamiento; falla en generalizar a prueba. | Sec 12.1.4 |
| **Regresión** | ML donde $y$ es valor real. Minimiza RMSE (error vertical). | Sec 12.1.1, 12.1.2 |
| **On-line Learning** | Actualiza modelo con cada nuevo ejemplo; ideal para streams y datos masivos. | Sec 12.1.4 |
| **Linear Separability** | Existencia de un hiperplano que divide clases; requisito para Perceptrón. | Sec 12.2 |
| **Cross-Validation** | Rotar $k$ trozos de datos como test set para validar robustez. | Sec 12.1.4 |
| **Feature Vector** | Representación numérica/categórica de la entrada $x$. | Sec 12.1.1 |
| **SVM** | Evolución del Perceptrón; maneja no separabilidad y maximiza margen. | Sec 12.1.3 |
| **Active Learning** | El modelo consulta etiquetas para datos ambiguos (cerca del límite). | Sec 12.1.4 |


