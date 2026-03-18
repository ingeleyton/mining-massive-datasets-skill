# Parte 56 - RNNs, LSTMs, and BPTT

## 1. Metadatos del documento
- **Libro:** Mining of Massive Datasets, 3ª ed.
- **Fragmento/Parte:** Parte 56 - RNNs, LSTMs, and BPTT
- **Temas principales:** Recurrent Neural Networks (RNN), Long Short-Term Memory (LSTM), Backpropagation Through Time (BPTT), Vanishing/Exploding Gradients, Procesamiento de Secuencias, GRU.
- **Tipo de contenido:** Teoría / Algoritmo / Implementación

## 2. Resumen técnico de alto valor
Las Redes Neuronales Recurrentes (RNN) extienden las arquitecturas neuronales tradicionales para procesar datos secuenciales (texto, video, series temporales) mediante la introducción de un estado oculto $s_t$ que actúa como memoria del prefijo de la secuencia procesada. A diferencia de las CNN, las RNN comparten pesos ($U, W, V$) a través del tiempo, permitiendo procesar secuencias de longitud variable y modelar dependencias temporales. El entrenamiento se realiza mediante Backpropagation Through Time (BPTT), que despliega la red en el tiempo para calcular gradientes.

Sin embargo, la arquitectura RNN estándar sufre críticamente del problema de los **gradientes desvanecientes** (vanishing gradients) debido a la multiplicación repetida de matrices derivadas de funciones de activación como `tanh`, lo que impide aprender dependencias a largo plazo. Para mitigar esto, se introduce la arquitectura **LSTM** (Long Short-Term Memory), que separa el estado en memoria a largo plazo ($c_t$) y memoria de trabajo ($s_t$), reguladas por compuertas (gates) que permiten olvidar, guardar y enfocar información selectivamente, evitando la degradación del gradiente.

## 3. Conceptos y definiciones clave
- **RNN (Recurrent Neural Network):** Arquitectura diseñada para datos secuenciales donde la salida en el tiempo $t$ depende de la entrada actual $x_t$ y el estado oculto previo $s_{t-1}$.
- **Estado oculto ($s_t$):** Vector que codifica la "memoria de trabajo" o información del prefijo de la secuencia visto hasta el tiempo $t$. Se calcula como $s_t = f(Ux_t + Ws_{t-1} + b)$.
- **1-hot vector:** Representación de entrada donde un vector de longitud igual al vocabulario tiene un 1 en la posición de la palabra actual y 0 en el resto.
- **BPTT (Backpropagation Through Time):** Algoritmo de entrenamiento que despliega (unroll) la RNN a través de los pasos temporales para aplicar backpropagation estándar.
- **Gradientes desvanecientes (Vanishing Gradients):** Fenómeno donde el gradiente tiende a cero exponencialmente a medida que se propaga hacia atrás en el tiempo, impidiendo que las capas iniciales aprendan (común con activación `tanh`).
- **Gradientes explosivos (Exploding Gradients):** Fenómeno donde el gradiente crece descontroladamente (común con ReLU o pesos grandes), mitigable mediante *gradient clipping*.
- **LSTM (Long Short-Term Memory):** Variante de RNN que introduce un estado de celda $c_t$ (memoria a largo plazo) y compuertas para controlar el flujo de información, resolviendo el problema del gradiente desvaneciente.
- **Compuertas (Gates):** Vectores con valores en $[0, 1]$ que multiplican elemento a elemento (Hadamard) al estado para filtrar información. Tipos: *Forget gate* ($f_t$), *Input gate* ($i_t$), *Output gate* ($o_t$).
- **Producto de Hadamard:** Operación $\circ$ que multiplica vectores elemento a elemento. Usado en LSTMs para aplicar las compuertas.

## 4. Principios, reglas y heurísticas
- **Compartición de pesos:** En una RNN, las matrices de pesos $U$ (entrada-estado) y $W$ (estado-estado) son las mismas para cada paso temporal $t$. Esto permite generalizar a secuencias de diferentes longitudes.
- **Gestión de longitudes variables:**
    - Usar **Zero-padding**: Rellenar secuencias cortas con ceros hasta la longitud máxima $n$.
    - Usar **Bucketing**: Agrupar secuencias por longitud y crear RNNs específicas por grupo para eficiencia.
