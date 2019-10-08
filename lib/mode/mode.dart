import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:scoped_model/scoped_model.dart';

class GameModel extends Model {
  int _level = 2; // 难度等级 显示的间隔量级，可表示难易程度，值越大越不能保证唯一性
  VoidCallback snpTipBack;

  List<OperateModel> operates = []; //九宫格按钮的操作
  int selectedOperateItem = 0; // 选中的操作符

  List<Map> _removeItem1 = []; // 被移除的item
  List<Map> _removeItem2 = []; // 移除之后的item
  List<ItemModel> _dataSource = []; // 储存生成的九宫格数组
  bool isEdit = false; // 是否是编辑模式

  GameModel() {
    _initData();
  }

// 更换选中的操作按钮
  void changeSelctedOperateitem() {
    if (isEdit) {
      int row = _index ~/ 3; // 单元格内的 列
      int low = _index % 3; // 单元格内的 行

      int rowIndex = row + 3 * (_itemIndex ~/ 3); // 获取在九宫格内的行索引
      List rowAry = rows[rowIndex];

      int lowIndex = low + 3 * (_itemIndex % 3); // 获取在九宫格内的列索引
      List lowAry = lows[lowIndex];

      List itemAry = items[_itemIndex]; // 获取单元格的数组

      ItemModel _itemModel = itemAry[_index]; // 具体选择的单元格

      if (_isInclude(itemAry, rowAry, lowAry)) {
        snpTipBack();
      } else {
        _itemModel.item = selectedOperateItem;
        rowAry.add(_itemModel);
        itemAry.add(_itemModel);

        _removeItem1 = List.from(_removeItem2);
        ItemModel mapModel = ItemModel(_itemModel.item, _itemModel.isSelected);
        _removeItem1.add({_itemIndex: _index, "itemModel": mapModel});
        _removeItem2.add({_itemIndex: _index, "itemModel": mapModel});

        // 下面的item次数-1
        for (var operate in operates) {
          if (selectedOperateItem == operate.item) {
            operate.hideCount -= 1;
            // 如果一个item已经全部填写完了，选中的item则 == 0
            if (operate.hideCount == 0) {
              selectedOperateItem = 0;
            }
          }
        }
      }
    } else {
      // 对选中的item进行提示
      for (var opera in operates) {
        opera.isSelected = opera.item == selectedOperateItem ? true : false;
      }

      for (List itemList in items) {
        for (ItemModel aaa in itemList) {
          aaa.isSelected = false;
          if (aaa.item == selectedOperateItem) {
            aaa.isSelected = true;
          }
        }
      }
    }
    notifyListeners();
  }

  // 撤回
  void withdrawItem() {
    if (_removeItem2.length <= 0) {
      return;
    }
    Map map = _removeItem2.last;
    ItemModel model = items[map.keys.first][map.values.first];
    model.item = 0;
    items[map.keys.first]
        .replaceRange(map.values.first, map.values.first + 1, [model]);
    _removeItem2.removeLast();

    for (var operate in operates) {
      if (map["itemModel"].item == operate.item) {
        operate.hideCount += 1;
      }
    }
    notifyListeners();
  }

  // 回撤
  void withdrawalItem() {
    if (_removeItem1.length > _removeItem2.length) {
      Map map = _removeItem1[_removeItem2.length];
      ItemModel model1 = items[map.keys.first][map.values.first];
      ItemModel model2 = map["itemModel"];
      model1.item = model2.item;
      model1.isSelected = model2.isSelected;
      _removeItem2.add(map);

      for (var operate in operates) {
        if (model2.item == operate.item) {
          operate.hideCount -= 1;
        }
      }
      notifyListeners();
    }
  }

  int _itemIndex = 0;
  int _index = 0;

