import 'package:flutter/material.dart';

class AppStateProvider extends ChangeNotifier {
  int coins = 0;
  int xp = 0;
  int level = 1;

  void addCoins(int value) {
    coins += value;
    notifyListeners();
  }

  void addXp(int value) {
    xp += value;
    notifyListeners();
  }

  void levelUp() {
    level += 1;
    notifyListeners();
  }
}