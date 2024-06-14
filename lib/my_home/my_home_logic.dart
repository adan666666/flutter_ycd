import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ycd/my_db/DbHelper.dart';
import 'package:ycd/my_db/Table1Model.dart';
import '../my_db/Table2Model.dart';
import '../utils/my_character.dart';
import 'my_home_state.dart';

class MyHomeLogic extends GetxController {
  final MyState state = MyState();
  Future<Database>? _instance;

  final scrollController = ScrollController();
  final textEditingController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _instance = DbHelper.instance.getDb();
    List.generate(32, (index) {
      if (index == 0) {
        state.totalValue.add('10000'); //本金
      } else if (index == 19) {
        state.totalValue.add('0.08'); //期望值
      } else if (index == 23) {
        state.totalValue.add('${MyState.RATE}'); //赔率
      } else {
        state.totalValue.add('$index');
      }
    });
    queryAll();

    textEditingController.addListener(() => state.bettingMoney = textEditingController.text);
  }

  @override
  void onClose() {
    super.onClose();
    textEditingController.dispose();
  }

  setRandom(Function(int) f) {
    if (next(1, 90485) > 44625 - MyState.OFFSET8431) {
      state.totalValue[30] = '庄';
      state.randomV = '庄';
    } else {
      state.totalValue[30] = '闲';
      state.randomV = '闲';
    }
  }

  int next(int min, int max) => min + Random().nextInt(max - min + 1);

  queryAll() {
    _instance?.then((db) {
      db.query(DbHelper.table1).then((value) {
        state.table1List.clear();
        for (var data in value) {
          state.table1List.add(Table1Model.fromJson(data));
        }
        _queryAllTable2();
      });
    });
  }

  add(int i, String tableName, {Table1Model? table1, Table2Model? table2}) {
    if (state.randomV.isEmpty) {
      Get.snackbar("温馨提示", '请摇塞子', duration: const Duration(seconds: 2), snackPosition: SnackPosition.TOP);
      return;
    }
    print('下注金额${state.bettingMoney}');
    if (state.bettingMoney.isEmpty) {
      Get.snackbar("温馨提示", '请输入下注金额', duration: const Duration(seconds: 2), snackPosition: SnackPosition.TOP);
      return;
    }

    final table = tableName == 'table2'
        ? Table2Model(
            table2Id: state.table2List.length,
            columnXiazhujine: state.bettingMoney,
            colmunZx: state.randomV,
            //输（-） 赢 （+）
            colmunRemark: (i == 1 || i == 2) ? "1" : "-1",
            colmunShengfulu: ((i == 1 || i == 3) && (state.randomV == '闲')) || ((i == 2 || i == 4) && (state.randomV == '庄')) ? "正打" : "反打",
            colmunShuyingzhi: syzL(i),
            colmunShuyingzhiD: syzL(i),
            columnCurrentJin: getCurrentJin(i, double.parse(state.bettingMoney)).toString(),
          )
        : Table1Model(columnBenjin: "10000", columnYongJin: "0.95", columnMean: "0.08", columnRestartIndex: "0", columnLiushuiIndex: "10");

    _instance
        ?.then((value) => value.insert(tableName == 'table1' ? DbHelper.table1 : DbHelper.table2,
            tableName == 'table1' ? (table as Table1Model).toJson() : (table as Table2Model).toJson()))
        .then((value) => queryAll());
  }

  _queryAllTable2() {
    _instance?.then((db) {
      db.query(DbHelper.table2).then((value) {
        state.table2List.clear();
        for (var data in value) {
          state.table2List.add(Table2Model.fromJson(data));
          print(data);
        }
        scrollController.jumpTo(scrollController.position.maxScrollExtent + 50);
        //统计区，计算
        state.totalValue[1] = '${state.table2List.length}';
      });
    });
  }

  getCurrentJin(int i, double parse) {
    switch (i) {
      case 1:
        return (10000 + parse);
      case 2:
        return 10000 + parse * double.parse(state.totalValue[27]);
      case 3:
      case 4:
        return 10000 - parse;
    }
  }

  syzL(int i) {
    switch (i) {
      case 1: //闲
        return state.bettingMoney;
      case 2: //庄赢
        double parse = double.parse(state.bettingMoney);
        var xx = parse * double.parse(state.totalValue[23]);
        print('庄赢值=>$xx');
        String syz /*庄赢值*/ = xx.toStringAsFixed(2); //四舍五入保留两位小数
        print('庄赢值$syz');
        return syz;
      case 3:
      case 4:
        return '-${state.bettingMoney}';
    }
  }

  void deleteLast() {
    _instance?.then((db) => db.delete(DbHelper.table2, where: 'table2Id =?', whereArgs: [state.table2List.last.table2Id]).then((value) => _queryAllTable2()));
  }

  void updateSqlite(int index) {
    _instance?.then((value) => value.update(DbHelper.table2, state.table2List[index].toJson()..update("colmun_shuyingzhi_d", (value) => "") /*具体更新的数据*/,
        where: "table2Id =?", //通过id查找需要更新的数据
        whereArgs: [index])).then((value) => _queryAllTable2());
  }
}
