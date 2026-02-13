import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class HomeState {
  RxBool isObscure = false.obs;
  RxBool isLoading = false.obs;
  // late StreamSubscription? requestSubscription;

  // Change from 'late StreamSubscription' to nullable
  StreamSubscription<QuerySnapshot>? requestSubscription;

  // RxList<QueryDocumentSnapshot<Map<String, dynamic>>> requestData =
  //     <QueryDocumentSnapshot<Map<String, dynamic>>>[].obs;
  var requestData = <DocumentSnapshot>[].obs;
}
