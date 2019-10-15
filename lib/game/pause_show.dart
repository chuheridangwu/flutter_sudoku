import 'package:flutter/material.dart';

class PauseShowView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List _lists = [
      PauseModel('下一关', () {
        Navigator.of(context).popAndPushNamed('/home');
      }),
      PauseModel('选关', () {
        Navigator.of(context).popAndPushNamed('level');
      }),
      PauseModel('返回', () {
        Navigator.of(context).pop();
      }),
    ];
    return Material(
      color: Colors.transparent,
      child:  Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _lists.map((item) {
          return Column(
            children: <Widget>[
              Container(
                width: 180,
                height: 40,
                decoration: BoxDecoration(
                    boxShadow: [BoxShadow(offset: Offset(0, 2))],
                    borderRadius: BorderRadius.all(Radius.circular(5))),
                child: FlatButton(
                  child: Text(
                    '${item.name}',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  onPressed: item.callback,
                ),
              ),
              SizedBox(
                height: 12,
              )
            ],
          );
        }).toList(),
      ),
    );
  }
}

class PauseModel {
  String name;
  VoidCallback callback;
  PauseModel(this.name, this.callback);
}
