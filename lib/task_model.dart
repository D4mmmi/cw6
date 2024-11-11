class Task {
  String id;
  String name;
  bool isCompleted;
  String priority;

  Task({required this.id, required this.name, this.isCompleted = false, this.priority = 'Low'});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isCompleted': isCompleted,
      'priority': priority,
    };
  }

  static Task fromMap(Map<String, dynamic> map, String id) {
    return Task(
      id: id,
      name: map['name'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      priority: map['priority'] ?? 'Low',
    );
  }
}
