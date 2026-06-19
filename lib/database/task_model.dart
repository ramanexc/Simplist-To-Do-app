import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String name;

  @HiveField(2)
  bool isCompleted;

  @HiveField(3)
  DateTime? dueDate;

  @HiveField(4)
  String category;

  @HiveField(5)
  int priority; // 0: Low, 1: Medium, 2: High

  @HiveField(6)
  String recurring; // 'none', 'daily', 'weekly', 'monthly'

  @HiveField(7)
  double orderIndex;

  Task({
    this.id,
    required this.name,
    this.isCompleted = false,
    this.dueDate,
    this.category = 'General',
    this.priority = 1,
    this.recurring = 'none',
    this.orderIndex = 0.0,
  });

  // Helper method to update Hive key based ID
  void updateId() {
    if (key != null && key is int) {
      id = key as int;
      save();
    }
  }

  // Helper to convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isCompleted': isCompleted,
      'dueDate': dueDate?.toIso8601String(),
      'category': category,
      'priority': priority,
      'recurring': recurring,
      'orderIndex': orderIndex,
    };
  }

  // Helper to create from Firestore map
  factory Task.fromMap(Map<String, dynamic> map, String docId) {
    return Task(
      id: map['id'] as int?,
      name: map['name'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      category: map['category'] ?? 'General',
      priority: map['priority'] ?? 1,
      recurring: map['recurring'] ?? 'none',
      orderIndex: (map['orderIndex'] ?? 0.0).toDouble(),
    );
  }
}
