import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:ycd/main.dart';
import 'package:ycd/my_db/DbHelper.dart';
import 'package:ycd/my_db/Table1Model.dart';
import 'package:ycd/utils/loading.dart';
import 'package:ycd/utils/network/get_store.dart';
import '../my_db/Table2Model.dart';
import '../utils/bx_loading.dart';
import '../utils/network/Api.dart';
import '../utils/network/http_mgr.dart';
import 'my_home_state.dart';
import 'my_home_view.dart';

class MyHomeLogic extends GetxController {
  EasyRefreshController refreshcontroller = EasyRefreshController(controlFinishRefresh: true, controlFinishLoad: true);
  final MyState state = MyState();
  Future<Database>? _instance;

  final scrollController = ScrollController();
  final textEditingController = TextEditingController();
  final focusNode = FocusNode();

  FixedExtentScrollController? fixedExtentScrollController;

// 定义一个计时器，用于延时锁屏
  Timer? _timer;

  final ScrollController scrollController1 = ScrollController(); //路子图的controller

  @override
  void onInit() {
    super.onInit();
    WakelockPlus.enable();
    onUserInteraction();
    // _instance = DbHelper.instance.getDb();

    List.generate(32, (index) => state.totalValue.add('$index'));
    // //创建表
    // BXPost<Table1Model>(Api.createtables,
    //     success: (isSuccess, code, message, results) {
    //       if (isSuccess) queryAll();
    //       BXLoading.showToast(message);
    //     },
    //     failed: (p0, p1) => BXLoading.showToast(p1.msg),
    //     onModel: (m) => Table1Model.fromJson(m));
    textEditingController.addListener(
      () {
        state.bettingMoney = textEditingController.text;
        if (textEditingController.text.isNotEmpty) {
          ///总体
          state.totalValue[20] = pVal1();

          ///局部
          state.totalValue[24] = pVal2();
        }
      },
    );
    // Future.delayed(const Duration(seconds: 20), () => lockScreen());
    scrollController1.addListener(() {
      if (scrollController1.position.pixels == scrollController1.position.maxScrollExtent) {
        print('已经滚动到了底部');
      }
    });

    //1。查询表一数据
    _queryMysqlTable1();
    //2。起始要拿到统计区数据
    _getStatisticalAreasData(1); //传的有数据就是从传的数据的行开始计算
    //3。启始先查66条数据
    BXGet<Table2Model>(Api.loadMore,
        params: {"last_id": -1, "uid": GetStore.getInstance().userModel.userId, "c": 66}, //"c"每页多少个数据
        success: (isSuccess, code, message, results) {
          if (isSuccess && results.isNotEmpty) {
            // var temp = <Table2Model>[];
            // temp.addAll(results);
            // temp.addAll(state.table2ListX.reversed.toList());
            state.table2ListX.clear();
            state.table2ListX.value = results.reversed.toList();
            state.listMap.value = state.table2ListX.reversed.toList().map((e) => e.colmunShuyingzhi!.startsWith("-") ? "P" : "B").toList();
            print("起启一共多少${state.table2ListX.length}条数据");
          }
        },
        onModel: (m) => Table2Model.fromJson(m));
  }

  void _getStatisticalAreasData(int? tempIndex) {
    BXGet<dynamic>(
      Api.getStatisticalAreasData,
      params: {"tempIndex": tempIndex},
      success: (isSuccess, code, message, results) {
        state.totalValue.value = results.map((e) => e.toString()).toList();
        state.totalValue[28] = "${state.js1}/${state.js2}";
        //预测平均值
        if (textEditingController.text.isNotEmpty) {
          ///总体
          state.totalValue[20] = pVal1();

          ///局部
          state.totalValue[24] = pVal2();
        }
        state.isCanPress = true;
        getCharts();
      },
    );
  }

  showBottomFunction() {
    focusNode.nextFocus();
    fixedExtentScrollController = FixedExtentScrollController(initialItem: state.selectIndex.value);
    Get.bottomSheet(const SinglePicker());
  }

  String pVal2() {
    if (state.bettingMoney.isEmpty || !state.bettingMoney.isNum) return '';
    var x = double.parse(state.totalValue[18]); //总输赢
    var y = double.parse(state.bettingMoney); //输入框下注额
    var z = double.parse(removeChineseCharacters(state.totalValue[14])); //净胜
    var z1 = (double.parse(removeChineseCharacters(state.totalValue[14])).abs()); //净胜绝对值
    if (z == 0) {
      return "回合结束";
    } else if (z > 0) /*赢>输的情况*/ {
      if ((z1 - 1) <= 0) {
        return '${((x + y) / (z1 + 1)).toStringAsFixed(1)}/';
      }
      return '${((x + y) / (z1 + 1)).toStringAsFixed(1)}/${((x - y) / (z1 - 1)).toStringAsFixed(1)}';
    } else {
      if ((z1 - 1) <= 0) {
        return '/${((x - y) / (z1 + 1)).toStringAsFixed(1)}';
      }
      return '${((x + y) / (z1 - 1)).toStringAsFixed(1)}/${((x - y) / (z1 + 1)).toStringAsFixed(1)}';
    }
  }

