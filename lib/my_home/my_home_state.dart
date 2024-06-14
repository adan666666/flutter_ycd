import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../my_db/Table1Model.dart';
import '../my_db/Table2Model.dart';

class MyState {
  MyState() {}
  static const OFFSET8431=8431;
  var isLoading = false;
  var lineColor = Colors.black87.withOpacity(0.8);
  var randomV='';//随机的出来的庄闲
  var bettingMoney='';
  var bgColor = Colors.green;
  var textColor = Colors.white;
  static const RATE = 0.95;
  var totalValue = <String>[].obs;
  var chartData/*图表数据*/ = <SalesData>[].obs;
  // List<SalesData> chartData/*图表数据*/ = List.generate(70, (index) =>SalesData(index.toString(),Random().nextInt(1).toDouble() )).toList().obs;

  var table1List=<Table1Model>[].obs;
  var table2List=<Table2Model>[].obs;
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
