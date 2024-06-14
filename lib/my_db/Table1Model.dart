class Table1Model {
  String? columnBenjin;
  String? columnYongJin;//赔率
  String? columnMean;
  String? columnRestartIndex;
  String? columnLiushuiIndex;

  Table1Model(
      {this.columnBenjin,
        this.columnYongJin,
        this.columnMean,
        this.columnRestartIndex,
        this.columnLiushuiIndex});

  Table1Model.fromJson(Map<String, dynamic> json) {
    columnBenjin = json['column_benjin'];
    columnYongJin = json['column_yongJin'];
    columnMean = json['column_mean'];
    columnRestartIndex = json['column_restart_index'];
    columnLiushuiIndex = json['column_liushui_index'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['column_benjin'] = this.columnBenjin;
    data['column_yongJin'] = this.columnYongJin;
    data['column_mean'] = this.columnMean;
    data['column_restart_index'] = this.columnRestartIndex;
    data['column_liushui_index'] = this.columnLiushuiIndex;
    return data;
  }
}