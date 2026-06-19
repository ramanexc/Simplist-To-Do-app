import 'package:hive_flutter/hive_flutter.dart';
import 'task_model.dart';

class Tododatabase {
  final Box<Task> _mybox = Hive.box<Task>('mybox');
  List<Task> items = [];

  void createinitialdata() {
    _mybox.clear();
    items = [];
  }

  void loaddata() {
    try {
      items = _mybox.values.toList();
    } catch (e) {
      _mybox.clear();
      items = [];
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