- **Inicialización de estado:** El estado inicial $s_0$ se define como un vector de ceros.
- **Elección de activación:**
    - `tanh` para actualización de estado en RNN simples (propensa a vanishing gradients).
    - `sigmoid` para compuertas en LSTM (permite "abrir" o "cerrar" flujo).
    - `softmax` para la capa de salida $y_t$ si se requiere distribución de probabilidad.
- **Tratamiento de gradientes explosivos:** Se recomienda "clipping" (recorte) del gradiente para limitarlo a un rango fijo.
- **Diseño LSTM vs RNN:** Usar LSTM cuando se requieran dependencias de largo alcance. Usar RNN simple solo para dependencias locales o recursos limitados.

## 5. Procedimientos, métodos y workflows

### 5.1 Forward Pass en RNN Estándar
**Precondiciones:** Entrada secuencial $x_1, \dots, x_n$, pesos $U, W, V$, bias $b, c$.
**Pasos:**
1. Inicializar $s_0 = \vec{0}$.
2. Para cada paso $t$ de $1$ a $n$:
   a. Calcular estado oculto: $s_t = \tanh(Ux_t + Ws_{t-1} + b)$.
   b. Calcular salida: $y_t = \text{softmax}(Vs_t + c)$.
**Postcondición:** Secuencia de salidas $y_1, \dots, y_n$.

### 5.2 Forward Pass en LSTM
**Precondiciones:** Estado oculto previo $s_{t-1}$, estado de celda previo $c_{t-1}$, entrada $x_t$.
**Pasos:**
1. Calcular vector candidato de actualización: $h_t = \tanh(W_h s_{t-1} + U_h x_t + b_h)$.
2. Calcular compuerta de olvido: $f_t = \sigma(W_f s_{t-1} + U_f x_t + b_f)$.
3. Calcular compuerta de entrada: $i_t = \sigma(W_i s_{t-1} + U_i x_t + b_i)$.
4. Actualizar estado de celda (memoria largo plazo): $c_t = c_{t-1} \circ f_t + h_t \circ i_t$.
5. Calcular compuerta de salida: $o_t = \sigma(W_u s_{t-1} + U_u x_t + b_u)$.
6. Actualizar estado oculto (memoria trabajo): $s_t = \tanh(c_t \circ o_t)$.
7. Calcular salida final: $y_t = g(Vs_t + d)$.

### 5.3 Backpropagation Through Time (BPTT) - Cálculo de Gradientes
**Objetivo:** Calcular $\frac{de}{dW}$.
1. Definir error total $e = \sum_{i=1}^n e_i$.
2. Definir $R_t = \frac{ds_t}{dW}$.
3. Calcular recursivamente $R_t$ hacia atrás:
   $$R_t = A(B + W^T R_{t-1})$$
   Donde $A$ es la derivada de la activación (matriz diagonal de $1 - s_t^2$ para tanh) y $B$ es la derivada parcial respecto a $W$ directo.
4. Acumular gradientes: $\frac{de}{dW} = \sum_{t=1}^n \frac{de_t}{dW}$.

## 6. Problemas comunes y soluciones
- **Problema:** Dependencias de largo alcance no se aprenden en RNN simples.
  - **Causa:** La recurrencia $R_t = P_t + Q_t R_{t-1}$ implica multiplicar matrices $Q_t$ repetidamente. Si sus valores propios son $<1$, el gradiente desaparece.
  - **Solución:** Usar arquitectura LSTM. La actualización de celda $c_t = c_{t-1} \circ f_t + \dots$ permite que el gradiente fluya sin degradarse si $f_t \approx 1$.
- **Problema:** Gradientes explosivos ($\|\nabla\| \to \infty$).
  - **Solución:** Gradient Clipping (limitar el valor máximo del gradiente).
- **Problema:** Secuencias de longitud variable ineficiente con padding excesivo.
  - **Solución:** Bucketing (agrupar por longitudes similares) para minimizar el cómputo de padding.

## 7. Implementación técnica y generación de código

```pseudocode
# Algoritmo: Paso Forward RNN simple
# Entrada: x_seq (secuencia de vectores), U, W, V, b, c
# Salida: y_seq, s_seq

s_prev = vector_de_ceros(dimension_estado)
para cada t en rango(longitud_secuencia):
    entrada = x_seq[t]
    # Combinación lineal y activación
    s_actual = tanh(dot(U, entrada) + dot(W, s_prev) + b)
    # Salida
    y_actual = softmax(dot(V, s_actual) + c)
    
    guardar s_actual en s_seq
    guardar y_actual en y_seq
    s_prev = s_actual
fin para
retornar y_seq, s_seq
```

