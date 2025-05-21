import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(const TangoApp());

class TangoApp extends StatelessWidget {
  const TangoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '☀️🌙 Tango Puzzle',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.transparent,
        textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.black)),
        fontFamily: 'Roboto',
      ),
      home: const TangoGame(),
    );
  }
}

class TangoGame extends StatefulWidget {
  const TangoGame({super.key});

  @override
  State<TangoGame> createState() => _TangoGameState();
}

class _TangoGameState extends State<TangoGame> {
  static const int gridSize = 6;
  static const String sun = '☀️';
  static const String moon = '🌙';

  List<List<String>> board =
      List.generate(gridSize, (_) => List.generate(gridSize, (_) => ''));
  List<List<bool>> fixed =
      List.generate(gridSize, (_) => List.generate(gridSize, (_) => false));
  List<List<String>> solution =
      List.generate(gridSize, (_) => List.generate(gridSize, (_) => ''));

  List<List<String>> copyBoard(List<List<String>> original) {
    return original.map((row) => List<String>.from(row)).toList();
  }

  List<List<List<String>>> history = [];

  @override
  void initState() {
    super.initState();
    generatePuzzle();
  }

  void toggleCell(int row, int col) {
    if (fixed[row][col]) return;
    setState(() {
      history.add(copyBoard(board));
      if (board[row][col] == '') {
        board[row][col] = sun;
      } else if (board[row][col] == sun) {
        board[row][col] = moon;
      } else {
        board[row][col] = '';
      }
    });
  }

  void clearCell(int row, int col) {
    if (fixed[row][col]) return;
    setState(() {
      history.add(copyBoard(board));
      board[row][col] = '';
    });
  }

  void undo() {
    setState(() {
      if (history.isNotEmpty) {
        board = history.removeLast();
      }
    });
  }

  void clearBoard() {
    setState(() {
      for (int i = 0; i < gridSize; i++) {
        for (int j = 0; j < gridSize; j++) {
          if (!fixed[i][j]) {
            board[i][j] = '';
          }
        }
      }
      history.clear();
    });
  }

  void hint() {
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (!fixed[i][j] && board[i][j] != solution[i][j]) {
          setState(() {
            history.add(copyBoard(board));
            board[i][j] = solution[i][j];
          });
          return;
        }
      }
    }
  }

  bool isValidBoard(List<List<String>> board) {
    for (int i = 0; i < gridSize; i++) {
      int sunCountRow = 0, moonCountRow = 0;
      int sunCountCol = 0, moonCountCol = 0;

      for (int j = 0; j < gridSize; j++) {
        if (board[i][j] == sun) sunCountRow++;
        if (board[i][j] == moon) moonCountRow++;

        if (board[j][i] == sun) sunCountCol++;
        if (board[j][i] == moon) moonCountCol++;

        if (j >= 2) {
          if (board[i][j] == board[i][j - 1] &&
              board[i][j] == board[i][j - 2] &&
              board[i][j] != '') {
            return false;
          }
          if (board[j][i] == board[j - 1][i] &&
              board[j][i] == board[j - 2][i] &&
              board[j][i] != '') {
            return false;
          }
        }
      }

      if (sunCountRow > gridSize ~/ 2 || moonCountRow > gridSize ~/ 2) return false;
      if (sunCountCol > gridSize ~/ 2 || moonCountCol > gridSize ~/ 2) return false;
    }
    return true;
  }

  void generatePuzzle() {
    setState(() {
      board = List.generate(gridSize, (_) => List.generate(gridSize, (_) => ''));
      fixed = List.generate(gridSize, (_) => List.generate(gridSize, (_) => false));
      solution = List.generate(gridSize, (_) => List.generate(gridSize, (_) => ''));
      history.clear();

      final random = Random();
      do {
        for (int i = 0; i < gridSize; i++) {
          for (int j = 0; j < gridSize; j++) {
            solution[i][j] = random.nextBool() ? sun : moon;
          }
        }
      } while (!isValidBoard(solution));

      int prefilled = 0;
      while (prefilled < 8) {
        int r = random.nextInt(gridSize);
        int c = random.nextInt(gridSize);
        if (!fixed[r][c]) {
          board[r][c] = solution[r][c];
          fixed[r][c] = true;
          prefilled++;
        }
      }
    });
  }

  void checkSolution() {
    bool solved = true;
    outer:
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (board[i][j] != solution[i][j]) {
          solved = false;
          break outer;
        }
      }
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: solved ? Colors.green[50] : Colors.red[50],
        title: Text(
          solved ? "✅ Correct!" : "❌ Not Yet",
          style: TextStyle(
            color: solved ? Colors.green[800] : Colors.red[800],
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          solved
              ? "Great job! You've solved the puzzle."
              : "Some cells are incorrect or missing.",
          style: TextStyle(
            color: solved ? Colors.green[700] : Colors.red[700],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  Widget buildCell(int row, int col) {
    Color? textColor;
    if (!fixed[row][col] && board[row][col] != '' && board[row][col] != solution[row][col]) {
      textColor = Colors.red;
    } else if (board[row][col] == moon) {
      textColor = Colors.blue[700];
    } else if (board[row][col] == sun) {
      textColor = Colors.orange[800];
    } else {
      textColor = Colors.black87;
    }

    return GestureDetector(
      onTap: () => toggleCell(row, col),
      onLongPress: () => clearCell(row, col),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: fixed[row][col] ? Colors.grey[300] : Colors.white,
          border: Border.all(color: Colors.black26),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          board[row][col],
          style: TextStyle(fontSize: 30, color: textColor),
        ),
      ),
    );
  }

  Widget buildGrid() {
    return Column(
      children: List.generate(gridSize, (row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(gridSize, (col) {
            return Padding(
              padding: const EdgeInsets.all(5.0),
              child: SizedBox(width: 52, height: 52, child: buildCell(row, col)),
            );
          }),
        );
      }),
    );
  }

  Widget buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color backgroundColor,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.black87),
      label: Text(label, style: const TextStyle(color: Colors.black87)),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xffFDF6EC), Color(0xffFAEEE0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.deepOrangeAccent,
          elevation: 4,
          title: const Text(
            '☀️🌙 Tango Puzzle',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              buildGrid(),
              const Spacer(),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
                  buildActionButton(
                    onPressed: undo,
                    icon: Icons.undo,
                    label: 'Undo',
                    backgroundColor: Colors.grey.shade300,
                  ),
                  buildActionButton(
                    onPressed: hint,
                    icon: Icons.school,
                    label: 'Teach me',
                    backgroundColor: Colors.lightBlue.shade100,
                  ),
                  buildActionButton(
                    onPressed: generatePuzzle,
                    icon: Icons.autorenew,
                    label: 'New Game',
                    backgroundColor: Colors.green.shade200,
                  ),
                  buildActionButton(
                    onPressed: clearBoard,
                    icon: Icons.clear,
                    label: 'Clear',
                    backgroundColor: Colors.red.shade200,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: checkSolution,
                  icon: const Icon(Icons.check_circle_outline, color: Colors.black87),
                  label: const Text('Check Solution', style: TextStyle(color: Colors.black87)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade200,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
