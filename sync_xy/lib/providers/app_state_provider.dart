import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:sync_xy/models/task.dart';
import 'package:sync_xy/models/note.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:sync_xy/models/bank_account.dart';
import 'package:sync_xy/models/reward.dart';

class AppStateProvider with ChangeNotifier {
  int _coins = 0;
  int _xp = 0;
  int _level = 1;
  BankAccount bankAccount = BankAccount();
  int lineOfCredit = 50;
  int creditTaken = 0;
  int depositInterest = 0;
  List<Task> _tasks = [];
  List<Note> notes = [];
  List<Reward> _rewards = []; // Rewards list
  List<Map<String, dynamic>> _historyLog = [];
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  DateTime lastCheckedDate = DateTime.now();
  final String lastCheckedKey = 'lastCheckedDate';

  // Keys for SharedPreferences
  final String coinsKey = 'coins';
  final String xpKey = 'xp';
  final String levelKey = 'level';
  final String themeModeKey = 'themeMode';

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;
  List<Task> get tasks => _tasks;
  List<Reward> get rewards => _rewards;
  int get coins => _coins;
  int get xp => _xp;
  int get level => _level;
  List<Map<String, dynamic>> get historyLog => _historyLog;

  int _lineOfCreditUpgradeCost = 100;
  int get lineOfCreditUpgradeCost => _lineOfCreditUpgradeCost;

  int _creditInterestUpgradeCost = 50;
  int get creditInterestUpgradeCost => _creditInterestUpgradeCost;

  int _depositInterestUpgradeCost = 75;
  int get depositInterestUpgradeCost => _depositInterestUpgradeCost;

  void setThemeMode(ThemeMode themeMode) {
    _themeMode = themeMode;
    _saveThemeMode();
    notifyListeners();
  }

