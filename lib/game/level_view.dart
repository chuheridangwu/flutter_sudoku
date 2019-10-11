import 'package:flutter/material.dart';

class LevelView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            FlatButton(
              color: Colors.black,
              onPressed: () {
                Navigator.of(context).pushNamed('/home');
              },
              child: Text('开天'),
            ),
            FlatButton(
              color: Colors.yellow,
              onPressed: () {
                Navigator.of(context).popAndPushNamed('/home');
              },
              child: Text('入道'),
            ),
            FlatButton(
              color: Colors.red,
              onPressed: () {
                Navigator.of(context).popAndPushNamed('/home');
              },
              child: Text('渡劫'),
            ),
            FlatButton(
              onPressed: () {
                Navigator.of(context).popAndPushNamed('/home');
              },
              child: Text('飞升'),
            ),
          ],
        ),
        )
      ),
    );
  }
}
