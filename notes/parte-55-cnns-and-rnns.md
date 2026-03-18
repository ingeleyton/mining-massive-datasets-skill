# Parte 55 - CNNs and RNNs

## 1. Metadatos del documento
- **Libro:** Mining of Massive Datasets, 3ª ed.
- **Fragmento/Parte:** Parte 55 - CNNs and RNNs
- **Temas principales:** Redes Neuronales Convolucionales (CNN), Capas Convolucionales, Capas de Pooling, Arquitectura CNN, Implementación Matricial de Convolución, Redes Neuronales Recurrentes (RNN)
- **Tipo de contenido:** Teoría / Algoritmo / Implementación

## 2. Resumen técnico de alto valor
El fragmento aborda la limitación de las redes totalmente conectadas (fully-connected) para procesamiento de imágenes debido a la explosión de parámetros (ej. 33 millones para imágenes 224x224), introduciendo las Redes Neuronales Convolucionales (CNN) como solución que explota la localidad espacial y la invarianza traslacional de los datos visuales. Se detalla la operación de convolución mediante filtros (kernels), definiendo matemáticamente la respuesta del filtro y el cálculo de la dimensión de salida en función del stride, padding y tamaño del filtro. Se explica la implementación eficiente mediante vectorización (im2col) para aprovechar la multiplicación matricial en GPUs. Se describen las capas de pooling para reducción de dimensionalidad y robustez frente a pequeñas traslaciones, culminando en una arquitectura típica (tipo VGG) que alterna convolución y pooling. Finalmente, se introduce el concepto de Redes Neuronales Recurrentes (RNN) para datos secuenciales, destacando la necesidad de "memoria" y compartición de parámetros a lo largo del tiempo.

## 3. Conceptos y definiciones clave
- **Capa Convolucional (Convolutional Layer):** Capa que aplica filtros espaciales pequeños a regiones contiguas de la entrada, reduciendo drásticamente el número de parámetros respecto a una capa densa y permitiendo la detección de características independientes de su ubicación.
- **Filtro (Filter) / Kernel:** Matriz de pesos pequeña (ej. 5x5 o 3x3) que se desliza sobre la entrada para detectar características específicas (bordes, texturas). En imágenes a color, la profundidad del filtro coincide con los canales de la imagen (ej. 3 para RGB).
- **Mapa de Activación (Activation Map):** Salida 2D resultante de aplicar un filtro sobre toda la imagen de entrada. Indica la presencia e intensidad de una característica en cada ubicación espacial.
- **Stride (Paso):** Número de píxeles que se desplaza el filtro en cada paso. Un stride mayor reduce la dimensión espacial de la salida.
- **Zero Padding (Relleno de ceros):** Adición de filas y columnas de ceros alrededor del borde de la imagen para controlar la reducción dimensional o preservar el tamaño espacial.
- **Capa de Pooling:** Capa de submuestreo que reduce la extensión espacial mediante una función de agregación (típicamente `max`) sobre regiones locales, proporcionando invarianza a pequeñas traslaciones.
- **Cross-Correlation vs Convolution:** Matemáticamente, la operación en las CNNs es una correlación cruzada (el kernel no se voltea), aunque se denomina "convolución" por convención histórica.
- **Red Neuronal Recurrente (RNN):** Arquitectura especializada para datos secuenciales donde la salida en cada paso depende del prefijo de la secuencia, requiriendo retención de memoria y compartición de parámetros a través del tiempo.

## 4. Principios, reglas y heurísticas
- **Regla de dimensión de salida:** Para una entrada de tamaño $m \times m$, filtro $f$, stride $s$ y padding $p$, la salida es de tamaño $n \times n$ donde:
  $$n = \frac{m - f + 2p}{s} + 1$$
  *Condición:* $s$ debe dividir exactamente $m - f + 2p$ para evitar error en la implementación.
