import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:scoped_model/scoped_model.dart';

class GameModel extends Model {
  List<List> dataSource = []; // 九宫格数组
  List<OperateModel> operates = []; //九宫格按钮的操作
  int selectedOperateItem = 0; // 选中的操作符

  int _level = 2; // 难度等级 显示的间隔量级，可表示难易程度，值越大越不能保证唯一性

  GameModel() {
    _initData();
  }

  static GameModel of(BuildContext context) {
    return ScopedModel.of<GameModel>(context);
  }

  void _initData() {
    List randomAry = [];

    for (var i = 1; i < 10; i++) {
      // 创建9个按钮
      OperateModel model = OperateModel();
      model.item = i;
      operates.add(model);

      // 创建随机数组[1~9]
      int random = _creatRandomTitle(randomAry);
      randomAry.add(random);

      // 生成单元格  行 列  数组
      List itemList = [];
      List rowList = [];
      List lowList = [];
      items.add(itemList);
      rows.add(rowList);
      lows.add(lowList);
    }

    _excisionItemAry(randomAry);
  }

  // 将原生数组生成单元格数组
  List<List> items = [];
  List<List> rows = [];
  List<List> lows = [];
  void _excisionItemAry(List randomAry) {
    for (var j = 0; j < rps.length; j++) {
      int row = j ~/ 9;
      int low = j % 9;
      bool row1 = row == 0 || row == 1 || row == 2;
      bool row2 = row == 3 || row == 4 || row == 5;
      bool row3 = row == 6 || row == 7 || row == 8;
      bool low1 = low == 0 || low == 1 || low == 2;
      bool low2 = low == 3 || low == 4 || low == 5;
      bool low3 = low == 6 || low == 7 || low == 8;

      int title = _changeTitleWithAry(randomAry, rps[j]);

      // 随机隐藏个数,计算每个数现有多少个
      if (Random().nextInt(_level) != 1) {
        title = 0;
      } else {
        OperateModel model = operates[title - 1];
        if (model.item == title) {
          model.hideCount -= 1;
        }
      }

      rows[row].add(title);
      lows[low].add(title);

      if (row1 && low1) {
        // item1
        items[0].add(title);
      } else if (row1 && low2) {
        // item2
        items[1].add(title);
      } else if (row1 && low3) {
        // item3
        items[2].add(title);
      } else if (row2 && low1) {
        // item4
        items[3].add(title);
      } else if (row2 && low2) {
        // item5
        items[4].add(title);
      } else if (row2 && low3) {
        // item6
        items[5].add(title);
      } else if (row3 && low1) {
        // item7
        items[6].add(title);
      } else if (row3 && low2) {
        // item8
        items[7].add(title);
      } else if (row3 && low3) {
        // item9
        items[8].add(title);
      }
    }
  }

  // 递归生成 0~9 的随机数
  int _creatRandomTitle(List ary) {
    int random = Random().nextInt(10);
    if (ary.contains(random) || random == 0) {
      return _creatRandomTitle(ary);
    }
    return random;
  }

  void changeSelcted() {
    for (var opera in operates) {
      opera.isSelected = opera.item == selectedOperateItem ? true : false;
    }
    notifyListeners();
  }

  //能够生���362880个不同的随机矩阵 (9的阶乘), (这里应该只是换顺序)
  int _changeTitleWithAry(List tempAry, int title) {
    List data = List.castFrom(tempAry);
    int randomTitle = 0;
    for (var i = 0; i < tempAry.length; i++) {
      if (tempAry[i] == title) {
        if (i == tempAry.length - 1) {
          randomTitle = data[0];
        } else {
          randomTitle = data[i + 1];
        }
      } else {
        continue;
      }
    }
    return randomTitle;
  }

  List rps = [
    5,
    7,
    4,
    1,
    8,
    2,
    3,
    9,
    6,
    3,
    1,
    8,
    4,
    9,
    6,
    5,
    7,
    2,
    9,
    6,
    2,
    7,
    5,
    3,
    8,
    4,
    1,
    6,
    2,
    9,
    5,
    1,
    8,
    4,
    3,
    7,
    7,
    3,
    1,
    9,
    2,
    4,
    6,
    8,
    5,
    8,
    4,
    5,
    3,
    6,
    7,
    1,
    2,
    9,
    1,
    5,
    7,
    8,
    3,
    9,
    2,
    6,
    4,
    4,
    8,
    6,
    2,
    7,
    1,
    9,
    5,
    3,
    2,
    9,
    3,
    6,
    4,
    5,
    7,
    1,
    8
  ];
}

class OperateModel {
  int item = 0;
  int hideCount = 9;
  bool isSelected = false;
}