  String pVal1() {
    if (state.bettingMoney.isEmpty || !state.bettingMoney.isNum) return '';
    var x = double.parse(state.totalValue[17]); //总输赢
    var y = double.parse(state.bettingMoney); //输入框下注额
    var z = double.parse(removeChineseCharacters(state.totalValue[13])); //净胜
    var z1 = (double.parse(removeChineseCharacters(state.totalValue[13])).abs()); //净胜绝对值
    if (z == 0) {
      return "回合结束";
    } else if (z > 0) /*赢>输的情况*/ {
      if ((z1 - 1) <= 0) {
        return '${((x + y) / (z1 + 1)).toStringAsFixed(1)}/';
      }
      return '${((x + y) / (z1 + 1)).toStringAsFixed(1)}/${((x - y) / (z1 - 1)).toStringAsFixed(1)}';
    } else {
      if ((z1 - 1) <= 0) {
        return '/${((x - y) / (z1 + 1)).toStringAsFixed(1)}';
      }
      return '${((x + y) / (z1 - 1)).toStringAsFixed(1)}/${((x - y) / (z1 + 1)).toStringAsFixed(1)}';
    }
  }

  @override
  void onClose() {
    // 取消计时器
    _timer?.cancel();
    super.onClose();
    WakelockPlus.disable();
    textEditingController.dispose();
  }

  setRandom(Function(int) f) {
    if (!state.isCanPress) {
      return;
    }
    state.isCanPress = false;
    state.js2 = state.js2 + 1;
    state.totalValue[28] = "${state.js1}/${state.js2}";
    // if (next(1, 90485) > 44625 - MyState.OFFSET8431) {
    if (next(1, 100) <= 70) { //1到100（包含1，100）
      state.totalValue[30] = '庄';
      state.randomValue = '庄';
    } else {
      state.totalValue[30] = '闲';
      state.randomValue = '闲';
    }
    Get.dialog(NewWidget(state.randomValue), barrierDismissible: false, barrierColor: Colors.black.withOpacity(0.18));
    state.isCanPress = true;
  }

  int next(int min, int max) => min + Random().nextInt(max - min + 1);

  queryAll() {
    // _instance?.then((db) {
    //   db.query(DbHelper.table1).then((value) {
    //     state.table1List.clear();
    //     for (var data in value) {
    //       state.table1List.add(Table1Model.fromJson(data));
    //     }
    //     state.totalValue[0] = '${state.table1List.last.columnBenjin}'; //本金
    //     state.totalValue[19] = '${state.table1List.last.columnMean}'; //期望值
    //     state.chartData.value = List.generate(50, (index) => SalesData(index, double.parse(state.table1List.last.columnBenjin.toString()))).toList();
    //     _queryAllTable2();
    //   });
    // });

    ///改变成查询远程数据库
    // _queryMysqlTable1();
  }

  _queryMysqlTable1() {
    BXGet<Table1Model>(Api.getTable1,
        isShowLoading: false,
        success: (isSuccess, code, message, value) {
          state.table1List.clear();
          if (value.isNotEmpty) {
            state.table1List.value = value;
            state.totalValue[0] = '${state.table1List.last.columnBenjin}'; //本金
            state.totalValue[19] = '${state.table1List.last.columnMean}'; //期望值
            state.chartData.value = List.generate(75, (index) => SalesData(index, double.parse(state.table1List.last.columnBenjin.toString()))).toList();
          }
          state.isRefreshing.value = false;
        },
        failed: (p0, p1) {
          refreshcontroller.finishRefresh(IndicatorResult.fail);
          state.isCanPress = true;
          state.isRefreshing.value = false;
        },
        onModel: (m) => Table1Model.fromJson(m));
  }