- **Regla de parámetros:** Una capa convolucional con $k$ filtros de tamaño $f$ sobre entrada con $d$ canales tiene $k(df^2 + 1)$ parámetros (pesos + bias).
- **Heurística de diseño:** Las redes profundas con filtros pequeños son superiores a las redes superficiales con filtros grandes.
- **Heurística de arquitectura:** Usar capas convolucionales para preservar extensión espacial (usando padding) y capas de pooling exclusivamente para reducción de tamaño.
- **Heurística de stride:** Strides pequeños (1 o 2) funcionan mejor en la práctica que strides grandes.
- **Heurística de tamaño de entrada:** Es útil que el tamaño de entrada sea divisible por 2 múltiples veces para facilitar la reducción progresiva mediante pooling.

## 5. Procedimientos, métodos y workflows
### Aplicación de un Filtro (Forward Pass)
1.  **Alineación:** Colocar el filtro $W$ sobre una región de la imagen $X$.
2.  **Producto punto:** Multiplicar elemento a elemento y sumar (o vectorizar región y filtro y realizar producto punto).
3.  **Suma de Bias:** Añadir el término de sesgo $b$.
4.  **Activación:** Aplicar función de activación (típicamente ReLU) al resultado.
5.  **Desplazamiento:** Mover el filtro según el stride y repetir hasta cubrir toda la imagen.

### Implementación Matricial Eficiente (Vectorización)
1.  **Aplanar Filtro:** Convertir el filtro $F$ en un vector columna $g$ de tamaño $f^2 \times 1$.
2.  **Construir Matriz de Entrada (im2col):** Crear matriz $Y$ donde cada columna es una región $f \times f$ de la entrada aplanada. Tamaño resultante: $f^2 \times n^2$.
3.  **Operación Lineal:** Calcular $z = Y^T g + b$.
4.  **Reconstrucción:** Reorganizar el vector resultante $z$ en la matriz de salida $n \times n$.

## 6. Problemas comunes y soluciones
- **Problema:** Explosión de parámetros en redes fully-connected para imágenes (overfitting, costo computacional).
  - **Solución:** Usar capas convolucionales que comparten pesos (filtros) y asumen localidad espacial.
- **Problema:** Reducción excesiva del tamaño espacial en capas profundas.
  - **Solución:** Implementar *Zero Padding*. Un padding $p = (f-1)/2$ con stride 1 preserva el tamaño de entrada.
- **Problema:** Alta consumo de memoria en implementación matricial de convolución.
  - **Solución:** Aceptar el trade-off. La matriz $Y$ es mayor que $X$ (repetición de datos), pero la operación $Y^T g$ es extremadamente rápida en GPUs.
- **Problema:** Configuración inválida de hiperparámetros (stride no divide exactamente la dimensión espacial).
  - **Solución:** Validar que $s$ divida $m - f + 2p$ antes de la construcción del modelo; la mayoría de frameworks lanzan excepción si no se cumple.

## 7. Implementación técnica y generación de código

```pseudocode
# Cálculo de respuesta de filtro (Ecuación 13.1)
# Entrada: Imagen X, Filtro W (tamaño fxf), Bias b
# Salida: Mapa de activación R

Para i desde 1 hasta (m - f + 2p)/s + 1:
    Para j desde 1 hasta (m - f + 2p)/s + 1:
        suma = 0
        Para k desde 0 hasta f-1:
            Para l desde 0 hasta f-1:
                # Asumiendo manejo de bordes implícito o padding previo
                suma = suma + X[i+k, j+l] * W[k, l]
        R[i, j] = activacion(suma + b)
```

