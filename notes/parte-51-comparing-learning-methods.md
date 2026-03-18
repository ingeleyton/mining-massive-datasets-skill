# Parte 51 - Comparing Learning Methods

## 1. Metadatos del documento
- **Libro:** Mining of Massive Datasets, 3ª ed.
- **Fragmento/Parte:** Parte 51 - Comparing Learning Methods
- **Temas principales:** Comparativa de clasificadores, Máquinas de Vectores de Soporte (SVM), Perceptrón, Vecinos más cercanos (k-NN), Árboles de decisión, Sobreajuste (Overfitting), Descenso de gradiente.
- **Tipo de contenido:** Teoría / Comparativa / Resumen Técnico.

## 2. Resumen técnico de alto valor
El fragmento presenta una comparativa estructurada de métodos de aprendizaje automático a gran escala, evaluando su idoneidad según el tipo de características (categóricas vs. numéricas), la dimensionalidad y la interpretabilidad del modelo. Se destaca que **Perceptrones y SVM** son efectivos para alta dimensionalidad y características numéricas, requiriendo separabilidad lineal (o transformaciones kernel), pero carecen de interpretabilidad intuitiva. **k-NN** es conceptualmente simple pero sufre de la "maldición de la dimensionalidad" y requiere ajuste de parámetros (métrica de distancia, k, kernel). Los **Árboles de Decisión** son los únicos que manejan nativamente características categóricas y numéricas con alta interpretabilidad, pero son propensos al sobreajuste en profundidad; se recomienda el uso de *Decision Forests* (bosques de decisión) para mitigar esto. Adicionalmente, se formalizan las medidas de impureza (GINI, Entropía, Precisión) y los métodos de optimización como el descenso de gradiente (batch, estocástico, mini-batch).

## 3. Conceptos y definiciones clave
- **Training Set (Conjunto de entrenamiento):** Conjunto de datos compuesto por vectores de características y una etiqueta de clase. Las características pueden ser categóricas o numéricas.
- **Overfitting (Sobreajuste):** Ocurre cuando un clasificador rinde significativamente peor en el conjunto de prueba que en el de entrenamiento, indicando que se ha ajustado a peculiaridades no generalizables de los datos.
- **Batch vs. On-Line Learning:** En *Batch*, el conjunto de entrenamiento está disponible para múltiples pasadas. En *On-Line*, los ejemplos llegan como un flujo y se usan una sola vez.
- **Perceptrón:** Algoritmo para dos clases (positiva/negativa) que asume la existencia de un hiperplano separador. Converge ajustando el hiperplano hacia el promedio de los puntos mal clasificados.
- **Winnow Algorithm:** Variante del perceptrón para vectores de características binarios (0 o 1). Ajusta los pesos de las características activas (valor 1) hacia arriba o abajo para corregir clasificaciones.
- **Support-Vector Machines (SVM):** Mejora el perceptrón buscando el hiperplano que maximiza el margen (distancia perpendicular a los puntos más cercanos). Los puntos en el margen mínimo son los "vectores de soporte".
- **Curse of Dimensionality (Maldición de la dimensionalidad):** Fenómeno donde, al aumentar las dimensiones, los datos se vuelven dispersos, haciendo ineficaces los métodos basados en distancia como k-NN.
- **Decision Forest (Bosque de decisión):** Estrategia para mejorar árboles de decisión consistente en combinar múltiples árboles de poca profundidad para evitar sobreajuste y mejorar la robustez.

## 4. Principios, reglas y heurísticas
- **Selección de método por tipo de dato:**
    - Si las características son numéricas y la dimensionalidad es muy alta: Usar Perceptrón o SVM.
    - Si las características son mixtas (categóricas y numéricas) y se requiere interpretabilidad: Usar Árboles de Decisión.
    - Si se requiere interpretabilidad total del modelo: Evitar SVM/Perceptrones (vectores de alta dimensión difíciles de interpretar); preferir Árboles de Decisión o k-NN.
- **Gestión de características categóricas en k-NN:** Se pueden mapear características binarias a 0 y 1. Para características con $\ge 3$ valores, no es posible asignar números equidistantes, lo que hace problemático el uso de k-NN.
- **Prevención del sobreajuste en Árboles de Decisión:** Limitar la profundidad del árbol. Si se necesitan más características, usar un bosque de árboles de baja profundidad en lugar de un árbol profundo.
- **Separabilidad lineal:** Si los datos no son linealmente separables, se debe aplicar una transformación de espacio antes de usar Perceptrón o SVM lineal.
- **Impureza y Convexidad:** La medida de impureza "Precisión" no es convexa, lo que puede causar problemas en la optimización de nodos de árboles de decisión; GINI y Entropía son convexas y preferibles.

