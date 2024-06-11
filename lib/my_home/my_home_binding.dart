import 'package:get/get.dart';

import 'my_home_logic.dart';

class MyHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MyHomeLogic());
  }
}
