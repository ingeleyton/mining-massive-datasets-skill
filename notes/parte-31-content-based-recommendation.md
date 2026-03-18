# Parte 31 - Content-Based Recommendation

## 1. Metadatos del documento
- **Libro:** Mining of Massive Datasets, 3ª ed.
- **Fragmento/Parte:** Parte 31 - Content-Based Recommendation
- **Temas principales:** Sistemas de recomendación basados en contenido, Perfiles de ítems y usuarios, TF.IDF, Similitud del coseno, Árboles de decisión, Filtrado colaborativo.
- **Tipo de contenido:** Mixto (Teoría / Algoritmo / Implementación)

## 2. Resumen técnico de alto valor
El fragmento detalla la arquitectura de los sistemas de recomendación **basados en contenido**, donde la similitud entre ítems se define por sus propiedades intrínsecas, no por las interacciones de los usuarios. Se introduce la construcción de **perfiles de ítems** mediante vectores de características, diferenciando entre atributos discretos (booleanos, ej. actores) y numéricos (ej. tamaño de pantalla, rating promedio). Para documentos de texto, se establece el uso de **TF.IDF** para extraer palabras características, eliminando stop words y midiendo similitud mediante distancia Jaccard o Coseno.

La construcción del **perfil de usuario** se define como una agregación ponderada de los perfiles de los ítems con los que interactuó. Una técnica crítica mencionada es la **normalización de la matriz de utilidad** restando el rating promedio del usuario, permitiendo identificar preferencias positivas y negativas (pesos positivos vs. negativos en el vector resultante). Finalmente, se presenta la alternativa de usar **árboles de decisión** como clasificadores binarios por usuario y se introduce conceptualmente el **Filtrado Colaborativo**, que shifta el foco de las propiedades del ítem a la similitud entre las columnas/filas de la matriz de utilidad.

## 3. Conceptos y definiciones clave
- **Sistema basado en contenido (Content-Based):** Arquitectura donde la recomendación se basa en la similitud entre las propiedades de los ítems y las preferencias del usuario derivadas de ítems previos.
- **Perfil de Ítem (Item Profile):** Registro o vector de características que representa propiedades importantes del ítem (ej. actores en películas, TF.IDF en documentos).
- **Perfil de Usuario (User Profile):** Vector que resume las preferencias del usuario, construido mediante la agregación (promedio o ponderación) de los perfiles de los ítems que el usuario ha calificado o consumido.
- **Matriz de Utilidad (Utility Matrix):** Estructura que relaciona usuarios con ítems; las entradas pueden ser binarias (compra/vista) o numéricas (ratings).
- **TF.IDF (Term Frequency - Inverse Document Frequency):** Métrica utilizada para identificar palabras representativas en un documento, filtrando stop words y destacando términos con alta frecuencia local y baja frecuencia global.
- **Distancia Coseno (Cosine Distance):** Medida de similitud entre vectores definida como $1 - \cos(\theta)$, donde $\cos(\theta)$ es el producto punto normalizado por las longitudes de los vectores. Fundamental para comparar perfiles de usuarios e ítems.
- **Filtrado Colaborativo (Collaborative Filtering):** Enfoque alternativo donde la similitud de ítems se basa en las calificaciones de usuarios que calificaron ambos ítems, ignorando las propiedades intrínsecas del ítem.

## 4. Principios, reglas y heurísticas
- **Construcción de perfiles de documentos:** Eliminar stop words primero; luego, calcular TF.IDF. Seleccionar los $n$ términos con mayor puntaje o aquellos sobre un umbral fijo.
- **Similitud léxica vs. temática:** Para recomendación de documentos, la similitud temática (palabras clave compartidas) es preferible sobre la similitud léxica exacta (secuencia de caracteres/shingling).
- **Escalado de características numéricas:** En vectores mixtos (booleanos y numéricos), los componentes numéricos deben escalarse cuidadosamente (factor $\alpha$) para que no dominen el cálculo de la distancia coseno ni resulten irrelevantes.
- **Normalización de ratings:** Al construir perfiles de usuario con ratings no booleanos, restar el rating promedio del usuario a cada calificación. Esto genera componentes positivos para gustos y negativos para disgustos.
- **Interpretación del ángulo Coseno:**
    - Ángulo cercano a 0° (Coseno $\approx 1$): Fuerte preferencia positiva.
    - Ángulo cercano a 90° (Coseno $\approx 0$): Indiferencia o mezcla equilibrada de gustos/disgustos.
    - Ángulo cercano a 180° (Coseno $\approx -1$): Fuerte rechazo.
