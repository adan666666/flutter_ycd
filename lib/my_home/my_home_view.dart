import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../my_widget/auto_text.dart';
import 'my_home_logic.dart';
import 'my_home_state.dart';

class MyHomePage extends GetView<MyHomeLogic> {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return KeyboardDismissOnTap(
      dismissOnCapturedTaps: true,
      child: Listener(
        onPointerDown: (PointerDownEvent event) {
          controller.onUserInteraction();
        },
        child: Scaffold(
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: GestureDetector(
            onLongPress: () => controller.lockScreen(),
            child: FloatingActionButton(
              backgroundColor: Colors.transparent,
              onPressed: () => controller.setRandom((int _) => print(_)),
              child: Image.asset('assets/images/shai.png'),
            ),
          ),
          appBar: AppBar(
              actions: [
                GestureDetector(
                    onTap: () => controller.lockScreen(),
                    child: const Icon(
                      Icons.lock,
                      size: 20,
                      color: Colors.white,
                    )),
                GestureDetector(
                    onTap: () => controller.showBottomFunction(),
                    child: const Icon(
                      Icons.edit,
                      size: 20,
                      color: Colors.white,
                    )),
                const SizedBox(
                  width: 10,
                )
              ],
              elevation: 0,
              toolbarHeight: 0,
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
                //表格区
                /* ColoredBox(
                  color: controller.state.lineColor,
                  child: SizedBox(
                    height: ((MediaQuery.of(context).size.width - 3) / 4) / MyState.height * 8 + 4,
                    width: double.infinity,
                    child: Obx(() => GridView.builder(
                          gridDelegate:  const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: 0.5,
                            crossAxisSpacing: 0.5,
                            childAspectRatio: MyState.height,
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
                ),*/
                Obx(() => Table(
                      border: TableBorder(
                        //在右上下的边框线
                        // top: BorderSide(color: Colors.red),
                        // left: BorderSide(color: Colors.red),
                        // right: BorderSide(color: Colors.red),
                        // bottom: BorderSide(color: Colors.red),
                        //水平线
                        horizontalInside: BorderSide(color: controller.state.lineColor, width: 0.5),
                        //垂直线
                        verticalInside: BorderSide(color: controller.state.lineColor, width: 0.5),
                      ),
                      //单元格的宽， map哪列 ：宽度
                      columnWidths: const {
                        1: FlexColumnWidth(1),
                        0: IntrinsicColumnWidth(), //包裹内容
                        3: IntrinsicColumnWidth(),
                        2: FlexColumnWidth(1),
                      },
                      defaultVerticalAlignment: TableCellVerticalAlignment.middle, //垂直的位置
                      children: List.generate(
                          8,
                          (i) => TableRow(
                              decoration: BoxDecoration(color: controller.state.bgColor),
                              children: List.generate(
                                  4,
                                  (index) => GestureDetector(
                                        onTap: () {
                                          if (index == 2) controller.juBuPingHeng(0);
                                        },
                                        child: Center(
                                          child: Text(
                                              style: TextStyle(
                                                  height: 1.1,
                                                  //相当于padding
                                                  wordSpacing: 0,
                                                  fontSize: fontSize(i, index),
                                                  fontWeight: FontWeight.w300,
                                                  color: (i * 4 + index) == 2 && controller.state.currentTempIndex != 0
                                                      ? Colors.purpleAccent
                                                      : controller.state.textColor),
                                              controller.state.totalValue[i * 4 + index]),
                                        ),
                                      )).toList())).toList(),
                    )),
                //按钮功能区
                SizedBox(
                  height: 35,
                  child: Row(
                    children: [
                      divier2(Colors.black, 38),
                      buildButton(Colors.red, "P", 1),
                      divier2(Colors.black, 38),
                      buildButton(Colors.red, "B", 2),
                      divier2(Colors.black, 38),
                      buildButton(Colors.green, "P", 3),
                      divier2(Colors.black, 38),
                      buildButton(Colors.green, "B", 4),
                      divier2(Colors.black, 38),
                      GestureDetector(
                          onTap: () {
                            controller.deleteLast();
                          },
                          child: SizedBox(width: 65, child: Image.asset('assets/images/delete.png', width: 35, height: 35))),
                      Container(height: 25, width: 0.5, color: Colors.black),
                    ],
                  ),
                ),
                //列表
                Expanded(
                  child: Obx(() => GestureDetector(
                        onLongPress: () => controller.lockScreen(),
                        child: ColoredBox(
                          color: controller.state.listViewColor,
                          child: ListView.separated(
                            padding: const EdgeInsets.only(left: 6, right: 2),
                            controller: controller.scrollController,
                            itemCount: controller.state.table2List.length,
                            itemBuilder: (BuildContext context, int index) => buildItem(index),
                            separatorBuilder: (BuildContext context, int index) =>
                                Divider(height: 2, indent: 5, thickness: 0.3, color: index % 2 == 0 ? Colors.red : Colors.black),
                          ),
                        ),
                      )),
                ),
                //输入金额
                SafeArea(
                  bottom: true,
                  child: SizedBox(
                    height: 40,
                    child: TextField(
                      focusNode: controller.focusNode,
                      autofocus: false,
                      controller: controller.textEditingController,
                      onChanged: (value) {},
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      // ignorePointers: false,//是否可以用虚拟键盘
                      //过滤（仅只能输入数字，不能小数点.）
                      // inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      //限制只能输入数字
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        icon: Icon(CupertinoIcons.ant_fill),
                        contentPadding: EdgeInsets.only(bottom: 7),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(width: 1, color: Colors.blue)),
                        // border: OutlineInputBorder(borderSide: BorderSide(width: 5, color: Colors.red)),
                        // focusedBorder: OutlineInputBorder(borderSide: BorderSide(width: 1, color: Colors.blue)),
                        hintText: "请输入下注金额",
                        hintStyle: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  double fontSize(int i, int index) =>
      (i * 4 + index) == 15 || (i * 4 + index) == 3 || (i * 4 + index) == 20 || (i * 4 + index) == 24 || (i * 4 + index) == 16 ? 10 : 14;

  buildItem(int index) => SizedBox(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //序号
            GestureDetector(
              onTap: () => controller.juBuPingHeng(index),
              child: Container(
                color: controller.state.bgColor,
                width: 45,
                alignment: Alignment.centerRight,
                child: Text("${controller.state.table2List[index].table2Id + 1}"),
              ),
            ),
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
            SizedBox(
                width: 110,
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Text(
                    "${controller.state.table2List[index].colmunShuyingzhiD}",
                    style: TextStyle(
                      color: controller.state.table2List[index].colmunShuyingzhiD.toString().startsWith('-') ? Colors.green : Colors.redAccent,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Visibility(
                    visible: controller.state.table2List[index].colmunShuyingzhiD!.isNotEmpty,
                    child: GestureDetector(
                        onTap: () {
                          controller.updateSqlite(index);
                        },
                        child: Image.asset(height: 20, 'assets/images/delete.png')),
                  )
                ])),
            //下注值
            Container(
              width: 55,
              alignment: Alignment.centerRight,
              child: Text("${controller.state.table2List[index].columnXiazhujine}"),
            ),
            //胜负路
            sflContainer(index),
          ],
        ),
      );

  Container sflContainer(int index) => controller.state.table2List[index].colmunShengfulu == '正打'
      ? (controller.state.table2List[index].colmunRemark!.startsWith('-')
          ? Container(
              color: Colors.transparent,
              width: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  divier(Colors.grey.withOpacity(0.5), 15),
                  const SizedBox(width: 2),
                  const Text("1", style: TextStyle(color: Colors.green)),
                  const SizedBox(width: 8),
                  divier(Colors.grey.withOpacity(0.5), 15),
                  const SizedBox(width: 8),
                  const Text("1", style: TextStyle(color: Colors.green)),
                  const SizedBox(width: 2),
                  divier(Colors.grey.withOpacity(0.5), 15),
                ],
              ),
            )
          : Container(
              color: Colors.transparent,
              width: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  divier(Colors.grey.withOpacity(0.5), 15),
                  const Text("1", style: TextStyle(color: Colors.red)),
                  const SizedBox(width: 8),
                  divier(Colors.grey.withOpacity(0.5), 15),
                  const SizedBox(width: 8),
                  const Text("1", style: TextStyle(color: Colors.red)),
                  divier(Colors.grey.withOpacity(0.5), 15),
                ],
              ),
            ))
      : controller.state.table2List[index].colmunRemark!.startsWith('-')
          ? Container(
              color: Colors.transparent,
              width: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  divier(Colors.grey.withOpacity(0.5), 15),
                  const Text("1", style: TextStyle(color: Colors.green)),
                  const SizedBox(width: 8),
                  divier(Colors.grey.withOpacity(0.5), 15),
                  const SizedBox(width: 8),
                  const Text("1", style: TextStyle(color: Colors.red)),
                  divier(Colors.grey.withOpacity(0.5), 15),
                ],
              ),
            )
          : Container(
              color: Colors.transparent,
              width: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  divier(Colors.grey.withOpacity(0.5), 15),
                  const Text("1", style: TextStyle(color: Colors.red)),
                  const SizedBox(width: 8),
                  divier(Colors.grey.withOpacity(0.5), 15),
                  const SizedBox(width: 8),
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
                // borderColor: Colors.red,
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
                    color: Colors.green,
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
                    color: Colors.green,
                    dashArray: [1],
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
                    width: 1.0,
                    //线条宽度
                    enableTooltip: true,
                    //圆点的外边框颜色
                    pointColorMapper: (datum, index) => index % 3 == 0
                        ? index % 2 == 0
                            ? Colors.blue
                            : Colors.green
                        : index % 2 == 0
                            ? Colors.red
                            : Colors.purple,
                    //修饰数据点（显示圆圈）
                    markerSettings: const MarkerSettings(
                        height: 3,
                        width: 3,
                        //不传显示空心
                        color: Colors.green,
                        isVisible: true),
                    dataSource: controller.state.chartData,
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
          : const Text('data'),
    );
  }

  Container divier(Color color, double height) => Container(height: height, width: 1, color: color);

  Container divier2(Color color, double height) => Container(height: height, width: 5, color: Colors.transparent);

  buildButton(Color bg, String str, int i) => Expanded(
        child: Container(
          height: 32,
          child: TextButton(
            style: buildButtonStyle(bg),
            onLongPress: () {
              switch (i) {
                case 1:
                  controller.showBottomFunction();
                  break;
                case 2:
                  controller.lockScreen();
                  break;
              }
            },
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
        ),
      );

  buildButtonStyle(Color bg) => ButtonStyle(
        backgroundColor: MaterialStateProperty.all(bg),
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

class SinglePicker extends StatefulWidget {
  const SinglePicker({super.key});

  @override
  State<StatefulWidget> createState() => _SinglePickerState();
}

class _SinglePickerState extends State<SinglePicker> {
  final controller = Get.find<MyHomeLogic>();
  int selectIndex = 0;

  @override
  void initState() {
    selectIndex = controller.state.selectIndex.value;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Get.back();
                  controller.functionConfirm(selectIndex);
                },
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)),
                child: const Text(
                  "确定",
                  style: TextStyle(color: Colors.redAccent, fontSize: 20),
                ),
              ),
            ],
          ),
          Obx(() => Expanded(
                child: CupertinoPicker(
                    scrollController: controller.fixedExtentScrollController,
                    itemExtent: 50, // 每个选项的高度
                    onSelectedItemChanged: (int index) {
                      // 处理选中项的变化
                      selectIndex = index;
                    },
                    children: List.generate(
                      controller.state.functionTypes.length,
                      (index) => Align(
                        alignment: Alignment.center,
                        child: Text(controller.state.functionTypes[index].toString()),
                      ),
                    )),
              ))
        ],
      ),
    );
  }
}
