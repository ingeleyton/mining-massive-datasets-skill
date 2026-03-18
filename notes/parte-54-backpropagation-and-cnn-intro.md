# Parte 54 - Backpropagation and CNN Intro

## 1. Metadatos del documento
- **Libro:** Mining of Massive Datasets, 3ª ed.
- **Fragmento/Parte:** Parte 54 - Backpropagation and CNN Intro
- **Temas principales:** Backpropagation, Gradiente Descendente, Grafos de Computación, Jacobianos, Regla de la Cadena, Tensores, Redes Neuronales Convolucionales (CNN).
- **Tipo de contenido:** Teoría / Algoritmo / Implementación

## 2. Resumen técnico de alto valor
El fragmento detalla el algoritmo de **Backpropagation** como método eficiente para calcular gradientes en redes neuronales profundas mediante la regla de la cadena aplicada iterativamente hacia atrás sobre un **grafo de computación** (DAG). Se formaliza el uso de **Jacobianos** para derivadas de funciones vectoriales y se demuestra la ventaja computacional de combinar **Softmax** con **Cross-Entropy** (gradiente simple: $q-p$). Se describe el ciclo de **Gradiente Descendente** (y su variante estocástica/minibatch), la importancia crítica de la tasa de aprendizaje y la inicialización aleatoria. Se introduce el concepto de **Tensores** como generalización de vectores/matrices y la técnica de "flattening" para adaptarlos a la retropropagación estándar. Finalmente, se introduce la motivación de las CNN para reducir la explosión de parámetros en datos de alta dimensión como imágenes.

## 3. Conceptos y definiciones clave
- **Grafo de Computación (Compute Graph):** Grafo dirigido acíclico (DAG) que representa el flujo de datos de una red neuronal. Los nodos contienen operandos (escalares, vectores, matrices) y operadores (funciones de activación, pérdida, operaciones algebraicas).
- **Gradiente ($\nabla_x y$):** Vector de derivadas parciales de una función escalar $y$ respecto a un vector $x$. Indica la dirección de máximo crecimiento de la función.
- **Jacobiano ($J_x(y)$):** Matriz de derivadas parciales para funciones vectoriales $f: \mathbb{R}^m \to \mathbb{R}^n$. Si $y=f(x)$, la entrada $(i,j)$ es $\frac{\partial y_i}{\partial x_j}$.
- **Backpropagation:** Algoritmo para calcular el gradiente de la función de pérdida respecto a los parámetros de la red, propagando gradientes hacia atrás desde la salida usando la regla de la cadena.
- **Tasa de aprendizaje (Learning Rate - $\eta$):** Hiperparámetro que controla el tamaño del paso en la actualización de parámetros durante el gradiente descendente.
- **Tensor:** Generalización de vectores y matrices a $n$ dimensiones. En el contexto de Deep Learning, se tratan como colecciones anidadas de vectores para aplicar backpropagation.
- **Overfitting (Sobreajuste):** Fenómeno donde el modelo tiene baja pérdida en el conjunto de entrenamiento pero bajo rendimiento en datos reales, debido a la alta capacidad paramétrica de las redes profundas.

## 4. Principios, reglas y heurísticas
- **Regla de actualización de parámetros:** $z \leftarrow z - \eta g(z)$, donde $g(z)$ es el gradiente promedio.
- **Regla de la cadena vectorial:** Si $y = g(x)$ y $z = f(y)$, entonces $\nabla_x z = J_x(y) \nabla_y z$.
- **Regla de la cadena con múltiples sucesores:** Si un nodo $a$ tiene sucesores, su gradiente es la suma de las contribuciones de cada sucesor.
- **Elección de Learning Rate:**
    - Muy pequeño: convergencia lenta.
    - Muy grande: oscilaciones y falta de convergencia.
    - Heurística: Decaimiento temporal ($\eta_{t+1} = \beta \eta_t$ con $0 < \beta < 1$).
- **Inicialización de pesos:** Debe ser aleatoria (uniforme o normal). Inicializar con valores idénticos causaría que todos los nodos de una capa aprendan las mismas características.
- **Combinación Softmax + Cross-Entropy:** Usar esta pareja es una buena práctica obligatoria en clasificación porque produce un gradiente simple ($\nabla_y l = q - p$) que evita problemas de saturación o explosión de gradiente.

## 5. Procedimientos, métodos y workflows
**Algoritmo de Backpropagation:**
1.  **Forward Pass:** Ejecutar el grafo de computación hacia adelante para calcular la salida y la pérdida $L$.
2.  **Backward Pass:** Empezar desde el nodo de pérdida $L$.
    -   Calcular el gradiente de $L$ respecto a la salida ($g(y)$).
    -   Iterar hacia atrás: Para cada nodo $a$ cuyo sucesor $b$ ya fue procesado, calcular $g(a) = J_a(b)g(b)$.
    -   Si hay múltiples sucesores, sumar los gradientes.
