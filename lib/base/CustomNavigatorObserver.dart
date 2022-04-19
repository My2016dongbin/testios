import 'package:flutter/cupertino.dart';

class CustomNavigatorObserver extends NavigatorObserver {
  static CustomNavigatorObserver _instance = CustomNavigatorObserver();

  static CustomNavigatorObserver getInstance() {
    return _instance;
  }
}