```python
import numpy as np

def rnn_step_forward(x, s_prev, U, W, V, b, c):
    """
    Ejecuta un único paso forward de una RNN simple.
    """
    # Cálculo del estado oculto (memoria de trabajo)
    # s_t = tanh(Ux_t + Ws_{t-1} + b)
    linear_comb = np.dot(U, x) + np.dot(W, s_prev) + b
    s_next = np.tanh(linear_comb)
    
    # Cálculo de la salida (probabilidad)
    # y_t = softmax(Vs_t + c)
    # Nota: Se usa softmax para ejemplo de lenguaje
    logits = np.dot(V, s_next) + c
    exp_scores = np.exp(logits)
    y = exp_scores / np.sum(exp_scores)
    
    return y, s_next

def lstm_step_forward(x, s_prev, c_prev, params):
    """
    Ejecuta un único paso forward de una LSTM.
    params: diccionario con matrices W_f, W_i, W_u, W_h y biases.
    """
    # Concatenar entrada y estado previo es común en implementaciones reales,
    # pero aquí seguimos la notación del libro (matrices separadas).
    
    # 1. Candidato de actualización
    h = np.tanh(np.dot(params['W_h'], s_prev) + np.dot(params['U_h'], x) + params['b_h'])
    
    # 2. Compuertas (Forget, Input, Output)
    f = sigmoid(np.dot(params['W_f'], s_prev) + np.dot(params['U_f'], x) + params['b_f'])
    i = sigmoid(np.dot(params['W_i'], s_prev) + np.dot(params['U_i'], x) + params['b_i'])
    o = sigmoid(np.dot(params['W_u'], s_prev) + np.dot(params['U_u'], x) + params['b_u'])
    
    # 3. Estados (Celda y Oculto)
    c_next = c_prev * f + h * i  # Memoria largo plazo
    s_next = np.tanh(c_next) * o # Memoria trabajo / salida
    
    return s_next, c_next

def sigmoid(x):
    return 1 / (1 + np.exp(-x))
```

## 8. Funciones, métodos, librerías o comandos identificados
- **`tanh`**: Función de activación para estados ocultos. Rango $[-1, 1]$. Derivada $1 - s^2$.
- **`sigmoid` ($\sigma$)**: Función de activación para compuertas LSTM. Rango $[0, 1]$.
- **`softmax`**: Función de activación para capa de salida (probabilidades sobre vocabulario).
- **`dot` (Producto escalar)**: Operación principal para proyecciones lineales ($Ux, Ws$).
- **`*` (Producto de Hadamard)**: Multiplicación elemento a elemento para aplicar compuertas ($c_t \circ f_t$).

## 9. Snippets o plantillas reutilizables

```python
# Plantilla: Preparación de datos para RNN con Bucketing y Padding
# Contexto: El libro sugiere agrupar secuencias por longitud para eficiencia.

def bucket_and_pad(sequences, max_lengths):
    """
    Agrupa secuencias en buckets definidos y aplica padding.
    max_lengths: lista de longitudes máximas para cada bucket, ej [10, 20, 30]
    """
    buckets = {length: [] for length in max_lengths}
    
    for seq in sequences:
        # Encontrar el bucket más pequeño que quepa la secuencia
        suitable_bucket = min([b for b in max_lengths if b >= len(seq)])
        
        # Crear vector de padding (asumiendo 0 como token de pad)
        pad_length = suitable_bucket - len(seq)
        padded_seq = seq + [0] * pad_length
        
        buckets[suitable_bucket].append(padded_seq)
        
    return buckets
```

## 10. Casos de uso y aplicaciones
- **Modelado de Lenguaje:** Predicción de la siguiente palabra en una oración. Entrada: prefijo de la oración. Salida: vector de probabilidad sobre el vocabulario.
- **Traducción Automática:** Secuencia de entrada (oración origen) -> Codificador RNN -> Decodificador RNN -> Secuencia de salida (oración destino). A menudo requiere salida solo al final.
- **Análisis de Video:** Secuencia de frames (imágenes) para detectar acciones o transiciones de escena.
- **Series Temporales Financieras:** Predicción de precios de acciones basada en el historial de precios.

