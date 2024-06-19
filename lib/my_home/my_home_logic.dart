import 'dart:convert';
import 'dart:ffi';
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

    List.generate(32, (index) => state.totalValue.add('$index'));
    state.chartData.value = List.generate(50, (index) => SalesData(index, Random().nextInt(1).toDouble())).toList();
    queryAll();
    textEditingController.addListener(() => state.bettingMoney = textEditingController.text);
  }

  @override
  void onClose() {
    super.onClose();
    textEditingController.dispose();
  }

  setRandom(Function(int) f) {
    if (!state.isCanPress) {
      return;
    }
    state.isCanPress = false;
    state.js2 = state.js2 + 1;
    print(state.js2);
    state.totalValue[28] = "${state.js1}/${state.js2}";
    if (next(1, 90485) > 44625 - MyState.OFFSET8431) {
      state.totalValue[30] = '庄';
      state.randomValue = '庄';
    } else {
      state.totalValue[30] = '闲';
      state.randomValue = '闲';
    }
    _queryAllTable2();
  }

  int next(int min, int max) => min + Random().nextInt(max - min + 1);

  queryAll() {
    _instance?.then((db) {
      db.query(DbHelper.table1).then((value) {
        state.table1List.clear();
        for (var data in value) {
          print(data);
          state.table1List.add(Table1Model.fromJson(data));
        }
        _queryAllTable2();
      });
    });
  }

  add(int i, String tableName, {Table1Model? table1, Table2Model? table2}) {
    if (state.randomValue.isEmpty) {
      Get.snackbar("温馨提示", '请摇塞子', duration: const Duration(seconds: 2), snackPosition: SnackPosition.TOP);
      return;
    }
    print('下注金额${state.bettingMoney}');
    if (state.bettingMoney.isEmpty) {
      Get.snackbar("温馨提示", '请输入下注金额', duration: const Duration(seconds: 2), snackPosition: SnackPosition.TOP);
      return;
    }
    if (!state.isCanPress) {
      Get.snackbar("温馨提示", '速度太快', duration: const Duration(seconds: 2), snackPosition: SnackPosition.BOTTOM);
      return;
    }
    state.isCanPress = false;
    state.js1 = state.js1 + 1;
    state.totalValue[28] = "${state.js1}/${state.js2}";
    final table = tableName == 'table2'
        ? Table2Model(
            table2Id: state.table2List.length,
            columnXiazhujine: state.bettingMoney,
            colmunZx: state.randomValue,
            //输（-） 赢 （+）
            colmunRemark: (i == 1 || i == 2) ? "1" : "-1",
            colmunShengfulu: ((i == 1 || i == 3) && (state.randomValue == '闲')) || ((i == 2 || i == 4) && (state.randomValue == '庄')) ? "正打" : "反打",
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
        //计算
        statisticalArea();
      });
    });
  }

  getCharts() {
    double current = 0 /* double.parse(state.totalValue[0])*/;
    var listZiJi = <double>[];
    var c = 0;
    for (var i = 0; i < state.table2List.length; i++) {
      current += double.parse(state.table2List[i].colmunShuyingzhi.toString());
      c++;
      if (c > state.chartData.length) {
        return;
      }
      listZiJi.add(current);
    }
    print('测试 原始资金表：${listZiJi}');
    var z = 0;
    for (var i = listZiJi.length - 1; i >= 0; i--) {
      z++;
      state.chartData[state.chartData.length - z].sales = listZiJi[i];
    }
    var removeLast = state.chartData.removeLast();
    Future.delayed(const Duration(milliseconds: 300), () => state.chartData.add(removeLast));
  }

  void statisticalArea() {
    state.totalValue[0] = '${state.table1List.last.columnBenjin}'; //本金
    state.totalValue[19] = '${state.table1List.last.columnMean}'; //期望值

    //图表区
    getCharts();

    //统计区，计算
    state.totalValue[1] = '${state.table2List.length}'; //一共打多少手

    var zt_y = 0;
    var zt_s = 0;
    var zt_syz = 0.0;
    var runningWater = 0.0;
    for (var element in state.table2List) {
      zt_syz += double.parse(element.colmunShuyingzhi.toString());
      runningWater += double.parse(element.columnXiazhujine.toString());
      if (element.colmunRemark!.startsWith("-1")) {
        zt_s--;
      } else {
        zt_y++;
      }
    }
    state.totalValue[5] = '${zt_y}'; //胜
    state.totalValue[9] = '${(zt_y / double.parse(state.totalValue[1]) * 100).toStringAsFixed(2)}%'; //胜率
    state.totalValue[13] = '${zt_y.abs() - zt_s.abs()}'; //净胜~须多少手回到50%
    state.totalValue[17] = '${zt_syz}'; //一共输赢多少钱
    state.totalValue[21] = '${zt_syz / double.parse(removeChineseCharacters(state.totalValue[13]))}'; //平均输赢多少钱
    var d = (double.parse(state.totalValue[1]) + 1) * double.parse(state.totalValue[19]); //期望一共的值
    var parse = int.parse(state.totalValue[13]).abs();
    state.totalValue[25] = zt_syz < 0
        ? /*state.randomValue == '闲' || state.randomValue.isEmpty
            ?*/
        '须${((zt_syz.abs() + d) / parse).toStringAsFixed(1)}x${parse}'
        : '须${((zt_syz.abs() + d) / double.parse(state.totalValue[23]) / parse).toStringAsFixed(1)}x${parse}' /*: '可负${((zt_syz.abs() - d) / parse).toStringAsFixed(1)}x${parse}'*/; //还需，可负
    state.totalValue[29] = '${state.table1List.last.columnRestartIndex}'; //流水索引 重启位置

    state.totalValue[4] = "${double.parse(state.totalValue[0]) + zt_syz}"; //当前金额

    //局部
    int index = state.table1List.isEmpty ? 0 : int.parse(state.table1List.last.columnRestartIndex.toString());
    state.totalValue[2] = '${state.table2List.length - index}'; //一共打多少手
    var jb_y = 0;
    var jb_s = 0;
    var jb_syz = 0.0;
    var jb_count = 0;
    for (var element in state.table2List) {
      if (element.table2Id >= index) {
        jb_count++;
        jb_syz += double.parse(element.colmunShuyingzhi.toString());
        if (element.colmunRemark!.startsWith("-1")) {
          jb_s--;
        } else {
          jb_y++;
        }
      }
    }
    state.totalValue[6] = '$jb_y'; //净胜
    state.totalValue[10] = '${(jb_y / jb_count * 100).toStringAsFixed(2)}%'; //胜率
    state.totalValue[14] = '${jb_y.abs() - jb_s.abs()}'; //净胜~须多少手回到50%
    state.totalValue[18] = '$jb_syz'; //一共输赢多少钱
    state.totalValue[22] = '${jb_syz / double.parse(removeChineseCharacters(state.totalValue[14]))}'; //平均输赢多少钱
    var dJ = (jb_count + 1) * double.parse(state.totalValue[19]); //期望一共的值
    parse = int.parse(state.totalValue[14]).abs();
    state.totalValue[26] = /*state.randomValue == '闲' || state.randomValue.isEmpty
        ? */
            jb_syz < 0 ? '须${((jb_syz.abs() + dJ) / parse).toStringAsFixed(1)}x${parse}' : '可负${((jb_syz.abs() - dJ) / parse).toStringAsFixed(1)}x${parse}'
        /* : jb_syz < 0
            ? '须${((jb_syz.abs() + dJ) / double.parse(state.totalValue[23]) / parse).toStringAsFixed(1)}x${parse}'
            : '可负${((jb_syz.abs() - dJ) / parse).toStringAsFixed(1)}x${parse}'*/
        ; //还需，可负

    ///第四列
    state.totalValue[3] = '流水$runningWater';
    state.totalValue[7] = '均利${zt_syz / state.table2List.length}';
    state.totalValue[23] = '${state.table1List.last.columnYongJin}'; //赔率
    state.totalValue[27] = zt_syz>0?"": (double.parse(state.totalValue[21]) / double.parse(state.totalValue[23])).toStringAsFixed(2); //打庄需要
    state.totalValue[31] = jb_syz>0?"":(double.parse(state.totalValue[22]) / double.parse(state.totalValue[23])).toStringAsFixed(2); //打庄需要
    state.isCanPress = true;
    print(state.isCanPress);
  }

  getCurrentJin(int i, double parse) {
    switch (i) {
      case 1:
        return (double.parse(state.table1List.last.columnBenjin.toString()) + parse);
      case 2:
        return (double.parse(state.table1List.last.columnBenjin.toString()) + parse * double.parse(state.totalValue[27]));
      case 3:
      case 4:
        return (double.parse(state.table1List.last.columnBenjin.toString()) - parse);
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
    _instance?.then((db) => db.delete(DbHelper.table2, where: 'table2Id =?', whereArgs: [state.table2List.last.table2Id]).then((value) => queryAll()));
  }

  void updateSqlite(int index) {
    _instance?.then((value) => value.update(DbHelper.table2, state.table2List[index].toJson()..update("colmun_shuyingzhi_d", (value) => "") /*具体更新的数据*/,
        where: "table2Id =?", //通过id查找需要更新的数据
        whereArgs: [index])).then((value) => _queryAllTable2());
  }

  void reStart() {
    // valueC.last..update('column_restart_index', (value) => "${state.table2List.length - 1}")
    _instance?.then((value) => value.query(DbHelper.table1).then((valueC) => _instance?.then((value) => value
        .insert(
            DbHelper.table1,
            Table1Model(
              columnBenjin: valueC.last['column_benjin'].toString(),
              columnYongJin: valueC.last['column_yongJin'].toString(),
              columnMean: valueC.last['column_mean'].toString(),
              columnRestartIndex: "${state.table2List.length}",
              columnLiushuiIndex: valueC.last['column_liushui_index'].toString(),
            ).toJson())
        .then((value) => queryAll()))));
  }
}

String removeChineseCharacters(String input) {
  return input.replaceAll(RegExp('[\u4e00-\u9fa5]'), '');
}
