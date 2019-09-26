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
                  Positioned(
                    top: 12.0,
                    child: Container(),
                  ),
                  GameListView(),
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
    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 5,
      mainAxisSpacing: 5,
      children: model.items.map((items) {
        return Container(
          child: CellView(items),
          color: Colors.grey,
        );
      }).toList(),
    );
  }
}

// 单元格widget
class CellView extends StatelessWidget {
  final List items;
  CellView(this.items);
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      children: items.map((item) {
        return GestureDetector(
          onTap: () {},
          child: Card(
            child: Center(
              child: Text(item == 0 ? "" :'$item'),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// 返回和撤回操作
class OperatingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0.0,
      right: 0.0,
      bottom: 45.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          FlatButton(
            onPressed: () {},
            child: Text('撤回'),
          ),
          FlatButton(
            onPressed: () {},
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
                model.changeSelcted();
              },
              child: operate.hideCount == 0 ? Container() : Stack(
                children: <Widget>[
                  Card(
                    color: operate.isSelected ? Colors.red : Colors.white,
                      child: Center(
                    child: Text('${operate.item}'),
                  )),
                  Positioned(
                    right: 2,
                    top: 2,
                    child: Text("${operate.hideCount}",style: TextStyle(fontSize: 10),),
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
