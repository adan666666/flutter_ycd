import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ycd/my_db/DbHelper.dart';
import 'package:ycd/my_db/Table1Model.dart';
import '../my_db/Table2Model.dart';
import 'my_home_state.dart';

class MyHomeLogic extends GetxController {
  final MyState state = MyState();
  Future<Database>? _instance;

  var scrollController = ScrollController();
  var textEditingController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _instance = DbHelper.instance.getDb();
    List.generate(32, (index) {
      if (index==23){
        state.totalValue.add('${MyState.RATE}');
      }else {
        state.totalValue.add('$index');
      }
    });
  }

  @override
  void onClose() {
    super.onClose();
  }

  @override
  void onReady() {
    super.onReady();
    queryAll();
  }

  setRandom(Function(int) f) {
    if (next(1, 90485) > 44625 - MyState.OFFSET8431) {
      state.totalValue[30] = '庄';
      state.randomV='庄';
    } else {
      state.totalValue[30] = '闲';
      state.randomV='闲';
    }
  }

  int next(int min, int max) => min + Random().nextInt(max - min + 1);

  queryAll() {
    _instance?.then((db) {
      db.query(DbHelper.table1).then((value) {
        state.table1List.clear();
        for (var data in value) {
          state.table1List.add(Table1Model.fromJson(data));
          scrollController.jumpTo(scrollController.position.maxScrollExtent + 50);
        }
      });
    });
  }

  add({Table1Model? table1,Table2Model? table2}) {
    _instance?.then((value) => value.insert(DbHelper.table1, table1!.toJson())).then((value) => queryAll());
  }
}
