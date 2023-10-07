import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class SnakeGUI extends StatefulWidget {
  const SnakeGUI({super.key});

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

class _SnakeGUIState extends State<SnakeGUI> {
  Direction d = Direction.right;
  int score = 0;

  @override
  void initState() {
    startGame();
    super.initState();
  }

  bool gameOver() {
    for (int i = 0; i < snake.length - 1; i++) {
      if (snake.last == snake[i]) {
        HapticFeedback.heavyImpact();
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('GameOver'),
                actions: [
                  TextButton(
                      onPressed: () {
                        startGame();
                        Navigator.of(context).pop();
                      },
                      child: Text('Restart'))
                ],
              );
            });

        return true;
      }
    }
    return false;
  }

  startGame() {
    d = Direction.right;
    snake = [];
    score = 0;

    snake.add(400);
    snake.add(401);
    snake.add(402);
    snake.add(403);

    Timer.periodic(Duration(milliseconds: 300), (timer) {
      if (!gameOver()) {
        validityOfBorder();
      } else {
        timer.cancel();
      }
    });
  }

  // foodLogic() {}

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

  validityOfBorder() {
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Stack(
      alignment: AlignmentDirectional.bottomEnd,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(width: 3.0),
            borderRadius: BorderRadius.circular(10.0),
          ),
          margin: EdgeInsets.all(10.0),
          alignment: Alignment.center,
          child: GestureDetector(
            onHorizontalDragEnd: (details) => horizontalUpdate(details),
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
        Padding(
          padding: EdgeInsets.only(right: 20.0, bottom: 20.0),
          child: Text(
            'Score: $score',
            style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ));
  }
}

class ListElement extends StatelessWidget {
  ListElement({super.key, required this.index});
  int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(0.5),
      decoration: BoxDecoration(
          color: snake.contains(index)
              ? Colors.amberAccent
              : index == food
                  ? Colors.red.shade300
                  : Colors.white,
          // border: Border.all(),
          borderRadius: BorderRadius.circular(4.0)),
    );
  }
}
