# Parte 53 - Dense Neural Networks and Loss Functions

## 1. Metadatos del documento
- **Libro:** Mining of Massive Datasets, 3ª ed.
- **Fragmento/Parte:** Parte 53 - Dense Neural Networks and Loss Functions
- **Temas principales:** Redes neuronales densas, Álgebra lineal en redes neuronales, Funciones de activación (Sigmoid, Tanh, ReLU, Softmax), Funciones de pérdida (MSE, Huber, Cross-Entropy), Entrenamiento mediante Gradient Descent.
- **Tipo de contenido:** Teoría / Algoritmo / Implementación

## 2. Resumen técnico de alto valor
El fragmento aborda la transición de los perceptrones binarios a las redes neuronales densas (Feedforward Networks) entrenables mediante descenso de gradiente. Se establece la notación de álgebra lineal (vectores, matrices, bias) como estándar para representar capas neuronales, destacando su eficiencia computacional en GPUs y frameworks modernos (TensorFlow, PyTorch).

El núcleo técnico radica en la selección de funciones de activación diferenciables que reemplazan a la función escalón (`step`) para permitir el cálculo del gradiente. Se analizan detalladamente las propiedades, derivadas y patologías de Sigmoid, Tanh, ReLU y Softmax, introduciendo variantes como Leaky ReLU y ELU para mitigar problemas de saturación y "muerte" de neuronas.

Finalmente, se formalizan las funciones de pérdida (Loss Functions) para regresión (Error Cuadrático Medio, Huber Loss) y clasificación (Cross-Entropy, Divergencia KL), justificando matemáticamente el acoplamiento entre Softmax y Cross-Entropy para evitar inestabilidad numérica y saturación del gradiente.

## 3. Conceptos y definiciones clave
- **Red Feedforward (Feedforward Network):** Arquitectura neuronal donde todas las aristas se orientan hacia adelante, desde la entrada hasta la salida, sin ciclos.
- **Vector de Bias ($b$):** Vector que contiene los umbrales de activación (negativos de los thresholds) de los nodos de una capa. Permite desplazar la función de activación.
- **Función de Activación (Activation Function):** Función no lineal aplicada tras la transformación lineal ($Wx+b$). Debe ser continua, diferenciable y evitar la saturación/explotación del gradiente para ser compatible con el descenso de gradiente.
- **Saturación:** Fenómeno donde la derivada de la función de activación tiende a cero, provocando que el aprendizaje se detenga (gradientes desvanecientes).
- **Softmax:** Función de activación vectorial que convierte un vector de valores reales en una distribución de probabilidad (suma 1). Se usa típicamente en la capa de salida para clasificación multiclase.
- **Dying ReLU:** Problema en unidades ReLU donde, si los pesos provocan entradas negativas consistentes, el gradiente se vuelve 0 permanentemente y la neurona deja de aprender.
- **Cross Entropy ($H(p,q)$):** Medida de distancia entre dos distribuciones de probabilidad $p$ (real) y $q$ (predicha). Es la función de pérdida estándar para clasificación.
- **Divergencia Kullback-Leibler (KL-divergence):** Diferencia entre la Cross Entropy y la entropía de la distribución real. Mide el costo de usar una codificación óptima para una distribución incorrecta.

## 4. Principios, reglas y heurísticas
- **Regla de diferenciabilidad para Gradient Descent:** Evitar funciones discontinuas o con derivadas nulas en amplios rangos (como la función `step`) en redes profundas.
- **Regla de estabilidad numérica en Softmax:** Antes de calcular $e^{x_i}$, restar el valor máximo del vector ($c = \max_j x_j$) para evitar desbordamiento (overflow) o subdesbordamiento (underflow).
- **Heurística de selección de activación:**
    - Evitar Sigmoid/Tanh en capas ocultas profundas debido a la saturación.
    - Preferir ReLU por velocidad de convergencia, pero monitorear "Dying ReLU".
    - Usar ELU o Leaky ReLU si se detectan neuronas muertas.
- **Heurística de selección de pérdida:**
    - Regresión: Usar MSE para datos limpios; usar Huber Loss si hay outliers (es robusta a valores extremos).
    - Clasificación: Usar Cross-Entropy (combina bien con Softmax y evita saturación).
