import 'package:hive_flutter/hive_flutter.dart';
import 'task_model.dart';

class Tododatabase {
  final Box<Task> _mybox = Hive.box<Task>('mybox');
  List<Task> items = [];

  void createinitialdata() {
    _mybox.clear();
    items = [];
  }

  Future<void> loaddata() async {
    try {
      items = _mybox.values.toList();
    } catch (e) {
      _mybox.clear();
      items = [];
    }

    // Handle first-run placeholder tasks
    var settingsBox = Hive.box('settings');
    bool isFirstRun = settingsBox.get('isFirstRun', defaultValue: true);

    if (isFirstRun) {
      await saveTask(Task(
        name: 'Welcome to Simplist! 👋',
        isCompleted: false,
        category: 'Personal',
        priority: 2, // High priority
        orderIndex: 0.0,
      ));
      await saveTask(Task(
        name: 'Swipe left to edit or delete me',
        isCompleted: false,
        category: 'General',
        priority: 1, // Medium priority
        orderIndex: 1.0,
      ));
      await saveTask(Task(
        name: 'Tap the + button to add a new task',
        isCompleted: false,
        category: 'General',
        priority: 0, // Low priority
        orderIndex: 2.0,
      ));

      await settingsBox.put('isFirstRun', false);
      items = _mybox.values.toList();
    }
  }

  Future<void> saveTask(Task task) async {
    if (!task.isInBox && task.id == null) {
      await _mybox.add(task);
      task.updateId();
    } else if (task.id != null) {
      await _mybox.put(task.id, task);
    } else {
      await task.save();
    }
  }

  Future<void> syncTasks(List<Task> tasks) async {
    for (var task in tasks) {
      if (task.id != null) {
        await _mybox.put(task.id, task);
      }
    }
    items = tasks;
  }

  Future<void> deleteTask(int id) async {
    await _mybox.delete(id);
  }
  
  Future<void> clearAll() async {
    await _mybox.clear();
  }
}