## 5. Procedimientos, métodos y workflows
### Diseño de un nodo de Árbol de Decisión
1.  **Precondición:** Un conjunto de ejemplos de entrenamiento llega al nodo.
2.  **Selección de característica:** Considerar cada característica posible para la prueba en el nodo.
3.  **División (Split):**
    - *Característica numérica:* Ordenar ejemplos por valor y buscar un punto de corte que minimice la impureza promedio de los hijos.
    - *Característica categórica:* Ordenar valores por la fracción de ejemplos en una clase y dividir la lista para minimizar la impureza promedio.
4.  **Postcondición:** El nodo se convierte en prueba con la mejor división o en hoja si la impureza es mínima.

### Optimización con Descenso de Gradiente
1.  Definir una función de pérdida dependiente de variables y ejemplos.
2.  Calcular la derivada de la función de pérdida respecto a cada variable para un ejemplo dado.
3.  Mover el valor de cada variable en la dirección que reduce la pérdida.
    - *Batch:* Acumular cambios sugeridos por todos los ejemplos antes de actualizar.
    - *Stochastic:* Actualizar variables inmediatamente tras cada ejemplo.
    - *Minibatch:* Actualizar tras un pequeño subconjunto de ejemplos.

## 6. Problemas comunes y soluciones
- **Problema:** Clasificador funciona bien en entrenamiento pero mal en prueba.
    - **Causa:** Sobreajuste (Overfitting).
    - **Solución:** Simplificar el modelo (ej. reducir profundidad del árbol) o usar técnicas de regularización (en SVM).
- **Problema:** k-NN falla en datos de alta dimensión.
    - **Causa:** Maldición de la dimensionalidad (dispersión de datos).
    - **Solución:** Reducción de dimensionalidad previa o evitar k-NN; considerar SVM o Perceptrón.
- **Problema:** Datos no separables linealmente.
    - **Solución:** Transformar los puntos a un espacio de mayor dimensión donde la separación sea lineal (Kernel trick implícito).
- **Problema:** Inestabilidad al usar "Accuracy" como medida de impureza.
    - **Causa:** La medida de Accuracy no es convexa.
    - **Solución:** Usar GINI o Entropía, que garantizan convexidad y mejor convergencia en la división de nodos.

## 7. Implementación técnica y generación de código

```pseudocode
# Algoritmo Winnow (Concepto)
# Entrada: Vector de pesos w, Conjunto de entrenamiento E (features binarias)
# Por cada ejemplo (x, y) en E en round-robin:
#   Calcular prediccion = sign(w . x)
#   Si prediccion != y (error):
#     Por cada componente i donde x[i] == 1:
#       Si y es positivo: w[i] = w[i] * factor_aumento
#       Si y es negativo: w[i] = w[i] / factor_aumento
```

```python
# Implementación de medidas de impureza para Árboles de Decisión
import numpy as np

def gini_impurity(class_counts):
    """
    Calcula la impureza GINI.
    class_counts: lista o array con el conteo de ejemplos por clase.
    Formula: 1 - sum(p_i^2)
    """
    total = np.sum(class_counts)
    if total == 0:
        return 0
    probabilities = class_counts / total
    return 1.0 - np.sum(probabilities ** 2)

def entropy_impurity(class_counts):
    """
    Calcula la entropía.
    class_counts: lista o array con el conteo de ejemplos por clase.
    Formula: sum(p_i * log2(1/p_i))
    """
    total = np.sum(class_counts)
    if total == 0:
        return 0
    probabilities = class_counts / total
    # Filtrar ceros para evitar log(0)
    probabilities = probabilities[probabilities > 0]
    return -np.sum(probabilities * np.log2(probabilities))

# Nota: La medida de 'Accuracy' se menciona en el texto como no convexa y problemática.
```

## 8. Funciones, métodos, librerías o comandos identificados
- **Perceptron:** Algoritmo de clasificación lineal.
- **Winnow:** Algoritmo de clasificación lineal para características binarias.
- **SVM (Support-Vector Machine):** Clasificador de margen máximo.
- **Gradient Descent:** Método de optimización (Batch, Stochastic, Minibatch).
- **GINI:** Medida de impureza ($1 - \sum p_i^2$).
- **Entropy:** Medida de impureza ($-\sum p_i \log p_i$).

## 9. Snippets o plantillas reutilizables
> *Sección no aplicable a este fragmento (el fragmento es teórico/comparativo, los snippets se generaron en la sección 7 basados en las definiciones matemáticas).*

## 10. Casos de uso y aplicaciones
- **Alta dimensionalidad y datos numéricos (ej. texto, imágenes):** Uso de SVM o Perceptrones. El texto menciona explícitamente que pueden manejar millones de características.
- **Datos mixtos y necesidad de explicabilidad (ej. decisiones de crédito, diagnóstico médico simple):** Árboles de Decisión. Permiten seguir la lógica "si-entonces" fácilmente.
- **Regresión funcional:** Uso de k-NN para promediar valores de vecinos cercanos (interpolación local).

