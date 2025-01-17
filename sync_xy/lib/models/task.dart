
class Task {
  final String name;
  final String type;
  final int coins;
  final int xp;
  final DateTime endDate;
  final String penalty;
  bool isCompleted;

  Task({
    required this.name,
    required this.type,
    required this.coins,
    required this.xp,
    required this.endDate,
    required this.penalty,
    this.isCompleted = false,
  });

  void toggleCompletion() {
    isCompleted = !isCompleted;
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type,
        'coins': coins,
        'xp': xp,
        'endDate': endDate.toIso8601String(),
        'penalty': penalty,
        'isCompleted': isCompleted,
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        name: json['name'],
        type: json['type'],
        coins: json['coins'],
        xp: json['xp'],
        endDate: DateTime.parse(json['endDate']),
        penalty: json['penalty'],
        isCompleted: json['isCompleted'],
      );
}