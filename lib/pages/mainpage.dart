import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:practice5/database/database.dart';
import 'package:practice5/database/task_model.dart';
import 'package:practice5/services/firestore_service.dart';
import 'package:practice5/services/notification_service.dart';
import 'package:practice5/widgets/addnewitem.dart';
import 'package:practice5/widgets/tiles.dart';

class Mainpage extends StatefulWidget {
  const Mainpage({super.key});

  @override
  State<Mainpage> createState() => _MainpageState();
}

class _MainpageState extends State<Mainpage> {
  final Tododatabase db = Tododatabase();
  final FirestoreService _firestoreService = FirestoreService();
  final NotificationService _notificationService = NotificationService();
  StreamSubscription<List<Task>>? _taskSubscription;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  @override
  void dispose() {
    _taskSubscription?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initApp() async {
    db.loaddata(); // Load offline data immediately
    try {
      await _firestoreService.signInAnonymously();
      // Sync tasks from Firestore in the background
      _taskSubscription = _firestoreService.getTasks().listen((tasks) {
        if (tasks.isNotEmpty) {
          db.syncTasks(tasks);
        }
      });
    } catch (e) {
      debugPrint("Error signing in anonymously: $e");
    }
  }

  Future<void> tilechange(Task task) async {
    task.isCompleted = !task.isCompleted;
    
    // Update Hive
    await db.saveTask(task);
    
    // Update Firestore
    await _firestoreService.updateTask(task);
    
    // Cancel notification if completed
    if (task.isCompleted && task.id != null) {
      await _notificationService.cancelNotification(task.id!);
    } else if (!task.isCompleted && task.dueDate != null && task.id != null) {
      await _notificationService.scheduleNotification(task.id!, task.name, task.dueDate!);
    }
  }

  final TextEditingController _controller = TextEditingController();

  void onPressed() {
    showDialog(
      context: context,
      builder: (context) {
        return Addnewitem(
          controllers: _controller,
          onsave: (dueDate) => onsave(dueDate),
        );
      },
    );
  }

  Future<void> onsave(DateTime? dueDate) async {
    if (_controller.text.isEmpty) return;
    
    final newTask = Task(
      name: _controller.text,
      isCompleted: false,
      dueDate: dueDate,
    );
    
    // Save to Hive to get auto-incremented ID
    await db.saveTask(newTask);
    
    // Save to Firestore with the Hive ID
    await _firestoreService.addTask(newTask);
    
    // Schedule notification
    if (newTask.id != null && dueDate != null) {
      await _notificationService.scheduleNotification(newTask.id!, newTask.name, dueDate);
    }
    
    _controller.clear();
    Navigator.of(context).pop();
  }

  void onedit(Task task) {
    _controller.text = task.name;
    showDialog(
      context: context,
      builder: (context) {
        return Addnewitem(
          controllers: _controller,
          initialDate: task.dueDate,
          onsave: (dueDate) async {
            if (_controller.text.isEmpty) return;
            
            task.name = _controller.text;
            task.dueDate = dueDate;
            
            // Update Hive
            await db.saveTask(task);
            
            // Update Firestore
            await _firestoreService.updateTask(task);
            
            // Reschedule notification
            if (task.id != null) {
              if (dueDate != null && !task.isCompleted) {
                await _notificationService.scheduleNotification(task.id!, task.name, dueDate);
              } else {
                await _notificationService.cancelNotification(task.id!);
              }
            }
            
            _controller.clear();
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  Future<void> deletefunc(Task task) async {
    if (task.id != null) {
      // Cancel notification
      await _notificationService.cancelNotification(task.id!);
      
      // Delete from Firestore
      await _firestoreService.deleteTask(task.id!);
      
      // Delete from Hive
      await db.deleteTask(task.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Simplist',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onPressed,
        backgroundColor: Colors.indigoAccent,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Task',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ValueListenableBuilder<Box<Task>>(
        valueListenable: Hive.box<Task>('mybox').listenable(),
        builder: (context, box, _) {
          final displayTasks = box.values.toList().cast<Task>();
          
          if (displayTasks.isEmpty) {
            return Center(
              child: Text(
                'No tasks yet. Enjoy your day!',
                style: TextStyle(color: Colors.grey[500], fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: displayTasks.length,
            itemBuilder: (context, index) {
              final task = displayTasks[index];
              return Tiles(
                tiletext: task.name,
                tilebool: task.isCompleted,
                dueDate: task.dueDate,
                onChanged: (p0) => tilechange(task),
                deletefunc: () {
                  deletefunc(task);
                },
                editfunc: () => onedit(task),
              );
            },
          );
        },
      ),
    );
  }
}
