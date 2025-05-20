// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'dart:math' show Random;

class _NodoBusqueda implements Comparable<_NodoBusqueda> {
  final List<List<int>> estado;
  final int costo;
  final int heuristica;
  final _NodoBusqueda? padre;
  
  _NodoBusqueda(this.estado, this.costo, this.heuristica, this.padre);
  
  int get funcionF => costo + heuristica;
  
  @override
  int compareTo(_NodoBusqueda otro) {
    return funcionF.compareTo(otro.funcionF);
  }
}

class PuzzleGame extends StatefulWidget {
  const PuzzleGame({super.key});

  @override
  State<PuzzleGame> createState() => _PuzzleGameState();
}

class _PuzzleGameState extends State<PuzzleGame> with SingleTickerProviderStateMixin {
  // Posición de la ficha vacía (0 representa el espacio vacío)
  late List<List<int>> cuadriculaJuego;
  late int filaVacia;
  late int columnaVacia;
  // Cuadrícula de referencia (objetivo)
  late List<List<int>> cuadriculaObjetivo;
  bool haGanado = false;
  final Random _aleatorio = Random();

  // Variables para A* solver
  bool _resolviendo = false;
  List<List<List<int>>> _pasosSolucion = [];
  int _pasoActual = 0;

  // Controlador de animación para el efecto de arrastre
  late AnimationController _controladorArrastre;
  // Posición de la ficha actualmente arrastrada
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