- **Árboles de decisión:** Detener la construcción de una rama si el grupo de ítems es homogéneo (todos positivos o negativos) o si el grupo es demasiado pequeño para tener significancia estadística.

## 5. Procedimientos, métodos y workflows

### 5.1 Construcción de Perfil de Usuario (Matriz de Utilidad No Booleana)
**Precondiciones:** Perfiles de ítems definidos, matriz de utilidad con ratings numéricos.
1. Calcular el rating promedio del usuario $U$.
2. Para cada ítem $I$ calificado por $U$, obtener su vector perfil $V_I$.
3. Ponderar $V_I$ restando el promedio del usuario al rating dado al ítem: $w = (rating_I - promedio_U)$.
4. Construir el vector de usuario $V_U$ promediando los vectores ponderados de todos los ítems calificados.
**Postcondición:** $V_U$ contiene valores positivos para características de ítems gustados y negativos para los no gustados.

### 5.2 Recomendación mediante Distancia Coseno y LSH
**Precondiciones:** Perfiles de ítems y usuario en el mismo espacio vectorial.
1. Calcular la distancia coseno entre el vector del usuario y los vectores de los ítems candidatos.
2. Para optimización en grandes escalas: Usar **Random Hyperplanes** (para distancia coseno) y **LSH** (Locality Sensitive Hashing) para agrupar ítems en buckets.
3. Buscar ítems en los buckets cercanos al vector del usuario.
4. Ordenar por similitud y recomendar los de menor distancia (ángulo más pequeño).

## 6. Problemas comunes y soluciones
- **Problema:** Extracción de características en imágenes (los pixeles no representan semántica).
    - **Solución:** Uso de **Tags** manuales de usuarios o juegos colaborativos (ej. GWAP - Games With A Purpose) para etiquetar contenido.
- **Problema:** Dominancia de características numéricas en distancia coseno.
    - **Solución:** Aplicar factores de escala ($\alpha$) a componentes numéricos. Un método justo es hacer la escala inversamente proporcional al valor promedio de esa característica.
- **Problema:** Sesgo en perfiles de usuario debido a ratings siempre altos o bajos.
    - **Solución:** Normalización restando la media del usuario (centrado de datos).
- **Problema:** Construcción costosa de árboles de decisión por usuario.
    - **Solución:** Limitar uso a problemas pequeños o usar técnicas de ensamble (overfitted trees) para mejorar eficiencia y robustez, aunque el texto advierte que sigue siendo costoso.

## 7. Implementación técnica y generación de código

```pseudocode
# Algoritmo: Construcción de Perfil de Usuario (Basado en Sección 9.2.5)
Entrada: Matriz de Utilidad M, Perfiles de Items P
Salida: Vector Perfil de Usuario U

Para cada usuario u en M:
    promedio_u = Media de ratings de u
    vector_suma = vector_cero(dimension_perfil)
    count = 0
    
    Para cada item i calificado por u:
        rating_normalizado = M[u][i] - promedio_u
        vector_suma = vector_suma + (P[i] * rating_normalizado)
        count += 1
    
    Si count > 0:
        U[u] = vector_suma / count
    Sino:
        U[u] = vector_cero
```