```python
import numpy as np

def conv2d_forward(input_image, kernel, bias, stride=1, padding=0):
    """
    Implementación simplificada de una convolución 2D basada en el enfoque 
    de vectorización descrito en la Sección 13.4.5.
    input_image: Matriz 2D (m x m)
    kernel: Matriz 2D (f x f)
    """
    m, _ = input_image.shape
    f, _ = kernel.shape
    
    # 1. Aplicar Padding si es necesario
    if padding > 0:
        input_padded = np.pad(input_image, padding, mode='constant', constant_values=0)
    else:
        input_padded = input_image
        
    # Calcular dimensión de salida
    n = int((m - f + 2 * padding) / stride + 1)
    
    # 2. Construcción de la matriz Y (Concepto im2col simplificado para 2D)
    # Extraemos todas las regiones fxf como columnas
    # Nota: En librerías reales esto se optimiza, aquí es ilustrativo.
    cols = []
    for i in range(0, n * stride, stride):
        for j in range(0, n * stride, stride):
            region = input_padded[i:i+f, j:j+f]
            cols.append(region.flatten())
    
    Y = np.array(cols).T # Tamaño (f^2, n^2)
    
    # 3. Aplanar filtro y calcular
    g = kernel.flatten().reshape(-1, 1) # Tamaño (f^2, 1)
    
    # Operación: z = Y.T @ g + b
    # Y.T es (n^2, f^2), g es (f^2, 1) -> Resultado (n^2, 1)
    output_flat = Y.T @ g + bias
    
    # 4. Reorganizar a matriz n x n
    output = output_flat.reshape(n, n)
    
    return output

# Ejemplo de uso basado en Fig 13.10
img = np.array([[1, 0, 1, 0],
                [0, 1, 0, 1],
                [1, 1, 0, 0],
                [0, 0, 0, 1]])
                
filt = np.array([[1, 0],
                 [0, -1]])
                 
# Resultado esperado (aprox): esquina sup-izq = 1*1 + 0*0 + 0*0 + (-1)*1 = 0
res = conv2d_forward(img, filt, bias=0, stride=1, padding=0)
print(res[0, 0]) # Debería ser cercano a 0
```

## 8. Funciones, métodos, librerías o comandos identificados
- **`im2col` (Concepto):** Transformación de imagen a columnas para vectorizar la convolución.
- **ReLU:** Función de activación estándar para mapas de activación en CNNs.
- **Max Pooling:** Función de agregación que selecciona el valor máximo en una ventana local.
- **Zero Padding:** Operación de relleno de bordes.
- **Dot Product:** Operación fundamental para calcular la respuesta del filtro.

## 9. Snippets o plantillas reutilizables

```python
def calculate_output_dim(m, f, s, p):
    """
    Calcula la dimensión espacial de salida de una capa convolucional o pooling.
    m: Dimensión de entrada
    f: Tamaño del filtro/kernel/pool
    s: Stride
    p: Padding
    """
    n = (m - f + 2 * p) / s + 1
    if not n.is_integer():
        raise ValueError(f"Configuración inválida: stride {s} no divide exactamente la dimensión resultante.")
    return int(n)

def count_cnn_params(d_in, f, k):
    """
    Cuenta parámetros en una capa convolucional.
    d_in: Profundidad/canales de entrada
    f: Tamaño del filtro (ancho/alto)
    k: Número de filtros
    """
    weights = d_in * (f ** 2)
    bias = 1
    total_per_filter = weights + bias
    return k * total_per_filter
```

## 10. Casos de uso y aplicaciones
- **Clasificación de imágenes (ImageNet):** Procesamiento de imágenes 224x224x3 para clasificación en 1000 clases. Arquitectura tipo VGG (Ejemplo 13.11) con bloques Conv-Pool sucesivos que duplican filtros al reducir dimensionalidad espacial (64 -> 128 -> 256 ...).
- **Detección de características simples:** Filtros 3x3 entrenados para detectar bordes verticales, diagonales o esquinas (Ejercicio 13.4.4).
- **Procesamiento de secuencias (RNN):** Modelado de lenguaje donde la salida depende del prefijo de la sentencia (ej. predicción de la siguiente palabra).