  // itemIndex: 单元格的索引   index: 单元格内索引
  void fillFromTable(int itemIndex, int index) {
    _itemIndex = itemIndex;
    _index = index;

    int row = index ~/ 3; // 单元格内的 列
    int low = index % 3; // 单元格内的 行

    int rowIndex = row + 3 * (itemIndex ~/ 3); // 获取在九宫格内的行索引
    List rowAry = rows[rowIndex];

    int lowIndex = low + 3 * (itemIndex % 3); // 获取在九宫格内的列索引
    List lowAry = lows[lowIndex];

    List itemAry = items[itemIndex]; // 获取单元格的数组

    ItemModel _itemModel = itemAry[index]; // 具体选择的单元格

    for (List itemList in items) {
      for (ItemModel aaa in itemList) {
        aaa.isSelected = false;
        if (_itemModel.item != 0 && _itemModel.item == aaa.item) {
          aaa.isSelected = true;
        }
      }
    }

    if (isEdit) {
      // 如果是编辑模式，取消下面item所有的点击效果
      for (var opera in operates) {
        opera.isSelected = false;
      }
      // 当选中的单元值 == 0 ，显示提示(这里还有优化的地方)
      if (_itemModel.item == 0) {
        for (ItemModel item in rowAry) {
          item.isSelected = true;
        }
        for (ItemModel item in lowAry) {
          item.isSelected = true;
        }
        // for (ItemModel item in itemAry) {
        //   item.isSelected = true;
        // }
      }
    } else {
      // 改变下面选择的item颜色
      selectedOperateItem = _itemModel.item;
      for (var opera in operates) {
        opera.isSelected = opera.item == selectedOperateItem ? true : false;
      }
    }

    notifyListeners();
  }

//  输入的值是否包含在  行 列 单元格内
  bool _isInclude(List itemAry, List rowAry, List lowAry) {
    for (ItemModel model in itemAry) {
      if (model.item == selectedOperateItem) {
        return true;
      }
    }

    for (ItemModel model in rowAry) {
      if (model.item == selectedOperateItem) {
        return true;
      }
    }

    for (ItemModel model in lowAry) {
      if (model.item == selectedOperateItem) {
        return true;
      }
    }
    return false;
  }

  static GameModel of(BuildContext context) {
    return ScopedModel.of<GameModel>(context);
  }

  void refreshData() {
    _level = 2; // 难度等级 显示的间隔量级，可表示难易程度，值越大越不能保证唯一性
    operates = []; //九宫格按钮的操作
    selectedOperateItem = 0; // 选中的操作符

    _removeItem1 = []; // 被移除的item
    _removeItem2 = []; // 移除之后的item
    _dataSource = []; // 储存生成的九宫格数组
    isEdit = false; // 是否是编辑模式
    items = [];
    rows = [];
    lows = [];

    _initData();
    notifyListeners();
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
      ItemModel itemModel = ItemModel(title, false);

      _dataSource.add(itemModel);

      // 随机隐藏个数,计算每个数现有多少个
      if (Random().nextInt(_level) != 1) {
        itemModel.item = 0;
      } else {
        OperateModel model = operates[title - 1];
        if (model.item == title) {
          model.hideCount -= 1;
        }
      }

      rows[row].add(itemModel);
      lows[low].add(itemModel);

      if (row1 && low1) {
        // item1
        items[0].add(itemModel);
      } else if (row1 && low2) {
        // item2
        items[1].add(itemModel);
      } else if (row1 && low3) {
        // item3
        items[2].add(itemModel);
      } else if (row2 && low1) {
        // item4
        items[3].add(itemModel);
      } else if (row2 && low2) {
        // item5
        items[4].add(itemModel);
      } else if (row2 && low3) {
        // item6
        items[5].add(itemModel);
      } else if (row3 && low1) {
        // item7
        items[6].add(itemModel);
      } else if (row3 && low2) {
        // item8
        items[7].add(itemModel);
      } else if (row3 && low3) {
        // item9
        items[8].add(itemModel);
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

class ItemModel {
  int item = 0;
  bool isSelected = false;
  ItemModel(this.item, this.isSelected);
}
