# Parte 47 - Perceptron, Winnow, and SVM Intro

## 1. Metadatos del documento
- **Libro:** Mining of Massive Datasets, 3ª ed.
- **Fragmento/Parte:** Parte 47 - Perceptron, Winnow, and SVM Intro
- **Temas principales:** Perceptrón, Algoritmo Winnow, Separabilidad lineal, Entrenamiento paralelo (MapReduce), Clasificación multiclase, Support-Vector Machines (SVM).
- **Tipo de contenido:** Mixto (Teoría / Algoritmo / Implementación)

## 2. Resumen técnico de alto valor
El fragmento detalla el **Perceptrón** como un clasificador binario lineal fundamental, definiendo su mecánica operativa basada en vectores de peso $w$, umbral $\theta$ y la separación del espacio de características mediante un hiperplano. Se profundiza en el algoritmo de entrenamiento iterativo para el caso de umbral cero y la técnica de augmentación de dimensiones para umbrales variables. Se presenta el **Algoritmo Winnow** como una variante de actualización multiplicativa (opuesta a la aditiva del perceptrón estándar) para características binarias, garantizando pesos positivos.

Críticamente, se abordan las **limitaciones de convergencia**: el perceptrón solo converge si los datos son linealmente separables; en caso contrario, entra en bucle o requiere estrategias de terminación temprana (decaimiento de tasa de aprendizaje, conjuntos de prueba). Se identifican problemas de generalización (múltiples hiperplanos separadores posibles, sobreajuste) que motivan la introducción de las **Support-Vector Machines (SVM)**, las cuales optimizan el margen de separación. Finalmente, se detalla una **implementación paralela mediante MapReduce** para escalabilidad, transformando el proceso inherentemente secuencial en uno de procesamiento por lotes (batch) para acumular actualizaciones de pesos.

## 3. Conceptos y definiciones clave
- **Perceptrón:** Clasificador binario lineal. Define un hiperplano de decisión $w \cdot x = \theta$. Clasifica como +1 si $w \cdot x > \theta$ y -1 si $w \cdot x < \theta$.
- **Separabilidad Lineal:** Propiedad de un conjunto de datos donde existe al menos un hiperplano que separa perfectamente todos los puntos positivos de los negativos. Condición necesaria para la convergencia del perceptrón estándar.
- **Hiperplano:** Subespacio de dimensión $d-1$ que divide el espacio de características en dos semi-espacios (positivo y negativo).
- **Tasa de aprendizaje ($\eta$):** Parámetro escalar pequeño que modula el tamaño del ajuste de los pesos en cada paso de entrenamiento. Valores altos causan oscilación; valores bajos, convergencia lenta.
- **Algoritmo Winnow:** Variante del perceptrón para características binarias (0/1) que actualiza pesos mediante multiplicación (por 2 o 1/2) en lugar de suma. Produce pesos siempre positivos.
- **Margen (Margin):** Distancia entre el hiperplano separador y los puntos más cercanos del conjunto de entrenamiento. Concepto central en SVMs para elegir el "mejor" hiperplano.
- **Vector de peso disperso (Sparse weight vector):** En problemas como detección de spam, el vector de características tiene muchas dimensiones pero pocos valores no nulos. Se recomienda almacenar solo índices no nulos para eficiencia.

## 4. Principios, reglas y heurísticas
- **Regla de actualización del Perceptrón:** Si $y'(w \cdot x)$ y $y$ tienen signos distintos (o $y' = 0$), actualizar $w := w + \eta y x$. No hacer nada si la clasificación es correcta.
- **Regla de actualización de Winnow:**
    - Si $w \cdot x \le \theta$ y $y=+1$: Multiplicar pesos por 2 donde $x_i=1$.
    - Si $w \cdot x \ge \theta$ y $y=-1$: Dividir pesos entre 2 donde $x_i=1$.
