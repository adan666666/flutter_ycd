


import 'package:sqflite/sqflite.dart';

class DbHelper {
  final String path = "my.db"; // 数据库名称 一般不变
  static const table1 = "table_ycd1";
  static const table2 = "table_ycd2";//历史记录
  //私有构造
  DbHelper._();
  static DbHelper? _instance;
  static DbHelper get instance => _getInstance();
  factory DbHelper() {
    return instance;
  }
  static DbHelper _getInstance() {
    _instance ??= DbHelper._();
    return _instance ?? DbHelper._();
  }
  Future<Database>? _db;

  Future<Database>? getDb() {
    _db ??= _initDb();
    return _db;
  }
  // Guaranteed to be called only once.保证只调用一次
  Future<Database> _initDb() async {
    // 这里是我们真正创建数据库的地方 vserion代表数据库的版本，如果版本改变
    //，则db会调用onUpgrade方法进行更新操作
    final db =
    await openDatabase(path, version: 1, onCreate: (db, version) {
      // 数据库创建完成
      db.execute("create table $table1 (column_benjin text not null, column_yongJin text not null,column_mean text,column_restart_index text,column_liushui_index text)");
      db.execute("create table $table2 (table2Id int not null,column_xiazhujine text not null, colmun_shuyingzhi text not null,colmun_shuyingzhi_d text,colmun_shengfulu text,colmun_zx text,colmun_remark text,column_current_jin text)");
    }, onUpgrade: (db, oldV, newV) {
      // 升级数据库调用
      ///  db 数据库
      ///   oldV 旧版本号
      //   newV 新版本号
      //   升级完成就不会在调用这个方法了
    });

    return db;
  }

// 关闭数据库
  close() async {
    await _db?.then((value) => value.close());
  }
}