- **Principio de diseño de capas:** La matriz de pesos $W$ tiene dimensiones `[nodos_capa_actual, nodos_capa_anterior]`. El vector bias tiene dimensión `[nodos_capa_actual]`.

## 5. Procedimientos, métodos y workflows
### Cálculo de la salida de una capa densa (Forward Pass)
1.  **Entrada:** Vector de entrada $x$ (o salida de la capa anterior $h_{prev}$).
2.  **Parámetros:** Matriz de pesos $W$, vector de bias $b$.
3.  **Transformación lineal:** Calcular $z = Wx + b$.
4.  **Activación:** Aplicar función de activación elemento a elemento $h = \sigma(z)$ (o ReLU, Tanh).
5.  **Salida:** El vector $h$ se convierte en la entrada para la siguiente capa.

### Cálculo numéricamente estable de Softmax
1.  Dado un vector $x$.
2.  Encontrar $c = \max(x)$.
3.  Calcular vector exponencial desplazado: $e^{x_i - c}$.
4.  Normalizar dividiendo por la suma de los exponentes: $\mu(x_i) = \frac{e^{x_i - c}}{\sum_j e^{x_j - c}}$.

## 6. Problemas comunes y soluciones
- **Problema:** La función escalón (`step`) tiene derivada 0 o indefinida, inutilizando el descenso de gradiente.
    - **Solución:** Usar funciones continuas como Sigmoid o ReLU.
- **Problema:** Saturación de Sigmoid/Tanh (gradientes tienden a 0 lejos del origen).
    - **Solución:** Usar ReLU (gradiente constante para $x>0$) o inicialización cuidadosa.
- **Problema:** "Dying ReLU" (neuronas bloqueadas emitiendo 0).
    - **Solución:** Usar Leaky ReLU ($f(x) = \alpha x$ para $x<0$) o ELU.
- **Problema:** Inestabilidad numérica al calcular $e^{x}$ para valores grandes en Softmax.
    - **Solución:** Restar el máximo valor del vector antes de exponenciar.
- **Problema:** MSE sensible a outliers en regresión.
    - **Solución:** Usar Huber Loss, que es cuadrática cerca del origen (precisa) y lineal lejos de él (robusta).

## 7. Implementación técnica y generación de código

```pseudocode
# Definición de funciones de activación y sus derivadas

Funcion Sigmoid(x):
    Retornar 1 / (1 + exp(-x))

Funcion Sigmoid_Deriv(y):
    # y es la salida de Sigmoid(x)
    Retornar y * (1 - y)

Funcion Tanh(x):
    Retornar (exp(x) - exp(-x)) / (exp(x) + exp(-x))

Funcion Tanh_Deriv(y):
    # y es la salida de Tanh(x)
    Retornar 1 - y^2

Funcion ReLU(x):
    Retornar max(0, x)

Funcion Softmax(x):
    c = max(x) # Truco de estabilidad numérica
    exp_scores = exp(x - c)
    suma = sum(exp_scores)
    Retornar exp_scores / suma
```

```python
import numpy as np

def sigmoid(x):
    """Función de activación Sigmoide."""
    return 1 / (1 + np.exp(-x))

def sigmoid_derivative(y):
    """Derivada de la sigmoide en función de su salida y."""
    return y * (1 - y)

def tanh_derivative(y):
    """Derivada de la tangente hiperbólica en función de su salida y."""
    return 1 - y**2

def relu(x):
    """Unidad Lineal Rectificada (ReLU)."""
    return np.maximum(0, x)

def leaky_relu(x, alpha=0.01):
    """Leaky ReLU para evitar Dying ReLU."""
    return np.where(x > 0, x, alpha * x)

def softmax(x):
    """
    Función Softmax estable numéricamente.
    Entrada: x (vector o matriz donde cada fila es una instancia).
    """
    # Restar el max para evitar overflow de exp
    x_shifted = x - np.max(x, axis=-1, keepdims=True)
    exp_x = np.exp(x_shifted)
    return exp_x / np.sum(exp_x, axis=-1, keepdims=True)

def mse_loss(y_pred, y_true):
    """Error Cuadrático Medio."""
    return np.mean((y_pred - y_true)**2)

def huber_loss(y_pred, y_true, delta=1.0):
    """Función de pérdida Huber."""
    error = y_pred - y_true
    is_small_error = np.abs(error) <= delta
    squared_loss = np.square(error) / 2
    linear_loss = delta * (np.abs(error) - delta / 2)
    return np.where(is_small_error, squared_loss, linear_loss)

def cross_entropy_loss(y_pred, y_true):
    """
    Cross Entropy para clasificación.
    y_pred: probabilidades predichas (salida de softmax).
    y_true: one-hot encoding de la clase real.
    """
    # Clip para evitar log(0)
    y_pred = np.clip(y_pred, 1e-15, 1 - 1e-15)
    return -np.sum(y_true * np.log(y_pred)) / y_pred.shape[0]
```

