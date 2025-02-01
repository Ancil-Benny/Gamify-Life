class Reward {
  final String title;
  final String description;
  final int cost;

  Reward({
    required this.title,
    required this.description,
    required this.cost,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'cost': cost,
      };

  factory Reward.fromJson(Map<String, dynamic> json) => Reward(
        title: json['title'] as String,
        description: json['description'] as String,
        cost: json['cost'] as int,
      );
}