import 'package:flutter/material.dart';

class AutoText extends StatefulWidget {
  /// 要显示的文字
  final String text;

  ///指定text的父容器的宽度
  ///必须制定宽度
  final double width;

  ///最小的字体大小
  ///默认最小是6
  final double minTextSize;

  ///正常的字体大小
  ///默认值是14
  final double? textSize;

  /// 正常的字体大小
  /// 默认值是14
  final Color? textColor;

  /// 字体的样式
  final TextStyle? textStyle;

  AutoText({Key? key, String? text, this.textStyle, required this.width, double? minTextSize, this.textColor, double? textSize})
      : this.minTextSize = minTextSize ?? 6,
        this.textSize = textSize != null
            ? textSize
            : textStyle != null
                ? textStyle.fontSize
                : 14,
        this.text = text ?? '',
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    //定义开始的text样式
    TextStyle textFieldTextStyle = textStyle ?? TextStyle(fontSize: textSize, color: textColor);

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: text,
        style: textFieldTextStyle,
      ),
    );
    textPainter.layout();
    State state = AutoTextState(textPainter, textFieldTextStyle);

    return state;
  }
}

class AutoTextState extends State<AutoText> with TickerProviderStateMixin {
  final GlobalKey _autoTextKey = GlobalKey();

  // double _textWidth = 0.0;
  double _fontSize = 0;
  late final TextPainter textPainter;
  late final TextStyle textFieldTextStyle;

  late AnimationController _controller;

  AutoTextState(this.textPainter, this.textFieldTextStyle);

  @override
  void initState() {
    super.initState();
    _fontSize = widget.textSize!;
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 200))
      ..addStatusListener((status) {
        double? containerWidth = widget.width ?? _autoTextKey.currentContext?.size?.width; //始终是-2
        if (status == AnimationStatus.completed) {
          //当前没有缩放前的text宽度

          var textWidth = textPainter.width;
          var fontSize = textFieldTextStyle.fontSize;
          /**
           * only text width largger than Container Width can do while
           */
          if (textWidth > containerWidth!) {
            while (textWidth > containerWidth && fontSize! > widget.minTextSize) {
              fontSize -= 0.5;
              textPainter.text = TextSpan(
                text: widget.text,
                style: textFieldTextStyle.copyWith(fontSize: fontSize),
              );
              textPainter.layout();
              textWidth = textPainter.width;
            }
            setState(() {
              // _textWidth = textWidth;
              _fontSize = fontSize!;
            });
          }
        }
      });
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
        scale: CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
        ),
        child: Text(maxLines: 1, widget.text, key: _autoTextKey, style: textFieldTextStyle.copyWith(fontSize: _fontSize,overflow: TextOverflow.visible)));
  }
}
