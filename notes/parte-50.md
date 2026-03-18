# parte-50 — Mining-of-Massive-Datasets-Third-Edition-Jure-Leskovec-Anand-Rajaraman-etc-z-library-sk-1lib-sk-z-lib-parte-50.pdf

## 1. Metadatos del documento
- **Libro:** Mining of Massive Datasets, 3ª ed.
- **Fragmento/Parte:** Sección 12.5 (Decision Trees) y inicio de 12.6 (Comparison of Learning Methods)
- **Temas principales:** Árboles de decisión, Medidas de impureza (GINI, Entropía, Exactitud), Poda de nodos, Bosques de decisión (Decision Forests), Paralelización de algoritmos, Sobreajuste (Overfitting).
- **Tipo de contenido:** Mixto (Teoría / Algoritmo / Implementación)

## 2. Resumen técnico de alto valor
El fragmento detalla la construcción y optimización de árboles de decisión para clasificación de datos masivos. Se centra en la selección de pruebas (tests) en cada nodo para particionar los datos, utilizando medidas de impureza (GINI, Entropía, Exactitud) para evaluar la calidad de la división. Se distingue entre el manejo de características numéricas (ordenación y búsqueda de punto de corte óptimo) y categóricas (ordenación por fracción de clase para clasificación binaria). Se aborda la paralelización del diseño del árbol mediante sumas acumulativas paralelas (prefix sums) y la poda de nodos para mitigar el sobreajuste. Finalmente, introduce los Bosques de decisión como método de ensamblaje (ensemble) donde árboles superficiales votan para mejorar la precisión, comparando este enfoque con métodos lineales como Perceptrones y SVMs.

## 3. Conceptos y definiciones clave
- **Árbol de decisión (Decision Tree):** Programa de ramificación donde cada nodo interno representa una prueba sobre una característica del vector de entrada y cada hoja representa una clase de salida (conclusión).
- **Impureza (Impurity):** Métrica que cuantifica la heterogeneidad de las clases en un nodo. Es 0 si todos los ejemplos pertenecen a una sola clase.
- **Medidas de impureza:**
    - **Exactitud (Accuracy):** $1 - \max(p_1, \dots, p_n)$.
    - **GINI:** $1 - \sum_{i=1}^n (p_i)^2$.
    - **Entropía:** $\sum_{i=1}^n p_i \log_2(1/p_i)$.
    Donde $p_i$ es la fracción de ejemplos de la clase $i$ en el nodo.
- **Sobreajuste (Overfitting):** Ocurre cuando el árbol se ajusta a artefactos del conjunto de entrenamiento pequeño (ej. usar la población para distinguir países específicos) en lugar de patrones generales, fallando en datos no vistos.
- **Poda (Pruning):** Proceso de simplificar el árbol reemplazando nodos internos (cuyos hijos son hojas) por una sola hoja (clase mayoritaria), si no aumenta significativamente la tasa de error en un conjunto de prueba.
- **Bosque de decisión (Decision Forest):** Conjunto de árboles de decisión (generalmente superficiales) diseñados en paralelo que votan para determinar la clase final. Es una estrategia de métodos de ensamblaje (ensemble methods).
- **Suma acumulativa paralela (Parallel Prefix Sum):** Algoritmo divide-y-vencerás para calcular todas las sumas parciales de una lista en $O(\log n)$ pasos paralelos en lugar de $O(n)$ secuenciales.

## 4. Principios, reglas y heurísticas
- **Principio de diseño de nodo:** Seleccionar la prueba (split) que minimice la media ponderada de la impureza de los hijos, ponderando por el número de ejemplos que llegan a cada hijo.
- **Restricción de pruebas:** Limitar las pruebas a comparaciones binarias: (1) Comparar una característica numérica con una constante, o (2) Verificar si una característica categórica pertenece a un conjunto de valores.
- **Heurística para características categóricas (Clase binaria):** Si solo hay dos clases, ordenar los valores de la característica por la fracción de ejemplos en la primera clase. La partición óptima será un prefijo de esta lista ordenada.
- **Regla de poda:** Reemplazar un nodo $N$ (con hijos hoja) por una hoja de clase mayoritaria si la tasa de error en datos de prueba no aumenta significativamente.
- **Regla de convexidad:** Las medidas GINI y Entropía son convexas; la medida de Exactitud no siempre lo es. La convexidad garantiza que la reducción de impureza sea una métrica fiable para la división.

## 5. Procedimientos, métodos y workflows

