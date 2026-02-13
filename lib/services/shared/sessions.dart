import 'dart:developer';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager extends GetxService {
  static SessionManager get to => Get.find();

  late final SharedPreferences? sharedPreferences;

  Future<SessionManager> init() async {
    sharedPreferences = await SharedPreferences.getInstance();
    return this;
  }

  Future<bool> setString(String key, String value) async {
    return await sharedPreferences!.setString(key, value);
  }

  Future<bool> setBool(String key, bool value) async {
    return await sharedPreferences!.setBool(key, value);
  }

  Future<bool> setInt(String key, int value) async {
    log("SetInt");
    return await sharedPreferences!.setInt(key, value);
  }

  Future<bool> setList(String key, List<String> value) async {
    return await sharedPreferences!.setStringList(key, value);
  }

  int getInt(String key) {
    return sharedPreferences!.getInt(key) ?? 0;
  }

  String getString(String key) {
    return sharedPreferences!.getString(key) ?? '';
  }

  bool getBool(String key) {
    return sharedPreferences!.getBool(key) ?? false;
  }

  List<String> getList(String key) {
    return sharedPreferences!.getStringList(key) ?? [];
  }

  Future<bool> remove(String key) async {
    return await sharedPreferences!.remove(key);
  }

  Future<bool> removeAll() async {
    return await sharedPreferences!.clear();
  }
}