    // Inicializar controlador de animación para el efecto de arrastre
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
    _controladorArrastre.dispose(); // Liberar el controlador de animación
    super.dispose();
  }

  void _generarNuevoObjetivo() {
    // Crear un puzzle resuelto como punto de partida
    cuadriculaObjetivo = [
      [1, 2, 3],
      [4, 5, 6],
      [7, 8, 0], // 0 representa la ficha vacía
    ];

    // Mezclar la cuadrícula objetivo con un patrón diferente cada vez
    int filaObjVacio = 2;
    int columnaObjVacio = 2;

    // Hacer suficientes movimientos aleatorios para crear un objetivo válido pero desafiante
    // Usando menos movimientos que la mezcla principal del puzzle para mantenerlo razonable
    int movimientos = _aleatorio.nextInt(20) + 15; // Entre 15-35 movimientos

    for (int i = 0; i < movimientos; i++) {
      List<List<int>> movimientosPosibles = [];

      // Verificar todas las fichas adyacentes al espacio vacío
      if (filaObjVacio > 0) movimientosPosibles.add([filaObjVacio - 1, columnaObjVacio]);
      if (filaObjVacio < 2) movimientosPosibles.add([filaObjVacio + 1, columnaObjVacio]);
      if (columnaObjVacio > 0) movimientosPosibles.add([filaObjVacio, columnaObjVacio - 1]);
      if (columnaObjVacio < 2) movimientosPosibles.add([filaObjVacio, columnaObjVacio + 1]);

      // Seleccionar un movimiento aleatorio y aplicarlo
      final movimiento = movimientosPosibles[_aleatorio.nextInt(movimientosPosibles.length)];

      // Intercambiar la ficha con el espacio vacío
      cuadriculaObjetivo[filaObjVacio][columnaObjVacio] = cuadriculaObjetivo[movimiento[0]][movimiento[1]];
      cuadriculaObjetivo[movimiento[0]][movimiento[1]] = 0;

      // Actualizar la posición del espacio vacío
      filaObjVacio = movimiento[0];
      columnaObjVacio = movimiento[1];
    }
  }

  void _inicializarPuzzle() {
    // Inicializar la cuadrícula jugable para que coincida con el objetivo (comenzando resuelto)
    cuadriculaJuego = List.generate(3, (i) => List.generate(3, (j) => cuadriculaObjetivo[i][j]));

    // Encontrar la posición de la ficha vacía
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
    // Una ficha puede moverse si está adyacente al espacio vacío
    return (fila == filaVacia && (columna == columnaVacia - 1 || columna == columnaVacia + 1)) ||
        (columna == columnaVacia && (fila == filaVacia - 1 || fila == filaVacia + 1));
  }

  void _moverFicha(int fila, int columna) {
    if (_puedeMoverseFicha(fila, columna)) {
      setState(() {
        // Intercambiar la ficha tocada con el espacio vacío
        cuadriculaJuego[filaVacia][columnaVacia] = cuadriculaJuego[fila][columna];
        cuadriculaJuego[fila][columna] = 0;

        // Actualizar la posición del espacio vacío
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
      // Calcular en qué dirección estamos arrastrando (horizontal o vertical)
      bool esArrastreHorizontal = _filaFichaArrastrada == filaVacia;
      bool esArrastreVertical = _columnaFichaArrastrada == columnaVacia;

      // Restringir el arrastre al eje correcto
      double dx = esArrastreHorizontal ? delta.dx : 0;
      double dy = esArrastreVertical ? delta.dy : 0;

      // Restringir aún más la dirección en función de la posición de la ficha vacía
      if (esArrastreHorizontal) {
        // Si el vacío está a la derecha, solo puede arrastrar hacia la derecha (dx positivo)
        if (columnaVacia > _columnaFichaArrastrada! && dx < 0) dx = 0;
        // Si el vacío está a la izquierda, solo puede arrastrar hacia la izquierda (dx negativo)
        if (columnaVacia < _columnaFichaArrastrada! && dx > 0) dx = 0;
        // Limitar la distancia de arrastre
        dx = dx.clamp(-84.0, 84.0);
      }

      if (esArrastreVertical) {
        // Si el vacío está abajo, solo puede arrastrar hacia abajo (dy positivo)
        if (filaVacia > _filaFichaArrastrada! && dy < 0) dy = 0;
        // Si el vacío está arriba, solo puede arrastrar hacia arriba (dy negativo)
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
        // Animar la finalización del arrastre
        _controladorArrastre.forward(from: 0).then((_) {
          _moverFicha(_filaFichaArrastrada!, _columnaFichaArrastrada!);
          _controladorArrastre.reset();
        });
      } else {
        // Restablecer arrastre si no se movió lo suficiente
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
    // Comparar la cuadrícula actual con la cuadrícula objetivo
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
              '¡Felicidades! ¡Puzzle Resuelto!',
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
      // Luego inicializar la cuadrícula del puzzle basada en el nuevo objetivo
      _inicializarPuzzle();
      // Luego mezclar para comenzar el juego
      _mezclarPuzzle();
    });
  }

  void _mezclarPuzzle() {
    // Mezclar el puzzle haciendo movimientos válidos aleatorios
    setState(() {
      haGanado = false;

      // Hacer movimientos aleatorios válidos
      for (int i = 0; i < 100; i++) { // Hacer 100 movimientos aleatorios
        List<List<int>> movimientosPosibles = [];

        // Verificar todas las fichas adyacentes al espacio vacío
        if (filaVacia > 0) movimientosPosibles.add([filaVacia - 1, columnaVacia]);
        if (filaVacia < 2) movimientosPosibles.add([filaVacia + 1, columnaVacia]);
        if (columnaVacia > 0) movimientosPosibles.add([filaVacia, columnaVacia - 1]);
        if (columnaVacia < 2) movimientosPosibles.add([filaVacia, columnaVacia + 1]);

        // Seleccionar un movimiento aleatorio y aplicarlo
        final movimiento = movimientosPosibles[_aleatorio.nextInt(movimientosPosibles.length)];

        // Intercambiar la ficha con el espacio vacío (sin llamar a setState o verificar victoria)
        cuadriculaJuego[filaVacia][columnaVacia] = cuadriculaJuego[movimiento[0]][movimiento[1]];
        cuadriculaJuego[movimiento[0]][movimiento[1]] = 0;

        // Actualizar la posición del espacio vacío
        filaVacia = movimiento[0];
        columnaVacia = movimiento[1];
      }
    });
  }

  // Calcular la distancia Manhattan (heurística para A*)
  int _calcularDistanciaManhattan(List<List<int>> estado) {
    int distancia = 0;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        int valor = estado[i][j];
        if (valor != 0) {
          // Encontrar la posición correcta del valor en el objetivo
          int filaObjetivo = -1;
          int columnaObjetivo = -1;
          for (int m = 0; m < 3; m++) {
            for (int n = 0; n < 3; n++) {
              if (cuadriculaObjetivo[m][n] == valor) {
                filaObjetivo = m;
                columnaObjetivo = n;
                break;
              }
            }
            if (filaObjetivo != -1) break;
          }
          
          // Sumar la distancia Manhattan (|x1 - x2| + |y1 - y2|)
          distancia += (i - filaObjetivo).abs() + (j - columnaObjetivo).abs();
        }
      }
    }
    return distancia;
  }

  // Convertir matriz a string para usarla como clave en el conjunto visitado
  String _estadoAClave(List<List<int>> estado) {
    return estado.map((fila) => fila.join(',')).join(';');
  }

  // Encontrar la posición del espacio vacío (0) en un estado
  List<int> _encontrarVacio(List<List<int>> estado) {
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (estado[i][j] == 0) {
          return [i, j];
        }
      }
    }
    return [-1, -1]; // No debería llegar aquí
  }

  // Obtener estados sucesores a partir de un estado
  List<List<List<int>>> _obtenerSucesores(List<List<int>> estado) {
    List<List<List<int>>> sucesores = [];
    final posicionVacio = _encontrarVacio(estado);
    final int fila = posicionVacio[0];
    final int columna = posicionVacio[1];
    
    // Direcciones posibles (arriba, abajo, izquierda, derecha)
    final List<List<int>> direcciones = [
      [-1, 0], [1, 0], [0, -1], [0, 1]
    ];
    
    for (var direccion in direcciones) {
      final int nuevaFila = fila + direccion[0];
      final int nuevaColumna = columna + direccion[1];
      
      // Verificar si la nueva posición está dentro de los límites
      if (nuevaFila >= 0 && nuevaFila < 3 && nuevaColumna >= 0 && nuevaColumna < 3) {
        // Crear una copia profunda del estado actual
        List<List<int>> nuevoEstado = List.generate(
          3, (i) => List.generate(3, (j) => estado[i][j])
        );
        
        // Obtener el valor de la ficha que se movería
        int valorFicha = estado[nuevaFila][nuevaColumna];
        
        // Verificar restricción para la ficha 4
        if (valorFicha == 4) {
          // Si es un movimiento horizontal, ignorarlo
          if (nuevaFila == fila) {
            continue; // No permitir que la ficha 4 se mueva horizontalmente
          }
        }
        
        // Intercambiar la ficha con el espacio vacío
        nuevoEstado[fila][columna] = valorFicha;
        nuevoEstado[nuevaFila][nuevaColumna] = 0;
        
        sucesores.add(nuevoEstado);
      }
    }
    
    return sucesores;
  }

  // Implementación del algoritmo A*
  Future<void> _resolverConAStar() async {
    if (_resolviendo) return;
    
    setState(() {
      _resolviendo = true;
      _pasosSolucion = [];
      _pasoActual = 0;
    });
    
    // Usar lista ordenada como alternativa a PriorityQueue
    List<_NodoBusqueda> colaPrioridad = [];
    
    // Conjunto para estados visitados
    final visitados = <String>{};
    
    // Estado inicial
    final estadoInicial = List.generate(
      3, (i) => List.generate(3, (j) => cuadriculaJuego[i][j])
    );
    
    // Calcular heurística inicial
    final heuristicaInicial = _calcularDistanciaManhattan(estadoInicial);
    
    // Crear nodo inicial
    final nodoInicial = _NodoBusqueda(estadoInicial, 0, heuristicaInicial, null);
    
    // Agregar a la lista de prioridad
    colaPrioridad.add(nodoInicial);
    
    // Buscar solución
    while (colaPrioridad.isNotEmpty) {
      // Ordenar la lista por valor f (costo + heurística)
      colaPrioridad.sort((a, b) => a.funcionF.compareTo(b.funcionF));
      
      // Extraer nodo con menor f
      final nodoActual = colaPrioridad.removeAt(0);
      
      // Verificar si el estado es el objetivo
      if (_calcularDistanciaManhattan(nodoActual.estado) == 0) {
        // Solución encontrada, reconstruir camino
        List<List<List<int>>> camino = [];
        var nodo = nodoActual;
        while (nodo.padre != null) {
          camino.insert(0, nodo.estado);
          nodo = nodo.padre!;
        }
        
        setState(() {
          _pasosSolucion = camino;
          _pasoActual = 0;
          // Iniciar la animación de la solución
          _animarSolucion();
        });
        
        return;
      }
      
      // Marcar como visitado
      final claveEstado = _estadoAClave(nodoActual.estado);
      if (visitados.contains(claveEstado)) continue;
      visitados.add(claveEstado);
      
      // Generar sucesores
      final sucesores = _obtenerSucesores(nodoActual.estado);
      
      for (var sucesor in sucesores) {
        final claveSucc = _estadoAClave(sucesor);
        if (visitados.contains(claveSucc)) continue;
        
        final nuevoCosto = nodoActual.costo + 1;
        final nuevaHeuristica = _calcularDistanciaManhattan(sucesor);
        
        colaPrioridad.add(_NodoBusqueda(
          sucesor, nuevoCosto, nuevaHeuristica, nodoActual
        ));
      }
    }
    
    // Si llegamos aquí, no se encontró solución
    setState(() {
      _resolviendo = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No se pudo encontrar una solución"),
          duration: Duration(seconds: 3),
        )
      );
    });
  }

  // Animar la solución paso a paso
  Future<void> _animarSolucion() async {
    if (_pasoActual >= _pasosSolucion.length) {
      setState(() {
        _resolviendo = false;
      });
      return;
    }
    
    // Aplicar el paso actual
    final nuevoEstado = _pasosSolucion[_pasoActual];
    
    setState(() {
      // Actualizar la cuadrícula
      cuadriculaJuego = List.generate(
        3, (i) => List.generate(3, (j) => nuevoEstado[i][j])
      );
      
      // Encontrar la nueva posición del espacio vacío
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          if (cuadriculaJuego[i][j] == 0) {
            filaVacia = i;
            columnaVacia = j;
            break;
          }
        }
      }
      
      _pasoActual++;
    });
    
    // Verificar victoria en cada paso
    _verificarVictoria();
    
    // Esperar antes del siguiente paso
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Si aún no hemos terminado y seguimos resolviendo, continuar con el siguiente paso
    if (_resolviendo && _pasoActual < _pasosSolucion.length) {
      _animarSolucion();
    } else {
      setState(() {
        _resolviendo = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Juego de Puzzle', style: TextStyle(color: Colors.white)),
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
            tooltip: 'Mezclar Puzzle Actual',
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
                // Sección de objetivo
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
                            // Mostrar un diálogo de pista
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Pista"),
                                  content: const Text("Organiza las fichas en la cuadrícula inferior para que coincidan con el patrón mostrado en la cuadrícula superior. Puedes arrastrar las fichas para moverlas."),
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
                              // Mostrar cuadrícula objetivo
                              for (int i = 0; i < 3; i++)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    for (int j = 0; j < 3; j++)
                                      cuadriculaObjetivo[i][j] == 0
                                          ? Container(height: 54, width: 54)
                                          : _construirFicha(cuadriculaObjetivo[i][j].toString(), pequenia: true,
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

                // Cuadrícula de puzzle jugable (más grande)
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Juega Aquí',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                        const SizedBox(width: 20),
                        // Botón para resolver automáticamente
                        ElevatedButton.icon(
                          onPressed: _resolviendo ? null : _resolverConAStar,
                          icon: const Icon(Icons.auto_fix_high),
                          label: Text(_resolviendo ? 'Resolviendo...' : 'Resolver Auto'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey,
                          ),
                        ),
                      ],
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
                              // Construir cuadrícula de puzzle dinámica desde el estado
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
                          // Indicador de resolución automática
                          if (_resolviendo)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Text(
                                  "Resolviendo...",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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

  // Obtener color de ficha basado en número
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

  // Ficha interactiva con detección de gestos de arrastre
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

  // Ficha estática (para la vista previa del objetivo pequeño)
  Widget _construirFicha(
    String numero, {
    bool pequenia = false,
    Color color = Colors.blue,
  }) {
    final tamanio = pequenia ? 50.0 : 80.0;
    final tamanioFuente = pequenia ? 20.0 : 30.0;

    return Container(
      width: tamanio,
      height: tamanio,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(pequenia ? 6 : 10),
        color: pequenia ? Colors.white : color.withOpacity(0.5),
      ),
      child: Center(
        child: Text(
          numero,
          style: TextStyle(fontSize: tamanioFuente, color: Colors.black54),
        ),
      ),
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return const PuzzleGame();
  }
}