```python
# Implementación Python: Cálculo de Similitud Coseno con Escalado (Ejemplo 9.2)
import numpy as np

def cosine_similarity_scaled(vec_a, vec_b, scale_factors=None):
    """
    Calcula la similitud coseno entre dos vectores mixtos (booleanos/numéricos).
    scale_factors: lista o array con factores de escala para cada componente.
    """
    v_a = np.array(vec_a, dtype=float)
    v_b = np.array(vec_b, dtype=float)
    
    if scale_factors:
        # Aplicar escalado a componentes numéricas (asumiendo que el último elemento es numérico)
        # En un caso real, se aplicaría según el índice de la característica
        s = np.array(scale_factors)
        v_a = v_a * s
        v_b = v_b * s
        
    dot_product = np.dot(v_a, v_b)
    norm_a = np.linalg.norm(v_a)
    norm_b = np.linalg.norm(v_b)
    
    if norm_a == 0 or norm_b == 0:
        return 0.0
    
    return dot_product / (norm_a * norm_b)

# Ejemplo del libro: Películas con actores (Booleano) y Rating Promedio (Numérico)
# Actores: [A1, A2, A3, A4, A5, A6, A7, A8], Feature: Rating
movie_1 = [0, 1, 1, 0, 1, 1, 0, 1, 3] # 5 actores, rating 3
movie_2 = [1, 1, 0, 1, 0, 1, 1, 0, 4] # 5 actores, rating 4

# Caso alfa = 1 (sin escalado extra más allá del valor real)
sim_alfa1 = cosine_similarity_scaled(movie_1, movie_2, [1,1,1,1,1,1,1,1,1])
# Caso alfa = 2 (duplicar importancia del rating)
sim_alfa2 = cosine_similarity_scaled(movie_1, movie_2, [1,1,1,1,1,1,1,1,2])

print(f"Similitud (alfa=1): {sim_alfa1:.4f}") # Esperado aprox 0.816
print(f"Similitud (alfa=2): {sim_alfa2:.4f}") # Esperado aprox 0.940
```

## 8. Funciones, métodos, librerías o comandos identificados
- **TF.IDF**: Técnica de ponderación de términos para perfiles de texto.
- **Jaccard Distance**: Métrica para conjuntos de palabras (tamaño de la intersección / tamaño de la unión).
- **Cosine Distance**: Métrica principal para comparar vectores de perfiles.
- **Random Hyperplanes**: Técnica para generar firmas hash para distancia coseno (referencia al Cap. 3).
- **LSH (Locality Sensitive Hashing)**: Estructura para búsqueda eficiente de vecinos cercanos.
- **Decision Tree**: Clasificador no lineal para predecir "like/dislike".

## 9. Snippets o plantillas reutilizables

```python
# Plantilla: Generador de Perfil de Usuario Normalizado
import numpy as np
from collections import defaultdict

def build_user_profile(user_ratings, item_profiles):
    """
    user_ratings: dict {item_id: rating}
    item_profiles: dict {item_id: numpy_array}
    """
    if not user_ratings:
        return None
    
    # 1. Calcular promedio
    avg_rating = np.mean(list(user_ratings.values()))
    
    # 2. Inicializar vector perfil
    profile_dim = next(iter(item_profiles.values())).shape[0]
    user_profile = np.zeros(profile_dim)
    
    # 3. Agregar perfiles ponderados
    for item_id, rating in user_ratings.items():
        if item_id in item_profiles:
            weight = rating - avg_rating
            user_profile += item_profiles[item_id] * weight
            
    # 4. Normalizar (opcional pero recomendado para cosine similarity)
    norm = np.linalg.norm(user_profile)
    if norm > 0:
        user_profile = user_profile / norm
        
    return user_profile
```

## 10. Casos de uso y aplicaciones
- **Recomendación de Películas:** Uso de actores, directores, año y género como características. Cálculo de similitud entre el historial del usuario y el catálogo.
- **Sistemas de Noticias/Blogs:** Clasificación de documentos mediante TF.IDF para sugerir artículos sobre temas de interés (ej. "béisbol" pero no "Yankees").
- **Etiquetado de Imágenes (Tags):** Sistemas como `del.icio.us` o juegos de etiquetado (GWAP) para generar características semánticas donde el análisis visual falla.
- **Productos de Hardware (PCs):** Comparación de especificaciones técnicas (velocidad procesador, disco, RAM) usando distancia coseno con escalado para equilibrar magnitudes.

## 11. Limitaciones, riesgos y precauciones
- **Subjetividad del Género:** El texto menciona que el género es un concepto vago y a menudo requiere asignación manual o heurística (IMDB).
- **Escalado Arbitrario:** La elección del factor de escala $\alpha$ para características numéricas es crítica y no hay una respuesta "correcta" única; afecta drásticamente los resultados.
- **Costo Computacional (Árboles de Decisión):** Construir un árbol por usuario es prohibitivo para grandes volúmenes de datos debido a la complejidad de evaluar predicados complejos.
- **Dependencia de Tags:** La calidad de los sistemas basados en tags depende de la voluntad de los usuarios a etiquetar; datos escasos o erróneos degradan el sistema.
- **Sobreajuste (Overfitting):** En árboles de decisión profundos, se corre el riesgo de crear nodos con poca significancia estadística.

