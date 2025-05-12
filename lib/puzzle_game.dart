import 'package:flutter/material.dart';

class PuzzleGame extends StatelessWidget {
  const PuzzleGame({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Puzzle Game', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange[500],
      ),
      body: SafeArea(
        // Se usa SafeArea para evitar el notch (espacio de la camara)
        child: Container(
          decoration: BoxDecoration(
            color: Colors.orange[100],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
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
                          // First row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildTile('1', small: true, color: Colors.blue),
                              _buildTile('2', small: true, color: Colors.amber),
                              _buildTile('3', small: true, color: Colors.red),
                            ],
                          ),
                          // Second row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildTile('4', small: true, color: Colors.green),
                              _buildTile('5', small: true, color: Colors.purple),
                              _buildTile('6', small: true, color: Colors.orange),
                            ],
                          ),
                          // Third row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildTile('7', small: true, color: Colors.cyan),
                              _buildTile('8', small: true, color: Colors.teal),
                              Container(height: 54, width: 54),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
          
                // Bottom puzzle grid (larger one)
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black26, width: 1),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildTile('1', color: Colors.blue),
                              _buildTile('2', color: Colors.amber),
                              _buildTile('3', color: Colors.red),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildTile('4', color: Colors.green),
                              _buildTile('5', color: Colors.purple),
                              _buildTile('6', color: Colors.orange),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildTile('7', color: Colors.cyan),
                              _buildTile('8', color: Colors.teal),
                              Container(width: 80, height: 80),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // creacion de un widget para los tiles
  Widget _buildTile(
    String number, {
    bool small = false,
    Color color = Colors.blue,
  }) {
    final size = small ? 50.0 : 80.0;
    final fontSize = small ? 20.0 : 30.0;

    return Container(
      width: size,
      height: size,
      margin: const EdgeInsets.all(2), // Define un margen para el tile
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(small ? 6 : 10),
        color:
            small
                ? Colors.white
                : color.withValues(alpha: 0.5), // Color de fondo
      ),
      child: Center(
        child: Text(
          number,
          style: TextStyle(fontSize: fontSize, color: Colors.black54),
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