  recordButton(int i, String tableName, {Table1Model? table1, Table2Model? table2}) {
    // getDeviceId().then((value) {
    //   print('测试=》${value}');
    // });

    if (state.randomValue.isEmpty) {
      Get.snackbar("温馨提示", '请摇塞子', duration: const Duration(seconds: 2), snackPosition: SnackPosition.TOP, backgroundColor: Colors.white.withOpacity(0.7));
      return;
    }

    if (state.bettingMoney.isEmpty) {
      Get.snackbar("温馨提示", '请输入下注金额', duration: const Duration(seconds: 2), snackPosition: SnackPosition.TOP, backgroundColor: Colors.white.withOpacity(0.7));
      return;
    }
    if (!state.bettingMoney.isNum) {
      Get.snackbar("温馨提示", '请输入数字', duration: const Duration(seconds: 2), snackPosition: SnackPosition.TOP, backgroundColor: Colors.white.withOpacity(0.7));
      return;
    }
    if (!state.isCanPress) {
      Get.snackbar("温馨提示", '速度太快', duration: const Duration(seconds: 2), snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.white.withOpacity(0.7));
      return;
    }
    Loading.show();
    state.isCanPress = false;
    state.js1 = state.js1 + 1;
    final table = tableName == 'table2'
        ? Table2Model(
            id: state.table2ListX.length + 1,
            //mysql数据库下标是从1开始的
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

    // _instance
    //     ?.then((value) => value.insert(tableName == 'table1' ? DbHelper.table1 : DbHelper.table2,
    //         tableName == 'table1' ? (table as Table1Model).toJson() : (table as Table2Model).toJson()))
    //     .then((value) => queryAll());

    ///改变成插入远程数据库
    if (tableName == 'table1') {
      BXPut<Table1Model>(Api.inserttable1,
          params: (table as Table1Model).toJson()..addAll({"UserID": int.parse(GetStore.getInstance().userModel.userId)}),
          success: (isSuccess, code, message, results) => queryAll(),
          failed: (p0, p1) => state.isCanPress = true,
          onModel: (m) => Table1Model.fromJson(m));
    } else {
      BXPut<Table2Model>(Api.inserttable2,
          params: (table as Table2Model).toJson()
            ..remove("table2Id")
            ..addAll({"UserID": int.parse(GetStore.getInstance().userModel.userId)}),
          success: (isSuccess, code, message, results) {
            _getStatisticalAreasData(-2); //重新计算
            state.table2ListX.insert(0, results.first); //打一手 记录一笔
            state.listMap.value = state.table2ListX.reversed.toList().map((e) => e.colmunShuyingzhi!.startsWith("-") ? "P" : "B").toList();
            print("图表的值：${state.listMap}");
          },
          failed: (p0, p1) => state.isCanPress = true,
          onModel: (m) => Table2Model.fromJson(m));
    }
  }

  getCharts() {
    // var chartDataTemp = <double>[];
    // if (state.table2ListX.length <= state.chartData.length) {
    //   for (var i = 0; i < state.table2ListX.length; i++) {
    //     chartDataTemp.add(double.parse(state.table2ListX[i].columnCurrentJin.toString()));
    //   }
    // } else {
    //   for (var i = state.table2ListX.length - state.chartData.length; i < state.table2ListX.length; i++) {
    //     chartDataTemp.add(double.parse(state.table2ListX[i].columnCurrentJin.toString()));
    //   }
    // }
    // if (chartDataTemp.isNotEmpty) {
    //   var z = 0;
    //   for (var i = chartDataTemp.length - 1; i >= 0; i--) {
    //     z++;
    //     state.chartData[state.chartData.length - z].sales = chartDataTemp[i];
    //   }
    //   var removeLast = state.chartData.removeLast();
    //   Future.delayed(const Duration(milliseconds: 300), () => state.chartData.add(removeLast));
    // // }

    var z = 0;
    var chartDataTemp = <double>[];
    BXGet<dynamic>(
      Api.getLinechartData,
      success: (isSuccess, code, message, results) {
        for (var i = results.length - 1; i >= 0; i--) {
          if (results[i].toString().isNotEmpty) {
            state.chartData[z].sales = double.parse(results[i]);
          }
          z++;
        }
        //解决外面的点跑，里面的线不动
        var removeLast = state.chartData.removeLast();
        Future.delayed(const Duration(milliseconds: 300), () => state.chartData.add(removeLast));
      },
    );
  }

  // void statisticalArea() {
  //   //图表区
  //   getCharts();
  //
  //   //统计区，计算
  //   state.totalValue[1] = '${state.table2List.length}'; //一共打多少手
  //
  //   //总体
  //   var zt_y = 0;
  //   var zt_s = 0;
  //   var zt_syz = 0.0;
  //   var runningWater = 0.0;
  //   var countLianShengFu = 1;
  //   var zCount = 0;
  //   var it = state.table2List;
  //   var benUse1 = state.table2List.isNotEmpty ? int.parse(state.table2List.first.columnXiazhujine.toString()) : 0;
  //   for (var index = 0; index < state.table2List.length; index++) {
  //     var element = state.table2List[index];
  //     zt_syz += double.parse(element.colmunShuyingzhi.toString());
  //     if (zt_syz < 0 && zt_syz < benUse1) benUse1 = zt_syz.toInt();
  //
  //     runningWater += double.parse(element.columnXiazhujine.toString());
  //     if (element.colmunRemark!.startsWith("-1")) {
  //       zt_s--;
  //     } else {
  //       zt_y++;
  //     }
  //     //连胜负
  //     if (it.length > 1 && (index - 1) >= 0) {
  //       var shuyingzhi = it[(index - 1)].colmunShuyingzhi; //上一个
  //       var shuyingzhi1 = element.colmunShuyingzhi;
  //       if ((double.parse(shuyingzhi1!) > 0 && double.parse(shuyingzhi!) > 0) || (double.parse(shuyingzhi1) < 0 && double.parse(shuyingzhi!) < 0)) {
  //         countLianShengFu++;
  //       } else {
  //         countLianShengFu = 1;
  //       }
  //     }
  //     //庄个数
  //     if (element.colmunZx == '庄') zCount++;
  //   }
  //   state.totalValue[5] = '$zt_y'; //胜
  //   state.totalValue[9] = '${(zt_y / double.parse(state.totalValue[1]) * 100).toStringAsFixed(2)}%'; //胜率
  //   state.totalValue[13] = '${zt_y.abs() - zt_s.abs()}'; //净胜~须多少手回到50%
  //   state.totalValue[17] = zt_syz.toStringAsFixed(3); //一共输赢多少钱
  //   state.totalValue[21] =
  //       state.totalValue[13] == '0' ? '-' : (zt_syz / double.parse(removeChineseCharacters(state.totalValue[13])).abs()).toStringAsFixed(2); //平均赢
  //   var d = (double.parse(state.totalValue[1]) + 1) * double.parse(state.totalValue[19]); //期望一共的值
  //   var parse = int.parse(state.totalValue[13]).abs();
  //   state.totalValue[25] = state.totalValue[13] == '0'
  //       ? '-'
  //       : zt_syz < 0
  //           ? '须${((zt_syz.abs() + d) / parse).toStringAsFixed(1)}x$parse'
  //           : '可负${((zt_syz.abs() - d) / parse).toStringAsFixed(1)}x$parse'; //还需，可负
  //   state.totalValue[29] = '${state.table1List.last.columnRestartIndex}'; //重启位置
  //   state.totalValue[8] = '${state.table1List.last.columnLiushuiIndex}'; //流水索引
  //   state.totalValue[12] = '${benUse1.abs()}'; //本金使用
  //   state.totalValue[16] = '';
  //
  //   state.totalValue[4] = (double.parse(state.totalValue[0]) + zt_syz).toStringAsFixed(2); //当前金额
  //
  //   //局部
  //   int index = state.currentTempIndex != 0
  //       ? state.currentTempIndex
  //       : state.table1List.isEmpty
  //           ? 0
  //           : int.parse(state.table1List.last.columnRestartIndex.toString()); //重启位置
  //   state.totalValue[2] = '${state.table2List.length - index}'; //一共打多少手
  //   var jb_y = 0;
  //   var jb_s = 0;
  //   var jb_syz = 0.0;
  //   var jb_count = 0;
  //   for (var i = 0; i < state.table2List.length; i++) {
  //     if (i >= index) {
  //       jb_count++;
  //       jb_syz += double.parse(state.table2List[i].colmunShuyingzhi.toString());
  //       if (state.table2List[i].colmunRemark!.startsWith("-1")) {
  //         jb_s--;
  //       } else {
  //         jb_y++;
  //       }
  //     }
  //   }
  //   state.totalValue[6] = '$jb_y'; //净胜
  //   state.totalValue[10] = jb_count == 0 ? "" : '${(jb_y / jb_count * 100).toStringAsFixed(2)}%'; //胜率
  //   state.totalValue[14] = '${jb_y.abs() - jb_s.abs()}'; //净胜~须多少手回到50%
  //   state.totalValue[18] = jb_syz.toStringAsFixed(3); //一共输赢多少钱
  //   state.totalValue[22] =
  //       state.totalValue[14] == '0' ? "-" : (jb_syz / double.parse(removeChineseCharacters(state.totalValue[14])).abs()).toStringAsFixed(3); //平均赢
  //   var dJ = (jb_count + 1) * double.parse(state.totalValue[19]); //期望一共的值
  //   parse = int.parse(state.totalValue[14]).abs();
  //   state.totalValue[26] = state.totalValue[14] == '0'
  //       ? "-"
  //       : jb_syz < 0
  //           ? parse == 0
  //               ? ''
  //               : '须${((jb_syz.abs() + dJ) / parse).toStringAsFixed(1)}x$parse'
  //           : parse == 0
  //               ? ''
  //               : '可负${((jb_syz.abs() - dJ) / parse).toStringAsFixed(1)}x$parse';
  //
  //   ///第四列
  //   state.totalValue[3] = '流水${runningWater.toStringAsFixed(1)}';
  //   state.totalValue[7] = '均利${(zt_syz / state.table2List.length).toStringAsFixed(2)}';
  //   state.totalValue[11] = '连胜负$countLianShengFu';
  //   state.totalValue[15] = '$zCount/${int.parse(state.totalValue[1])}';
  //   state.totalValue[23] = '${state.table1List.last.columnYongJin}'; //赔率
  //   state.totalValue[27] = state.totalValue[14] == '0'
  //       ? ""
  //       : state.totalValue[21] == '-'
  //           ? ""
  //           : (double.parse(removeChineseCharacters(state.totalValue[25].split("x")[0])) / double.parse(state.totalValue[23])).toStringAsFixed(2); //打庄需要
  //   state.totalValue[31] = state.totalValue[14] == '0'
  //       ? ""
  //       : state.totalValue[22] == '-'
  //           ? ""
  //           : (double.parse(removeChineseCharacters(state.totalValue[26].split("x")[0])) / double.parse(state.totalValue[23])).toStringAsFixed(2);
  //
  //   //预测平均值
  //   if (textEditingController.text.isNotEmpty) {
  //     ///总体
  //     state.totalValue[20] = pVal1();
  //
  //     ///局部
  //     state.totalValue[24] = pVal2();
  //   }
  //   state.isCanPress = true;
  //   Loading.dismiss();
  // }

  //得到当的钱数
  getCurrentJin(int i, double playMoney) {
    var lastJinE = state.table2ListX.isEmpty ? 5000 : double.parse(state.table2ListX.first.columnCurrentJin.toString());
    switch (i) {
      case 1:
        return (lastJinE + playMoney);
      case 2:
        return (lastJinE) + playMoney * double.parse(state.totalValue[23] == "23" || state.totalValue[23] == "" ? "0.95" : state.totalValue[23]);
      case 3:
      case 4:
        return (lastJinE) - playMoney;
    }
  }

  syzL(int i) {
    switch (i) {
      case 1: //闲
        return state.bettingMoney;
      case 2: //庄赢
        double parse = double.parse(state.bettingMoney);
        var xx = parse * double.parse(state.totalValue[23] == "23" || state.totalValue[23] == "" ? "0.95" : state.totalValue[23]);
        String syz /*庄赢值*/ = xx.toStringAsFixed(2); //四舍五入保留两位小数
        return syz;
      case 3:
      case 4:
        return '-${state.bettingMoney}';
    }
  }

  void deleteLast() {
    if (state.table2ListX.isNotEmpty) {
      Get.defaultDialog(
        barrierDismissible: false,
        title: '警告',
        content: const Text('确定删除最后一行数据？'),
        onCancel: () {},
        onConfirm: () {
          BXDelete<Table2Model>(Api.deletelast,
              success: (isSuccess, code, message, results) {
                _getStatisticalAreasData(-2);
                state.js1 = state.js1 - 1;
                state.totalValue[28] = "${state.js1}/${state.js2}";
                state.table2ListX.removeAt(0);
                Get.back();
              },
              onModel: (m) => Table2Model.fromJson(m));
        },
      );
    }
  }

  void updateSqlite(int index) {
    //1
    // _instance?.then((db) => db.update(DbHelper.table2, state.table2List[index].toJson()..update("colmun_shuyingzhi_d", (value) => "") /*具体更新的数据*/,
    //     where: "table2Id =?", //通过id查找需要更新的数据
    //     whereArgs: [index])).then((value) => _queryAllTable2());
    BXLoading.show();
    BXPost(Api.xiaoshu,
        isShowLoading: false,
        params: state.table2ListX[index].toJson()
          ..update("colmun_shuyingzhi_d", (value) => "")
          ..update("table2Id", (value) => ((value as int) + 1)), success: (isSuccess, code, message, results) {
      if (isSuccess) queryAll();
    });
  }

  void reStart() {
    // _instance?.then((_db) => _db.query(DbHelper.table1).then((value) => _instance?.then((db) {
    //       //重启时，清除消数列数据
    //       for (int i = 0; i < state.table2List.length; i++) {
    //         db.update(DbHelper.table2, state.table2List[i].toJson()..update('colmun_shuyingzhi_d', (value) => ''),
    //             where: 'table2Id =?', whereArgs: [state.table2List[i].table2Id]);
    //       }
    //       return db
    //           .insert(
    //               DbHelper.table1,
    //               Table1Model(
    //                 columnBenjin: value.last['column_benjin'].toString(),
    //                 columnYongJin: value.last['column_yongJin'].toString(),
    //                 columnMean: value.last['column_mean'].toString(),
    //                 columnRestartIndex: "${state.table2List.length}",
    //                 columnLiushuiIndex: value.last['column_liushui_index'].toString(),
    //               ).toJson())
    //           .then((value) => queryAll());
    //     })));
    BXPost<Table1Model>(
      Api.restart,
      params: {"index": state.table2ListX.first.id},
      success: (isSuccess, code, message, value) {
        if (isSuccess) {
          // BXLoading.showToast("${value.last.columnRestartIndex}");
          state.table1List.value = value;
          state.table2ListX.value = state.table2ListX.map((element) => element..colmunShuyingzhiD = "").toList();
          _getStatisticalAreasData(-1);
          state.currentTempIndex = 0;
        }
      },
      onModel: (m) => Table1Model.fromJson(m),
    );
  }

  void updateBenJin(String b) {
    // _instance?.then((db) => db.query(DbHelper.table1).then((value) => _instance?.then((db) => db
    //     .insert(
    //         DbHelper.table1,
    //         Table1Model(
    //           columnBenjin: b,
    //           columnYongJin: value.last['column_yongJin'].toString(),
    //           columnMean: value.last['column_mean'].toString(),
    //           columnRestartIndex: value.last['column_restart_index'].toString(),
    //           columnLiushuiIndex: value.last['column_liushui_index'].toString(),
    //         ).toJson())
    //     .then((value) => queryAll()))));
    BXPost<Table1Model>(
      Api.updateBenjin,
      params: {"benjin": b},
      success: (isSuccess, code, message, value) {
        if (isSuccess) {
          BXLoading.showToast("${value.last.columnBenjin}");
          state.totalValue[0] = b;
          state.totalValue[4] = (double.parse(state.totalValue[0]) + double.parse(state.totalValue[17])).toString();
        }
      },
      onModel: (m) => Table1Model.fromJson(m),
    );
  }

  void updateOdds(String b) {
    // _instance?.then((db) => db.query(DbHelper.table1).then((value) => _instance?.then((db) => db
    //     .insert(
    //         DbHelper.table1,
    //         Table1Model(
    //           columnBenjin: value.last['column_benjin'].toString(),
    //           columnYongJin: b,
    //           columnMean: value.last['column_mean'].toString(),
    //           columnRestartIndex: value.last['column_restart_index'].toString(),
    //           columnLiushuiIndex: value.last['column_liushui_index'].toString(),
    //         ).toJson())
    //     .then((value) => queryAll()))));

    BXPost/*<Map<String,dynamic>>*/(Api.updateOdds, params: {"odds": b}, success: (isSuccess, int code, String message, List<dynamic> results) {
      if (isSuccess) {
        BXLoading.showToast(message);
        print("赔率值是=${(results[0]["odds"])}");
        queryAll();
      }
    });
  }

  //底部选项
  Future<void> functionConfirm(int i) async {
    var s = textEditingController.text.toString();
    switch (i) {
      case 0: //排列数据
        Loading.show();
        // var list =
        //     state.table2List.map((element) => element.colmunShuyingzhiD.toString().isEmpty ? 0.0 : double.parse(element.colmunShuyingzhiD.toString())).toList()
        //       ..removeWhere((element) => element == 0.0)
        //       ..sort();
        // _instance?.then((db) {
        //   var x = 0;
        //   for (int i = state.table2List.length - 1; i >= state.table2List.length - list.length; i--) {
        //     x++;
        //     if (x > list.length) {
        //       break;
        //     }
        //     db.update(DbHelper.table2, state.table2List[i].toJson()..update('colmun_shuyingzhi_d', (value) => '${list[list.length - x]}'),
        //         where: 'table2Id =?', whereArgs: [state.table2List[i].table2Id]);
        //   }
        // }).then((value) => _queryAllTable2());
        //改成接口
        BXPost(Api.sortxiaoshu, success: (isSuccess, code, message, results) {
          if (isSuccess) {
            BXLoading.showToast(message);
            var list = state.table2ListX
                .map((element) => element.colmunShuyingzhiD.toString().isEmpty ? 0.0 : double.parse(element.colmunShuyingzhiD.toString()))
                .toList()
              ..removeWhere((element) => element == 0.0)
              ..sort();
            for (int i = 1; i <= list.length; i++) {
              state.table2ListX[i - 1].colmunShuyingzhiD = list[list.length - i].toString();
              state.table2ListX.refresh(); //调用了list里面的对象一定要用refresh()要不然不会刷新
            }
          }
        });
        break;
      case 1: //清除数据
        // Loading.show();
        // _instance?.then((db) {
        //   for (int i = 0; i < state.table2List.length; i++) {
        //     if (state.table2List[i].colmunShuyingzhiD!.isEmpty) continue;
        //     db.update(DbHelper.table2, state.table2List[i].toJson()..update('colmun_shuyingzhi_d', (value) => ''),
        //         where: 'table2Id =?', whereArgs: [state.table2List[i].id]);
        //   }
        // }).then((value) => queryAll());
        int count = 0;
        for (var value in state.table2ListX) {
          state.table2ListX[count].colmunShuyingzhiD = "";
          state.table2ListX.refresh();
          count++;
        }
        break;
      case 2: //修改本金
        Loading.show();
        if (s.isEmpty) {
          Loading.showToast(toast: '请输入金额 ${textEditingController.text} ');
          break;
        }
        if (!s.isNum) {
          Loading.showToast(toast: '请输入数字 ${textEditingController.text} ');
          break;
        }
        updateBenJin(s);
        break;
      case 3: //修改位置
        Loading.show();
        state.js2 = state.js1;
        state.totalValue[28] = "${state.js1}/${state.js2}";
        Loading.dismiss();
        break;
      case 4: //删除本页

        // _instance?.then((db) {
        //   db.rawQuery('DELETE FROM ${DbHelper.table1}');
        //   return db.rawQuery('DELETE FROM ${DbHelper.table2}');
        // }).then((value) => dropAll());

        Get.defaultDialog(
          barrierDismissible: false,
          title: '警告',
          content: const Text('是否删除全部数据'),
          onCancel: () {},
          onConfirm: () {
            Loading.show();
            BXDelete(Api.deleteall, success: (isSuccess, code, message, results) {
              if (isSuccess) {
                BXLoading.showToast(message);
                state.table1List.clear();
                state.table2ListX.clear();
                state.randomValue = '';
                List.generate(32, (index) => state.totalValue[index] = index.toString());
                _getStatisticalAreasData(-1);
              }
            });
            Get.back();
          },
        );
        break;
      case 5: //重置流水
        BXPost(
          Api.resetliushui,
          params: {"resetIndex": (state.table2ListX.first.id)},
          success: (bool isSuccess, int code, String message, List<dynamic> results) {},
        );
        break;
      case 6: //备份数据
        Loading.show();
        final Directory documentsDirectory = await getApplicationDocumentsDirectory();
        final Directory tempDir = await getTemporaryDirectory();
        final Directory? downloadsDir = await getDownloadsDirectory();
        print(documentsDirectory);
        print(tempDir);
        print(downloadsDir);

        _instance
            ?.then((db) => db.query(DbHelper.table1))
            .then((value1) => _instance?.then((db) => db.query(DbHelper.table2)).then((value2) => saveString('${jsonEncode(value1)}\n${jsonEncode(value2)}')));

        break;
      case 7:
        Get.defaultDialog(
          barrierDismissible: false,
          title: '警告',
          content: const Text('是否重启'),
          onCancel: () {},
          onConfirm: () {
            Loading.show();
            reStart();
            Get.back();
          },
        );
        break;
      case 8: //修改期望值
        if (s.isEmpty) {
          Loading.showToast(toast: '请输入期望值 ${textEditingController.text} ');
          break;
        }
        if (!s.isNum) {
          Loading.showToast(toast: '请输入数字 ${textEditingController.text} ');
          break;
        }
        updateQiWangZhi(s);
        break;
      case 9: //恢复数据
        Loading.show();
        getString();
        break;
      case 10: //修改赔率
        Loading.show();
        if (s.isEmpty) {
          Loading.showToast(toast: '请输入赔率 ${textEditingController.text} ');
          break;
        }
        if (!s.isNum) {
          Loading.showToast(toast: '请输入赔率 ${textEditingController.text} ');
          break;
        }
        updateOdds(s);
        break;
      case 11: //退出程序
        GetStore.getInstance().cleanUser();
        Get.offAndToNamed(AppRoutes.login);
        break;
    }
  }

  void dropAll() {
    state.table2ListX.clear();
    state.randomValue = '';
    List.generate(32, (index) => state.totalValue[index] = index.toString());
    _instance
        ?.then((db) => db.insert(DbHelper.table1,
            Table1Model(columnBenjin: "5000", columnYongJin: "0.95", columnMean: "0.08", columnRestartIndex: "0", columnLiushuiIndex: "0").toJson()))
        .then((value) => Loading.dismiss());
  }

  void updateQiWangZhi(String qiwangzhi) {
    // _instance?.then((db) => db.query(DbHelper.table1).then((value) => _instance?.then((db) => db
    //     .insert(
    //         DbHelper.table1,
    //         Table1Model(
    //           columnBenjin: value.last['column_benjin'].toString(),
    //           columnYongJin: value.last['column_yongJin'].toString(),
    //           columnMean: qiwangzhi,
    //           columnRestartIndex: value.last['column_restart_index'].toString(),
    //           columnLiushuiIndex: value.last['column_liushui_index'].toString(),
    //         ).toJson())
    //     .then((value) => queryAll()))));
    BXPost/*<Map<String,dynamic>>*/(Api.updateQiWangValue, params: {"mean": qiwangzhi}, success: (isSuccess, int code, String message, List<dynamic> results) {
      if (isSuccess) {
        BXLoading.showToast(message);
        print("期望值是=${(results[0]["mean"])}");
        queryAll();
      }
    });
  }

  /**
   * 利用文件存储数据
   */
  saveString(String s) async {
    final file = await getFile('file.text');
    //写入字符串
    file.writeAsString(s).then((value) {
      Loading.dismiss();
      print('=====备份完成=====');
    });
  }

  /**
   * 获取存在文件中的数据
   */
  Future getString() async {
    final file = await getFile('file.text');
    if (!await file.exists()) {
      Loading.dismiss();
      Loading.showToast(toast: '文件不存在');
      return;
    }
    var filePath = file.path;
    file.readAsString().then((String value) {
      var s = '文件存储路径：' + filePath;
      print(s);
      var split1 = value.split('\n')[0];
      print(jsonDecode(split1).length);
      print(split1);
      var split2 = value.split('\n')[1];
      print(jsonDecode(split2).length);
      print(split2);
      for (var element in jsonDecode(split1)) {
        _instance?.then((db) => db.insert(DbHelper.table1, element));
      }
      for (var element in jsonDecode(split2)) {
        _instance?.then((db) => db.insert(DbHelper.table2, element));
      }
      print('=====写入数据库完成====');
      queryAll();
    });
  }

  /**
   * 初始化文件路径
   */
  Future<File> getFile(String fileName) async {
    //获取应用文件目录类似于Ios的NSDocumentDirectory和Android上的 AppData目录
    final fileDirectory = await getApplicationDocumentsDirectory();

    //获取存储路径
    final filePath = fileDirectory.path;

    //或者file对象（操作文件记得导入import 'dart:io'）
    return File(filePath + "/" + fileName);
  }

  lockScreen() {
    _timer?.cancel();
    _timer = null;
    screenLock(
      config: const ScreenLockConfig(
        backgroundColor: Colors.black,
      ),
      onValidate: (input) => getFuture(input),
      secretsConfig: const SecretsConfig(
        spacing: 15, // or spacingRatio
        padding: EdgeInsets.all(40),
        //输入密码框的配置
        // secretConfig: SecretConfig(
        //   borderColor: Colors.red,
        //   borderSize: 1.0,
        //   disabledColor: Colors.black,
        //   enabledColor: Colors.red,
        // ),
      ),
      title: const Icon(Icons.lock, size: 30, color: Colors.white),
      context: Get.context!,
      correctString: '1234',
      canCancel: false,
      //是否可以取消
      onUnlocked: () {
        Get.back();
        onUserInteraction();
      },
    );
  }

  void onUserInteraction() {
    // 取消之前的计时器
    _timer?.cancel();
    // 设置新的计时器，时间设置为你想要的锁屏延时时间
    _timer = Timer(const Duration(seconds: 60 * 2), () {
      lockScreen();
    });
  }

  getFuture(String input) => Future.delayed(const Duration(milliseconds: 200), () {
        if (input.length == 4 && input == "0000") {
          return true;
        } else {
          Loading.showError(toast: '密码错误');
          return false;
        }
      });

  Future<String?> getDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String? deviceId;

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      // deviceId = androidInfo.board;
      // deviceId = androidInfo.hardware;//mt6762
      // deviceId = androidInfo.product;//dandelion
      // deviceId = androidInfo.tags;//release-keys
      deviceId = androidInfo.device; //release-keys
      print(androidInfo.toMap());
      deviceId = androidInfo.device; //release-keys
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      // iOS没有设备ID的概念，但可以使用idfv来获取用户标识符
      deviceId = iosInfo.identifierForVendor;
    }

