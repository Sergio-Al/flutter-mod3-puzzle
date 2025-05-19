import 'package:flutter/material.dart';
import 'dart:math' show Random;

class PuzzleGame extends StatefulWidget {
  const PuzzleGame({super.key});

  @override
  State<PuzzleGame> createState() => _PuzzleGameState();
}

class _PuzzleGameState extends State<PuzzleGame> with SingleTickerProviderStateMixin {
  // Position of the empty tile (0 represents the empty space)
  late List<List<int>> puzzleGrid;
  late int emptyRow;
  late int emptyCol;
  // Reference grid (objective)
  late List<List<int>> objectiveGrid;
  bool hasWon = false;
  final Random _random = Random();

  // Animation controller for dragging effect
  late AnimationController _dragController;
  // Currently dragged tile position
  int? _draggedTileRow;
  int? _draggedTileCol;
  // Drag progress for visual effect
  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _generateNewObjective();
    _initializePuzzle();

    // Initialize animation controller for drag effect
    _dragController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _isDragging = false;
            _dragOffset = Offset.zero;
            _draggedTileRow = null;
            _draggedTileCol = null;
          });
        }
      });
  }

  @override
  void dispose() {
    _dragController.dispose();
    super.dispose();
  }

  void _generateNewObjective() {
    // Create a solved puzzle as the starting point
    objectiveGrid = [
      [1, 2, 3],
      [4, 5, 6],
      [7, 8, 0], // 0 represents the empty tile
    ];

    // Shuffle the objective grid with a different pattern each time
    int emptyObjRow = 2;
    int emptyObjCol = 2;

    // Make enough random moves to create a valid but challenging objective
    // Using fewer moves than the main puzzle shuffle to keep it reasonable
    int moves = _random.nextInt(20) + 15; // Between 15-35 moves

    for (int i = 0; i < moves; i++) {
      List<List<int>> possibleMoves = [];

      // Check all adjacent tiles to the empty space
      if (emptyObjRow > 0) possibleMoves.add([emptyObjRow - 1, emptyObjCol]);
      if (emptyObjRow < 2) possibleMoves.add([emptyObjRow + 1, emptyObjCol]);
      if (emptyObjCol > 0) possibleMoves.add([emptyObjRow, emptyObjCol - 1]);
      if (emptyObjCol < 2) possibleMoves.add([emptyObjRow, emptyObjCol + 1]);

      // Pick a random move and apply it
      final move = possibleMoves[_random.nextInt(possibleMoves.length)];

      // Swap the tile with the empty space
      objectiveGrid[emptyObjRow][emptyObjCol] = objectiveGrid[move[0]][move[1]];
      objectiveGrid[move[0]][move[1]] = 0;

      // Update empty space position
      emptyObjRow = move[0];
      emptyObjCol = move[1];
    }
  }

  void _initializePuzzle() {
    // Initialize the playable grid to match the objective (starting solved)
    puzzleGrid = List.generate(3, (i) => List.generate(3, (j) => objectiveGrid[i][j]));

    // Find the empty tile position
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (puzzleGrid[i][j] == 0) {
          emptyRow = i;
          emptyCol = j;
          break;
        }
      }
    }
    hasWon = true; // Start as "solved" so we can shuffle right away
  }

  bool _canMoveTile(int row, int col) {
    // A tile can move if it's adjacent to the empty space
    return (row == emptyRow && (col == emptyCol - 1 || col == emptyCol + 1)) ||
        (col == emptyCol && (row == emptyRow - 1 || row == emptyRow + 1));
  }

  void _moveTile(int row, int col) {
    if (_canMoveTile(row, col)) {
      setState(() {
        // Swap the tapped tile with the empty space
        puzzleGrid[emptyRow][emptyCol] = puzzleGrid[row][col];
        puzzleGrid[row][col] = 0;

        // Update empty space position
        emptyRow = row;
        emptyCol = col;

        // Check for victory
        _checkVictory();
      });
    }
  }

  void _startDrag(int row, int col) {
    if (_canMoveTile(row, col) && !_isDragging) {
      setState(() {
        _isDragging = true;
        _draggedTileRow = row;
        _draggedTileCol = col;
      });
    }
  }

  void _updateDrag(Offset delta) {
    if (_isDragging && _draggedTileRow != null && _draggedTileCol != null) {
      // Calculate which direction we're dragging (horizontal or vertical)
      bool isHorizontalDrag = _draggedTileRow == emptyRow;
      bool isVerticalDrag = _draggedTileCol == emptyCol;

      // Constrain drag to the correct axis
      double dx = isHorizontalDrag ? delta.dx : 0;
      double dy = isVerticalDrag ? delta.dy : 0;

      // Further constrain direction based on position of empty tile
      if (isHorizontalDrag) {
        // If empty is to the right, can only drag right (positive dx)
        if (emptyCol > _draggedTileCol! && dx < 0) dx = 0;
        // If empty is to the left, can only drag left (negative dx)
        if (emptyCol < _draggedTileCol! && dx > 0) dx = 0;
        // Limit the drag distance
        dx = dx.clamp(-84.0, 84.0);
      }

      if (isVerticalDrag) {
        // If empty is below, can only drag down (positive dy)
        if (emptyRow > _draggedTileRow! && dy < 0) dy = 0;
        // If empty is above, can only drag up (negative dy)
        if (emptyRow < _draggedTileRow! && dy > 0) dy = 0;
        // Limit the drag distance
        dy = dy.clamp(-84.0, 84.0);
      }

      setState(() {
        _dragOffset = Offset(dx, dy);
      });
    }
  }

  void _endDrag() {
    if (_isDragging && _draggedTileRow != null && _draggedTileCol != null) {
      bool shouldMove = false;

      // Determine if the drag was significant enough to trigger a move
      // For horizontal drags
      if (_draggedTileRow == emptyRow) {
        if ((_draggedTileCol! < emptyCol && _dragOffset.dx > 30) || // Dragging right
            (_draggedTileCol! > emptyCol && _dragOffset.dx < -30)) { // Dragging left
          shouldMove = true;
        }
      }
      // For vertical drags
      if (_draggedTileCol == emptyCol) {
        if ((_draggedTileRow! < emptyRow && _dragOffset.dy > 30) || // Dragging down
            (_draggedTileRow! > emptyRow && _dragOffset.dy < -30)) { // Dragging up
          shouldMove = true;
        }
      }

      if (shouldMove) {
        // Animate the completion of the drag
        _dragController.forward(from: 0).then((_) {
          _moveTile(_draggedTileRow!, _draggedTileCol!);
          _dragController.reset();
        });
      } else {
        // Reset drag if not moved enough
        setState(() {
          _isDragging = false;
          _dragOffset = Offset.zero;
          _draggedTileRow = null;
          _draggedTileCol = null;
        });
      }
    }
  }

  void _checkVictory() {
    // Compare current grid with objective grid
    bool isVictory = true;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (puzzleGrid[i][j] != objectiveGrid[i][j]) {
          isVictory = false;
          break;
        }
      }
      if (!isVictory) break;
    }

    if (isVictory && !hasWon) {
      hasWon = true;
      // Show victory toast
      _showVictoryMessage();
    }
  }

  void _showVictoryMessage() {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber),
            const SizedBox(width: 10),
            const Text(
              'Congratulations! Puzzle Solved!',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'New Game',
          textColor: Colors.white,
          onPressed: () {
            _newGame();
            scaffold.hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _newGame() {
    setState(() {
      // Generate a new objective first
      _generateNewObjective();
      // Then initialize the puzzle grid based on the new objective
      _initializePuzzle();
      // Then shuffle to start the game
      _shufflePuzzle();
    });
  }

  void _shufflePuzzle() {
    // Shuffle the puzzle by making random valid moves
    setState(() {
      hasWon = false;

      // Make random valid moves
      for (int i = 0; i < 100; i++) { // Make 100 random moves
        List<List<int>> possibleMoves = [];

        // Check all adjacent tiles to the empty space
        if (emptyRow > 0) possibleMoves.add([emptyRow - 1, emptyCol]);
        if (emptyRow < 2) possibleMoves.add([emptyRow + 1, emptyCol]);
        if (emptyCol > 0) possibleMoves.add([emptyRow, emptyCol - 1]);
        if (emptyCol < 2) possibleMoves.add([emptyRow, emptyCol + 1]);

        // Pick a random move and apply it
        final move = possibleMoves[_random.nextInt(possibleMoves.length)];

        // Swap the tile with the empty space (without calling setState or checking victory)
        puzzleGrid[emptyRow][emptyCol] = puzzleGrid[move[0]][move[1]];
        puzzleGrid[move[0]][move[1]] = 0;

        // Update empty space position
        emptyRow = move[0];
        emptyCol = move[1];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Puzzle Game', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange[500],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _newGame,
            tooltip: 'New Game',
          ),
          IconButton(
            icon: const Icon(Icons.shuffle, color: Colors.white),
            onPressed: _shufflePuzzle,
            tooltip: 'Shuffle Current Puzzle',
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
                // Objective section
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Objective',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.lightbulb_outline, color: Colors.amber),
                          onPressed: () {
                            // Show a hint dialog
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Hint"),
                                  content: const Text("Arrange the tiles in the bottom grid to match the pattern shown in the top grid. You can drag tiles to move them."),
                                  actions: [
                                    TextButton(
                                      child: const Text("Got it!"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          tooltip: 'Get a hint',
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
                              // Display objective grid
                              for (int i = 0; i < 3; i++)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    for (int j = 0; j < 3; j++)
                                      objectiveGrid[i][j] == 0
                                          ? Container(height: 54, width: 54)
                                          : _buildTile(objectiveGrid[i][j].toString(), small: true,
                                              color: _getTileColor(objectiveGrid[i][j].toString())),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Playable puzzle grid (larger one)
                Column(
                  children: [
                    const Text(
                      'Play Here',
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
                            color: hasWon ? Colors.green : Colors.black26,
                            width: hasWon ? 3 : 1),
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
                              // Build dynamic puzzle grid from state
                              for (int i = 0; i < 3; i++)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    for (int j = 0; j < 3; j++)
                                      puzzleGrid[i][j] == 0
                                          ? Container(width: 80, height: 80)
                                          : _buildDraggableTile(puzzleGrid[i][j].toString(), i, j),
                                  ],
                                ),
                            ],
                          ),
                          if (hasWon)
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

  // Get tile color based on number
  Color _getTileColor(String number) {
    final Map<String, Color> colorMap = {
      '1': Colors.blue,
      '2': Colors.amber,
      '3': Colors.red,
      '4': Colors.green,
      '5': Colors.purple,
      '6': Colors.orange,
      '7': Colors.cyan,
      '8': Colors.teal,
    };
    return colorMap[number] ?? Colors.grey;
  }

  // Interactive tile with drag gesture detection
  Widget _buildDraggableTile(String number, int row, int col) {
    Color tileColor = _getTileColor(number);
    bool isMovable = _canMoveTile(row, col);
    bool isCurrentlyDragged = _isDragging && row == _draggedTileRow && col == _draggedTileCol;

    // Calculate offset for current dragged tile
    Offset tileOffset = isCurrentlyDragged ? _dragOffset : Offset.zero;

    return GestureDetector(
      onTap: () => _moveTile(row, col),
      onPanStart: (_) => _startDrag(row, col),
      onPanUpdate: (details) => _updateDrag(details.delta),
      onPanEnd: (_) => _endDrag(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(tileOffset.dx, tileOffset.dy, 0),
        width: 80,
        height: 80,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          border: Border.all(
            color: isMovable
                ? tileColor.withOpacity(1.0)
                : tileColor.withOpacity(0.8),
            width: isMovable ? 2.5 : 1.5,
          ),
          borderRadius: BorderRadius.circular(10),
          color: tileColor.withOpacity(0.5),
          boxShadow: isMovable || isCurrentlyDragged
              ? [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: isCurrentlyDragged ? 8 : 5,
                    offset: isCurrentlyDragged
                        ? const Offset(2, 3)
                        : const Offset(1, 2),
                  )
                ]
              : null,
        ),
        child: Center(
          child: Text(
            number,
            style: TextStyle(
              fontSize: 30,
              color: Colors.black54,
              fontWeight: isMovable ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  // Static tile (for the small objective preview)
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
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(small ? 6 : 10),
        color: small ? Colors.white : color.withOpacity(0.5),
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