  Future<void> _saveThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    String mode;
    switch (_themeMode) {
      case ThemeMode.light:
        mode = 'light';
        break;
      case ThemeMode.dark:
        mode = 'dark';
        break;
      case ThemeMode.system:
        mode = 'system';
        break;
    }
    await prefs.setString(themeModeKey, mode);
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    String? mode = prefs.getString(themeModeKey);
    if (mode != null) {
      switch (mode) {
        case 'light':
          _themeMode = ThemeMode.light;
          break;
        case 'dark':
          _themeMode = ThemeMode.dark;
          break;
        case 'system':
        default:
          _themeMode = ThemeMode.system;
          break;
      }
    } else {
      _themeMode = ThemeMode.system;
    }
  }

  void resetHistoryLog() {
    _historyLog.clear();
    _saveHistoryLog();
    notifyListeners();
  }

  void deleteAllTasks() {
    _tasks.clear();
    _saveTasks();
    notifyListeners();
  }

  void deleteRewards() {
    _rewards.clear();
    _saveRewards();
    notifyListeners();
  }

  void resetCoins() {
    _coins = 0;
    _saveUserData();
    notifyListeners();
  }

  void resetXPAndLevel() {
    _xp = 0;
    _level = 1;
    _saveUserData();
    notifyListeners();
  }

  void resetAll() {
    resetHistoryLog();
    deleteAllTasks();
    deleteRewards();
    resetCoins();
    resetXPAndLevel();
  }

  AppStateProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadTasks();
    await _loadNotes();
    await _loadRewards();
    await _loadHistoryLog();
    await _loadLastCheckedDate();
    await _loadThemeMode();
    await _loadUserData(); 
    checkAndUpdateTasks();
    await _saveLastCheckedDate(); 
    notifyListeners();
  }

  Future<void> _loadLastCheckedDate() async {
    final prefs = await SharedPreferences.getInstance();
    String? lastCheckedString = prefs.getString(lastCheckedKey);
    if (lastCheckedString != null) {
      lastCheckedDate = DateTime.parse(lastCheckedString);
    } else {
      lastCheckedDate = DateTime.now();
    }
  }

  Future<void> _saveLastCheckedDate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(lastCheckedKey, DateTime.now().toIso8601String());
  }

  // Add Reward
  void addReward(String title, String description, int cost) {
    _rewards.add(Reward(title: title, description: description, cost: cost));
    _saveRewards();
    notifyListeners();
  }

  // Update Reward
  void updateReward(int index, String title, String description, int cost) {
    if (index >= 0 && index < _rewards.length) {
      _rewards[index] = Reward(title: title, description: description, cost: cost);
      _saveRewards();
      notifyListeners();
    }
  }

  // Buy Reward
  void buyReward(int index) {
    Reward reward = _rewards[index];
    if (_coins >= reward.cost) {
      _coins -= reward.cost;
      addToHistoryLog(
        Task(
          name: 'Purchased Reward: ${reward.title}',
          coins: reward.cost,
          xp: 0,
          type: 'once',
          endDate: DateTime.now(),
          penalty: '0%',
        ),
        'purchase',
      );
      notifyListeners();
    }
  }

  // Save Rewards
  Future<void> _saveRewards() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(_rewards.map((reward) => reward.toJson()).toList());
    await prefs.setString('rewards', encodedData);
  }

  // Load Rewards
  Future<void> _loadRewards() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString('rewards');
    if (encodedData != null) {
      final List<dynamic> decodedData = jsonDecode(encodedData);
      _rewards = decodedData.map((item) => Reward.fromJson(item)).toList();
      notifyListeners();
    }
  }

  // **Methods to Save and Load Coins, XP, Level**

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(coinsKey, _coins);
    await prefs.setInt(xpKey, _xp);
    await prefs.setInt(levelKey, _level);
    // Save bankAccount as part of user data.
    await prefs.setString('bankAccount', jsonEncode(bankAccount.toJson()));
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _coins = prefs.getInt(coinsKey) ?? 0;
    _xp = prefs.getInt(xpKey) ?? 0;
    _level = prefs.getInt(levelKey) ?? 1;
    // Load bankAccount from user data.
    String? bankAccountString = prefs.getString('bankAccount');
    if (bankAccountString != null) {
      bankAccount = BankAccount.fromJson(jsonDecode(bankAccountString));
    }
  }

  // **Updating Methods to Save User Data After Changes**

  void addCoins(int value) {
    _coins += value;
    _saveUserData();
    notifyListeners();
  }

  void addXp(int value) {
    _xp += value;
    int threshold = 100 * (1 << (_level - 1));
    // Level up as long as the accumulated XP exceeds the threshold.
    while (_xp >= threshold) {
      _xp -= threshold;
      _level++;
      threshold = 100 * (1 << (_level - 1)); // Recalculate for the new level.
    }
    _saveUserData();
    notifyListeners();
  }

  void levelUp() {
    _level += 1;
    _saveUserData();
    notifyListeners();
  }

  void addTask(Task task) {
    _tasks.add(task);
    _saveTasks();
    notifyListeners();
  }

  void updateTask(int index, Task newTask) {
    _tasks[index] = newTask;
    _saveTasks();
    notifyListeners();
  }

  // **Ensure Task Completion Also Saves User Data**

  void toggleTaskCompletion(int index) {
    _tasks[index].toggleCompletion();
    if (_tasks[index].isCompleted) {
      addCoins(_tasks[index].coins);
      addXp(_tasks[index].xp);
      addToHistoryLog(_tasks[index], 'Task Completed');
    }
    _saveTasks();
    notifyListeners();
  }

  void deleteTask(int index) {
    _tasks.removeAt(index);
    _saveTasks();
    notifyListeners();
  }

  void addToHistoryLog(Task task, String action) {
    _historyLog.add({
      'date': DateTime.now().toIso8601String(),
      'name': task.name, // Ensure this field is correctly populated
      'coins': task.coins,
      'xp': task.xp,
      'action': action,
    });
    _saveHistoryLog();
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(_tasks.map((task) => task.toJson()).toList());
    await prefs.setString('tasks', encodedData);
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString('tasks');
    if (encodedData != null) {
      final List<dynamic> decodedData = jsonDecode(encodedData);
      _tasks = decodedData.map((item) => Task.fromJson(item)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveHistoryLog() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(_historyLog);
    await prefs.setString('historyLog', encodedData);
  }

  Future<void> _loadHistoryLog() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString('historyLog');
    if (encodedData != null) {
      _historyLog = List<Map<String, dynamic>>.from(jsonDecode(encodedData));
      notifyListeners();
    }
  }


  Future<void> scheduleDailyTaskCheck() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'daily_task_check',
      'Daily Task Check',
      channelDescription: 'Check tasks daily at 00:00',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Daily Task Check',
      'Check and update tasks',
      _nextInstanceOfMidnight(),
      platformChannelSpecifics,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexact,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    debugPrint('Scheduled daily task check');
  }

  tz.TZDateTime _nextInstanceOfMidnight() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 0);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  void checkAndUpdateTasks() {
    final DateTime now = DateTime.now();
    final int daysPassed = now.difference(lastCheckedDate).inDays;
    if (daysPassed <= 0) return; // No days passed, no action needed

    bool tasksUpdated = false;

    for (int i = _tasks.length - 1; i >= 0; i--) {
      final Task task = _tasks[i];
      if (now.isAfter(task.endDate)) {
        if (task.type == 'once') {
          if (!task.isCompleted) {
            _applyPenalty(task, 1);
            _logHistory(task, 1, 'Penalty applied for once task overdue');
          }
          _tasks.removeAt(i);
          tasksUpdated = true;
        } else if (task.type == 'daily') {
          int overdueDays = now.difference(task.endDate).inDays;
          overdueDays = overdueDays > daysPassed ? daysPassed : overdueDays;
          if (!task.isCompleted) {
            _applyPenalty(task, overdueDays);
            _logHistory(task, overdueDays, 'Penalty applied for $overdueDays day(s) overdue');
          }
          // Reset task state
          task.isCompleted = false;
          // Update end date to today
          task.endDate = now;
          tasksUpdated = true;
        }
      }
    }

    if (tasksUpdated) {
      _saveTasks();
      notifyListeners();
    }
  }

  // **Ensure Penalty Application Also Saves User Data**

  void _applyPenalty(Task task, int days) {
    double penaltyRate = double.parse(task.penalty.replaceAll('%', '')) / 100;
    int penaltyCoins = (task.coins * penaltyRate * days).toInt();
    int penaltyXP = (task.xp * penaltyRate * days).toInt();

    _coins = (_coins - penaltyCoins) < 0 ? 0 : (_coins - penaltyCoins);
    _xp = (_xp - penaltyXP) < 0 ? 0 : (_xp - penaltyXP);

    _saveUserData();

    addToHistoryLog(task, 'Penalty applied: -$penaltyCoins coins, -$penaltyXP XP for $days day(s) overdue');
  }

  void _logHistory(Task task, int days, String action) {
    _historyLog.add({
      'date': DateTime.now().toIso8601String(),
      'task': task.name,
      'days': days,
      'action': action,
    });
    _saveHistoryLog();
    // Notify user
    // Assuming you have access to BuildContext or use another method
  }

  void resetTasks() {
    DateTime now = DateTime.now();
    for (int i = _tasks.length - 1; i >= 0; i--) {
      Task task = _tasks[i];
      if (isNextDay(task.endDate, now)) {
        if (task.type == 'once') {
          if (!task.isCompleted) {
            applyPenalty(task);
          }
          _tasks.removeAt(i);
        } else if (task.type == 'daily') {
          if (!task.isCompleted) {
            applyPenalty(task);
          } else {
            task.isCompleted = false;
          }
          task.endDate = now;
        }
        _saveTasks();
      }
    }
    notifyListeners();
  }

  bool isNextDay(DateTime taskDate, DateTime currentDate) {
    return taskDate.day != currentDate.day ||
           taskDate.month != currentDate.month ||
           taskDate.year != currentDate.year;
  }

  void applyPenalty(Task task) {
    double penaltyRate = double.parse(task.penalty.replaceAll('%', '')) / 100;
    _coins -= (task.coins * penaltyRate).toInt();
    _xp -= (task.xp * penaltyRate).toInt();
    addToHistoryLog(task, 'penalty');
  }

  // Bank-related methods
  void deposit(int amount) {
    if (amount > 0 && amount <= _coins) {
      _coins -= amount;
      bankAccount.accountBalance += amount;
      _saveUserData();
      notifyListeners();
    }
  }

  void withdraw(int amount) {
    if (amount > 0 && amount <= bankAccount.accountBalance) {
      bankAccount.accountBalance -= amount;
      _coins += amount;
      _saveUserData();
      notifyListeners();
    }
  }

  void takeCredit(int amount) {
    if (amount <= (lineOfCredit - creditTaken)) {
      creditTaken += amount;
      _coins += amount;
      notifyListeners();
    }
  }

  void increaseLineOfCredit() {
    if (_coins >= lineOfCreditUpgradeCost) {
      bankAccount.lineOfCredit += 100; // adjust increment as necessary
      _coins -= lineOfCreditUpgradeCost;
      _saveUserData();
      notifyListeners();
    }
  }

  void decreaseCreditInterest() {
    if (_coins >= creditInterestUpgradeCost && bankAccount.creditInterest > 5) {
      bankAccount.creditInterest -= 5;
      _coins -= creditInterestUpgradeCost;
      _saveUserData();
      notifyListeners();
    } else {
      // Optionally show an error that the minimum interest rate of 5% is reached
    }
  }

  void increaseDepositInterest() {
    if (_coins >= depositInterestUpgradeCost && bankAccount.depositInterest < 100) {
      bankAccount.depositInterest += 1;
      _coins -= depositInterestUpgradeCost;
      _saveUserData();
      notifyListeners();
    } else {
      // Optionally handle error if maximum is reached or insufficient coins are available.
    }
  }

  void resetATMActions() {
    bankAccount.accountBalance = 0;
    bankAccount.creditTaken = 0;
    _saveUserData();
    notifyListeners();
  }

  void resetUpgrades() {
    bankAccount.lineOfCredit = 50;
    bankAccount.creditInterest = 90.0;
    bankAccount.depositInterest = 0.0;
    _saveUserData();
    notifyListeners();
  }

  // Note management methods
  void addNote(Note note) {
    notes.add(note);
    _saveNotes();
    notifyListeners();
  }

  void updateNote(int index, Note newNote) {
    notes[index] = newNote;
    _saveNotes();
    notifyListeners();
  }

  void deleteNote(int index) {
    notes.removeAt(index);
    _saveNotes();
    notifyListeners();
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(notes.map((note) => note.toJson()).toList());
    await prefs.setString('notes', encodedData);
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString('notes');
    if (encodedData != null) {
      final List<dynamic> decodedData = jsonDecode(encodedData);
      notes = decodedData.map((item) => Note.fromJson(item)).toList();
      notifyListeners();
    }
  }
}