## 11. Limitaciones, riesgos y precauciones
- **Consumo de memoria en Vectorización:** La matriz intermedia $Y$ en la implementación matricial es aproximadamente $f^2$ veces más grande que la entrada original, lo que puede saturar memoria VRAM en GPUs.
- **Pérdida de información en Pooling:** Valores altos de $f$ en pooling (ej. >3) provocan pérdida excesiva de información espacial.
- **Invarianza limitada:** El pooling proporciona invarianza traslacional limitada; no garantiza invarianza a rotaciones o escalas grandes sin técnicas adicionales (Data Augmentation).
- **Configuración Inválida:** Strides mal configurados pueden impedir la construcción de la capa.

## 12. Relaciones con otros temas del corpus
- **Backpropagation (Sección 13.3):** El entrenamiento de CNNs requiere backpropagation. El gradiente de la convolución es también una convolución (o correlación cruzada).
- **Fully Connected Layers:** Las CNNs eventualmente usan capas totalmente conectadas al final de la arquitectura para la clasificación final.
- **RNNs vs CNNs:** Mientras las CNNs explotan localidad espacial, las RNNs explotan localidad temporal/secuencial.
- **MinHash / LSH:** Al igual que en otros capítulos, la reducción de dimensionalidad es clave, aquí lograda mediante Pooling y Stride.

## 13. Preguntas que la skill debería poder responder
1. ¿Por qué las redes totalmente conectadas son ineficientes para procesar imágenes de alta resolución?
2. ¿Cómo afectan el stride y el padding al tamaño de salida de una capa convolucional?
3. ¿Cuál es la diferencia matemática entre la operación de convolución y la correlación cruzada en el contexto de CNNs?
4. ¿Cómo se implementa eficientemente una convolución utilizando operaciones de álgebra lineal estándar?
5. ¿Cuál es el propósito principal de una capa de Max Pooling y qué propiedad de las imágenes aprovecha?
6. ¿Cuántos parámetros tendría una capa convolucional con 64 filtros de 5x5 sobre una imagen RGB?
7. ¿Qué reglas heurísticas se deben seguir al diseñar una arquitectura CNN profunda?
8. ¿Cómo se relaciona el tamaño del filtro con el campo receptivo en capas profundas?

## 14. Acciones que la skill debería poder recomendar o ejecutar
- Calcular la dimensión exacta de los tensores de activación en cada etapa de una arquitectura CNN dada.
- Determinar si una configuración de hiperparámetros (stride, padding, kernel) es válida.
- Estimar el uso de memoria para la implementación matricial de una convolución.
- Sugerir valores de padding para mantener la resolución espacial ("same convolution").
- Diseñar un bloque convolucional básico (Conv -> ReLU -> Pool).

## 15. Activos finales de conocimiento en formato compacto

| Concepto | Descripción | Referencia |
| :--- | :--- | :--- |
| **Fórmula Salida CNN** | $n = \frac{m - f + 2p}{s} + 1$ | Eq. 13.3 |
| **Parámetros CNN** | $k(df^2 + 1)$ (filtros $\times$ (canales $\times$ área + bias)) | Sec. 13.4.1 |
| **Vectorización** | Convertir convolución a multiplicación matricial $Y^T g + b$ | Sec. 13.4.5 |
| **Max Pooling** | Reduce tamaño espacial, preserva canales, aporta invarianza traslacional. | Sec. 13.4.3 |
| **Zero Padding** | Añade filas/columnas de ceros para controlar tamaño de salida. | Sec. 13.4.1 |
| **Stride** | Paso de desplazamiento del filtro; $s > 1$ reduce dimensionalidad. | Sec. 13.4.1 |
| **RNN** | Procesa secuencias compartiendo pesos y manteniendo estado/memoria. | Sec. 13.5 |
| **Heurística CNN** | Preferir redes profundas con filtros pequeños (3x3, 5x5). | Sec. 13.4.4 |