    return deviceId;
  }

  juBuPingHeng(int index) {
    if (index == -1) {
      state.currentTempIndex = 0;
    } else {
      state.currentTempIndex = index;
    }
    if (state.table2ListX.isNotEmpty) _getStatisticalAreasData(index);
  }

  //下拉刷新
  void onRefresh() {
    state.isRefreshing.value = true;
    queryAll();
  }

  //加载更多
  void onLoadMore() {
    BXGet<Table2Model>(Api.loadMore,
        params: {"last_id": state.table2ListX.last.id, "uid": GetStore.getInstance().userModel.userId, "c": 10}, //"c"每页多少个数据
        success: (isSuccess, code, message, results) {
          if (isSuccess && results.isNotEmpty) {
            var temp = <Table2Model>[];
            temp.addAll(results);
            temp.addAll(state.table2ListX.reversed.toList());
            state.table2ListX.clear();
            state.table2ListX.value = temp.reversed.toList();
          }
          refreshcontroller.finishLoad(IndicatorResult.success, isSuccess);
        },
        onModel: (m) => Table2Model.fromJson(m));
  }

  srollChange() {
    scrollController1.animateTo(
      scrollController1.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }
}

class NewWidget extends StatefulWidget {
  final String title;

  const NewWidget(
    this.title, {
    super.key,
  });

  @override
  State<NewWidget> createState() => _NewWidgetState();
}

class _NewWidgetState extends State<NewWidget> {
  Timer? timer;

  @override
  Widget build(BuildContext context) {
    timer ??= Timer.periodic(const Duration(milliseconds: 500), (timer) => setState(() => Get.back()));
    return Center(
      child: Text(
        widget.title,
        style: const TextStyle(fontSize: 90),
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}

String removeChineseCharacters(String input) {
  return input.replaceAll(RegExp('[\u4e00-\u9fa5]'), '');
}