## 12. Relaciones con otros temas del corpus
- **MinHashing y LSH (Cap. 3):** El texto referencia explícitamente el uso de MinHash para distancia Jaccard y Random Hyperplanes para distancia Coseno como métodos eficientes para encontrar ítems candidatos en grandes datasets.
- **Modelo de Espacio Vectorial (Cap. 1):** El uso de TF.IDF y vectores de documentos conecta con los fundamentos de recuperación de información.
- **Filtrado Colaborativo (Sección 9.3):** Se presenta como la evolución o alternativa al enfoque basado en contenido, utilizando la matriz de utilidad directamente en lugar de perfiles de contenido.

## 13. Preguntas que la skill debería poder responder
1. ¿Cómo se construye un perfil de usuario en un sistema basado en contenido si la matriz de utilidad contiene ratings numéricos (1-5)?
2. ¿Por qué es necesario eliminar las "stop words" antes de calcular el perfil de un documento?
3. ¿Cuál es la diferencia fundamental entre la similitud léxica (shingling) y la similitud temática (TF.IDF) en el contexto de recomendación de documentos?
4. ¿Cómo afecta el factor de escala $\alpha$ en el cálculo de la distancia coseno para características numéricas?
5. ¿Qué técnica se puede utilizar para acelerar la búsqueda de ítems similares en sistemas de recomendación basados en contenido a gran escala?
6. ¿Cuáles son las limitaciones de usar árboles de decisión para sistemas de recomendación personalizados?
7. ¿Cómo se representa un ítem que tiene tanto características booleanas (ej. género) como numéricas (ej. precio) en un vector de perfil?
8. ¿Qué significa un ángulo de 90 grados entre el vector de un usuario y el vector de un ítem en términos de preferencia?

## 14. Acciones que la skill debería poder recomendar o ejecutar
- **Preprocesamiento:** Aplicar eliminación de stop words y cálculo de TF.IDF a un corpus de documentos para generar perfiles de ítems.
- **Ingeniería de Features:** Sugerir la conversión de características categóricas (actores, directores) a representación vectorial booleana (one-hot encoding implícito).
- **Normalización:** Implementar la resta de la media del usuario en la matriz de utilidad antes de generar perfiles.
- **Selección de Métrica:** Recomendar distancia Coseno sobre Jaccard cuando los vectores contienen componentes numéricos o pesos de importancia.
- **Optimización:** Sugerir el uso de LSH si el número de ítems a comparar impide un cálculo exhaustivo de similitudes.

## 15. Activos finales de conocimiento en formato compacto
| Concepto | Descripción | Referencia |
| :--- | :--- | :--- |
| **Item Profile** | Vector de características (booleanas/numéricas) que define propiedades intrínsecas del ítem. | Sec 9.2.1 |
| **User Profile** | Vector resultante de promediar perfiles de ítems consumidos, ponderados por desviación del rating medio. | Sec 9.2.5 |
| **TF.IDF** | Puntaje para identificar palabras clave en documentos; filtra stop words y destaca términos raros/frecuentes. | Sec 9.2.2 |
| **Cosine Scaling** | Necesidad de escalar features numéricas ($\alpha$) para evitar dominancia en el cálculo de similitud angular. | Sec 9.2.4 |
| **Utility Matrix** | Estructura base; entrada $M_{ij}$ representa la interacción (compra/rating) del usuario $i$ con el ítem $j$. | Sec 9.2.5 |
| **Decision Trees** | Alternativa de ML para recomendación; construye un clasificador binario por usuario basado en features. | Sec 9.2.7 |
| **Collaborative Filtering** | Enfoque que ignora contenido y usa similitud entre columnas/filas de la matriz de utilidad. | Sec 9.3 |
| **Random Hyperplanes** | Técnica de hashing para aproximar distancia coseno en espacios de alta dimensión (vía LSH). | Sec 9.2.6 |
| **Tagging** | Método para obtener features semánticas en datos no estructurados (imágenes) mediante intervención humana. | Sec 9.2.3 |
| **Normalized Rating** | $r' = r - \text{mean}_u$; convierte ratings absolutos en indicadores de gusto/disgusto relativos. | Sec 9.2.5 |


