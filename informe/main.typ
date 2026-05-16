#set page(
  paper: "a4",
  margin: (x: 2cm, y: 1.5cm),
  numbering: "1",
  header: context {
    if counter(page).get().first() > 1 [
      _Franco Berni_
      #h(1fr)
      TP2: Perceptrón Simple y Multicapa
    ]
  }
)
#set text(
  font: "New Computer Modern",
  size: 10pt,
  lang: "es",
  region: "AR",
)
#set par(
  justify: true,
)

#show heading: smallcaps
#show heading: set text(weight: "regular")
#set heading(numbering: "1.")
#set math.equation(numbering: "(1)")
#set figure(numbering: "1")

#show ref: it => {
  let eq = math.equation
  let el = it.element
  if el == none or el.func() != eq { return it }
  link(el.location(), numbering(
    el.numbering,
    ..counter(eq).at(el.location())
  ))
}

#set document(title: [Trabajo Práctico 2:\ Perceptrón Simple y Multicapa])

#show title: smallcaps
#show title: set text(size: 17pt)

#align(center)[
  #image("img/fiuba.png", width: 60%)

  #title()

  Franco Berni \
  #link("mailto:fberni@fi.uba.ar") \
  110007
]

#v(2em)
#align(center)[#smallcaps[Resumen]]
#text(style: "italic")[]

#let sgn = math.op("sgn")
#let erf = math.op("erf")

= Introducción

= Desarrollo

== Implementación de funciones lógicas con un perceptrón simple

En primer lugar se implementó un perceptrón simple con salidas booleanas ($plus.minus 1$), con el objetivo de entrenarlo sobre funciones lógicas. En particular, se estudió el desempeño del perceptrón sobre las funciones AND y OR, de las cuales se tiene garantía de hallar una solución puesto que son linealmente separables. Como función de activación se utilizó la función signo dada por
$ sgn(x) = cases( +1 "si" x gt.eq 0, -1 "si" x lt 0) space . $
Por simplicidad, se tomó la entrada $-1$ como correspondiente al cero lógico. Las tablas de verdad de las funciones lógicas de dos entradas $X_1$ y $X_2$, utilizando esta convención, se muestran en la @tab:verdad.

#figure(
  placement:auto,
  table(
    align: left,
    columns: 4,
    stroke: none,
    table.hline(),
    table.header([$X_1$], [$X_2$], [$y_("AND")$], [$y_("OR")$]),
    table.hline(),
    [-1], [-1], [-1], [-1],
    [-1], [+1], [-1], [+1],
    [+1], [-1], [-1], [+1],
    [+1], [+1], [+1], [+1],
    table.hline(),
  ),
  caption: figure.caption(position: top, [Tabla de verdad de las funciones AND y OR de dos entradas.]),
) <tab:verdad>

=== Función AND de dos entradas

Se entrenó primeramente un perceptrón simple con la tabla de verdad de la función AND. El modelo se entrenó con un número máximo de 20 épocas, y agregando un _early exit_ si el error se hacía nulo (en realidad, si era inferior a una tolerancia positiva pequeña). El _learning rate_ se estableció en $0.1$. La evolución del error cuadrático medio de entrenamiento durante la fase de entrenamiento se muestra en la @fig:and2d_boundary. Cada iteración se corresponde con una actualización de los pesos en base a una muestra. Dado que el conjunto de entrenamiento es la tabla de verdad completa ($N_p = 4$), cada cuatro iteraciones finaliza una época. Se observa que el error es inicialmente de 3, y va disminuyendo hasta anularse en la octava iteración ---luego de dos épocas---.

#figure(
  placement: auto,
  image("img/ej1/and2d_mse.svg", width: 67%),
  caption: [Evolución del error durante el entrenamiento de un perceptrón simple para la AND de dos entradas.],
) <fig:and2d_mse>

En la @fig:and2d_boundary se muestra la frontera de decisión dada por la recta discriminadora perpendicular al vector de los pesos resultantes del entrenamiento de la función AND, junto con las entradas al perceptrón coloreadas según la salida aprendida (en rojo las salidas $+1$; en azul, las $-1$). Se puede ver que la red fue capaz de aprender una frontera válida, algo esperable dado que el problema es linealmente separable.

