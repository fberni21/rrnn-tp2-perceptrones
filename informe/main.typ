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

// vim: lbr
