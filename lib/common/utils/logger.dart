import 'dart:developer';

import 'package:flutter/foundation.dart';

class Logger {
  static LogMode _logMode = LogMode.debug;

  static void init(LogMode mode) {
    Logger._logMode = mode;
  }

  static void error(dynamic data, {StackTrace? stackTrace}) {
    if (_logMode == LogMode.debug) {
      if (kDebugMode) {
        log("Error: $data $stackTrace ");
      }
    }
  }

  static void i(dynamic data) {
    if (_logMode == LogMode.debug) {
      if (kDebugMode) {
        log("Report: $data");
      }
    }
  }
}

enum LogMode { debug, live }
