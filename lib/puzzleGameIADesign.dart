import 'package:flutter/material.dart';

class PuzzleGame extends StatelessWidget {
  const PuzzleGame({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Apply a themed background gradient
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        title: const Text('Puzzle Challenge', 
          style: TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.indigo[800],
        elevation: 8.0,
      ),
      body: SafeArea(
        child: Container(
          // Apply a gradient background to the entire game area
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.indigo[900]!,
                Colors.indigo[800]!,
                Colors.indigo[700]!,
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Game title and instructions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    "Reorder the tiles to solve the puzzle!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.amber[200],
                    ),
                  ),
                ),
                
                // Top puzzle grid (smaller one) - Example/Preview
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.indigo[600],
                    border: Border.all(color: Colors.amber[300]!, width: 3),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Grid pattern background
                      GridPattern(),
                      
                      // Grid layout for the puzzle pieces
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // First row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildTile('1', small: true, color: Colors.teal),
                              _buildTile('2', small: true, color: Colors.teal),
                              _buildTile('3', small: true, color: Colors.teal),
                            ],
                          ),
                          // Second row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildTile('4', small: true, color: Colors.teal),
                              _buildTile('5', small: true, color: Colors.teal),
                              _buildTile('6', small: true, color: Colors.teal),
                            ],
                          ),
                          // Third row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildTile('7', small: true, color: Colors.teal),
                              _buildTile('8', small: true, color: Colors.teal),
                              _buildTile('9', small: true, color: Colors.teal),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Label for the game board
                Text(
                  "Game Board",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[300],
                    shadows: [
                      Shadow(
                        offset: const Offset(1, 1),
                        blurRadius: 3.0,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
                
                // Bottom puzzle grid (larger one) - Main game
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.indigo[400],
                    border: Border.all(color: Colors.amber[400]!, width: 3),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Grid pattern background
                      GridPattern(cellSize: 100),
                      
                      // Grid layout for the puzzle pieces
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // First row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildTile('1', color: Colors.amber[600]!),
                              _buildTile('2', color: Colors.purple[400]!),
                              _buildTile('3', color: Colors.teal[400]!),
                            ],
                          ),
                          // Second row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildTile('4', color: Colors.pink[400]!),
                              _buildTile('5', color: Colors.green[500]!),
                              _buildTile('6', color: Colors.blue[400]!),
                            ],
                          ),
                          // Third row with only two tiles
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildTile('7', color: Colors.orange[400]!),
                              _buildTile('8', color: Colors.red[400]!),
                              // The 9th tile is missing in the reference image - empty space
                              Container(
                                width: 80, 
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.indigo[300]!.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Game controls
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildControlButton(Icons.refresh, "Reset"),
                      const SizedBox(width: 30),
                      _buildControlButton(Icons.help_outline, "Hint"),
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

  // Helper method to create consistent puzzle tiles with improved visual design
  Widget _buildTile(
    String number, {
    bool small = false,
    required Color color,
  }) {
    final size = small ? 50.0 : 80.0;
    final fontSize = small ? 22.0 : 32.0;
    
    return Container(
      width: size,
      height: size,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            Color.lerp(color, Colors.black, 0.3)!,
          ],
        ),
        borderRadius: BorderRadius.circular(small ? 8 : 12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            offset: Offset(0, small ? 2 : 3),
            blurRadius: small ? 3 : 5,
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: small ? 1.0 : 1.5,
        ),
      ),
      child: Center(
        child: Text(
          number,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: 2.0,
                color: Colors.black.withOpacity(0.5),
                offset: const Offset(1, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Helper method to create game control buttons
  Widget _buildControlButton(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.amber[700],
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 30,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.amber[300],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// Custom widget to create grid background pattern
class GridPattern extends StatelessWidget {
  final double cellSize;
  
  const GridPattern({super.key, this.cellSize = 66.7});
  
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: GridPainter(cellSize: cellSize),
    );
  }
}

// Custom painter to draw the grid lines
class GridPainter extends CustomPainter {
  final double cellSize;
  
  GridPainter({required this.cellSize});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1.0;
      
    // Draw horizontal lines
    for (double i = 0; i <= size.height; i += cellSize) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
    
    // Draw vertical lines
    for (double i = 0; i <= size.width; i += cellSize) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return const PuzzleGame();
  }
}
