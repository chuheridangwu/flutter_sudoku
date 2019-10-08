import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sudoku/mode/mode.dart';
import 'package:scoped_model/scoped_model.dart';

class GameViewPage extends StatefulWidget {
  @override
  _GameViewPageState createState() => _GameViewPageState();
}

class _GameViewPageState extends State<GameViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Game'),
        ),
        body: ScopedModel(
          model: GameModel(),
          child: ScopedModelDescendant<GameModel>(
            builder: (context, _, model) {
              return SafeArea(
                  child: Stack(
                children: <Widget>[
                  GameListView(),
                  LoveView(),
                  TimeView(),
                  OperatingView(),
                  ItemView(),
                ],
              ));
            },
          ),
        ));
  }
}

// 整体的widget
class GameListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    GameModel model = GameModel.of(context);
    model.snpTipBack = () {
      showDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: Text('数据重复'),
              actions: <Widget>[
                FlatButton(
                  child: Text('取消'),
                  onPressed: () {
                    Navigator.of(context).pop('点击了取消');
                  },
                ),
                FlatButton(
                  child: Text('确定'),
                  onPressed: () {
                    Navigator.of(context).pop('点击了确定');
                  },
                )
              ],
            );
          });
    };
    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 5,
      mainAxisSpacing: 5,
      children: model.items
          .asMap()
          .map((itemIndex, items) {
            return MapEntry(
                itemIndex,
                Container(
                  child: CellView(items, itemIndex),
                  color: Colors.grey,
                ));
          })
          .values
          .toList(),
    );
  }
}

// 单元格widget
class CellView extends StatelessWidget {
  final List items;
  final int itemIndex; // 单元格索引
  CellView(this.items, this.itemIndex);
  @override
  Widget build(BuildContext context) {
    GameModel model = GameModel.of(context);
    return GridView.count(
      crossAxisCount: 3,
      children: items
          .asMap()
          .map((index, itemModel) {
            return MapEntry(
                index,
                GestureDetector(
                  onTap: () {
                    model.selectedOperateItem = 0;
                    model.isEdit = itemModel.item == 0 ? true : false;
                    model.fillFromTable(itemIndex, index);
                  },
                  child: Card(
                    color: itemModel.isSelected ? Colors.red : Colors.white,
                    child: Center(
                      child: Text(
                          (itemModel.item == 0) ? "" : '${itemModel.item}'),
                    ),
                  ),
                ));
          })
          .values
          .toList(),
    );
  }
}

// 返回和撤回操作
class OperatingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    GameModel model = GameModel.of(context);
    return Positioned(
      left: 0.0,
      right: 0.0,
      bottom: 45.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          FlatButton(
            onPressed: () {
              model.withdrawItem();
            },
            color: Colors.red,
            child: Text('撤回'),
          ),
          SizedBox(
            width: 10.0,
          ),
          FlatButton(
            onPressed: () {
              model.withdrawalItem();
            },
            color: Colors.red,
            child: Text('回撤'),
          ),
        ],
      ),
    );
  }
}

// 每个数字按钮
class ItemView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    GameModel model = GameModel.of(context);
    return Positioned(
      bottom: 0.0,
      left: 0.0,
      right: 0.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: model.operates.map((operate) {
          return Container(
            height: 40.0,
            width: 40.0,
            child: GestureDetector(
              onTap: () {
                model.selectedOperateItem = operate.item;
                model.changeSelctedOperateitem();
              },
              child: operate.hideCount == 0
                  ? Container()
                  : Stack(
                      children: <Widget>[
                        Card(
                            color:
                                operate.isSelected ? Colors.red : Colors.white,
                            child: Center(
                              child: Text('${operate.item}'),
                            )),
                        Positioned(
                          right: 2,
                          top: 2,
                          child: Text(
                            "${operate.hideCount}",
                            style: TextStyle(fontSize: 10),
                          ),
                        )
                      ],
                    ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class LoveView extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<LoveView> {
  List _loves = ["", "", ""]; // 爱心

  void removeLastLove() {
    setState(() {
      _loves.removeLast();
    });
  }

  @override
  Widget build(BuildContext context) {
    GameModel model = GameModel.of(context);
    model.snpTipBack = () {
      removeLastLove();
    };
    return Positioned(
      left: 0,
      top: MediaQuery.of(context).size.width,
      right: 0,
      child: Row(
        children: _loves.map((item) {
          return IconButton(
            icon: Icon(Icons.live_tv),
            onPressed: () {},
          );
        }).toList(),
      ),
    );
  }
}

class TimeView extends StatefulWidget {
  @override
  _TimeViewState createState() => _TimeViewState();
}

class _TimeViewState extends State<TimeView> {
  int _seconds = 0;
  Timer _timer;
  @override
  void initState() {
    super.initState();
    const period = const Duration(seconds: 1);
    _timer = Timer.periodic(period, (time) {
      setState(() {
        _seconds++;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _timer = null;
  }

  //时间格式化，根据总秒数转换为对应的 hh:mm:ss 格式
  String constructTime() {
    int hour = _seconds ~/ 3600;
    int minute = _seconds % 3600 ~/ 60;
    int secode = _seconds % 60;
    return formatTime(hour) +
        ':' +
        formatTime(minute) +
        ':' +
        formatTime(secode);
  }

  // 数字格式化 0~9
  String formatTime(int timeNum) {
    return timeNum < 10 ? '0' + timeNum.toString() : timeNum.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 10.0,
      top: MediaQuery.of(context).size.width + 20,
      child: Text('${constructTime()}'),
    );
  }
}
