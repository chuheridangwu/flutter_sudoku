import 'package:flutter/material.dart';
import 'package:flutter_sudoku/game/level_view.dart';
import './game/game_view.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: 'level',
      routes: {
        '/home': (context) => GameViewPage(),
        'level': (context) => LevelView(),
      },
    );
  }
}


