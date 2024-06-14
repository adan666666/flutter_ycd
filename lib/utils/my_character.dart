import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class MyCharacter {
  /// 格式化金额
  static String getMoney(
    double value, {
    int? fixed,
  }) {
    // 把传入的数精确到两位小数点
    List<String> valueStringList = [];

    // 整数部分用来在此计算
    int valueInt = 0;

    if (fixed == null || fixed == 0) {
      valueInt = value.toInt();
    } else {
      valueStringList = value.toStringAsFixed(fixed).split('.');
      valueInt = int.parse(valueStringList[0]);
    }

    // 用来装格式化好的数字
    List<String> intLIst = [];

    // 把整数部分格式化成 1,234,56 的形式
    while (valueInt > 1000) {
      if (valueInt % 1000 < 10) {
        intLIst.insert(0, '00${valueInt % 1000}');
      } else if (valueInt < 100) {
        intLIst.insert(0, '0${valueInt % 1000}');
      } else {
        intLIst.insert(0, (valueInt % 1000).toString());
      }

      valueInt = valueInt ~/ 1000;
    }

    // 把第一位放入容器
    intLIst.insert(0, valueInt.toString());

    var intResault = getListToString(intLIst, spacer: ',');

    // 返回完整的结构
    return fixed == null || fixed == 0
        ? intResault
        : '$intResault.${valueStringList[1]}';
  }

  /// 数组转字符串
  static String getListToString(List value, {String? spacer}) {
    String valueInt = '';
    for (int i = 0; i < value.length; i++) {
      if (spacer == null || i == value.length - 1) {
        valueInt += value[i].toString();
      } else {
        valueInt += value[i].toString() + spacer;
      }
    }
    return valueInt;
  }

  /// 取字符串后两位:隐藏手机号码
  static String getLastTwo(String value) {
    if (value.isEmpty) return '';
    return value.substring(value.length - 2);
  }

  /// 隐藏邮箱地址
  static String getEmailHide(String value) {
    if (value.isEmpty) return '';
    List<String> part_1 = value.split('@');
    return '${getLastTwo(part_1[0])}@${part_1[1]}';
  }

  /// 字符串去掉空白字符
  static String getClear(String value) {
    return value.replaceAll(RegExp(r"\s+\b|\b\s"), '');
  }

  /// 字符串转二进制数组
  static Uint8List encode(dynamic data) {
    String jsonString;

    // 根据输入类型转换为 JSON 字符串
    if (data is Map || data is List) {
      jsonString = jsonEncode(data);
    } else if (data is int || data is double || data is bool) {
      jsonString = data.toString();
    } else if (data is String) {
      jsonString = data;
    } else {
      throw ArgumentError('Unsupported input type');
    }

    // 使用 Gzip 压缩字符串
    List<int> stringBytes = utf8.encode(jsonString);
    List<int> compressedBytes = gzip.encode(stringBytes);

    return Uint8List.fromList(compressedBytes);
  }

  /// 二进制数组转字符串
  static String decode(Uint8List data) {
    // 尝试解压缩数据
    List<int> decompressedData = zlib.decode(data);
    String jsonString = utf8.decode(decompressedData);
    // Map<String,dynamic> jsonData = json.decode(jsonString);

    // 将解压缩后的数据转换为字符串
    return jsonString;
  }
}