#figure(
  placement: auto,
  image("img/ej1/and_boundary.svg", width: 45%),
  caption: [Recta discriminadora y entradas clasificadas por el perceptrón para la AND de dos entradas.],
) <fig:and2d_boundary>

=== Función OR de dos entradas

Similarmente, se repitió el experimento para un perceptrón simple entrenado sobre la función OR de dos entradas. Se utilizaron los mismo hiperparámetros que para el caso de la AND. El error cuadrático medio de entrenamiento se puede ver en la @fig:or2d_mse. Esta vez, comienza en 1 y se mantiene constante durante la primera época (hasta la iteración 4), hasta que finalmente en la quinta iteración converge a una solución con error nulo. Se entiende que esta vez el perceptrón comenzó con un conjunto de pesos que producía una única salida incorrecta, la cual produjo que se modificaran lentamente los pesos hasta su correcta clasificación.

#figure(
  placement: auto,
  image("img/ej1/or2d_mse.svg", width: 67%),
  caption: [Evolución del error durante el entrenamiento de un perceptrón simple para la OR de dos entradas.],
) <fig:or2d_mse>

En la @fig:or2d_boundary se muestra la frontera de decisión dada por la recta discriminadora perpendicular al vector de los pesos resultantes del entrenamiento de la función OR, junto con las entradas al perceptrón coloreadas según la salida aprendida. Nuevamente, se puede ver que la red fue capaz de aprender una frontera válida.

#figure(
  placement: auto,
  image("img/ej1/or_boundary.svg", width: 45%),
  caption: [Recta discriminadora y entradas clasificadas por el perceptrón para la OR de dos entradas.],
) <fig:or2d_boundary>

Observamos que en este caso (y, en menor medida, en el caso de la AND), la frontera encontrada está muy cerca de una de las muestras. Esto se debe a que no se incluyó ningún tipo de margen en el entrenamiento, por lo que una frontera puede estar extremadamente cerca de clasificar incorrectamente a una muestra y aún así ser considerada solución. En este caso donde las entradas son binarias, no hay ningún problema con este resultado. Si se tratara de datos continuos potencialmente afectado por ruido, una frontera tan cercana a una muestra de entrenamiento podría provocar errores si posteriormente se encuentra con muestras ligeramente perturbadas.

=== Función AND de cuatro entradas

Para analizar el comportamiento del perceptrón simple frente a más entradas, se procedió a estudiar la compuerta AND de cuatro entradas. Como extensión de la AND de dos entradas, la salida de la AND de cuatro entradas será $+1$ únicamente si todas sus cuatro entradas $X_1 = X_2 = X_3 = X_4 = +1$, y $-1$ en cualquier otro caso. El entrenamiento se realizó con los mismos hiperparámetros que para las funciones de dos entradas. En este caso, como hay $N_p = 2^4 = 16$ patrones diferentes, una época consiste de 16 iteraciones.

El error de entrenamiento del perceptrón para la función AND de cuatro entradas se muestra en la @fig:and4d_mse. Inicialmente, el error comienza en $2.5$ y decrece casi monotónicamente hasta anularse en la iteración 30, casi al final de la segunda época. A diferencia de lo observado anteriormente, vemos que el error crece tras la actualización de los pesos en el paso 26. Esto ocurre porque una de las muestras que era correctamente clasificada antes de la actualización pasa a estar clasificada incorrectamente tras la corrección. La misma se encontraba probablemente muy cerca del hiperplano de decisión, propiciando este error. Sin embargo, vemos que este error se corrige posteriormente, y se encuentra una solución válida.

#figure(
  placement: auto,
  image("img/ej1/and4d_mse.svg", width: 67%),
  caption: [Evolución del error durante el entrenamiento de un perceptrón simple para la AND de cuatro entradas.],
) <fig:and4d_mse>

También es interesante notar que el entrenamiento tarda más en cantidad de iteraciones, lo cual es esperable dado que se tienen que aprender más patrones. Si se lo mide en épocas, por el contrario, el entrenamiento es aproximadamente igual de largo, convergiendo en el orden de un par de épocas.

No se muestra un gráfico de la frontera de decisión ya que la misma es un hiperplano 3-dimensional embebido en el espacio 4-dimensional de las entradas, lo que imposibilita su representación. En forma intuitiva, el resultado se espera que sea similar al visto para el caso de dos entradas: un "plano" que separa la única entrada de resultado $+1$ (correspondiente a los $X_j = +1$), de las demás entradas cuya salida es $-1$.