- **Umbral variable (Truco de augmentación):** Para aprender $\theta$, añadir una dimensión extra al vector de características con valor -1. El peso aprendido para esta dimensión actúa como el umbral $\theta$.
- **Estrategias de terminación:** Si no hay convergencia clara:
    1. Fijar número máximo de rondas.
    2. Detener si el número de errores deja de cambiar.
    3. Usar un conjunto de prueba (test set) y detener cuando el error en prueba se estabilice.
- **Decaimiento de la tasa de aprendizaje:** Para mejorar convergencia en datos no linealmente separables o ruidosos, reducir $\eta$ en función del tiempo $t$: $\eta_t = \frac{\eta_0}{1 + ct}$.
- **Paralelización:** En entrenamiento masivo, usar procesamiento por lotes (batch). Acumular cambios de pesos de múltiples ejemplos en paralelo antes de actualizar el vector $w$ central.

## 5. Procedimientos, métodos y workflows

### Entrenamiento de Perceptrón (Umbral $\theta = 0$)
1.  **Inicialización:** $w \leftarrow [0, \dots, 0]$.
2.  **Selección de parámetro:** Elegir $\eta > 0$ pequeño.
3.  **Iteración:** Para cada ejemplo de entrenamiento $(x, y)$:
    a. Calcular $y' = w \cdot x$.
    b. Si $signo(y') \neq signo(y)$ o $y' = 0$:
       $w \leftarrow w + \eta y x$.
    c. Si está correctamente clasificado, pasar al siguiente.

### Algoritmo Winnow (Umbral $\theta = d$)
1.  **Inicialización:** $w \leftarrow [1, \dots, 1]$, $\theta \leftarrow d$ (número de dimensiones).
2.  **Iteración:** Para cada ejemplo $(x, y)$:
    a. Calcular producto punto $w \cdot x$.
    b. **Caso Falso Negativo** ($w \cdot x \le \theta$ pero $y=+1$): Para todo $i$ donde $x_i=1$, hacer $w_i \leftarrow 2w_i$.
    c. **Caso Falso Positivo** ($w \cdot x \ge \theta$ pero $y=-1$): Para todo $i$ donde $x_i=1$, hacer $w_i \leftarrow w_i / 2$.

### Implementación Paralela (MapReduce)
1.  **Map:** Recibe chunk de entrenamiento y vector $w$ actual. Para cada ejemplo mal clasificado $(x, y)$, emite pares clave-valor $(i, \eta y x_i)$ para cada componente no nulo $x_i$.
2.  **Reduce:** Suma todos los incrementos para cada componente $i$.
3.  **Actualización:** Aplica la suma acumulada al vector $w$ global.
4.  **Repetir:** Lanzar nuevo job si hubo cambios.

## 6. Problemas comunes y soluciones
- **Convergencia en espiral/bucle:** Si los datos no son linealmente separables, el perceptrón estándar repetirá vectores de peso infinitamente.
    *   *Solución:* Limitar rondas, usar test set para validación cruzada durante entrenamiento, o decaer $\eta$.
- **Sobreajuste (Overfitting):** Transformar datos a dimensiones superiores para forzar separabilidad lineal puede crear un clasificador perfecto en entrenamiento pero inútil en producción.
    *   *Solución:* Prudencia al elegir transformaciones; preferir SVM con regularización (implícito en sección 12.3).
- **Sesgo del hiperplano:** El perceptrón se detiene en el primer hiperplano que encuentra, que puede estar muy cerca de una clase (margen pequeño), causando errores en nuevos datos.
    *   *Solución:* Usar SVMs para maximizar el margen.
- **Vectores de alta dimensión dispersos:** Construir vectores completos de 0s y 1s para texto es ineficiente.
    *   *Solución:* Usar representación dispersa (lista de índices donde $x_i=1$). Solo el vector $w$ necesita representación completa.

## 7. Implementación técnica y generación de código

```pseudocode
# Algoritmo Perceptrón Estándar (Sección 12.2.1)
Entrada: Conjunto entrenamiento T, tasa aprendizaje eta
Salida: Vector peso w

w = [0, ..., 0] # Dimensión d
repetir:
    para cada (x, y) en T:
        y_prediccion = producto_punto(w, x)
        si (y_prediccion <= 0 y y == +1) o (y_prediccion >= 0 y y == -1):
            w = w + eta * y * x
hasta convergencia
retornar w
```

```python
# Implementación Python: Perceptrón con Umbral Variable (Truco de augmentación)
import numpy as np

class Perceptron:
    def __init__(self, dims, eta=0.1):
        self.eta = eta
        # Incluimos dimensión extra para el umbral (bias)
        self.w = np.zeros(dims + 1) 

    def predict(self, x):
        # Augmentar x con -1 para el umbral
        x_aug = np.append(x, -1)
        return 1 if np.dot(self.w, x_aug) > 0 else -1

    def train(self, X, Y, epochs=100):
        for _ in range(epochs):
            errors = 0
            for x, y in zip(X, Y):
                x_aug = np.append(x, -1)
                y_pred = np.dot(self.w, x_aug)
                
                # Verificar clasificación incorrecta (signos opuestos o cero)
                if y_pred * y <= 0:
                    self.w += self.eta * y * x_aug
                    errors += 1
            if errors == 0:
                break
        return self.w

# Ejemplo de uso basado en el libro (Spam)
# Features: [and, viagra, the, of, nigeria]
X_train = np.array([
    [1,1,0,1,1], [0,0,1,1,0], [0,1,1,0,0], 
    [1,0,0,1,0], [1,0,1,0,1], [1,0,1,1,0]
])
Y_train = np.array([1, -1, 1, -1, 1, -1]) # +1 spam, -1 no spam

p = Perceptron(dims=5, eta=0.5)
weights = p.train(X_train, Y_train)
print(f"Pesos finales (incluye bias): {weights}")
```

## 8. Funciones, métodos, librerías o comandos identificados
- **Producto punto ($w \cdot x$):** Operación central para calcular la puntuación de clasificación.
- **MapReduce:** Modelo de programación para entrenamiento paralelo.
- **Representación dispersa (Sparse representation):** Técnica de optimización de memoria para vectores de características de texto.
- **TF.IDF:** Mencionado como técnica para filtrar palabras y reducir dimensionalidad/dispersión antes de entrenar.

## 9. Snippets o plantillas reutilizables

```python
# Snippet: Transformación de coordenadas para separabilidad lineal
# Basado en Ejemplo 12.7 (Coordenadas polares)
def transform_to_polar(x):
    # x es [lat, lon] o similar [x1, x2]
    r = np.sqrt(x[0]**2 + x[1]**2)
    theta = np.arctan2(x[1], x[0])
    return np.array([r, theta]) # O simplemente [r] si el ángulo es irrelevante
```

## 10. Casos de uso y aplicaciones
- **Detección de Spam:** Clasificación de emails basada en presencia/ausencia de palabras clave (ej. "viagra", "nigeria"). Se menciona la importancia de eliminar "stop words" o usar TF.IDF para reducir ruido.
- **Clasificación de Tópicos Web:** Uso de perceptrones multiclase para categorizar páginas (deportes, política, etc.) basándose en palabras indicativas.
- **Análisis de Sentimiento:** Uso de ratings (estrellas) como entrenamiento para deducir sentimiento en textos sin rating (tweets).
- **Datos de Streaming:** Adaptación del perceptrón para flujos continuos de datos (ej. spam en tiempo real), donde el modelo evoluciona con el tiempo.

## 11. Limitaciones, riesgos y precauciones
- **Incapacidad para datos no linealmente separables:** El perceptrón básico falla si no existe un hiperplano separador puro.
- **Sensibilidad a la escala:** Aunque no se menciona explícitamente la normalización, el producto punto es sensible a la magnitud de los vectores.
- **Elección del Hiperplano:** El perceptrón puede encontrar un separador arbitrario que no generalice bien (margen pequeño). Se recomienda SVM para mitigar esto.
- **Paralelización aproximada:** La versión paralela (batch) es una aproximación de la versión secuencial; si $\eta$ no es pequeña, los resultados pueden diferir significativamente.

## 12. Relaciones con otros temas del corpus
- **Support-Vector Machines (SVM):** Evolución directa del perceptrón para resolver el problema del margen máximo y datos no separables (Sección 12.3).
- **MinHash / LSH:** Técnicas relacionadas para manejo de datos masivos y similitud de conjuntos, a menudo usadas en pre-procesamiento de características de texto.
- **Streaming Data (Sección 4.7):** El perceptrón es un algoritmo natural para entornos de streaming; se conecta con técnicas de "decaying windows".
- **TF.IDF:** Herramienta para la selección de características previa al entrenamiento del perceptrón.

## 13. Preguntas que la skill debería poder responder
1. ¿Qué condiciones debe cumplir un conjunto de datos para que un perceptrón estándar converja?
2. ¿Cómo se implementa un umbral variable ($\theta$) en un perceptrón sin modificar el algoritmo base?
3. ¿Cuál es la diferencia fundamental entre la regla de actualización del Perceptrón estándar y el algoritmo Winnow?
4. ¿Qué estrategias se recomiendan para detener el entrenamiento si el perceptrón no converge?
5. ¿Cómo se adapta el entrenamiento de un perceptrón a un entorno de procesamiento paralelo MapReduce?
6. ¿Por qué el perceptrón puede ser un mal clasificador incluso si encuentra un hiperplano separador?
7. ¿Cómo se utiliza el perceptrón para clasificación multiclase?
8. ¿Qué es el sobreajuste (overfitting) en el contexto de transformaciones de características para perceptrones?

## 14. Acciones que la skill debería poder recomendar o ejecutar
- **Seleccionar algoritmo:** Recomendar Winnow sobre Perceptrón estándar si las características son binarias y se desea mantener pesos positivos.
- **Pre-procesamiento:** Aplicar representación dispersa y filtrado TF.IDF antes de entrenar clasificadores de texto masivos.
- **Configuración de entrenamiento:** Ajustar la tasa de aprendizaje $\eta$ con decaimiento temporal si se detecta inestabilidad o falta de convergencia.
- **Escalabilidad:** Proponer arquitectura MapReduce para entrenamiento en datasets que no caben en memoria o requieren procesamiento distribuido.
- **Diagnóstico:** Si el modelo clasifica bien entrenamiento pero falla en test, sugerir evaluar SVM o revisar el margen de separación.

## 15. Activos finales de conocimiento en formato compacto

| Concepto | Descripción | Referencia |
|---|---|---|
| **Perceptrón** | Clasificador lineal binario definido por $w \cdot x = \theta$. | Sec 12.2 |
| **Separabilidad** | Requisito para convergencia del perceptrón; debe existir hiperplano separador. | Sec 12.2.1 |
| **Winnow** | Algoritmo de actualización multiplicativa ($ \times 2, /2$) para features binarias. | Sec 12.2.3 |
| **Umbral Variable** | Truco: añadir dimensión $x_{d+1} = -1$ para aprender $\theta$ como peso $w_{d+1}$. | Sec 12.2.4 |
| **Margen** | Distancia del hiperplano a los puntos más cercanos; objetivo a maximizar en SVM. | Sec 12.3 |
| **Paralelización** | MapReduce: Map calcula incrementos, Reduce suma y actualiza $w$ (batch training). | Sec 12.2.8 |
| **Tasa $\eta$** | Controla paso de ajuste. Pequeña = lento; Grande = oscilación. Decaimiento recomendado. | Sec 12.2.1/2 |
| **Multiclase** | Entrenar $k$ perceptrones (uno por clase), clasificar según máximo $w_i \cdot x$. | Sec 12.2.5 |
| **Transformación** | Mapear datos a espacio dimensional superior para lograr separabilidad lineal. | Sec 12.2.6 |
| **Streaming** | Perceptrón adaptable a flujos de datos infinitos; el modelo evoluciona con cada ejemplo. | Sec 12.2.8 |


