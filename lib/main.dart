import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(const TangoApp());

class TangoApp extends StatelessWidget {
  const TangoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tango Game',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.black)),
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
        title: Text(solved ? "✅ Correct!" : "❌ Not Yet"),
        content: Text(solved
            ? "Great job! You've solved the puzzle."
            : "Some cells are incorrect or missing."),
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
      textColor = Colors.blue;
    } else {
      textColor = Colors.black;
    }

    return GestureDetector(
      onTap: () => toggleCell(row, col),
      onLongPress: () => clearCell(row, col),
      child: Container(
        decoration: BoxDecoration(
          color: fixed[row][col] ? Colors.grey[200] : Colors.white,
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 3,
              offset: Offset(1, 1),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          board[row][col],
          style: TextStyle(fontSize: 28, color: textColor),
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
              padding: const EdgeInsets.all(4.0),
              child: SizedBox(width: 48, height: 48, child: buildCell(row, col)),
            );
          }),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Tango Game', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            buildGrid(),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: undo,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200]),
                  child: const Text('Undo', style: TextStyle(color: Colors.black)),
                ),
                ElevatedButton(
                  onPressed: hint,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[100]),
                  child: const Text('Teach me', style: TextStyle(color: Colors.black)),
                ),
                ElevatedButton(
                  onPressed: generatePuzzle,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green[100]),
                  child: const Text('New Game', style: TextStyle(color: Colors.black)),
                ),
                ElevatedButton(
                  onPressed: clearBoard,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red[100]),
                  child: const Text('Clear', style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: checkSolution,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple[100]),
              child: const Text('Check', style: TextStyle(color: Colors.black)),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
