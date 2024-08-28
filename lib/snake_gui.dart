import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:snake/constant.dart';
import 'package:snake/profile_data.dart';
import 'package:snake/sqlite_services.dart';
import 'package:flutter/services.dart';

class SnakeGUI extends StatefulWidget {
  SnakeGUI({required this.profileInfo});
  final ProfileInfo profileInfo;
  @override
  State<SnakeGUI> createState() => _SnakeGUIState();
}

enum Direction {
  up,
  down,
  left,
  right;
}

List<int> snake = [];
int food = 350;
String gameOverMsg = '';
bool canPopNow = false;
int isTwoTimeBack = 1;

class _SnakeGUIState extends State<SnakeGUI> {
  Direction d = Direction.right;
  int score = 0;
  var highScore;
  var prefs;

  @override
  void initState() {
    setAndGetHignScore();
    getHighScore();
    startGame();
    super.initState();
  }

  startGame() {
    d = Direction.right;
    snake = [400, 401, 402, 403];
    score = 0;

    Timer.periodic(Duration(milliseconds: 300), (timer) {
      if (!gameOver()) {
        setDirection();
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  bool gameOver() {
    for (int i = 0; i < snake.length - 1; i++) {
      if (snake.last == snake[i]) {
        HapticFeedback.heavyImpact();
        setAndGetHignScore();
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Game Over'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(gameOverMsg),
                    Text(
                      'Score: $score',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                backgroundColor: Color(0xFFE8F6EF),
                actions: [
                  TextButton(
                    onPressed: () {
                      startGame();
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Restart',
                      style: TextStyle(color: kFoodColor),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        canPopNow = true;
                      });
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Go to profiles',
                      style: TextStyle(color: kFoodColor),
                    ),
                  )
                ],
              );
            });
        return true;
      }
    }
    return false;
  }

  updatePosition(int updateValue) {
    setState(() {
      snake.add(snake.last + updateValue);
      if (snake.last == food) {
        HapticFeedback.mediumImpact();
        food = Random().nextInt(819);
        score++;
        return;
      }
      snake.removeAt(0);
    });
  }

  setDirection() {
    switch (d) {
      case Direction.up:
        updatePosition(20);
        if (snake.last > 819) updatePosition(-820);
        break;
      case Direction.down:
        updatePosition(-20);
        if (snake.last < 0) updatePosition(820);
        break;
      case Direction.left:
        if (snake.last % 20 == 0)
          updatePosition(19);
        else
          updatePosition(-1);
        break;
      case Direction.right:
        if ((snake.last + 1) % 20 == 0)
          updatePosition(-19);
        else
          updatePosition(1);
        break;
    }
  }

  horizontalUpdate(DragEndDetails details) {
    if (details.primaryVelocity! > 0)
      d = Direction.right;
    else
      d = Direction.left;
  }

  verticalUpdate(DragEndDetails details) {
    if (details.primaryVelocity! > 0)
      d = Direction.up;
    else
      d = Direction.down;
  }

  _listenKeyboard(RawKeyEvent event) {
    var e = event.logicalKey;
    if (e == LogicalKeyboardKey.arrowDown) d = Direction.up;
    if (e == LogicalKeyboardKey.arrowUp) d = Direction.down;
    if (e == LogicalKeyboardKey.arrowLeft) d = Direction.left;
    if (e == LogicalKeyboardKey.arrowRight) d = Direction.right;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PopScope(
        canPop: canPopNow,
        onPopInvoked: onPopInvoked,
        child: SafeArea(
          child: Stack(
            alignment: AlignmentDirectional.bottomEnd,
            children: [
              Center(
                child: RawKeyboardListener(
                  focusNode: FocusNode(),
                  onKey: _listenKeyboard,
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
                          horizontalUpdate(details),
                      onVerticalDragEnd: (details) => verticalUpdate(details),
                      child: GridView.count(
                        crossAxisCount: 20,
                        physics: NeverScrollableScrollPhysics(),
                        children: List.generate(
                          820,
                          (index) => ListElement(
                            index: index,
                            // selectedIndex: selectedIndex,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 30.0, bottom: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Your Score: $score',
                      style: TextStyle(
                          fontSize: 30.0, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'high Score: $highScore',
                      style: TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onPopInvoked(bool didPop) {
    isTwoTimeBack--;
    if (isTwoTimeBack == 0) {
      setState(() {
        canPopNow = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Press Back Button Again to Exit')));
    }
  }

  getHighScore() async {
    highScore = widget.profileInfo.highScore;
  }

  setAndGetHignScore() {
    if (highScore == null || highScore < score) {
      SqliteService().changeScore(widget.profileInfo.id, score);
      gameOverMsg = 'hurray new high score!!!';
    }
    setState(() {});
  }
}

class ListElement extends StatelessWidget {
  ListElement({super.key, required this.index});
  int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(0.3),
      decoration: BoxDecoration(
          color: snake.contains(index)
              ? (snake.last == index ? kSnakeColor : kSecondaryColor) //
              : index == food
                  ? kFoodColor
                  : Color(0xFFE8F6EF),
          // border:
          borderRadius: BorderRadius.circular(7.0)),
    );
  }
}