## 8. Funciones, métodos, librerías o comandos identificados
- **`step(z)`**: Función escalón (salida 0 o 1). No recomendada para entrenamiento con gradiente.
- **`σ(x)` (Sigmoid)**: Función logística. Rango $(0,1)$.
- **`tanh(x)`**: Tangente hiperbólica. Rango $(-1,1)$.
- **`max(0, x)`**: Definición matemática de ReLU.
- **`Softmax`**: Normalización exponencial para probabilidades.
- **`Cross Entropy`**: Función de pérdida para clasificación.
- **`MSE`**: Error Cuadrático Medio.
- **`GPU`**: Hardware optimizado para operaciones de álgebra lineal paralela usadas en redes neuronales.

## 9. Snippets o plantillas reutilizables

**Cálculo de una capa densa (Forward Pass) con NumPy:**
```python
# Definición de una capa densa simple
def dense_layer_forward(x, W, b, activation='relu'):
    """
    Ejecuta el paso hacia adelante de una capa densa.
    x: entrada (batch_size, input_features)
    W: pesos (input_features, output_features)
    b: bias (output_features)
    """
    # Transformación lineal: z = xW + b
    z = np.dot(x, W) + b
    
    # Selección de activación
    if activation == 'sigmoid':
        out = sigmoid(z)
    elif activation == 'relu':
        out = relu(z)
    elif activation == 'softmax':
        out = softmax(z)
    else:
        out = z # Identidad (útil en regresión)
        
    return out
```

## 10. Casos de uso y aplicaciones
- **Clasificación Multiclase:** Uso de Softmax en la capa de salida con Cross-Entropy Loss para identificar a qué clase pertenece una entrada (ej: reconocimiento de dígitos).
- **Regresión Robusta:** Uso de Huber Loss en modelos de predicción de valores continuos donde el dataset contiene outliers o ruido (ej: predicción de precios con errores de medición).
- **Aceleración de Entrenamiento:** Sustitución de Sigmoid por ReLU en capas ocultas para evitar saturación y acelerar la convergencia del gradiente.
- **Diseño de arquitecturas:** Uso de notación matricial para definir redes profundas ($W_1, W_2, \dots$) que pueden procesarse eficientemente en GPUs.

## 11. Limitaciones, riesgos y precauciones
- **Sigmoid/Tanh:** Sufren de *vanishing gradient* en redes profundas debido a la saturación de la derivada ($y(1-y)$ o $1-y^2$ se hacen muy pequeños).
- **ReLU:** No es diferenciable en $x=0$ (se resuelve asignando derivada 0 o 1 arbitrariamente). Riesgo de "Dying ReLU" si la entrada es consistentemente negativa.
- **Softmax:** Sensible a outliers en los logits (valores de entrada muy grandes causan inestabilidad numérica si no se usa el truco de restar el máximo).
- **KL-Divergence:** No es una métrica de distancia simétrica ($D(p||q) \neq D(q||p)$), por lo que no debe usarse como distancia geométrica estándar.
- **MSE:** Inadecuada para clasificación (derivada complicada con sigmoide y saturación); además, penaliza fuertemente outliers en regresión.

