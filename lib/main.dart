import 'package:flutter/material.dart';
import 'snake_gui.dart';

void main() {
  runApp(const Snake());
}

class Snake extends StatelessWidget {
  const Snake({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: SnakeGUI(),
      ),
    );
  }
}