### 5.1 Selección de prueba para característica numérica
**Precondición:** Un nodo con un subconjunto de ejemplos de entrenamiento.
**Pasos:**
1. Ordenar los ejemplos según el valor de la característica $A$. Valores: $a_1, \dots, a_n$.
2. Calcular incrementalmente las cuentas de cada clase para $j=1, \dots, n$.
3. Para cada posición $j$ (donde $a_j < a_{j+1}$), calcular la impureza ponderada de dividir en $\{a_1, \dots, a_j\}$ (hijo izq) y $\{a_{j+1}, \dots, a_n\}$ (hijo der).
4. Seleccionar el $j$ que minimiza la impureza ponderada. El umbral de corte es $(a_j + a_{j+1})/2$.

### 5.2 Selección de prueba para característica categórica (Caso binario)
**Precondición:** Problema de clasificación con dos clases.
**Pasos:**
1. Agrupar ejemplos por valor de la característica $A$.
2. Ordenar los valores de $A$ según la fracción de ejemplos que pertenecen a la primera clase.
3. Evaluar particiones que dividen esta lista ordenada en un prefijo (hijo izq) y sufijo (hijo der), similar al caso numérico.
4. Elegir la partición de mínima impureza.

### 5.3 Cálculo de suma acumulativa paralela (Parallel Prefix Sum)
**Entrada:** Lista $a_1, \dots, a_n$. **Salida:** $x_i = \sum_{j=1}^i a_j$.
1. **Base:** Si $n=1$, $x_1 = a_1$.
2. **Inducción:** Dividir la lista en mitades izquierda y derecha.
3. Calcular recursivamente las sumas acumulativas de ambas mitades en paralelo.
4. Sea $x_{n/2}$ la última suma acumulativa de la mitad izquierda. Sumar este valor a cada elemento de la lista de resultados de la mitad derecha.
5. Complejidad: $O(\log n)$ pasos paralelos.

## 6. Problemas comunes y soluciones
- **Problema:** Sobreajuste debido a pruebas irrelevantes (ej. usar población para distinguir países en un set pequeño).
    - **Solución:** Poda de nodos usando un conjunto de prueba (test set) para validar si la división realmente generaliza.
- **Problema:** Construcción de árboles es computacionalmente costosa (ordenación, evaluación de características).
    - **Solución:** Paralelización masiva: diseño de nodos en paralelo, evaluación de características en paralelo y uso de algoritmos de suma acumulativa paralela.
- **Problema:** Árboles profundos con alta varianza.
    - **Solución:** Utilizar Bosques de decisión (Decision Forests) con árboles superficiales (1-2 niveles) y combinar votos.
- **Problema:** Medida de "Exactitud" no es convexa.
    - **Solución:** Preferir GINI o Entropía para la selección de divisiones, ya que garantizan un comportamiento matemático estable en la optimización.

## 7. Implementación técnica y generación de código

```pseudocode
# Algoritmo: Encontrar mejor división para característica numérica
FUNCTION FindBestSplitNumerical(examples, feature_index, impurity_func):
    SORT examples BY feature_value ASCENDING
    n = LENGTH(examples)
    
    # Inicializar contadores acumulativos
    counts_left = [0, ..., 0] # Array de tamaño num_clases
    counts_right = COUNT_CLASSES(examples) # Total inicial
    
    best_impurity = INFINITY
    best_threshold = NULL
    
    FOR i FROM 0 TO n-2:
        label = examples[i].label
        counts_left[label] += 1
        counts_right[label] -= 1
        
        IF examples[i].feature_value == examples[i+1].feature_value:
            CONTINUE # No se puede dividir entre valores iguales
            
        # Calcular impureza ponderada
        p_left = i + 1
        p_right = n - (i + 1)
        
        imp_left = CALCULATE_IMPURITIES(counts_left, impurity_func)
        imp_right = CALCULATE_IMPURITIES(counts_right, impurity_func)
        
        weighted_impurity = (p_left/n * imp_left) + (p_right/n * imp_right)
        
        IF weighted_impurity < best_impurity:
            best_impurity = weighted_impurity
            best_threshold = (examples[i].feature_value + examples[i+1].feature_value) / 2
            
    RETURN best_threshold, best_impurity
```