## 12. Relaciones con otros temas del corpus
- **Perceptrones (Cap 13.1):** Las redes densas son generalizaciones de perceptrones que introducen capas ocultas y funciones de activación continuas.
- **Backpropagation (Cap 13.3):** Las funciones de activación y pérdida definidas aquí son los componentes necesarios para aplicar el algoritmo de retropropagación (cálculo de derivadas).
- **Entropía (Cap 12.5.2):** Concepto base para definir Cross Entropy y KL-Divergence.
- **GPU Computing:** La notación matricial presentada es la base para la optimización hardware en Deep Learning.

## 13. Preguntas que la skill debería poder responder
1. ¿Por qué la función escalón (`step`) no es adecuada para entrenar redes neuronales con descenso de gradiente?
2. ¿Cuál es la ventaja principal de ReLU sobre Sigmoid en capas ocultas y qué problema específico puede causar ReLU?
3. ¿Cómo se calcula la derivada de la función Sigmoid utilizando únicamente su valor de salida?
4. ¿Qué técnica se debe aplicar para calcular Softmax de manera numéricamente estable y evitar overflow?
5. ¿Cuándo es preferible usar Huber Loss en lugar de MSE en problemas de regresión?
6. ¿Por qué se recomienda usar Cross-Entropy en lugar de MSE para problemas de clasificación con Softmax?
7. ¿Qué relación matemática existe entre la entropía cruzada y la divergencia Kullback-Leibler?
8. ¿Cómo se estructura la matriz de pesos $W$ en una capa densa en términos de filas y columnas?
9. ¿Qué es el "Dying ReLU" y cómo lo solucionan variantes como Leaky ReLU o ELU?
10. ¿Por qué el uso de notación de álgebra lineal es crucial para la implementación moderna de Deep Learning?

## 14. Acciones que la skill debería poder recomendar o ejecutar
- **Seleccionar función de activación:** Recomendar ReLU (o variantes) para capas ocultas y Softmax para la capa de salida en clasificación multiclase.
- **Implementar estabilidad:** Aplicar la sustracción del máximo (`max(x)`) antes de exponenciar en implementaciones de Softmax personalizadas.
- **Diagnosticar estancamiento:** Si el modelo no aprende, sugerir verificar la saturación de Sigmoid/Tanh o la presencia de Dying ReLU.
- **Manejo de outliers:** Sustituir MSE por Huber Loss si el análisis exploratorio de datos (EDA) revela outliers significativos en la variable objetivo.
- **Vectorización:** Reescribir bucles `for` anidados que procesan neuronas individuales por operaciones matriciales (`W @ x + b`) para aprovechar GPUs.

## 15. Activos finales de conocimiento en formato compacto

| Concepto | Descripción en una línea | Referencia interna |
| :--- | :--- | :--- |
| **Sigmoid** | Función logística $1/(1+e^{-x})$, rango $(0,1)$, propensa a saturación. | Sec. 13.2.3 |
| **ReLU** | $\max(0, x)$, evita saturación en positivos, riesgo de neuronas muertas. | Sec. 13.2.6 |
| **Softmax** | Convierte logits a probabilidades (suma 1), usar con truco de estabilidad. | Sec. 13.2.5 |
| **Cross Entropy** | Pérdida óptima para clasificación, mide distancia entre distribuciones. | Sec. 13.2.9 |
| **Huber Loss** | Híbrido cuadrático-lineal, robusto frente a outliers en regresión. | Sec. 13.2.8 |
| **Bias Vector ($b$)** | Vector de umbrales de la capa, permite desplazamiento de la activación. | Sec. 13.2.1 |
| **Dying ReLU** | Neurona que siempre emite 0 debido a entradas negativas persistentes. | Sec. 13.2.6 |
| **ELU** | Unidad Lineal Exponencial, suaviza transición en negativos, evita sesgo. | Sec. 13.2.6 |
| **KL-Divergence** | Medida no simétrica de distancia entre distribuciones de probabilidad. | Sec. 13.2.9 |
| **Linear Algebra Notation** | Representación matricial ($h = \sigma(Wx+b)$) para eficiencia en GPU. | Sec. 13.2.1 |


