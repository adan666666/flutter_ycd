import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../my_db/Table1Model.dart';
import '../my_db/Table2Model.dart';

class MyState {
  static const OFFSET8431 = 8431;
  static const double height = 16 / 3;
  var isLoading = false;
  var isCanPress = true;
  var randomValue = ''; //随机的出来的庄闲
  var bettingMoney = '';
  var js1 = 0;//随机总数
  var js2 = 0;
  int currentTempIndex=0;
  var lineColor = Colors.black87.withOpacity(0.8);
  var listViewColor = const Color(0xFFE9EEDB);
  var bgColor = const Color(0xFFE9EEDB);
  var chartBgColor = Colors.black; //图表背景
  var textColor = Colors.black;
  var totalValue = <String>[].obs;
  var chartData /*图表数据*/ = <SalesData>[].obs;

  // List<SalesData> chartData/*图表数据*/ = List.generate(70, (index) =>SalesData(index.toString(),Random().nextInt(1).toDouble() )).toList().obs;

  var table1List = <Table1Model>[].obs;
  var table2List = <Table2Model>[].obs;

  var selectIndex=7.obs;
  var functionTypes = ['1.排列数据', '2.消除数据', '3.修改本金', '4.修改位置', '5.删除本页', '6.重置流水', '7.备份数据','8.重启系统','9.修改期望值','10.恢复数据','11.修改赔率'].obs;
}

class SalesData {
  SalesData(this.year, this.sales);

  int year;
  double sales;

  @override
  String toString() {
    return '{$sales}';
  }
}