=== Función OR de cuatro entradas

Análogamente, se entrenó un perceptrón simple con la función lógica OR de cuatro entradas.La extensión corresponde a tomar como salida $-1$ únicamente si todas las entradas $X_1 = X_2 = X_3 = X_4 = -1$, y como $+1$ en el resto de los casos. Se utilizaron los mismos hiperparámetros que para la AND.

El error de entrenamiento del perceptrón para la función OR de cuatro entradas se muestra en la @fig:or4d_mse. Inicialmente, el error comienza en $2.75$ y decrece casi monotónicamente hasta anularse en la iteración 20, poco después de comenzada la segunda época. Notamos que nuevamente hay un momento ---luego de la sexta iteración---, donde el error empeora. Sin embargo, posteriormente se corrige y finalmente el perceptrón es capaz de aprender la función con error nulo.

#figure(
  placement: auto,
  image("img/ej1/or4d_mse.svg", width: 67%),
  caption: [Evolución del error durante el entrenamiento de un perceptrón simple para la OR de cuatro entradas.],
) <fig:or4d_mse>

== Capacidad del perceptrón simple

La capacidad del perceptrón simple puede definirse como la máxima cantidad de patrones aleatorios que pueden enseñarse al perceptrón y que el mismo aún sea capaz de encontrar un hiperplano que separe las salidas deseadas $-1$ de las $+1$. Es decir, se busca la máxima cantidad de puntos tales que el problema a entrenar sea linealmente separable. Con gran trabajo, puede demostrarse que para $N arrow infinity$ la cantidad de patrones que pueden aprenderse es
$ N_(p, max) = 2 N, $
o sea, la capacidad relativa del perceptrón es
$ C = N_(p, max) / N = 2. $

Entonces, para $N$ grande, se espera que el perceptrón _siempre_ converja si la cantidad de puntos aleatorios enseñados es menor que $2 N$, y que _nunca_ halle tal solución si es mayor que dicho límite. En la realidad, para valores de $N$ finitos, se observará que la probabilidad de hallar una solución es alta para valores de $N_p$ pequeños, y caerá en forma aproximadamente sigmoide hacia cero, valiendo alrededor de $0.5$ en $N_p = 2 N$. Cuanto más grande sea $N$, más abrupta será la transición.

Para mostrar esto, se entrenó un perceptrón simple de $N=30$ entradas, con una cantidad creciente de patrones entre $N_p = 1$ y $N_p = 3 N$. Los patrones son puntos aleatorios uniformes en el hipercubo $[-1, 1]^N$, y sus salidas deseadas son al azar $plus.minus 1$. Se repitió el experimento 20 veces, notando la cantidad de pruebas en la que el perceptrón convergió a una solución de error nulo, antes de llegar a un número máximo de épocas establecido en 1000. Para cada valor de $N_p$ se obtuvo entonces una estimación de la probabilidad de que el entrenamiento converja. El _learning rate_ se estableció en $0.01$.

Los resultados se muestran en la @fig:capacidad, en función de la cantidad relativa $N_p slash N$ de patrones. Como es de esperar, para cantidades de patrones pequeñas, el aprendizaje logra encontrar una solución en cualquier caso. A medida que crece $N_p$, los patrones se vuelven más "difíciles" de aprender, por lo que hay más ocasiones en las que no converge a una solución. La caída es relativamente abrupta y alrededor de un valor de $N_p slash N = 2$, lo cual es esperable dado el número finito de entradas usado.

#figure(
  placement: auto,
  image("img/ej2/capacidad.svg", width: 67%),
  caption: [Probabilidad de convergencia del aprendizaje en función de la cantidad relativa $N_p slash N$ de patrones enseñados, simulado para $N=30$.],
) <fig:capacidad>

No se calculó la capacidad para valores superiores de $N$ dado que el cómputo tardaba demasiado tiempo.

== Implementación de XOR con un perceptrón multicapa