## 11. Limitaciones, riesgos y precauciones
- **Cuello de botella de memoria:** El BPTT requiere almacenar los estados intermedios de todos los pasos temporales para el paso backward, lo que consume mucha memoria para secuencias largas.
- **Latencia de inferencia:** A diferencia de las CNN, las RNN no son fácilmente paralelizables en el paso forward debido a la dependencia secuencial $s_t$ de $s_{t-1}$.
- **Sensibilidad a la longitud:** El libro advierte que sin técnicas avanzadas (LSTM), la RNN "olvida" información temprana tras unos pocos pasos.
- **Complejidad paramétrica:** Una LSTM tiene significativamente más parámetros (4 conjuntos de pesos: $h, f, i, o$) que una RNN simple, aumentando el riesgo de sobreajuste en datasets pequeños.

## 12. Relaciones con otros temas del corpus
- **CNNs (Sección 13.4):** Mientras las CNN comparten pesos espacialmente, las RNN comparten pesos temporalmente.
- **Embeddings (One-hot):** La entrada a la RNN suele ser un vector one-hot que se transforma mediante la matriz $U$ (que actúa como embedding layer).
- **Backpropagation:** Conocimiento previo esencial para entender BPTT.
- **Gradient Descent:** Algoritmo de optimización subyacente.

## 13. Preguntas que la skill debería poder responder
1. ¿Por qué una RNN estándar no puede aprender dependencias entre palabras distantes en una oración larga?
2. ¿Cuál es la diferencia funcional entre el estado oculto $s_t$ y el estado de celda $c_t$ en una LSTM?
3. ¿Cómo se implementa la técnica de "Bucketing" para manejar secuencias de longitud variable y por qué es preferible a un padding uniforme excesivo?
4. ¿Qué rol juega la compuerta de olvido ($f_t$) en la preservación del gradiente durante el entrenamiento?
5. ¿Cómo se calcula el gradiente de la función de error respecto a los pesos recurrentes $W$ en el tiempo?
6. ¿Qué es el producto de Hadamard y por qué es fundamental en la arquitectura LSTM?
7. ¿Cuándo se debe elegir una GRU sobre una LSTM?

## 14. Acciones que la skill debería poder recomendar o ejecutar
- **Diagnosticar fallos de entrenamiento:** Si el modelo no aprende dependencias largas, recomendar cambiar RNN por LSTM/GRU.
- **Optimizar memoria:** Si hay OOM (Out of Memory) en secuencias largas, sugerir reducir el tamaño del batch o usar *truncated BPTT* (aunque no explícito en el fragmento, se deriva de la limitación de BPTT).
- **Preprocesamiento:** Implementar una función de bucketing para datasets con alta varianza en longitudes de secuencia.
- **Regularización:** Sugerir Gradient Clipping si se detectan NaNs en el loss (síntoma de exploding gradients).

## 15. Activos finales de conocimiento en formato compacto
| Concepto | Descripción | Referencia |
| :--- | :--- | :--- |
| **RNN State Update** | $s_t = \tanh(Ux_t + Ws_{t-1} + b)$ | Eq. 13.5 |
| **LSTM Cell Update** | $c_t = c_{t-1} \circ f_t + h_t \circ i_t$ | Eq. 13.13 |
| **Vanishing Gradient** | Degradación exponencial del gradiente por multiplicación de derivadas $<1$. | Sec. 13.5.2 |
| **BPTT** | Backpropagation Through Time: Despliegue temporal de la red para calcular gradientes. | Sec. 13.5.1 |
| **Forget Gate** | $f_t = \sigma(W_f s_{t-1} + U_f x_t + b_f)$; controla qué memoria se retiene. | Eq. 13.11 |
| **Zero-padding** | Rellenar secuencias cortas con ceros para igualar longitud máxima. | Sec. 13.5 |
| **Bucketing** | Agrupar secuencias por longitud para minimizar padding y cómputo. | Sec. 13.5 |
| **Hadamard Product** | Multiplicación elemento a elemento ($\circ$), usada para aplicar compuertas. | Sec. 13.5.3 |
| **Gradient Clipping** | Técnica para mitigar gradientes explosivos limitando su magnitud. | Sec. 13.5.2 |
| **GRU** | Gated Recurrent Unit: Variante simplificada de LSTM con menos parámetros. | Sec. 13.5.3 |


