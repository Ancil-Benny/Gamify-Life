import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:sync_xy/models/task.dart';
import 'package:sync_xy/models/note.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class AppStateProvider extends ChangeNotifier {
  int coins = 0;
  int xp = 0;
  int level = 1;
  int accountBalance = 0;
  int creditInterest = 5; // 5%
  int lineOfCredit = 1000;
  int creditTaken = 0;
  int lineOfCreditUpgradeCost = 100;
  int creditInterestUpgradeCost = 250;
  int depositInterestUpgradeCost = 100;
  int depositInterest = 0;
  List<Task> tasks = [];
  List<Note> notes = [];
  List<Map<String, dynamic>> historyLog = [];
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  AppStateProvider() {
    _loadTasks();
    _loadNotes();
    _loadHistoryLog();
    _initializeNotifications();
    scheduleDailyTaskCheck();
  }

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

  void addTask(Task task) {
    tasks.add(task);
    _saveTasks();
    notifyListeners();
  }

  void updateTask(int index, Task newTask) {
    tasks[index] = newTask;
    _saveTasks();
    notifyListeners();
  }

  void toggleTaskCompletion(int index) {
    tasks[index].toggleCompletion();
    if (tasks[index].isCompleted) {
      addCoins(tasks[index].coins);
      addXp(tasks[index].xp);
      addToHistoryLog(tasks[index], 'completed');
    }
    _saveTasks();
    notifyListeners();
  }

  void deleteTask(int index) {
    tasks.removeAt(index);
    _saveTasks();
    notifyListeners();
  }

  void addToHistoryLog(Task task, String action) {
    historyLog.add({
      'date': DateTime.now().toIso8601String(),
      'name': task.name,
      'coins': task.coins,
      'xp': task.xp,
      'action': action,
    });
    _saveHistoryLog();
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(tasks.map((task) => task.toJson()).toList());
    await prefs.setString('tasks', encodedData);
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString('tasks');
    if (encodedData != null) {
      final List<dynamic> decodedData = jsonDecode(encodedData);
      tasks = decodedData.map((item) => Task.fromJson(item)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveHistoryLog() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(historyLog);
    await prefs.setString('historyLog', encodedData);
  }

  Future<void> _loadHistoryLog() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString('historyLog');
    if (encodedData != null) {
      historyLog = List<Map<String, dynamic>>.from(jsonDecode(encodedData));
      notifyListeners();
    }
  }

  Future<void> _initializeNotifications() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
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
    debugPrint('Checking and updating tasks at $now');
    for (int i = 0; i < tasks.length; i++) {
      final task = tasks[i];
      if (task.type == 'once' && task.endDate.isBefore(now)) {
        if (!task.isCompleted) {
          _applyPenalty(task);
        }
        tasks.removeAt(i);
        i--;
      } else if (task.type == 'daily') {
        if (task.isCompleted) {
          task.isCompleted = false;
        } else {
          _applyPenalty(task);
        }
      }
    }
    _saveTasks();
  }

  void _applyPenalty(Task task) {
    // Implement penalty logic here
    final penaltyPercentage = int.parse(task.penalty.replaceAll('%', ''));
    final penaltyCoins = (task.coins * penaltyPercentage / 100).toInt();
    final penaltyXp = (task.xp * penaltyPercentage / 100).toInt();
    coins -= penaltyCoins;
    xp -= penaltyXp;
    notifyListeners();
  }

  // Bank-related methods
  void deposit(int amount) {
    if (amount <= coins) {
      coins -= amount;
      accountBalance += amount;
      notifyListeners();
    }
  }

  void withdraw(int amount) {
    if (amount <= accountBalance) {
      accountBalance -= amount;
      coins += amount;
      notifyListeners();
    }
  }

  void takeCredit(int amount) {
    if (amount <= lineOfCredit - creditTaken) {
      creditTaken += amount;
      coins += amount;
      notifyListeners();
    }
  }

  void increaseLineOfCredit() {
    if (coins >= lineOfCreditUpgradeCost) {
      coins -= lineOfCreditUpgradeCost;
      lineOfCredit += 100;
      lineOfCreditUpgradeCost *= 2;
      notifyListeners();
    }
  }

  void decreaseCreditInterest() {
    if (creditInterest > 5 && coins >= creditInterestUpgradeCost) {
      coins -= creditInterestUpgradeCost;
      creditInterest -= 5;
      creditInterestUpgradeCost *= 2;
      notifyListeners();
    }
  }

  void increaseDepositInterest() {
    if (coins >= depositInterestUpgradeCost && depositInterest < 100) {
      coins -= depositInterestUpgradeCost;
      depositInterest += 1;
      depositInterestUpgradeCost *= 2;
      notifyListeners();
    }
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