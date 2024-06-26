import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wakelock/wakelock.dart';
import 'package:ycd/my_db/DbHelper.dart';
import 'package:ycd/my_db/Table1Model.dart';
import 'package:ycd/utils/loading.dart';
import '../my_db/Table2Model.dart';
import 'my_home_state.dart';
import 'my_home_view.dart';

class MyHomeLogic extends GetxController {
  final MyState state = MyState();
  Future<Database>? _instance;

  final scrollController = ScrollController();
  final textEditingController = TextEditingController();
  final focusNode = FocusNode();

  FixedExtentScrollController? fixedExtentScrollController;

// 定义一个计时器，用于延时锁屏
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    Wakelock.enable();
    onUserInteraction();
    _instance = DbHelper.instance.getDb();

    List.generate(32, (index) => state.totalValue.add('$index'));

    queryAll();
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
    Wakelock.disable();
    textEditingController.dispose();
  }

  setRandom(Function(int) f) {
    if (!state.isCanPress) {
      return;
    }
    state.isCanPress = false;
    state.js2 = state.js2 + 1;
    state.totalValue[28] = "${state.js1}/${state.js2}";
    if (next(1, 90485) > 44625 - MyState.OFFSET8431) {
      state.totalValue[30] = '庄';
      state.randomValue = '庄';
    } else {
      state.totalValue[30] = '闲';
      state.randomValue = '闲';
    }
    Get.dialog(NewWidget(state.randomValue),barrierDismissible: false,barrierColor: Colors.black.withOpacity(0.18));
    state.isCanPress = true;
  }

  int next(int min, int max) => min + Random().nextInt(max - min + 1);

  queryAll() {
    _instance?.then((db) {
      db.query(DbHelper.table1).then((value) {
        state.table1List.clear();
        for (var data in value) {
          state.table1List.add(Table1Model.fromJson(data));
        }
        state.totalValue[0] = '${state.table1List.last.columnBenjin}'; //本金
        state.totalValue[19] = '${state.table1List.last.columnMean}'; //期望值
        state.chartData.value = List.generate(50, (index) => SalesData(index, double.parse(state.table1List.last.columnBenjin.toString()))).toList();
        _queryAllTable2();
      });
    });
  }

  add(int i, String tableName, {Table1Model? table1, Table2Model? table2}) {
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
        }
        scrollController.jumpTo(scrollController.position.maxScrollExtent + 35);
        if (state.table2List.isNotEmpty) {
          //统计区计算
          statisticalArea();
        } else {
          state.isCanPress = true;
          Loading.dismiss();
        }
      });
    });
  }

  getCharts() {
    var chartDataTemp = <double>[];
    if (state.table2List.length <= state.chartData.length) {
      for (var i = 0; i < state.table2List.length; i++) {
        chartDataTemp.add(double.parse(state.table2List[i].columnCurrentJin.toString()));
      }
    } else {
      for (var i = state.table2List.length - state.chartData.length; i < state.table2List.length; i++) {
        chartDataTemp.add(double.parse(state.table2List[i].columnCurrentJin.toString()));
      }
    }
    if (chartDataTemp.isNotEmpty) {
      var z = 0;
      for (var i = chartDataTemp.length - 1; i >= 0; i--) {
        z++;
        state.chartData[state.chartData.length - z].sales = chartDataTemp[i];
      }
      var removeLast = state.chartData.removeLast();
      Future.delayed(const Duration(milliseconds: 300), () => state.chartData.add(removeLast));
    }
  }

  void statisticalArea() {
    //图表区
    getCharts();

    //统计区，计算
    state.totalValue[1] = '${state.table2List.length}'; //一共打多少手

    //总体
    var zt_y = 0;
    var zt_s = 0;
    var zt_syz = 0.0;
    var runningWater = 0.0;
    var countLianShengFu = 1;
    var zCount = 0;
    var it = state.table2List;
    for (var index = 0; index < state.table2List.length; index++) {
      var element = state.table2List[index];
      zt_syz += double.parse(element.colmunShuyingzhi.toString());
      runningWater += double.parse(element.columnXiazhujine.toString());
      if (element.colmunRemark!.startsWith("-1")) {
        zt_s--;
      } else {
        zt_y++;
      }
      //连胜负
      if (it.length > 1 && (index - 1) >= 0) {
        var shuyingzhi = it[(index - 1)].colmunShuyingzhi; //上一个
        var shuyingzhi1 = element.colmunShuyingzhi;
        if ((double.parse(shuyingzhi1!) > 0 && double.parse(shuyingzhi!) > 0) || (double.parse(shuyingzhi1) < 0 && double.parse(shuyingzhi!) < 0)) {
          countLianShengFu++;
        } else {
          countLianShengFu = 1;
        }
      }
      //庄个数
      if(element.colmunZx=='庄')zCount++;
    }
    state.totalValue[5] = '$zt_y'; //胜
    state.totalValue[9] = '${(zt_y / double.parse(state.totalValue[1]) * 100).toStringAsFixed(2)}%'; //胜率
    state.totalValue[13] = '${zt_y.abs() - zt_s.abs()}'; //净胜~须多少手回到50%
    state.totalValue[17] = zt_syz.toStringAsFixed(3); //一共输赢多少钱
    state.totalValue[21] =
        state.totalValue[13] == '0' ? '-' : (zt_syz / double.parse(removeChineseCharacters(state.totalValue[13])).abs()).toStringAsFixed(2); //平均赢
    var d = (double.parse(state.totalValue[1]) + 1) * double.parse(state.totalValue[19]); //期望一共的值
    var parse = int.parse(state.totalValue[13]).abs();
    state.totalValue[25] = state.totalValue[13] == '0'
        ? '-'
        : zt_syz < 0
            ? '须${((zt_syz.abs() + d) / parse).toStringAsFixed(1)}x$parse'
            : '可负${((zt_syz.abs() - d) / parse).toStringAsFixed(1)}x$parse'; //还需，可负
    state.totalValue[29] = '${state.table1List.last.columnRestartIndex}'; //重启位置
    state.totalValue[8] = '${state.table1List.last.columnLiushuiIndex}'; //流水索引
    state.totalValue[12] = '';
    state.totalValue[16] = '';

    state.totalValue[4] = (double.parse(state.totalValue[0]) + zt_syz).toStringAsFixed(2); //当前金额

    //局部
    int index = state.table1List.isEmpty ? 0 : int.parse(state.table1List.last.columnRestartIndex.toString()); //重启位置
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
    state.totalValue[10] = jb_count == 0 ? "" : '${(jb_y / jb_count * 100).toStringAsFixed(2)}%'; //胜率
    state.totalValue[14] = '${jb_y.abs() - jb_s.abs()}'; //净胜~须多少手回到50%
    state.totalValue[18] = jb_syz.toStringAsFixed(3); //一共输赢多少钱
    state.totalValue[22] =
        state.totalValue[14] == '0' ? "-" : (jb_syz / double.parse(removeChineseCharacters(state.totalValue[14])).abs()).toStringAsFixed(3); //平均赢
    var dJ = (jb_count + 1) * double.parse(state.totalValue[19]); //期望一共的值
    parse = int.parse(state.totalValue[14]).abs();
    state.totalValue[26] = state.totalValue[14] == '0'
        ? "-"
        : jb_syz < 0
            ? parse == 0
                ? ''
                : '须${((jb_syz.abs() + dJ) / parse).toStringAsFixed(1)}x$parse'
            : parse == 0
                ? ''
                : '可负${((jb_syz.abs() - dJ) / parse).toStringAsFixed(1)}x$parse';

    ///第四列
    state.totalValue[3] = '流水${runningWater.toStringAsFixed(0)}';
    state.totalValue[7] = '均利${(zt_syz / state.table2List.length).toStringAsFixed(2)}';
    state.totalValue[11] = '连胜负$countLianShengFu';
    state.totalValue[15] = '$zCount/${int.parse(state.totalValue[1])}';
    state.totalValue[23] = '${state.table1List.last.columnYongJin}'; //赔率
    state.totalValue[27] = state.totalValue[14] == '0'
        ? ""
        : state.totalValue[21] == '-'
            ? ""
            : (double.parse(removeChineseCharacters(state.totalValue[25].split("x")[0])) / double.parse(state.totalValue[23])).toStringAsFixed(2); //打庄需要
    state.totalValue[31] = state.totalValue[14] == '0'
        ? ""
        : state.totalValue[22] == '-'
            ? ""
            : (double.parse(removeChineseCharacters(state.totalValue[26].split("x")[0])) / double.parse(state.totalValue[23])).toStringAsFixed(2);

    //预测平均值
    if (textEditingController.text.isNotEmpty) {
      ///总体
      state.totalValue[20] = pVal1();

      ///局部
      state.totalValue[24] = pVal2();
    }
    state.isCanPress = true;
    Loading.dismiss();
  }

  getCurrentJin(int i, double playMoney) {
    var lastJinE = state.table2List.isEmpty
        ? double.parse(state.table1List.last.columnBenjin.toString())
        : double.parse(state.table2List.last.columnCurrentJin.toString());
    switch (i) {
      case 1:
        return (lastJinE + playMoney);
      case 2:
        return (lastJinE) + playMoney * double.parse(state.totalValue[23]);
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
        var xx = parse * double.parse(state.totalValue[23]);
        String syz /*庄赢值*/ = xx.toStringAsFixed(2); //四舍五入保留两位小数
        return syz;
      case 3:
      case 4:
        return '-${state.bettingMoney}';
    }
  }

  void deleteLast() {
    if (state.table2List.isNotEmpty) {
      _instance?.then((db) => db.delete(DbHelper.table2, where: 'table2Id =?', whereArgs: [state.table2List.last.table2Id]).then((value) => queryAll()));
    }
  }

  void updateSqlite(int index) {
    _instance?.then((db) => db.update(DbHelper.table2, state.table2List[index].toJson()..update("colmun_shuyingzhi_d", (value) => "") /*具体更新的数据*/,
        where: "table2Id =?", //通过id查找需要更新的数据
        whereArgs: [index])).then((value) => _queryAllTable2());
  }

  void reStart() {
    // valueC.last..update('column_restart_index', (value) => "${state.table2List.length - 1}")
    _instance?.then((_db) => _db.query(DbHelper.table1).then((value) => _instance?.then((db) {
          //重启时，清除消数列数据
          for (int i = 0; i < state.table2List.length; i++) {
            db.update(DbHelper.table2, state.table2List[i].toJson()..update('colmun_shuyingzhi_d', (value) => ''),
                where: 'table2Id =?', whereArgs: [state.table2List[i].table2Id]);
          }
          return db
              .insert(
                  DbHelper.table1,
                  Table1Model(
                    columnBenjin: value.last['column_benjin'].toString(),
                    columnYongJin: value.last['column_yongJin'].toString(),
                    columnMean: value.last['column_mean'].toString(),
                    columnRestartIndex: "${state.table2List.length}",
                    columnLiushuiIndex: value.last['column_liushui_index'].toString(),
                  ).toJson())
              .then((value) => queryAll());
        })));
  }

  void updateBenJin(String b) {
    _instance?.then((db) => db.query(DbHelper.table1).then((value) => _instance?.then((db) => db
        .insert(
            DbHelper.table1,
            Table1Model(
              columnBenjin: b,
              columnYongJin: value.last['column_yongJin'].toString(),
              columnMean: value.last['column_mean'].toString(),
              columnRestartIndex: value.last['column_restart_index'].toString(),
              columnLiushuiIndex: value.last['column_liushui_index'].toString(),
            ).toJson())
        .then((value) => queryAll()))));
  }

  Future<void> functionConfirm(int i) async {
    switch (i) {
      case 0: //排序
        Loading.show();
        var list =
            state.table2List.map((element) => element.colmunShuyingzhiD.toString().isEmpty ? 0.0 : double.parse(element.colmunShuyingzhiD.toString())).toList()
              ..removeWhere((element) => element == 0.0)
              ..sort();
        _instance?.then((db) {
          var x = 0;
          for (int i = state.table2List.length - 1; i >= state.table2List.length - list.length; i--) {
            x++;
            if (x > list.length) {
              break;
            }
            db.update(DbHelper.table2, state.table2List[i].toJson()..update('colmun_shuyingzhi_d', (value) => '${list[list.length - x]}'),
                where: 'table2Id =?', whereArgs: [state.table2List[i].table2Id]);
          }
        }).then((value) => _queryAllTable2());
        break;
      case 1: //清除数据
        Loading.show();
        _instance?.then((db) {
          for (int i = 0; i < state.table2List.length; i++) {
            if (state.table2List[i].colmunShuyingzhiD!.isEmpty) continue;
            db.update(DbHelper.table2, state.table2List[i].toJson()..update('colmun_shuyingzhi_d', (value) => ''),
                where: 'table2Id =?', whereArgs: [state.table2List[i].table2Id]);
          }
        }).then((value) => queryAll());
        break;
      case 2:
        Loading.show();
        if (textEditingController.text.toString().isEmpty) {
          Loading.showToast(toast: '请输入金额 ${textEditingController.text} ');
          break;
        }
        if (!textEditingController.text.toString().isNum) {
          Loading.showToast(toast: '请输入数字 ${textEditingController.text} ');
          break;
        }
        updateBenJin(textEditingController.text.toString());
        break;
      case 3:
        Loading.show();
        state.js2 = state.js1;
        state.totalValue[28] = "${state.js1}/${state.js2}";
        Loading.dismiss();
        break;
      case 4: //删除本页
        Loading.show();
        _instance?.then((db) {
          db.rawQuery('DELETE FROM ${DbHelper.table1}');
          return db.rawQuery('DELETE FROM ${DbHelper.table2}');
        }).then((value) => dropAll());
        break;
      case 5:
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
        if (textEditingController.text.toString().isEmpty) {
          Loading.showToast(toast: '请输入期望值 ${textEditingController.text} ');
          break;
        }
        if (!textEditingController.text.toString().isNum) {
          Loading.showToast(toast: '请输入数字 ${textEditingController.text} ');
          break;
        }
        updateQiWangZhi(textEditingController.text.toString());
        break;
      case 9: //恢复数据
        Loading.show();
        getString();
        break;
    }
  }

  void dropAll() {
    state.table2List.clear();
    state.randomValue = '';
    List.generate(32, (index) => state.totalValue[index] = index.toString());
    _instance
        ?.then((db) => db.insert(DbHelper.table1,
            Table1Model(columnBenjin: "5000", columnYongJin: "0.95", columnMean: "0.08", columnRestartIndex: "0", columnLiushuiIndex: "0").toJson()))
        .then((value) => Loading.dismiss());
  }

  void updateQiWangZhi(String qiwangzhi) {
    _instance?.then((db) => db.query(DbHelper.table1).then((value) => _instance?.then((db) => db
        .insert(
            DbHelper.table1,
            Table1Model(
              columnBenjin: value.last['column_benjin'].toString(),
              columnYongJin: value.last['column_yongJin'].toString(),
              columnMean: qiwangzhi,
              columnRestartIndex: value.last['column_restart_index'].toString(),
              columnLiushuiIndex: value.last['column_liushui_index'].toString(),
            ).toJson())
        .then((value) => queryAll()))));
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
        if (input.length == 4) {
          return true;
        } else {
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
