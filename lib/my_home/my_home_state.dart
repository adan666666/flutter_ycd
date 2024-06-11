import 'dart:ffi';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../my_db/Table1Model.dart';
import '../my_db/Table2Model.dart';

class MyState {
  MyState() {}
  static const OFFSET8431=8431;
  var isLoading = false;
  var lineColor = Colors.black87;
  var randomV='';
  var bgColor = Colors.green;
  var textColor = Colors.white;
  static const RATE = 0.95;
  var totalValue = <String>[].obs;
  List<SalesData> data = List.generate(150, (index) =>SalesData(index.toString(),Random().nextInt(1050).toDouble() )).toList();

  var table1List=<Table1Model>[].obs;
  var table2List=<Table2Model>[].obs;
}

class SalesData {
  SalesData(this.year, this.sales);

  final String year;
  final double sales;
}
