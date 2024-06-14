class Table2Model {
  int table2Id=0;
  String? columnXiazhujine; //下注金额
  String? colmunShuyingzhi; //输赢值
  String? colmunShuyingzhiD; //输赢值(消数列的)
  String? colmunShengfulu;
  String? colmunZx;
  String? colmunRemark; //输赢标记
  String? columnCurrentJin;

  Table2Model({
    required this.table2Id,
    this.columnXiazhujine,
    this.colmunShuyingzhi,
    this.colmunShuyingzhiD,
    this.colmunShengfulu,
    this.colmunZx,
    this.colmunRemark,
    this.columnCurrentJin,
  });

  Table2Model.fromJson(Map<String, dynamic> json) {
    table2Id = json['table2Id'];
    columnXiazhujine = json['column_xiazhujine'];
    colmunShuyingzhi = json['colmun_shuyingzhi'];
    colmunShuyingzhiD = json['colmun_shuyingzhi_d'];
    colmunShengfulu = json['colmun_shengfulu'];
    colmunZx = json['colmun_zx'];
    colmunRemark = json['colmun_remark'];
    columnCurrentJin = json['column_current_jin'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['table2Id'] = this.table2Id;
    data['column_xiazhujine'] = this.columnXiazhujine;
    data['colmun_shuyingzhi'] = this.colmunShuyingzhi;
    data['colmun_shuyingzhi_d'] = this.colmunShuyingzhiD;
    data['colmun_shengfulu'] = this.colmunShengfulu;
    data['colmun_zx'] = this.colmunZx;
    data['colmun_remark'] = this.colmunRemark;
    data['column_current_jin'] = this.columnCurrentJin;
    return data;
  }
}