3.  **Acumulación:** Promediar los gradientes sobre el conjunto (o minibatch) de entrenamiento.
4.  **Actualización:** Ajustar pesos $W$ y sesgos $b$ usando gradiente descendente.

**Manejo de Tensores en Backpropagation:**
1.  Identificar el tensor de entrada (ej. imagen $28 \times 28$).
2.  "Aplanar" (flatten) el tensor en un vector unidimensional (ej. vector de 784).
3.  Aplicar el algoritmo estándar de backpropagation sobre el vector aplanado.

## 6. Problemas comunes y soluciones
- **Explosión de parámetros en imágenes:** Una capa densa para una imagen de $224 \times 224 \times 3$ requiere $\approx 150,000$ parámetros por neurona, llevando a overfitting masivo.
    - *Solución:* Usar Redes Neuronales Convolucionales (CNN) que reducen drásticamente los parámetros mediante capas convolucionales y pooling.
- **Saturación de gradiente:** Usar funciones de activación como sigmoid puede causar gradientes pequeños.
    - *Solución:* Usar la combinación Softmax + Cross-Entropy en la capa de salida, que garantiza un gradiente limpio ($q-p$) sin dependencia directa de la derivada de la activación interna que cause saturación.
- **Simetría en pesos:** Inicializar todos los pesos a cero o constante hace que las neuronas sean redundantes.
    - *Solución:* Inicialización aleatoria.

## 7. Implementación técnica y generación de código

```pseudocode
# Algoritmo: Paso de Backpropagation para un nodo simple
# Entrada: Nodo actual 'a', Sucesor 'b', Gradiente del sucesor g(b)
# Salida: Gradiente del nodo actual g(a)

Funcion CalcularGradiente(a, b, g(b)):
    Si a tiene operador:
        Calcular Jacobiano J_a(b) basado en la operación entre a y b
        g(a) = J_a(b) * g(b)
    Sino:
        g(a) = g(b) # Caso trivial, identidad
    Retornar g(a)
```

```python
import numpy as np

def sigmoid(x):
    return 1 / (1 + np.exp(-x))

def softmax(y):
    # Estabilidad numérica: restar max
    exp_y = np.exp(y - np.max(y))
    return exp_y / exp_y.sum()

def cross_entropy_loss(p, q):
    """p: vector one-hot real, q: probabilidad estimada (softmax output)"""
    return -np.sum(p * np.log(q + 1e-9)) # epsilon para evitar log(0)

# Implementación del gradiente combinado Softmax + Cross-Entropy
# Derivado en Ejemplo 13.5: gradiente = q - p
def grad_softmax_cross_entropy(y_logits, p_true):
    """
    Calcula el gradiente de la pérdida (CrossEntropy) respecto a los logits (entrada a softmax).
    y_logits: salida de la última capa lineal (vector)
    p_true: vector one-hot de la etiqueta verdadera
    """
    q = softmax(y_logits)
    # El gradiente es simplemente la diferencia entre probabilidad predicha y real
    return q - p_true

# Ejemplo de paso de actualización (Gradient Descent)
def update_parameters(params, grads, learning_rate):
    # params y grads son diccionarios o listas de numpy arrays
    for i in range(len(params)):
        params[i] -= learning_rate * grads[i]
    return params
```

## 8. Funciones, métodos, librerías o comandos identificados
- **Operador $\sigma$ (Sigmoid):** Función de activación. Derivada: $y(1-y)$.
- **Operador $\mu$ (Softmax):** Normalización de salida a probabilidades.
- **MSE (Mean Squared Error):** Función de pérdida. Gradiente respecto a $y$: $2(y - \hat{y})$.
- **Producto de Hadamard ($\circ$):** Producto elemento a elemento entre vectores. Usado en el cálculo del gradiente a través de funciones de activación elemento a elemento.
- **Flattening:** Operación para convertir tensores ($n$-dimensionales) en vectores (1-dimensional).

## 9. Snippets o plantillas reutilizables

```python
# Plantilla: Estructura básica de entrenamiento con Minibatch SGD
def train_step(model_inputs, true_labels, model_params, lr):
    # 1. Forward Pass (Cálculo de pérdida)
    logits = forward_pass(model_inputs, model_params)
    loss = cross_entropy_loss(softmax(logits), true_labels)
    
    # 2. Backward Pass (Cálculo de gradientes)
    # Usando el resultado derivado para la última capa
    grad_logits = grad_softmax_cross_entropy(logits, true_labels)
    
    # Propagar gradientes hacia atrás por la red...
    # (Aquí iría la lógica específica de las capas ocultas)
    grads = backward_pass(grad_logits, model_params)
    
    # 3. Update Parameters
    model_params = update_parameters(model_params, grads, lr)
    
    return loss, model_params
```