Para abordar problemas de mayor complejidad que no son linealmente separables, como la función XOR, se implementó un perceptrón multicapa o MLP (por sus siglas en inglés). El MLP implementado realiza la actualización de los pesos por gradiente descendente y _error backpropagation_, modificando los pesos en _batch_. En particular, se usaron _full batches_, lo que significa que se procesa todo el conjunto de datos de entrenamiento completo durante una época, se calcula el gradiente promedio, y se actualizan los pesos al final de la época en función de dicho gradiente promediado.

La función de activación que se utilizó fue la sigmoide definida por
$ g(x) = 1 / (1 + exp(-x)), $
cuya salida tiende a $0$ para entradas muy negativas, pasa por $1 slash 2$ para $x=0$, y tiende a $1$ para entradas muy positivas. Una propiedad interesante y útil de esta función es que su derivada es
$ g'(x) = g(x) (1 - g(x)). $
Esto simplifica los cálculos de _backpropagation_.

Notar que debido a que $g : RR arrow (0, 1)$, las variables booleanas se tomaron como $1$ para el valor verdadero, y $0$ para el falso. Esto es en contraste con la convención tomada en las secciones anteriores.

La función de error o _loss_ utilizada es
$ E = 1/2 sum_i (hat(y)_i - y_i)^2, $
donde $hat(y)_i$ es la salida de la red para el $i$-ésimo patrón, mientras que $y_i$ es el resultado esperado.

Los pesos fueron iniciados con valores aleatorios i.i.d. normales estándar.

=== Función XOR de dos entradas

En primer lugar, se entrenó un perceptrón para que aprenda la función XOR de dos entradas. Esta función vale $1$ si alguna entrada, pero no ambas, vale $1$. Si ninguna o ambas son $1$, entonces devuelve $0$. Otra forma de verlo, que servirá para entender la extensión a múltiples entradas, es que devuelve $1$ si la cantidad de entradas en $1$ es impar, y $0$ si es par.

Es sabido que la función XOR no es linealmente separable, y que además requiere de un  MLP con al menos dos neuronas en la capa oculta. El MLP entrenado fue éste, teniendo dos entradas, dos neuronas en su capa oculta, y una única salida. La red se entrenó durante 5000 épocas, utilizando un _learning rate_ de $1.0$.

La evolución de la _loss_ se muestra en la @fig:xor2loss. Notar que tras una abrupta disminución del error en las primeras épocas, el entrenamiento se topa con una sección donde el gradiente del error se hace pequeño. El error disminuye muy poco hasta alrededor de la época 800, donde empieza a disminuir más rápidamente. Alrededor de la época 2000, un gradiente favorable hace el error caiga rápidamente y se acerque asintóticamente a cero.

#figure(
  placement: auto,
  image("img/ej3/loss2.svg", width: 67%),
  caption: [Evolución del error del perceptrón multicapa para el aprendizaje de la XOR de dos entradas],
) <fig:xor2loss>

La @fig:xor2boundary muestra las fronteras de decisión que aprendió el MLP para clasificar las muestras de la función XOR. Las fronteras se corresponden con las líneas donde la salida es $0.5$. Aquellas muestras que caen en sectores rojos (salida $>0.5$), se toman como $1$, mientras que las de la zona azul (salida $<0.5$) se clasifican como $0$. La red fue capaz de aprender correctamente la función XOR de dos entradas. Las salidas tomadas como $1$ se corresponden con valores de alrededor de $0.95$, mientras que las tomadas como $0$ rondaban $0.05$.

#figure(
  placement: auto,
  image("img/ej3/decision2.svg", width: 45%),
  caption: [Fronteras de decisión de la función XOR de dos entradas, aprendidas por el perceptrón multicapa.],
) <fig:xor2boundary>

=== Función XOR de cuatro entradas (función de paridad)

El siguiente experimento consistió del entrenamiento de un MLP sobre una función XOR de cuatro entradas. Como se mencionó anteriormente, esta generalización consiste en contar la cantidad de entradas que valen $1$, y devolviendo como salida $1$ si la cuenta es impar, o $0$ si es par. Por este motivo, la función XOR generalizada se suele llamar función de paridad.

El aprendizaje se hizo sobre los $16$ posibles pares de entrada-salida. La arquitectura de la red fue de cuatro entradas, una capa oculta con cuatro neuronas, y una neurona de salida . El _learning rate_ se mantuvo en $1.0$, y se entrenó durante 20000 épocas.

