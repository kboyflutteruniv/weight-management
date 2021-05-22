import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TopModel extends ChangeNotifier {
  bool saveDone = false;
  bool deleteDone = false;

  Future changeSaveDone(bool bool) {
    saveDone = bool;
    notifyListeners();
  }

  Future changeDeleteDone(bool bool) {
    deleteDone = bool;
    notifyListeners();
  }

  int currentIndex = 0;

  void onTabTapped(int index) async {
    currentIndex = index;

    notifyListeners();
  }
}