```python
# Implementación Python: Cálculo de impureza GINI y selección de umbral
import numpy as np

def gini_impurity(labels):
    """Calcula la impureza GINI para un array de etiquetas."""
    if len(labels) == 0:
        return 0
    probs = np.bincount(labels) / len(labels)
    return 1 - np.sum(probs ** 2)

def find_best_split_numerical(feature_values, labels):
    """
    Encuentra el mejor punto de corte para una característica numérica
    minimizando la impureza GINI ponderada.
    """
    # Ordenar índices basados en los valores de la característica
    sorted_indices = np.argsort(feature_values)
    sorted_features = feature_values[sorted_indices]
    sorted_labels = labels[sorted_indices]
    
    n = len(labels)
    best_gini = 1.0
    best_threshold = None
    
    # Iterar sobre posibles puntos de corte (entre valores distintos)
    for i in range(1, n):
        # Solo considerar cortes entre valores diferentes
        if sorted_features[i] == sorted_features[i-1]:
            continue
            
        threshold = (sorted_features[i] + sorted_features[i-1]) / 2
        
        # Dividir datos
        left_labels = sorted_labels[:i]
        right_labels = sorted_labels[i:]
        
        # Calcular GINI ponderado
        w_left = len(left_labels) / n
        w_right = len(right_labels) / n
        
        current_gini = (w_left * gini_impurity(left_labels) + 
                        w_right * gini_impurity(right_labels))
        
        if current_gini < best_gini:
            best_gini = current_gini
            best_threshold = threshold
            
    return best_threshold, best_gini

# Ejemplo de uso con datos del libro (Fig 12.27 simplificada)
# Population: [44, 46, 59, 65, 80, 211]
# Sport (S=0, C=1): [0, 0, 0, 1, 0, 0] (Argentina, Spain, Italy, UK, Ger, Bra)
pop = np.array([44, 46, 59, 65, 80, 211])
sports = np.array([0, 0, 0, 1, 0, 0]) # 0=Soccer, 1=Cricket
threshold, gini = find_best_split_numerical(pop, sports)
# Resultado esperado según libro: División después de Italy (59), threshold ~59.5 o similar
# Nota: El libro calcula GINI ponderado. 
```

## 8. Funciones, métodos, librerías o comandos identificados
- **Gini Impurity:** Función de coste $1 - \sum p_i^2$. Usada por defecto en muchos clasificadores (ej. CART).
- **Entropy:** Función de coste $\sum p_i \log(1/p_i)$. Base para la ganancia de información (Information Gain).
- **Parallel Prefix Sum (Scan):** Primitiva algorítmica clave para la paralelización de la construcción de árboles.
- **MapReduce:** Modelo de programación sugerido para la agrupación paralela de ejemplos por valor de característica.
- **Majority Voting:** Método de combinación de resultados en Bosques de decisión.

## 9. Snippets o plantillas reutilizables

```python
# Plantilla: Poda de un nodo en un árbol de decisión (Conceptual)
def prune_tree(node, validation_set):
    if node is Leaf:
        return
    
    # Poda recursiva primero (bottom-up)
    prune_tree(node.left, validation_set)
    prune_tree(node.right, validation_set)
    
    # Evaluar si los hijos son hojas
    if isinstance(node.left, Leaf) and isinstance(node.right, Leaf):
        # Calcular error actual
        error_before = evaluate(node, validation_set)
        
        # Crear nodo hoja temporal con la clase mayoritaria
        majority_class = get_majority_class(node)
        temp_leaf = Leaf(majority_class)
        
        # Calcular error si podamos
        error_after = evaluate(temp_leaf, validation_set) # Simplificación
        
        # Si el error no aumenta significativamente, podar
        if error_after <= error_before + epsilon:
            replace_node_with_leaf(node, majority_class)
```

## 10. Casos de uso y aplicaciones
- **Predicción de deportes favoritos por país:** Clasificación basada en continente y población (Ejemplo 12.14). Ilustra el riesgo de overfitting al usar población para distinguir pocos países.
- **Netflix Challenge:** Mencionado como ejemplo de método de ensamblaje (ensemble), donde múltiples algoritmos combinan sus predicciones.
- **Clasificación de datos masivos:** Uso de paralelización para construir árboles sobre datasets que no caben en memoria o requieren procesamiento distribuido.

## 11. Limitaciones, riesgos y precauciones
- **Complejidad en características categóricas:** El método de ordenación descrito para características categóricas solo funciona eficientemente para clasificación binaria. Para $n$ clases, se deben considerar todas las formas de dividir las clases en dos grupos, lo cual es exponencial ($2^n$).
- **Overfitting intrínseco:** Los árboles de decisión profundos tienden a sobreajustarse. Es obligatorio el uso de poda o limitación de profundidad.
- **Sensibilidad a datos ruidosos:** Pequeños cambios en los datos de entrenamiento pueden cambiar la estructura del árbol significativamente (inestabilidad).
- **Fronteras de decisión:** Las fronteras son ortogonales a los ejes (hiperrectángulos), lo que puede no ajustarse bien a relaciones lineales diagonales complejas sin transformaciones previas.

