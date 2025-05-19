import 'package:flutter/material.dart';
import 'dart:math' show Random;

class JuegoRompecabezas extends StatefulWidget {
  const JuegoRompecabezas({super.key});

  @override
  State<JuegoRompecabezas> createState() => _EstadoJuegoRompecabezas();
}

class _EstadoJuegoRompecabezas extends State<JuegoRompecabezas> with SingleTickerProviderStateMixin {
  // Posicion de la ficha vacia (0 representa el espacio vacio)
  late List<List<int>> cuadriculaJuego;
  late int filaVacia;
  late int columnaVacia;
  // Cuadricula de referencia (objetivo)
  late List<List<int>> cuadriculaObjetivo;
  bool haGanado = false;
  final Random _aleatorio = Random();

  // Controlador de animacion para el efecto de arrastre
  late AnimationController _controladorArrastre;
  // Posicion de la ficha actualmente arrastrada
  int? _filaFichaArrastrada;
  int? _columnaFichaArrastrada;
  // Progreso del arrastre para efecto visual
  Offset _desplazamientoArrastre = Offset.zero;
  bool _estaArrastrando = false;

  @override
  void initState() {
    super.initState();
    _generarNuevoObjetivo();
    _inicializarPuzzle();

    // Inicializar controlador de animacion para el efecto de arrastre
    _controladorArrastre = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _estaArrastrando = false;
            _desplazamientoArrastre = Offset.zero;
            _filaFichaArrastrada = null;
            _columnaFichaArrastrada = null;
          });
        }
      });
  }

  @override
  void dispose() {
    _controladorArrastre.dispose();
    super.dispose();
  }

  void _generarNuevoObjetivo() {
    // Crear un puzzle resuelto como punto de partida
    cuadriculaObjetivo = [
      [1, 2, 3],
      [4, 5, 6],
      [7, 8, 0], // 0 representa la ficha vacia
    ];

    // Mezclar la cuadricula objetivo con un patron diferente cada vez
    int filaObjVacio = 2;
    int columnaObjVacio = 2;

    // Hacer suficientes movimientos aleatorios para crear un objetivo valido pero desafiante
    // Usando menos movimientos que la mezcla principal del puzzle para mantenerlo razonable
    int movimientos = _aleatorio.nextInt(20) + 15; // Entre 15-35 movimientos

    for (int i = 0; i < movimientos; i++) {
      List<List<int>> movimientosPosibles = [];

      // Verificar todas las fichas adyacentes al espacio vacio
      if (filaObjVacio > 0) movimientosPosibles.add([filaObjVacio - 1, columnaObjVacio]);
      if (filaObjVacio < 2) movimientosPosibles.add([filaObjVacio + 1, columnaObjVacio]);
      if (columnaObjVacio > 0) movimientosPosibles.add([filaObjVacio, columnaObjVacio - 1]);
      if (columnaObjVacio < 2) movimientosPosibles.add([filaObjVacio, columnaObjVacio + 1]);

      // Seleccionar un movimiento aleatorio y aplicarlo
      final movimiento = movimientosPosibles[_aleatorio.nextInt(movimientosPosibles.length)];

      // Intercambiar la ficha con el espacio vacio
      cuadriculaObjetivo[filaObjVacio][columnaObjVacio] = cuadriculaObjetivo[movimiento[0]][movimiento[1]];
      cuadriculaObjetivo[movimiento[0]][movimiento[1]] = 0;

      // Actualizar la posicion del espacio vacio
      filaObjVacio = movimiento[0];
      columnaObjVacio = movimiento[1];
    }
  }

  void _inicializarPuzzle() {
    // Inicializar la cuadricula jugable para que coincida con el objetivo (comenzando resuelto)
    cuadriculaJuego = List.generate(3, (i) => List.generate(3, (j) => cuadriculaObjetivo[i][j]));

    // Encontrar la posicion de la ficha vacia
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (cuadriculaJuego[i][j] == 0) {
          filaVacia = i;
          columnaVacia = j;
          break;
        }
      }
    }
    haGanado = true; // Comenzar como "resuelto" para poder mezclar inmediatamente
  }

  bool _puedeMoverseFicha(int fila, int columna) {
    // Una ficha puede moverse si esta adyacente al espacio vacio
    return (fila == filaVacia && (columna == columnaVacia - 1 || columna == columnaVacia + 1)) ||
        (columna == columnaVacia && (fila == filaVacia - 1 || fila == filaVacia + 1));
  }

  void _moverFicha(int fila, int columna) {
    if (_puedeMoverseFicha(fila, columna)) {
      setState(() {
        // Intercambiar la ficha tocada con el espacio vacio
        cuadriculaJuego[filaVacia][columnaVacia] = cuadriculaJuego[fila][columna];
        cuadriculaJuego[fila][columna] = 0;

        // Actualizar la posicion del espacio vacio
        filaVacia = fila;
        columnaVacia = columna;

        // Verificar victoria
        _verificarVictoria();
      });
    }
  }

  void _iniciarArrastre(int fila, int columna) {
    if (_puedeMoverseFicha(fila, columna) && !_estaArrastrando) {
      setState(() {
        _estaArrastrando = true;
        _filaFichaArrastrada = fila;
        _columnaFichaArrastrada = columna;
      });
    }
  }

  void _actualizarArrastre(Offset delta) {
    if (_estaArrastrando && _filaFichaArrastrada != null && _columnaFichaArrastrada != null) {
      // Calcular en que direccion estamos arrastrando (horizontal o vertical)
      bool esArrastreHorizontal = _filaFichaArrastrada == filaVacia;
      bool esArrastreVertical = _columnaFichaArrastrada == columnaVacia;

      // Restringir el arrastre al eje correcto
      double dx = esArrastreHorizontal ? delta.dx : 0;
      double dy = esArrastreVertical ? delta.dy : 0;

      // Restringir aun mas la direccion en funcion de la posicion de la ficha vacia
      if (esArrastreHorizontal) {
        // Si el vacio esta a la derecha, solo puede arrastrar hacia la derecha (dx positivo)
        if (columnaVacia > _columnaFichaArrastrada! && dx < 0) dx = 0;
        // Si el vacio esta a la izquierda, solo puede arrastrar hacia la izquierda (dx negativo)
        if (columnaVacia < _columnaFichaArrastrada! && dx > 0) dx = 0;
        // Limitar la distancia de arrastre
        dx = dx.clamp(-84.0, 84.0);
      }

      if (esArrastreVertical) {
        // Si el vacio esta abajo, solo puede arrastrar hacia abajo (dy positivo)
        if (filaVacia > _filaFichaArrastrada! && dy < 0) dy = 0;
        // Si el vacio esta arriba, solo puede arrastrar hacia arriba (dy negativo)
        if (filaVacia < _filaFichaArrastrada! && dy > 0) dy = 0;
        // Limitar la distancia de arrastre
        dy = dy.clamp(-84.0, 84.0);
      }

      setState(() {
        _desplazamientoArrastre = Offset(dx, dy);
      });
    }
  }

  void _finalizarArrastre() {
    if (_estaArrastrando && _filaFichaArrastrada != null && _columnaFichaArrastrada != null) {
      bool debeMoverse = false;

      // Determinar si el arrastre fue lo suficientemente significativo para activar un movimiento
      // Para arrastres horizontales
      if (_filaFichaArrastrada == filaVacia) {
        if ((_columnaFichaArrastrada! < columnaVacia && _desplazamientoArrastre.dx > 30) || // Arrastrando hacia la derecha
            (_columnaFichaArrastrada! > columnaVacia && _desplazamientoArrastre.dx < -30)) { // Arrastrando hacia la izquierda
          debeMoverse = true;
        }
      }
      // Para arrastres verticales
      if (_columnaFichaArrastrada == columnaVacia) {
        if ((_filaFichaArrastrada! < filaVacia && _desplazamientoArrastre.dy > 30) || // Arrastrando hacia abajo
            (_filaFichaArrastrada! > filaVacia && _desplazamientoArrastre.dy < -30)) { // Arrastrando hacia arriba
          debeMoverse = true;
        }
      }

      if (debeMoverse) {
        // Animar la finalizacion del arrastre
        _controladorArrastre.forward(from: 0).then((_) {
          _moverFicha(_filaFichaArrastrada!, _columnaFichaArrastrada!);
          _controladorArrastre.reset();
        });
      } else {
        // Restablecer arrastre si no se movio lo suficiente
        setState(() {
          _estaArrastrando = false;
          _desplazamientoArrastre = Offset.zero;
          _filaFichaArrastrada = null;
          _columnaFichaArrastrada = null;
        });
      }
    }
  }

  void _verificarVictoria() {
    // Comparar la cuadricula actual con la cuadricula objetivo
    bool esVictoria = true;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (cuadriculaJuego[i][j] != cuadriculaObjetivo[i][j]) {
          esVictoria = false;
          break;
        }
      }
      if (!esVictoria) break;
    }

    if (esVictoria && !haGanado) {
      haGanado = true;
      // Mostrar mensaje de victoria
      _mostrarMensajeVictoria();
    }
  }

  void _mostrarMensajeVictoria() {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber),
            const SizedBox(width: 10),
            const Text(
              '¡Felicidades! ¡Rompecabezas Resuelto!',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'Nuevo Juego',
          textColor: Colors.white,
          onPressed: () {
            _nuevoJuego();
            scaffold.hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _nuevoJuego() {
    setState(() {
      // Generar un nuevo objetivo primero
      _generarNuevoObjetivo();
      // Luego inicializar la cuadricula del puzzle basada en el nuevo objetivo
      _inicializarPuzzle();
      // Luego mezclar para comenzar el juego
      _mezclarPuzzle();
    });
  }

  void _mezclarPuzzle() {
    // Mezclar el puzzle haciendo movimientos validos aleatorios
    setState(() {
      haGanado = false;

      // Hacer movimientos aleatorios validos
      for (int i = 0; i < 100; i++) { // Hacer 100 movimientos aleatorios
        List<List<int>> movimientosPosibles = [];

        // Verificar todas las fichas adyacentes al espacio vacio
        if (filaVacia > 0) movimientosPosibles.add([filaVacia - 1, columnaVacia]);
        if (filaVacia < 2) movimientosPosibles.add([filaVacia + 1, columnaVacia]);
        if (columnaVacia > 0) movimientosPosibles.add([filaVacia, columnaVacia - 1]);
        if (columnaVacia < 2) movimientosPosibles.add([filaVacia, columnaVacia + 1]);

        // Seleccionar un movimiento aleatorio y aplicarlo
        final movimiento = movimientosPosibles[_aleatorio.nextInt(movimientosPosibles.length)];

        // Intercambiar la ficha con el espacio vacio (sin llamar a setState o verificar victoria)
        cuadriculaJuego[filaVacia][columnaVacia] = cuadriculaJuego[movimiento[0]][movimiento[1]];
        cuadriculaJuego[movimiento[0]][movimiento[1]] = 0;

        // Actualizar la posicion del espacio vacio
        filaVacia = movimiento[0];
        columnaVacia = movimiento[1];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Juego de Rompecabezas', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange[500],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _nuevoJuego,
            tooltip: 'Nuevo Juego',
          ),
          IconButton(
            icon: const Icon(Icons.shuffle, color: Colors.white),
            onPressed: _mezclarPuzzle,
            tooltip: 'Mezclar Rompecabezas Actual',
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.orange[100],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Seccion de objetivo
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Objetivo',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.lightbulb_outline, color: Colors.amber),
                          onPressed: () {
                            // Mostrar un dialogo de pista
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Pista"),
                                  content: const Text("Organiza las fichas en la cuadricula inferior para que coincidan con el patron mostrado en la cuadricula superior. Puedes arrastrar las fichas para moverlas."),
                                  actions: [
                                    TextButton(
                                      child: const Text("¡Entendido!"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          tooltip: 'Obtener una pista',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black26, width: 1),
                        borderRadius: BorderRadius.circular(8),
                        gradient: LinearGradient(
                          colors: <Color>[
                            Colors.amber.shade100,
                            Colors.orange.shade300,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Mostrar cuadricula objetivo
                              for (int i = 0; i < 3; i++)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    for (int j = 0; j < 3; j++)
                                      cuadriculaObjetivo[i][j] == 0
                                          ? Container(height: 54, width: 54)
                                          : _construirFicha(cuadriculaObjetivo[i][j].toString(), pequena: true,
                                              color: _obtenerColorFicha(cuadriculaObjetivo[i][j].toString())),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Cuadricula de puzzle jugable (mas grande)
                Column(
                  children: [
                    const Text(
                      'Juega Aqui',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: haGanado ? Colors.green : Colors.black26,
                            width: haGanado ? 3 : 1),
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors: <Color>[
                            Colors.amber.shade100,
                            Colors.orange.shade100,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Construir cuadricula de puzzle dinamica desde el estado
                              for (int i = 0; i < 3; i++)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    for (int j = 0; j < 3; j++)
                                      cuadriculaJuego[i][j] == 0
                                          ? Container(width: 80, height: 80)
                                          : _construirFichaArrastrable(cuadriculaJuego[i][j].toString(), i, j),
                                  ],
                                ),
                            ],
                          ),
                          if (haGanado)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.check_circle_outline,
                                color: Colors.green,
                                size: 80,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Obtener color de ficha basado en numero
  Color _obtenerColorFicha(String numero) {
    final Map<String, Color> mapaColores = {
      '1': Colors.blue,
      '2': Colors.amber,
      '3': Colors.red,
      '4': Colors.green,
      '5': Colors.purple,
      '6': Colors.orange,
      '7': Colors.cyan,
      '8': Colors.teal,
    };
    return mapaColores[numero] ?? Colors.grey;
  }

  // Ficha interactiva con deteccion de gestos de arrastre
  Widget _construirFichaArrastrable(String numero, int fila, int columna) {
    Color colorFicha = _obtenerColorFicha(numero);
    bool estaMovible = _puedeMoverseFicha(fila, columna);
    bool estaActualmenteArrastrada = _estaArrastrando && fila == _filaFichaArrastrada && columna == _columnaFichaArrastrada;

    // Calcular desplazamiento para la ficha arrastrada actual
    Offset desplazamientoFicha = estaActualmenteArrastrada ? _desplazamientoArrastre : Offset.zero;

    return GestureDetector(
      onTap: () => _moverFicha(fila, columna),
      onPanStart: (_) => _iniciarArrastre(fila, columna),
      onPanUpdate: (details) => _actualizarArrastre(details.delta),
      onPanEnd: (_) => _finalizarArrastre(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(desplazamientoFicha.dx, desplazamientoFicha.dy, 0),
        width: 80,
        height: 80,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          border: Border.all(
            color: estaMovible
                ? colorFicha.withOpacity(1.0)
                : colorFicha.withOpacity(0.8),
            width: estaMovible ? 2.5 : 1.5,
          ),
          borderRadius: BorderRadius.circular(10),
          color: colorFicha.withOpacity(0.5),
          boxShadow: estaMovible || estaActualmenteArrastrada
              ? [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: estaActualmenteArrastrada ? 8 : 5,
                    offset: estaActualmenteArrastrada
                        ? const Offset(2, 3)
                        : const Offset(1, 2),
                  )
                ]
              : null,
        ),
        child: Center(
          child: Text(
            numero,
            style: TextStyle(
              fontSize: 30,
              color: Colors.black54,
              fontWeight: estaMovible ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  // Ficha estatica (para la vista previa del objetivo pequeno)
  Widget _construirFicha(
    String numero, {
    bool pequena = false,
    Color color = Colors.blue,
  }) {
    final tamano = pequena ? 50.0 : 80.0;
    final tamanoFuente = pequena ? 20.0 : 30.0;

    return Container(
      width: tamano,
      height: tamano,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(pequena ? 6 : 10),
        color: pequena ? Colors.white : color.withOpacity(0.5),
      ),
      child: Center(
        child: Text(
          numero,
          style: TextStyle(fontSize: tamanoFuente, color: Colors.black54),
        ),
      ),
    );
  }
}

class Inicio extends StatelessWidget {
  const Inicio({super.key});

  @override
  Widget build(BuildContext context) {
    return const JuegoRompecabezas();
  }
}