La evolución del error o _loss_ durante el entrenamiento se muestra en la @fig:xor4loss. Nuevamente, vemos una caída inicial abrupta del error. Un gran estancamiento ocurre entre las épocas 5000 y 17500, debido a un gradiente desfavorablemente pequeño. Finalmente, tras una caída rápida del error, este tiende a anularse hacia la época 20000.

#figure(
  placement: auto,
  image("img/ej3/loss4.svg", width: 67%),
  caption: [Evolución del error del perceptrón multicapa para el aprendizaje de la XOR de cuatro entradas],
) <fig:xor4loss>

Debido a la mayor complejidad de la función a aprender y de la mayor cantidad de neuronas, la red demora mucho más tiempo en converger que la de dos entradas, si se mantiene el mismo _learning rate_.

Se verificó que tras la convergencia, la red es capaz de evaluar correctamente la función XOR de cuatro entradas. Para ello, nuevamente se tomó como $1$ aquellas salidas cuyo valor es $>0.5$, y como $0$ si son menores. Aún así, se destaca que las salidas categorizadas como $1$ rondaban valores de $0.9$ y mayores, mientras que las salidas $0$ rondaban $0.1$ y menos.

== Implementación de una función continua con perceptrón multicapa

Este experimento consistió del entrenamiento de un perceptrón multicapa utilizando _backpropagation_, para el aprendizaje de un campo escalar continuo definido por
$ f(x,y,z) = sin(x) + cos(y) + z, $
con $(x,y) in [0, 2 pi]^2$ y $z in [-1, 1]$.

En todos los casos, la red utilizada posee tres entradas para las variables $(x, y, z)$, una capa oculta de 30 neuronas con activación sigmoide, y una única neurona de salida con activación lineal. La activación lineal es necesaria para que la red pueda ser capaz de tener a su salida valores en el rango de $[-3, 3]$ (el dominio de $f$), dado que no estamos en un problema de clasificación o de respuestas discretas, como anteriormente.

=== Entrenamiento de un perceptrón multicapa con muchas muestras

En primer lugar, se entrenó a la red descripta anteriormente utilizando un conjunto de datos de 1000 muestras, de las cuales 900 se usaron para el entrenamiento _per se_, y las restantes 100 como testeo. Las muestras se generaron aleatoriamente, escogiendo uniformemente valores de las tres entradas dentro del dominio de la función, y evaluando su resultado. El entrenamiento se realizó en un único batch, con una tasa de aprendizaje de 0.05, durante 10000 épocas.

La @fig:ej4_loss muestra el error de entrenamiento y de testeo (evaluación) durante el entrenamiento. Se observa cómo la red disminuye su error conforme pasan las épocas, inicialmente a una velocidad rápida y luego en forma más lenta. Tanto para el entrenamiento como la evaluación, el error decrece monotónicamente, y es similar en ambos casos, lo que sugiere que no hay _overfitting_. Esto es esperable pues hay muchas más muestras de entrenamiento (900) que parámetros (151#footnote([Cantidad de parámetros entrenables: $(3 times 30 + 30) + (30 times 1 + 1) = 151$.])).

#figure(
  placement: auto,
  image("img/ej4/loss.svg", width: 67%),
  caption: [Errores de entrenamiento y evaluación para el entrenamiento de un MLP con una capa oculta de 30 neuronas sobre la función $f(x,y,z) = sin(x) + cos(y) + z$.],
) <fig:ej4_loss>

Para comparar la salida real con la aprendida por la red, se graficaron las salidas de la red en función de las esperadas para cada una de las muestras de testeo. El resultado se observa en la @fig:ej4_pred. Si la red aprende perfectamente la función, el resultado esperado es que las muestras se alineen sobre una recta de pendiente unitaria (naranja), es decir, que las salidas esperadas y las reales coinciden. Vemos que el comportamiento de la red es correcto, ya que las muestras (azul) tienden a tener valores similares a los esperados, encontrándose cerca de la recta identidad.

Como segunda forma de comparación, se evaluó la función en el subconjunto $(x, y, z) = (x, pi, 0.5)$. La @fig:ej4_out muestra el valor esperado (naranja) y el valor evaluado por la red (azul) en este subconjunto. La red es relativamente capaz de aprender las curvas de la función resultante, aunque tiene más problemas para representar el valle de la función seno en estos valores.

