class Table2Model {
  int? columnXiazhujine;
  String? colmunShuyingzhi;
  String? colmunShuyingzhiD;
  String? colmunShengfulu;
  String? colmunZx;
  String? colmunRemark;
  String? columnCurrentJin;

  Table2Model({
    this.columnXiazhujine,
    this.colmunShuyingzhi,
    this.colmunShuyingzhiD,
    this.colmunShengfulu,
    this.colmunZx,
    this.colmunRemark,
    this.columnCurrentJin,
  });

  Table2Model.fromJson(Map<String, dynamic> json) {
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
