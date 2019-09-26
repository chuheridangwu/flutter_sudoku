import 'package:flutter/cupertino.dart';
import 'package:scoped_model/scoped_model.dart';

class GameModel extends Model {
  List<List> dataSource = []; // 九宫格数组
  List<int> items = [];
  GameModel() {
    for (var i = 1; i < 10; i++) {
      List a = [];
      for (var j = 1; j < 10; j++) {
        a.add(j);
      }
      items.add(i);
      dataSource.add(a);
    }
  }

  static GameModel of(BuildContext context){
    return  ScopedModel.of<GameModel>(context);
  }
}
