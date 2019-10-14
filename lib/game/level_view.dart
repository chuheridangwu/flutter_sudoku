import 'dart:ffi';

import 'package:flutter/material.dart';

class LevelView extends StatelessWidget {
  final List _levels = [
    LevelModel('混沌', 2),
    LevelModel('开天', 2),
    LevelModel('入道', 3),
    LevelModel('渡劫', 4),
    LevelModel('飞升', 5)
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
            image: ExactAssetImage('assets/images/level_bg.png')),
      ),
      child: Scaffold(
        body: SafeArea(
            child: Stack(
          children: <Widget>[
            Positioned(
              left: 0.0,
              right: 0.0,
              top: 80.0,
              child: Text(
                '趣味数独',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: _levels.map((item) {
                    return Column(
                      children: <Widget>[
                        Container(
                            width: 180,
                            height: 40,
                            decoration: BoxDecoration(
                                boxShadow: [BoxShadow(offset: Offset(2, 2))],
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                            child: FlatButton(
                              onPressed: () {
                                Navigator.of(context).pushNamed('/home');
                              },
                              child: Text(
                                '${item.name}',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                            )),
                        SizedBox(
                          height: 10,
                        )
                      ],
                    );
                  }).toList()),
            ),
          ],
        )),
      ),
    );
  }
}

class LevelModel {
  String name;
  int level;
  LevelModel(this.name, this.level);
}