## 12. Relaciones con otros temas del corpus
- **Perceptrones y SVMs (Sección 12.6):** Comparados con árboles de decisión. Los métodos lineales manejan mejor características numéricas y altas dimensiones, pero son menos interpretables y requieren separabilidad lineal (o kernels).
- **MapReduce (Sección 2.3.8):** Dependencia tecnológica para la implementación paralela de la agrupación de características.
- **Nearest Neighbors (Sección 12.4):** Los ejercicios iniciales del fragmento relacionan la clasificación por vecinos cercanos con la interpolación de etiquetas, contrastando con el enfoque basado en modelos de los árboles.
- **Métodos de Ensambles (Ensemble Methods):** Los Bosques de decisión son un caso específico de esta estrategia general.

## 13. Preguntas que la skill debería poder responder
1. ¿Cuáles son las tres medidas de impureza principales para árboles de decisión y cómo se calculan?
2. ¿Por qué la medida de "Exactitud" (Accuracy) puede ser problemática como medida de impureza comparada con GINI o Entropía?
3. ¿Cómo se selecciona el mejor umbral de división para una característica numérica en un árbol de decisión?
4. ¿Qué estrategia se utiliza para dividir nodos basados en características categóricas en problemas de clasificación binaria?
5. ¿Cómo se aplica la técnica de "Suma Acumulativa Paralela" (Parallel Prefix Sum) en la construcción de árboles de decisión?
6. ¿Qué es la poda de nodos (node pruning) y cómo ayuda a prevenir el sobreajuste?
7. ¿En qué consisten los Bosques de Decisión (Decision Forests) y por qué suelen superar a un solo árbol profundo?
8. ¿Cuál es la diferencia principal entre árboles de decisión y Perceptrones/SVMs respecto al manejo de características categóricas?
9. ¿Cómo se pondera la impureza de los nodos hijos al evaluar una división?
10. ¿Qué rol juega el conjunto de prueba (test set) en el proceso de poda?

## 14. Acciones que la skill debería poder recomendar o ejecutar
- Calcular la impureza GINI y Entropía dado un vector de etiquetas.
- Implementar una función para encontrar el mejor punto de corte (split point) en una característica numérica.
- Diseñar un flujo de trabajo de construcción de árbol que incluya validación cruzada para poda.
- Sugerir el uso de Bosques de Decisión si se detecta inestabilidad o sobreajuste en un modelo de árbol único.
- Recomendar Perceptrones o SVMs si el problema tiene características puramente numéricas y alta dimensionalidad, en lugar de árboles.
- Implementar un algoritmo de suma acumulativa paralela para optimizar el entrenamiento en sistemas distribuidos.

## 15. Activos finales de conocimiento en formato compacto

| Concepto | Descripción | Referencia |
| :--- | :--- | :--- |
| **Impureza GINI** | $1 - \sum p_i^2$. Mide la probabilidad de clasificación errónea aleatoria. | Sec 12.5.2 |
| **Entropía** | $\sum p_i \log_2(1/p_i)$. Mide el desorden/información promedio. | Sec 12.5.2 |
| **División Numérica** | Ordenar valores, evaluar cortes entre valores adyacentes distintos. | Sec 12.5.4 |
| **División Categórica** | Ordenar valores por fracción de clase (solo 2 clases), evaluar prefijos. | Sec 12.5.5 |
| **Parallel Prefix Sum** | Algoritmo $O(\log n)$ para calcular sumas acumulativas en paralelo. | Sec 12.5.6 |
| **Poda (Pruning)** | Reemplazar subárbol por hoja (clase mayoritaria) si error test no sube. | Sec 12.5.7 |
| **Decision Forest** | Ensamble de árboles superficiales que votan. Reduce overfitting. | Sec 12.5.8 |
| **Overfitting** | Árbol demasiado complejo que modela ruido del entrenamiento. | Sec 12.5.1 |
| **Convexidad** | GINI y Entropía son convexas; garantiza optimalidad en divisiones. | Ej 12.5.3 |
| **Comparación SVM/Tree** | SVM: numérico, alta dim. Tree: categórico, interpretable, baja dim. | Sec 12.6 |
