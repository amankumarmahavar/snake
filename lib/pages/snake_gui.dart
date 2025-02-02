import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:snake/constant.dart';
import 'package:snake/model/profile_data.dart';
import 'package:snake/pages/profile_page.dart';
import 'package:snake/services/sqlite_services.dart';

class SnakeGUI extends StatefulWidget {
  final ProfileData profileInfo;

  const SnakeGUI({super.key, required this.profileInfo});

  @override
  State<SnakeGUI> createState() => _SnakeGUIState();
}

enum Direction { up, down, left, right }

class _SnakeGUIState extends State<SnakeGUI> {
  late List<int> snake;
  int food = Random().nextInt(820);
  late int highScore;
  int score = 0;

  String gameOverMsg = '';
  Direction currentDirection = Direction.right;
  Timer? gameTimer;
  bool isExiting = false;

  @override
  void initState() {
    super.initState();
    highScore = widget.profileInfo.highScore;
    startGame();
  }

  void startGame() {
    currentDirection = Direction.right;
    score = 0;
    snake = generateRandomStartPosition();
    food = Random().nextInt(820);
    gameTimer?.cancel();

    gameTimer = Timer.periodic(const Duration(milliseconds: 300)  , (timer) {
      if (mounted) {
        if (snake.sublist(0, snake.length - 1).contains(snake.last)) {
          timer.cancel();
          showGameOverDialog();
        } else {
          updateSnakePosition();
        }
      }
    });
  }

  List<int> generateRandomStartPosition() {
    int start = Random().nextInt(820 - 4);
    return List.generate(4, (index) => start + index);
  }

  void updateSnakePosition() {
    setState(() {
      int nextPosition = getNextPosition(snake.last);
      if (nextPosition == food) {
        HapticFeedback.mediumImpact();
        food = Random().nextInt(820);
        score++;
      } else {
        snake.removeAt(0);
      }
      snake.add(nextPosition);
    });
  }

  int getNextPosition(int current) {
    switch (currentDirection) {
      case Direction.up:
        return (current - 20) < 0 ? current + 800 : current - 20;
      case Direction.down:
        return (current + 20) >= 820 ? current - 800 : current + 20;
      case Direction.left:
        return current % 20 == 0 ? current + 19 : current - 1;
      case Direction.right:
        return (current + 1) % 20 == 0 ? current - 19 : current + 1;
    }
  }

  void showGameOverDialog() {
    HapticFeedback.heavyImpact();
    updateHighScore();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Game Over'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(gameOverMsg),
            Text('Score: $score',
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              startGame();
            },
            child: const Text('Restart', style: TextStyle(color: kFoodColor)),
          ),
          TextButton(
            onPressed: () {
              Navigator.popUntil(context, (route) => false);
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const ProfilePage()));
            },
            child: const Text('Go to Profiles',
                style: TextStyle(color: kFoodColor)),
          ),
        ],
      ),
    );
  }

  void updateHighScore() {
    if (score > highScore) {
      highScore = score;
      gameOverMsg = 'Hurray! New High Score!';
      SqliteService().changeScore(widget.profileInfo.id, score);
    } else {
      gameOverMsg = 'Try Again!';
    }
  }

  // void handleSwipe(DragEndDetails details) {
  //   if (details.primaryVelocity != null) {
  //     if (details.primaryVelocity! > 0) {
  //       currentDirection = details. == Axis.horizontal ? Direction.right : Direction.down;
  //     } else {
  //       currentDirection = details.axis == Axis.horizontal ? Direction.left : Direction.up;
  //     }
  //   }
  // }
  _horizontalUpdate(DragEndDetails details) {
    if (details.primaryVelocity! > 0)
      currentDirection = Direction.right;
    else
      currentDirection = Direction.left;
  }

  _verticalUpdate(DragEndDetails details) {
    if (details.primaryVelocity! > 0)
      currentDirection = Direction.down;
    else
      currentDirection = Direction.up;
  }

  void handleKeyboardInput(RawKeyEvent event) {
    var e = event.logicalKey;
    if (e == LogicalKeyboardKey.arrowDown) currentDirection = Direction.down;
    if (e == LogicalKeyboardKey.arrowUp) currentDirection = Direction.up;
    if (e == LogicalKeyboardKey.arrowLeft) currentDirection = Direction.left;
    if (e == LogicalKeyboardKey.arrowRight) currentDirection = Direction.right;
  }

  Future<bool> handleBackButton() async {
    if (isExiting) {
      return true;
    } else {
      isExiting = true;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Press back again to exit')),
      );
      await Future.delayed(const Duration(seconds: 2));
      isExiting = false;
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: handleBackButton,
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            alignment: AlignmentDirectional.bottomEnd,
            children: [
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.height / 1.9,
                  decoration: BoxDecoration(
                    border: Border.all(width: 3.0),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  margin: EdgeInsets.all(10.0),
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onHorizontalDragEnd: (details) =>
                        _horizontalUpdate(details),
                    onVerticalDragEnd: (details) => _verticalUpdate(details),
                    child: GridView.count(
                      crossAxisCount: 20,
                      physics: NeverScrollableScrollPhysics(),
                      children: List.generate(
                        820,
                        (index) => ListElement(
                          index: index,
                          snake: snake,
                          food: food,
                          // selectedIndex: selectedIndex,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 30.0,
                bottom: 20.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Your Score: $score',
                        style: const TextStyle(
                            fontSize: 30.0, fontWeight: FontWeight.bold)),
                    Text('High Score: $highScore',
                        style: const TextStyle(fontSize: 18.0)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }
}

class ListElement extends StatelessWidget {
  const ListElement(
      {super.key,
      required this.index,
      required this.snake,
      required this.food});
  final int index;
  final List<int> snake;
  final int food;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(0.3),
      decoration: BoxDecoration(
        color: snake.contains(index)
            ? (snake.last == index ? kSnakeColor : kSecondaryColor)
            : index == food
                ? kFoodColor
                : const Color(0xFFE8F6EF),
        borderRadius: BorderRadius.circular(7.0),
      ),
    );
  }
}
