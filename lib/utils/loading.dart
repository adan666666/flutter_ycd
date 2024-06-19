import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

enum ToastType {
  getX,
  easyLoading,
}

class Loading {
  static const int val = 2;

  static show({String? content}) {
    configLoading();
    //弹窗loading
    EasyLoading.show(
        indicator: SizedBox(
          width: 80,
          height: 80,
          child: Center(
            child: LoadingAnimationWidget.flickr(
              leftDotColor: const Color(0xFF1A1A3F),
              rightDotColor: const Color(0xFFEA3799),
              size: 35,
            ),
          ),
        ),
        maskType: EasyLoadingMaskType.clear,
        status: content);
  }

  //移除loading
  static dismiss() {
    EasyLoading.dismiss();
  }

  static showToast({
    required String toast,
    int? interval,
    ToastType toastType = ToastType.easyLoading,
  }) {
    if (toastType == ToastType.getX) {
      Get.snackbar(
        "温馨提示",
        toast,
        duration: Duration(seconds: interval ?? val),
        snackPosition: SnackPosition.TOP,
      );
    } else {
      toastConfig();
      EasyLoading.showToast(
        toast,
        duration: Duration(seconds: interval ?? val),
        toastPosition: EasyLoadingToastPosition.center,
      );
    }
  }

  static showError({
    required String toast,
    int? interval,
  }) {
    Get.snackbar(
      "发现错误",
      toast,
      maxWidth: Get.width * 0.8,
      colorText: Colors.white,
      backgroundColor: Colors.black.withOpacity(0.4),
      duration: const Duration(
        seconds: 2,
      ),
      animationDuration: const Duration(
        milliseconds: 500,
      ),
      snackPosition: SnackPosition.TOP,
    );
  }

  static configLoading() {
    EasyLoading.instance
      ..displayDuration = const Duration(seconds: val)
      ..indicatorType = EasyLoadingIndicatorType.fadingCircle
      ..loadingStyle = EasyLoadingStyle.custom
      ..backgroundColor = Colors.transparent
      ..indicatorSize = 45.0
      ..radius = 10.0
      ..indicatorColor = Colors.white
      ..textColor = Colors.black
      ..maskColor = Colors.blue.withOpacity(0.5)
      ..userInteractions = true
      ..dismissOnTap = false
      ..maskColor = Colors.transparent
      ..boxShadow = <BoxShadow>[];
  }

  static toastConfig() {
    EasyLoading.instance
      ..displayDuration = const Duration(seconds: val)
      ..indicatorType = EasyLoadingIndicatorType.fadingCircle
      ..loadingStyle = EasyLoadingStyle.dark
      ..backgroundColor = Colors.black
      ..indicatorSize = 45.0
      ..radius = 10.0
      ..indicatorColor = Colors.white
      ..textColor = Colors.white
      ..maskColor = Colors.blue.withOpacity(0.5)
      ..userInteractions = true
      ..dismissOnTap = false;
  }
}

/*
* LoadingInWidget(
*       //隐藏和显示loading
        showLoading: true or false,
        * //传如需要加载loading的局部组件
        child: Container(

        ),
      ),
* **/

//局部容器剧中显示loading
class LoadingInWidget extends StatelessWidget {
  final bool? showLoading;
  final Widget child;

  const LoadingInWidget({
    super.key,
    this.showLoading = true,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
       if(showLoading!) Center(
          child: LoadingAnimationWidget.flickr(
            leftDotColor: const Color(0xFF1A1A3F),
            rightDotColor: const Color(0xFFEA3799),
            size: 30,
          ),
        ),
      ],
    );
  }
}
