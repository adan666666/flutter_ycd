class DBManager{
  // /// 查 全部all
  // static Future<List<BookSelfModel>> queryAll() async {
  //   List<BookSelfModel> list = [];
  //   await DbHelper.instance
  //       .getDb()
  //       ?.then((db) => db.query(DbHelper.historyTab).then((value) {
  //     for (var data in value) {
  //       list.add(BookSelfModel.fromJson(data));
  //     }
  //   }));
  //   return list;
  // }
}

// {
// @ColumnInfo(name = "column_benjin") //本金
// public Double columnBenJin;
// @ColumnInfo(name = "column_yongJin") //赔率
// public Double columnYongJin;
// @ColumnInfo(name = "column_mean") //期望
// public Double columnQiWang;
// @ColumnInfo(name = "column_restart_index") //重启位置
// public Integer columnRestartIndex;
// @ColumnInfo(name = "column_liushui_index") //流水位置
// public Integer columnLiushuiIndex;
// }