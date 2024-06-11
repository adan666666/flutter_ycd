import 'package:flutter/material.dart';

class MyButton extends StatefulWidget {
  const MyButton({
    super.key,
    this.width,
    this.height,
    this.onTap,
    this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
    this.color,
    this.padding = const EdgeInsets.only(left: 16, right: 16),
    this.waitTime = Duration.zero,
    this.onTapDownColor,
    this.shadow,
    this.shape = BoxShape.rectangle,
    this.margin,
    this.border,
  });

  final double? width;
  final double? height;
  final void Function()? onTap;
  final Widget? child;
  final BorderRadiusGeometry? borderRadius;
  final Color? color;
  final Color? onTapDownColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BoxBorder? border;
  final Duration waitTime;
  final BoxShadow? shadow;
  final BoxShape shape;

  @override
  State<MyButton> createState() => _MyButtonState();

  /// 大按钮，占据屏幕所有宽度的那种
  /// 例如登录页面用的
  /// 圆角可以自由设置，宽度是无限的
  factory MyButton.bigger() =>const MyButton();

  /// 小按钮，例如复制按钮
  /// 颜色是蓝色的
  factory MyButton.copy() =>const MyButton();

  /// 可拆单按钮
  /// 拆单专用
  factory MyButton.clip() =>const MyButton();

  /// 我要买按钮
  /// 小型按钮，蓝色
  factory MyButton.buy() =>const MyButton();

  /// 白色按钮
  /// 选中后会变色
  /// 这种按钮颜色不是固定的
  /// 宽度也不是固定的
  factory MyButton.check() =>const MyButton();
}

class _MyButtonState extends State<MyButton>
    with SingleTickerProviderStateMixin {
  bool isDisable = false;
  bool isTapDown = false;

  Future<void> onTapUp() async {
    setState(() {
      isDisable = true;
      isTapDown = false;
    });
    widget.onTap?.call();
    await Future.delayed(widget.waitTime);
    if (mounted) {
      setState(() {
        isDisable = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      borderRadius:
          widget.shape == BoxShape.circle ? null : widget.borderRadius,
      color: isTapDown && widget.onTapDownColor != null
          ? widget.onTapDownColor
          : widget.color,
      shape: widget.shape,
      boxShadow: widget.shadow == null ? null : [widget.shadow!],
      border: widget.border,
    );

    final buttonContent = Container(
      alignment: Alignment.center,
      width: widget.width,
      height: widget.height,
      decoration: decoration,
      clipBehavior: Clip.antiAlias,
      padding: widget.padding,
      margin: widget.margin,
      child: widget.child,
    );

    return GestureDetector(
      onTapDown: widget.onTap == null || isDisable
          ? null
          : (details) => setState(() => isTapDown = true),
      onTapUp:
          widget.onTap == null || isDisable ? null : (details) => onTapUp(),
      onTapCancel: () => setState(() => isTapDown = false),
      child: Opacity(
        opacity: isTapDown || isDisable ? 0.5 : 1,
        child: buttonContent,
      ),
    );
  }
}