## 11. Limitaciones, riesgos y precauciones
- **Perceptrón/SVM:** No manejan características categóricas directamente (requieren encoding). El modelo resultante (vector normal) es difícil de interpretar para humanos.
- **k-NN:** Degradación severa del rendimiento en altas dimensiones. Sensible a la métrica de distancia elegida y al valor de $k$.
- **Árboles de Decisión:** Riesgo alto de sobreajuste si se permite mucha profundidad. Limitación práctica: árboles con poca profundidad solo usan pocas características, ignorando información útil.
- **Convexidad:** El uso de medidas de impureza no convexas (como Accuracy) puede llevar a óptimos locales pobres o inestabilidad en la construcción del árbol.

## 12. Relaciones con otros temas del corpus
- **SVM $\rightarrow$ Kernel Trick:** El texto menciona la transformación de puntos para separación no lineal, relacionado con métodos kernel.
- **k-NN $\rightarrow$ Index Structures:** El texto referencia el Capítulo 14 para estructuras de indexación en altas dimensiones (posible dependencia de LSH o árboles KD).
- **Decision Trees $\rightarrow$ Random Forests:** El texto introduce el concepto de "Decision Forest" como evolución natural para resolver el problema de overfitting y baja profundidad.
- **Gradient Descent $\rightarrow$ Neural Networks:** Aunque no se profundiza, el descenso de gradiente es la base para redes neuronales (mencionado en contexto de "Large-scale machine learning").

## 13. Preguntas que la skill debería poder responder
1. ¿Qué método de aprendizaje es más adecuado si tengo características categóricas y numéricas y necesito interpretabilidad?
2. ¿Por qué se considera que el algoritmo k-NN sufre de la "maldición de la dimensionalidad"?
3. ¿Cuál es la diferencia fundamental entre el algoritmo Winnow y el Perceptrón estándar en cuanto a los datos de entrada?
4. ¿Qué problema presenta la medida de impureza "Accuracy" en comparación con GINI o Entropía al construir árboles de decisión?
5. ¿Cómo maneja una SVM el caso de puntos que no son linealmente separables?
6. ¿Qué es el margen en una Máquina de Vectores de Soporte y qué son los vectores de soporte?
7. ¿En qué escenarios se prefiere el descenso de gradiente estocástico sobre el batch?
8. ¿Qué estrategia se recomienda para evitar el sobreajuste en árboles de decisión sin perder capacidad de análisis de múltiples características?

## 14. Acciones que la skill debería poder recomendar o ejecutar
- **Recomendar algoritmo:** Sugerir Árboles de Decisión ante presencia de datos categóricos y necesidad de transparencia.
- **Diagnosticar fallo:** Identificar la "maldición de la dimensionalidad" como causa de bajo rendimiento en k-NN con muchas features.
- **Validar diseño:** Advertir contra el uso de "Accuracy" como función de impureza en la implementación de árboles.
- **Optimizar SVM:** Sugerir el ajuste del parámetro de regularización para balancear margen y penalización de errores.

## 15. Activos finales de conocimiento en formato compacto
| Concepto | Descripción | Referencia |
|---|---|---|
| **SVM** | Clasificador que maximiza el margen entre clases; ideal para datos numéricos de alta dimensión. | Sec. 12.6, 12.7 |
| **Árboles de Decisión** | Único método nativo para datos mixtos (cat/num); usar bosques para evitar overfitting. | Sec. 12.6 |
| **Maldición de la dimensionalidad** | Limitación crítica de k-NN: en altas dimensiones los datos son dispersos y la distancia pierde sentido. | Sec. 12.6 |
| **Winnow** | Variante de Perceptrón para features binarias; ajusta pesos solo de características activas. | Sec. 12.7 |
| **Impureza GINI** | Medida convexa preferida para splits en árboles: $1 - \sum p_i^2$. | Sec. 12.7 |
| **Impureza Entropía** | Medida convexa alternativa para árboles: $-\sum p_i \log p_i$. | Sec. 12.7 |
| **Overfitting** | Rendimiento excelente en entrenamiento pero pobre en prueba; común en árboles profundos. | Sec. 12.7 |
| **Gradiente Descendente** | Método de optimización iterativo; variantes: Batch, Stochastic, Minibatch. | Sec. 12.7 |
| **Vectores de Soporte** | Puntos de datos que definen el margen máximo en una SVM. | Sec. 12.7 |
| **Interpretabilidad** | Facilidad para entender el modelo; alta en Árboles/k-NN, baja en SVM/Perceptrón. | Sec. 12.6 |


