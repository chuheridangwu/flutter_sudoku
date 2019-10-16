import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sudoku/game/pause_show.dart';
import 'package:flutter_sudoku/mode/mode.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class GameViewPage extends StatefulWidget {
  @override
  _GameViewPageState createState() => _GameViewPageState();
}

class _GameViewPageState extends State<GameViewPage> {
// 监听内购传值结果
  StreamSubscription<List<PurchaseDetails>> _subscription;

  @override
  void initState() {
    final Stream purchaseUpdates =
        InAppPurchaseConnection.instance.purchaseUpdatedStream;
    _subscription = purchaseUpdates.listen((purchases) {
      _handlePurchaseUpdates(purchases);
    },onDone: (){
      print('完成');
    },onError: (error){
      print('有错误');
    },cancelOnError: false);
    super.initState();
  }

  // 监听付款结果
  void _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
  print('正在购买');
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
//          handleError(purchaseDetails.error);
        print('出现错误');
        } else if (purchaseDetails.status == PurchaseStatus.purchased) {
          print('已购买');
//          bool valid = await _verifyPurchase(purchaseDetails);
//          if (valid) {
//            deliverProduct(purchaseDetails);
//          } else {
//            _handleInvalidPurchase(purchaseDetails);
//          }
        }
//        if (Platform.isIOS) {
          InAppPurchaseConnection.instance.completePurchase(purchaseDetails);
//        } else if (Platform.isAndroid) {
//          if (!kAutoConsume && purchaseDetails.productID == _kConsumableId) {
//            InAppPurchaseConnection.instance.consumePurchase(purchaseDetails);
//          }
//        }
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  // 开始购买内购商品
  Future startBugProduct() async {
    // 连接店面
    final bool available = await InAppPurchaseConnection.instance.isAvailable();
    // if (!available) {
    // The store cannot be reached or accessed. Update the UI accordingly.

    // 获取商品信息
    const Set<String> _kIds = {'com.dym.sudoku_1'};
    final ProductDetailsResponse response =
        await InAppPurchaseConnection.instance.queryProductDetails(_kIds);

    // 如果商品不为空
    if (response.productDetails.length > 0) {
      final ProductDetails productDetails = response
          .productDetails.last; // Saved earlier from queryPastPurchases().
      final PurchaseParam purchaseParam =
          PurchaseParam(productDetails: productDetails);
      // 只对iOS进行内购
      InAppPurchaseConnection.instance
          .buyConsumable(purchaseParam: purchaseParam);
    }

    List<ProductDetails> products = response.productDetails;
    // }
  }

  @override
  Widget build(BuildContext context) {
//    _model.level = ModalRoute.of(context).settings.arguments;
//    _model.refreshData();
GameModel _model = GameModel(ModalRoute.of(context).settings.arguments);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueGrey[400],
          leading: IconButton(
            icon: Icon(Icons.pause),
            onPressed: () {
//              startBugProduct();
//              print('kaishigoumai');
              showDialog(
                  context: context,
                  builder: (context) {
                    return PauseShowView(_model.level);
                  });
            },
          ),
          // automaticallyImplyLeading: false,
          title: Text('趣味数独',style: TextStyle(color: Colors.white,fontSize: 24,fontWeight: FontWeight.bold)),
        ),
        body: ScopedModel(
          model: _model,
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
                    color: itemModel.isSelected ? Colors.blueGrey[300] : Colors.white,
                    child: Center(
                      child: Text(
                        (itemModel.item == 0) ? "" : '${itemModel.item}',
                        style: TextStyle(color: itemModel.isSelected ? Colors.white : Colors.black ,fontSize: 16,fontWeight: FontWeight.bold),
                      ),
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
            shape: BeveledRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(2)),
            ),
            onPressed: () {
              model.withdrawItem();
            },
            color: Colors.blueGrey[400],
            child: Text('撤回',style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold)),
          ),
          SizedBox(
            width: 10.0,
          ),
          FlatButton(
            shape: BeveledRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(2)),
            ),
            onPressed: () {
              model.withdrawalItem();
            },
            color: Colors.blueGrey[400],
            child: Text('回撤',style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold)),
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
                        Container(
                          decoration: BoxDecoration(
                            boxShadow: [BoxShadow(color: Color(0x99FFFF00), offset: Offset(5.0, 5.0),    blurRadius: 10.0, spreadRadius: 2.0), BoxShadow(color: Color(0x9900FF00), offset: Offset(1.0, 1.0)), BoxShadow(color: Color(0xFF0000FF))]
                          ),
                          child: Card(
                            color:
                                operate.isSelected ? Colors.blueGrey[400] : Colors.white,
                            child: Center(
                              child: Text('${operate.item}',style: TextStyle(color: operate.isSelected ? Colors.white : Colors.black,fontSize: 16,fontWeight: FontWeight.bold),),
                            )),
                        ),
                        Positioned(
                          right: 3,
                          top: 3,
                          child: Text(
                            "${operate.hideCount}",
                            style: TextStyle(fontSize: 12,color: operate.isSelected ? Colors.white : Colors.black),
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
      if (_loves.length > 0) {
        _loves.removeLast();
      }

      if (_loves.length == 0) {
        showDialog(
            context: context,
            child: CupertinoAlertDialog(
              title: Text('当前没有次数了'),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _loves = ["", "", "","",""];
                    });
                  },
                  child: Text('不抛弃，不放弃'),
                ),
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    GameModel model = GameModel.of(context);
                    model.refreshData();
                    setState(() {
                      _loves = ["", "", ""];
                    });
                  },
                  child: Text('再接再厉'),
                )
              ],
            ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    GameModel model = GameModel.of(context);
    model.snpTipBack = () {
      print('2222');
      removeLastLove();
    };
    return Positioned(
      left: 0,
      top: MediaQuery.of(context).size.width,
      right: 0,
      child: Row(
        children: _loves.map((item) {
          return IconButton(
            icon: Icon(Icons.favorite, color: Colors.red),
            onPressed: () {},
          );
        }).toList(),
      ),
    );
  }
}

// 时间视图
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
    super.dispose();
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