## 10. Casos de uso y aplicaciones
- **Clasificación MNIST:** Identificación de dígitos escritos a mano ($28 \times 28$ píxeles). El texto detalla cómo una imagen se convierte en un tensor y se aplana a un vector de 784 componentes para una capa densa, o cómo se estructura un tensor de pesos $7 \times 7 \times 28 \times 28$.
- **Procesamiento de imágenes en color:** Representación como tensor 2D de pixeles donde cada pixel es un vector de 3 dimensiones (RGB).
- **Clasificación general:** Uso de Softmax + Cross-Entropy para problemas de clasificación multiclase.

## 11. Limitaciones, riesgos y precauciones
- **Complejidad en Tensores:** El algoritmo de backpropagation estándar se define sobre vectores. El uso de tensores de alta dimensión requiere "flattening" o técnicas específicas (como convoluciones) para ser manejables.
- **Overfitting:** Las redes profundas tienen millones de parámetros. Riesgo alto de memorizar el set de entrenamiento.
- **Sensibilidad a Hiperparámetros:** La convergencia depende críticamente de $\eta$ (tasa de aprendizaje) y la inicialización. No hay método analítico cerrado para elegirlos; requiere prueba y error.

## 12. Relaciones con otros temas del corpus
- **Sección 9.4.4 (Overfitting):** Concepto base mencionado como riesgo principal en redes profundas.
- **Sección 12.3.5 (Stochastic Gradient Descent):** Base del algoritmo de optimización utilizado.
- **Sección 13.2 (Neural Nets):** Define las funciones de activación ($\sigma$, tanh) y la estructura de pesos ($W$) necesarias para entender el grafo de computación.
- **Sección 13.4 (CNNs):** Evolución natural para resolver la limitación de parámetros de las capas densas (fully-connected) en imágenes.

## 13. Preguntas que la skill debería poder responder
1. ¿Por qué se utiliza el Jacobiano en lugar del gradiente simple en funciones vectoriales?
2. ¿Cuál es la derivada (gradiente) de la función de pérdida Cross-Entropy combinada con Softmax y por qué es preferible usarlas juntas?
3. ¿Cómo se aplica la regla de la cadena en el algoritmo de Backpropagation dentro de un grafo de computación?
4. ¿Qué es el "flattening" de tensores y por qué es necesario en la implementación de backpropagation estándar?
5. ¿Qué riesgos conlleva una tasa de aprendizaje demasiado alta o demasiado baja?
6. ¿Por qué es incorrecto inicializar todos los pesos de una red neuronal a cero?
7. ¿Cómo se calcula el gradiente de la función sigmoide en términos de su propia salida?
8. ¿Qué problema resuelven las Redes Neuronales Convolucionales (CNN) respecto a las capas densas tradicionales?

## 14. Acciones que la skill debería poder recomendar o ejecutar
- Calcular el tamaño del vector de entrada necesario al aplanar (flatten) una imagen de dimensiones $H \times W \times C$.
- Implementar la función de gradiente para la última capa de una red de clasificación (Softmax + CrossEntropy).
- Diagnosticar falta de convergencia sugiriendo ajustes en la tasa de aprendizaje.
- Sugerir el uso de CNNs si el input son imágenes de alta resolución para evitar explosión de parámetros.
- Construir un grafo de computación simple para una red neuronal de una capa.

## 15. Activos finales de conocimiento en formato compacto
| Concepto | Descripción | Referencia |
| :--- | :--- | :--- |
| **Backpropagation** | Algoritmo para calcular gradientes recursivamente hacia atrás usando la regla de la cadena. | Sec 13.3.3 |
| **Grafo de Computación** | DAG que define el flujo de datos y operaciones para derivación automática. | Sec 13.3.1 |
| **Gradiente Softmax+CE** | Resultado simplificado: $\nabla_y l = q - p$ (predicción - real). | Sec 13.3.3, Ex 13.5 |
| **Jacobiano** | Matriz de derivadas parciales para mapeo vectorial $\mathbb{R}^m \to \mathbb{R}^n$. | Sec 13.3.2 |
| **Gradiente Descendente** | Regla de actualización: $z \leftarrow z - \eta \nabla_z L$. | Sec 13.3.4 |
| **Flattening** | Conversión de tensores $n$-dim a vectores para procesamiento estándar. | Sec 13.3.5 |
| **Inicialización** | Pesos deben ser aleatorios para romper simetría entre neuronas. | Sec 13.3.4 |
| **Minibatch SGD** | Estimación de gradiente usando muestras aleatorias pequeñas del dataset. | Sec 13.3.4 |
| **Overfitting** | Riesgo principal en redes profundas con muchos parámetros. | Sec 13.3 intro |
| **CNNs** | Solución arquitectónica para reducir parámetros en procesamiento de imágenes. | Sec 13.4 |


