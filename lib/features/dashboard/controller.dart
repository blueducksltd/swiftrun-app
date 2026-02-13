import 'package:get/get.dart';

class DashboardController extends GetxController {
  static const int homeTabIndex = 0;
  static const int historyTabIndex = 1;
  static const int profileTabIndex = 2;

  final RxInt pageIndex = homeTabIndex.obs;

  void changePage(int index) {
    pageIndex.value = index;
  }

  void goToProfile() {
    changePage(profileTabIndex);
  }
}