#grid(columns: 2, gutter: 1.5em,
grid.cell([
  #figure(
    placement:auto,
    image("img/ej4/prediction.svg"),
    caption: [Salidas de la red en función de las salidas esperadas para el conjunto de testeo, en azul. Resultado ideal esperado, en naranja.],
  ) <fig:ej4_pred>
]),
grid.cell([
  #figure(
    placement:auto,
    image("img/ej4/output.svg"),
    caption: [Salida esperada (naranja) y obtenida (azul) por la red para un _slice_ de $f(x,y,z)$, donde $y=pi$,\ $z=0.5$, y $x in [0, 2 pi]$.],
  ) <fig:ej4_out>
])
)

=== Efectos del tamaño del minibatch

En la segunda parte del experimento se reentrenó la misma red, pero utilizando únicamente 40 muestras. Además, se redujo el conjunto de testeo a 20 muestras. El entrenamiento se hizo mediante minibatches, es decir, calculando el gradiente y propagándolo hacia atrás para una pequeña porción de los datos cada vez. Cada época sigue pasando por todos los datos, pero lo hace de a bloques más pequeños que el conjunto completo. Esto tiene la ventaja de acelerar el aprendizaje, además de otorgarle cirta aleatoriedad que puede ayudar a salir de mínimos locales, pero esto mismo significa que la dirección de modificación de los pesos no es necesariamente opuesta al gradiente. Debido a este comportamiento, este método se conoce como gradiente descendente estocástico o _stochastic gradient descent_.

==== Entrenamiento por minibatch grande

Inicialmente se entrenó la red con un _learning rate_ de 0.05, durante 10000 épocas, utilizando un minibatch de tamaño 40, es decir, de la totalidad de los datos. El error de entrenamiento y de testeo se muestra en la @fig:ej4_loss40. Como antes, se observa que la _loss_ cae monotónicamente, hasta alcanzarse un error relativamente bajo. Sin embargo, vemos que el error de evaluación no llega a un valor tan bajo como el de entrenamiento. Dado que la red posee 30 neuronas, la cantidad de parámetros será bastante mayor a las 40 muestras de entrenamiento que se tienen. Por lo tanto, hay un alto riesgo de overfitting. La red no tiene la "necesidad" de generalizar puesto que puede memorizar los datos de entrenamiento.

#figure(
  placement: auto,
  image("img/ej4/loss_40.svg", width: 67%),
  caption: [Entrenamiento de la red de 30 neuronas ocultas con 40 muestras en un único minibatch de tamaño 40.],
) <fig:ej4_loss40>

==== Entrenamiento por minibatch pequeño (_stochastic gradient descent_)

Como contraste, se reentrenó la red con los mismos parámetros pero usando un minibatch de tamaño 1. Este es el caso más extremo de gradiente descendente estocástico, ya que se utiliza una única muestra cada vez para realizar el entrenamiento. La @fig:ej4_loss1 muestra cómo evoluciona el error de entrenamiento y testeo durante el aprendizaje. Debido a que el gradiente es estocástico y la red no siempre modifica sus pesos en la exacta dirección de máximo decrecimiento, vemos cierto ruido tanto en la _loss_ de entrenamiento como en la de evaluación. Es más notorio el efecto en testeo. Sin embargo, en promedio la red sigue corrigiendo sus pesos en una dirección correcta, por lo que puede aprender sin problemas y el error cae rápidamente. Los errores de evaluación y de entrenamiento obtenidos son menores que para el caso anterior. El ruido en la estimación del gradiente permite que la red escape de mínimos locales no óptimos. Nuevamente, se observa el ligero efecto de memorización dada la alta cantidad de parámetros respecto de la cantidad de muestras de entrenamiento, resultando en una _loss_ de entrenamiento no tan baja. Además, a partir de aproximadamente la época 1000 el error de evaluación aumenta consistentemente durante un largo tiempo, una clara señal de _overfitting_.

#figure(
  placement: auto,
  image("img/ej4/loss_1.svg", width: 67%),
  caption: [Entrenamiento de la red de 30 neuronas ocultas con 40 muestras en minibatches de tamaño 1.],
) <fig:ej4_loss1>

// vim: lbr
