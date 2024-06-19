import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
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
          backgroundColor: controller.state.chartBgColor,
          title: Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.white),
          )),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            //图表区
            buildChats(),
            //列表区
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
                        child: ColoredBox(
                            color: Colors.transparent,
                            child: Text(controller.state.totalValue[index],
                                textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: controller.state.textColor))),
                      ),
                    )),
              ),
            ),
            //按钮功能区
            SizedBox(
              height: 40,
              child: Row(
                children: [
                  divier2(Colors.black, 38),
                  buildButton("P", 1),
                  divier2(Colors.black, 38),
                  buildButton("B", 2),
                  divier2(Colors.black, 38),
                  buildButton("P", 3),
                  divier2(Colors.black, 38),
                  buildButton("B", 4),
                  divier2(Colors.black, 38),
                  GestureDetector(
                      onTap: () {
                        controller.deleteLast();
                      },
                      child: SizedBox(width: 70, child: Image.asset('assets/images/delete.png', width: 35, height: 35))),
                  Container(height: 25, width: 0.5, color: Colors.black),
                  GestureDetector(
                      onTap: () {
                        controller.reStart();
                      },
                      child: SizedBox(width: 70, child: Image.asset('assets/images/restart2.png', width: 35, height: 35))),
                ],
              ),
            ),
            //列表
            Expanded(
              child: Obx(() => ColoredBox(
                    color: controller.state.listViewColor,
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: controller.textEditingController,
                onChanged: (value) {},
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.only(left: 20),
                  border: OutlineInputBorder(borderSide: BorderSide(width: 5, color: Colors.red)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(width: 1, color: Colors.blue)),
                  hintText: "请输入下注金额",
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  buildItem(int index) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          //序号
          Text("${controller.state.table2List[index].table2Id + 1}"),
          //输赢
          Container(
            width: 80,
            alignment: Alignment.centerRight,
            child: Text(
              controller.state.table2List[index].colmunShuyingzhi.toString(),
              style: TextStyle(
                color: controller.state.table2List[index].colmunShuyingzhi.toString().startsWith('-') ? Colors.green : Colors.redAccent,
              ),
            ),
          ),
          //消数
          Container(
              width: 110,
              color: Colors.transparent,
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Text(
                  "${controller.state.table2List[index].colmunShuyingzhiD}",
                  style: TextStyle(
                    color: controller.state.table2List[index].colmunShuyingzhiD.toString().startsWith('-') ? Colors.green : Colors.redAccent,
                  ),
                ),
                const SizedBox(width: 5),
                GestureDetector(
                    onTap: () {
                      controller.updateSqlite(index);
                    },
                    child: Image.asset(height: 30, 'assets/images/delete.png'))
              ])),
          //下注值
          Container(
            width: 80,
            alignment: Alignment.centerRight,
            color: Colors.transparent,
            child: Text("${controller.state.table2List[index].columnXiazhujine}"),
          ),
          //胜负路
          SflContainer(index),
        ],
      );

  Container SflContainer(int index) => controller.state.table2List[index].colmunShengfulu == '正打'
      ? (controller.state.table2List[index].colmunRemark!.startsWith('-')
          ? Container(
              color: Colors.transparent,
              width: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  divier(Colors.grey.withOpacity(0.5), 15),
                  const Text("1", style: TextStyle(color: Colors.green)),
                  const SizedBox(width: 5),
                  divier(Colors.grey.withOpacity(0.5), 15),
                  const SizedBox(width: 5),
                  const Text("1", style: TextStyle(color: Colors.green)),
                  divier(Colors.grey.withOpacity(0.5), 15),
                ],
              ),
            )
          : Container(
              color: Colors.transparent,
              width: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  divier(Colors.grey.withOpacity(0.5), 15),
                  const Text("1", style: TextStyle(color: Colors.red)),
                  const SizedBox(width: 5),
                  divier(Colors.grey.withOpacity(0.5), 15),
                  const SizedBox(width: 5),
                  const Text("1", style: TextStyle(color: Colors.red)),
                  divier(Colors.grey.withOpacity(0.5), 15),
                ],
              ),
            ))
      : controller.state.table2List[index].colmunRemark!.startsWith('-')
          ? Container(
              color: Colors.transparent,
              width: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  divier(Colors.grey.withOpacity(0.5), 15),
                  const Text("1", style: TextStyle(color: Colors.green)),
                  const SizedBox(width: 5),
                  divier(Colors.grey.withOpacity(0.5), 15),
                  const SizedBox(width: 5),
                  const Text("1", style: TextStyle(color: Colors.red)),
                  divier(Colors.grey.withOpacity(0.5), 15),
                ],
              ),
            )
          : Container(
              color: Colors.transparent,
              width: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  divier(Colors.grey.withOpacity(0.5), 15),
                  const Text("1", style: TextStyle(color: Colors.red)),
                  const SizedBox(width: 5),
                  divier(Colors.grey.withOpacity(0.5), 15),
                  const SizedBox(width: 5),
                  const Text("1", style: TextStyle(color: Colors.green)),
                  divier(Colors.grey.withOpacity(0.5), 15),
                ],
              ),
            );

  buildChats() {
    return Obx(
      () => controller.state.chartData.isNotEmpty
          ? SizedBox(
              height: 70,
              child: SfCartesianChart(
                backgroundColor: controller.state.chartBgColor,
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
                    dataSource: controller.state.chartData.value,
                    xValueMapper: (SalesData sales, _) => "${sales.year}",
                    yValueMapper: (SalesData sales, _) => sales.sales,
                    //line color
                    color: Colors.white,
                    name: '卖',
                    //具体的数字显示
                    dataLabelSettings: const DataLabelSettings(isVisible: false),
                  )
                ],
              ),
            )
          : Text('data'),
    );
  }

  Container divier(Color color, double height) => Container(height: height, width: 1, color: Colors.transparent);

  Container divier2(Color color, double height) => Container(height: height, width: 5, color: Colors.transparent);

  buildButton(String str, int i) => Expanded(
        child: TextButton(
          style: buildButtonStyle(),
          onPressed: () {
            switch (i) {
              case 1: //闲赢
                controller.add(1, 'table2');
                break;
              case 2: //庄赢
                controller.add(2, 'table2');
                break;
              case 3: //闲输
                controller.add(3, 'table2');
                break;
              case 4: //庄输
                controller.add(4, 'table2');
                break;
            }
          },
          child: controller.state.isLoading
              ? const CupertinoActivityIndicator()
              : Text(
                  '$str',
                  style: const TextStyle(
                    color: Colors.black38,
                    fontWeight: FontWeight.bold,
                    height: 0,
                    fontSize: 18,
                  ),
                ),
        ),
      );

  buildButtonStyle() => ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.grey.shade100),
        overlayColor: MaterialStateProperty.all(Colors.red.shade100),
        padding: MaterialStateProperty.all(EdgeInsetsGeometry.lerp(EdgeInsets.zero, EdgeInsets.zero, 0)),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0), // 设置圆角大小
          ),
        ),
      );
}

// Expanded(child: Container(height: double.infinity, color:controller.state.bgColor, child: Text(text, textAlign: TextAlign.center)));
