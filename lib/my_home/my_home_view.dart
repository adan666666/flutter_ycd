import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../my_db/Table1Model.dart';
import '../my_db/Table2Model.dart';
import 'my_home_logic.dart';
import 'my_home_state.dart';

class MyHomePage extends GetView<MyHomeLogic> {
  const MyHomePage({super.key, required this.title});

  final String title;
  static const double height = 16 / 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.transparent,
        onPressed: () => controller.setRandom((int _) => print(_)),
        child: Image.asset('assets/images/shai.png'),
      ),
      appBar: AppBar(
          elevation: 0,
          toolbarHeight: 23,
          centerTitle: false,
          backgroundColor: controller.state.bgColor,
          title: Text(
            title,
            style: const TextStyle(fontSize: 12),
          )),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            //图表区
            Visibility(
              visible: true,
              child: buildChats(),
            ),
            //统计区
            ColoredBox(
              color: controller.state.lineColor,
              child: SizedBox(
                height: ((Get.width - 3) / 4) / height * 8 + 4,
                width: double.infinity,
                child: Obx(() => GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 0.5,
                        crossAxisSpacing: 0.5,
                        childAspectRatio: height,
                      ),
                      itemCount: controller.state.totalValue.length,
                      itemBuilder: (context, index) => Container(
                        alignment: Alignment.center,
                        color: controller.state.bgColor,
                        child: Text(controller.state.totalValue[index], textAlign: TextAlign.start, style: TextStyle(color: controller.state.textColor)),
                      ),
                    )),
              ),
            ),
            //按钮功能区
            SizedBox(
              height: 40,
              child: Row(
                children: [
                  buildButton("闲赢", 1),
                  divier(Colors.black, 38),
                  buildButton("庄赢", 2),
                  divier(Colors.black, 38),
                  buildButton("闲输", 3),
                  divier(Colors.black, 38),
                  buildButton("庄输", 4),
                  divier(Colors.black, 38),
                  buildButton("上一步", 5),
                  GestureDetector(onTap: () {}, child: SizedBox(width: 70, child: Image.asset('assets/images/restart2.png', width: 35, height: 35))),
                ],
              ),
            ),
            //列表
            Expanded(
              child: Obx(() => ColoredBox(
                    color: const Color(0xFFE9EEDB),
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      controller: controller.scrollController,
                      itemCount: controller.state.table2List.length,
                      itemBuilder: (BuildContext context, int index) => buildItem(index),
                      separatorBuilder: (BuildContext context, int index) => const Divider(color: Colors.black26),
                    ),
                  )),
            ),
            //输入金额
            TextField(
              controller: controller.textEditingController,
              onChanged: (value) {},
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(borderSide: BorderSide.none),
                hintText: "请输入下注金额",
              ),
            )
          ],
        ),
      ),
    );
  }

  buildItem(int index) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(child: Text("index${index + 1}")),
          Text("${index + 1}"),
          Row(children: [Text("${index + 1}"), const SizedBox(width: 5), Image.asset('assets/images/delete.png')]),
          Text("${index + 1}"),
          SizedBox(
            width: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                divier(Colors.grey.withOpacity(0.5), 8),
                const Text("1"),
                const SizedBox(width: 5),
                divier(Colors.grey.withOpacity(0.5), 8),
                const SizedBox(width: 5),
                const Text("1"),
                divier(Colors.grey.withOpacity(0.5), 8),
              ],
            ),
          ),
        ],
      );

  buildChats() {
    return Container(
      color: controller.state.bgColor,
      height: 80,
      child: SfCartesianChart(
        borderWidth: 0,
        borderColor: Colors.red,
        margin: EdgeInsets.zero,
        // plotAreaBackgroundColor: Colors.amber,//显示区颜色
        // plotAreaBorderColor: Colors.red, x轴外边框颜色

        // axes: const [
        //   NumericAxis(
        //     name: '你好',
        //     opposedPosition: false, //右侧显示
        //     title: AxisTitle(text: '金额（元）'),
        //   )
        // ],
        primaryXAxis: const CategoryAxis(
          majorTickLines: MajorTickLines(
            size: 1,
            color: Colors.amber,
            width: 1,
          ),
          rangePadding: ChartRangePadding.auto,
          //轴标题
          // title: AxisTitle(text: '1111'),
          //轴标题置顶
          opposedPosition: false,
          //是否显示标题
          isVisible: false,
          labelRotation: -45,
          edgeLabelPlacement: EdgeLabelPlacement.none,
          // maximum: 10,
          // minimum: 0,
          //x轴在外 或则内部
          labelPosition: ChartDataLabelPosition.inside,
          //x轴文案边框颜色
          borderColor: Colors.red,
          //x轴文案边框宽度
          borderWidth: 1,
          //x轴文案边框样式，分为所有边框和去掉了上下边框
          axisBorderType: AxisBorderType.withoutTopAndBottom,
          arrangeByIndex: false,
          labelPlacement: LabelPlacement.betweenTicks,
          // interactiveTooltip: InteractiveTooltip(
          //   borderRadius: 10,
          //   borderColor: Colors.blue,
          //   borderWidth: 10,
          // ),
        ),
        //y轴线，显示
        primaryYAxis: const NumericAxis(
          borderWidth: 0,
          rangePadding: ChartRangePadding.round,
          majorGridLines: MajorGridLines(
            width: 1,
            color: Colors.redAccent,
            dashArray: [1, 2, 3, 1, 2, 3, 1, 2, 3],
          ),
          //轴标题
          // title: AxisTitle(text: '1111'),
          //轴标题置顶
          opposedPosition: true,
          //是否显示标题
          isVisible: true,
          labelRotation: 0,
        ),

        // 图表标题
        // title: const ChartTitle(text: 'Half yearly sales analysis'),
        // Enable legend
        legend: const Legend(isVisible: false),
        // Enable tooltip 点了鼠标提示框
        tooltipBehavior: TooltipBehavior(enable: false),
        //系列；串联；连续
        series: <CartesianSeries<SalesData, String>>[
          LineSeries<SalesData, String>(
            width: 1.1,
            //线条宽度
            enableTooltip: true,
            //圆点的外边框颜色
            pointColorMapper: (datum, index) => Colors.redAccent,
            //修饰数据点（显示圆圈）
            markerSettings: const MarkerSettings(
                height: 5,
                width: 5,
                //不传显示空心
                color: Colors.transparent,
                isVisible: true),
            dataSource: controller.state.data,
            xValueMapper: (SalesData sales, _) => sales.year,
            yValueMapper: (SalesData sales, _) => sales.sales,
            //line color
            color: Colors.white,
            name: '卖',
            //具体的数字显示
            dataLabelSettings: const DataLabelSettings(isVisible: false),
          )
        ],
      ),
    );
  }

  Container divier(Color color, double height) => Container(height: height, width: 1, color: color);

  buildButton(String str, int i) {
    var bettingMoney = (controller.textEditingController.text);
    return Expanded(
      child: ElevatedButton(
        style: ButtonStyle(
          padding: MaterialStateProperty.all(EdgeInsetsGeometry.lerp(EdgeInsets.zero, EdgeInsets.zero, 0)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0), // 设置圆角大小
            ),
          ),
        ),
        onPressed: () {
          if (controller.state.randomV.isEmpty) {
            Get.snackbar("温馨提示", '请摇塞子', duration: const Duration(seconds: 2), snackPosition: SnackPosition.TOP);
            return;
          }
          if (bettingMoney.toString().isEmpty) {
            Get.snackbar("温馨提示", '请输入下注金额', duration: const Duration(seconds: 2), snackPosition: SnackPosition.TOP);
            return;
          }
          switch (i) {
            case 1: //闲赢
              if (controller.state.randomV == '庄') {
                var c = (bettingMoney as double) * double.parse(controller.state.totalValue[27]);
                controller.add(
                  table2: Table2Model(
                    colmunRemark: "-1",
                    colmunShengfulu: "-1",
                    colmunShuyingzhi: c.toString(),
                    colmunShuyingzhiD: c.toString(),
                    colmunZx: "1",
                  ),
                );
              } else if (controller.state.randomV == '闲') {
                var c = bettingMoney;
              }
              break;
            case 2: //庄赢
              controller.add(
                  table1: Table1Model(columnBenjin: "10000", columnYongJin: "0.95", columnMean: "0.08", columnRestartIndex: "0", columnLiushuiIndex: "10"));
              break;
            case 3: //闲输
              break;
            case 4: //庄输
              break;
            default:
              break;
          }
        },
        child: controller.state.isLoading
            ? const CupertinoActivityIndicator()
            : Text(
                '$str',
                style: const TextStyle(
                  color: Colors.black87,
                  height: 0,
                  fontSize: 10,
                ),
              ),
      ),
    );
  }
}

// Expanded(child: Container(height: double.infinity, color:controller.state.bgColor, child: Text(text, textAlign: TextAlign.center)));
