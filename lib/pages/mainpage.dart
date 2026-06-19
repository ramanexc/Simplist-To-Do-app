import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:practice5/database/database.dart';
import 'package:practice5/database/task_model.dart';
import 'package:practice5/services/firestore_service.dart';
import 'package:practice5/services/notification_service.dart';
import 'package:practice5/widgets/addnewitem.dart';
import 'package:practice5/widgets/tiles.dart';
import 'package:practice5/main.dart';

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

  // Sorting state
  String _sortBy = 'manual'; // 'manual', 'priority', 'date', 'name'

  @override
  void initState() {
    super.initState();
    _initApp();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      _taskSubscription?.cancel();
      // When auth changes, re-listen to the new user's tasks
      _taskSubscription = _firestoreService.getTasks().listen((tasks) {
        if (tasks.isNotEmpty) {
          db.syncTasks(tasks);
        }
      });
    });
  }

  @override
  void dispose() {
    _taskSubscription?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initApp() async {
    await db.loaddata(); // Load offline data immediately
    try {
      await _firestoreService.signInAnonymously();
    } catch (e) {
      debugPrint("Anonymous sign-in failed (may not be enabled): $e");
      // App continues to work offline-only without auth
    }
  }

  Future<void> tilechange(Task task) async {
    task.isCompleted = !task.isCompleted;
    
    // Update Hive
    await db.saveTask(task);
    // Update Firestore (wrapped in try-catch for offline resilience)
    try { await _firestoreService.updateTask(task); } catch (_) {}
    
    if (task.isCompleted) {
      if (task.id != null) await _notificationService.cancelNotification(task.id!);
      
      // Handle recurring logic
      if (task.recurring != 'none' && task.dueDate != null) {
        DateTime nextDate;
        if (task.recurring == 'daily') {
          nextDate = task.dueDate!.add(const Duration(days: 1));
        } else if (task.recurring == 'weekly') {
          nextDate = task.dueDate!.add(const Duration(days: 7));
        } else {
          nextDate = DateTime(task.dueDate!.year, task.dueDate!.month + 1, task.dueDate!.day, task.dueDate!.hour, task.dueDate!.minute);
        }
        
        final newTask = Task(
          name: task.name,
          category: task.category,
          priority: task.priority,
          recurring: task.recurring,
          dueDate: nextDate,
          orderIndex: task.orderIndex,
        );
        await db.saveTask(newTask);
        try { await _firestoreService.addTask(newTask); } catch (_) {}
        if (newTask.id != null) {
          await _notificationService.scheduleNotification(newTask.id!, newTask.name, nextDate);
        }
      }
    } else {
      if (task.dueDate != null && task.id != null) {
        await _notificationService.scheduleNotification(task.id!, task.name, task.dueDate!);
      }
    }
  }

  final TextEditingController _controller = TextEditingController();

  void onPressed() {
    _controller.clear();
    showDialog(
      context: context,
      builder: (context) {
        return Addnewitem(
          controllers: _controller,
          isEditing: false,
          onsave: (dueDate, category, priority, recurring) => onsave(dueDate, category, priority, recurring),
        );
      },
    );
  }

  Future<void> onsave(DateTime? dueDate, String category, int priority, String recurring) async {
    if (_controller.text.trim().isEmpty) return;
    
    final newTask = Task(
      name: _controller.text.trim(),
      isCompleted: false,
      dueDate: dueDate,
      category: category,
      priority: priority,
      recurring: recurring,
      orderIndex: Hive.box<Task>('mybox').length.toDouble(),
    );
    
    // Save to Hive to get auto-incremented ID
    await db.saveTask(newTask);
    
    // Save to Firestore with the Hive ID
    try { await _firestoreService.addTask(newTask); } catch (_) {}
    
    // Schedule notification
    if (newTask.id != null && dueDate != null) {
      await _notificationService.scheduleNotification(newTask.id!, newTask.name, dueDate);
    }
    
    _controller.clear();
  }

  void onedit(Task task) {
    _controller.text = task.name;
    showDialog(
      context: context,
      builder: (context) {
        return Addnewitem(
          controllers: _controller,
          initialDate: task.dueDate,
          initialCategory: task.category,
          initialPriority: task.priority,
          initialRecurring: task.recurring,
          isEditing: true,
          onsave: (dueDate, category, priority, recurring) async {
            if (_controller.text.trim().isEmpty) return;
            
            task.name = _controller.text.trim();
            task.dueDate = dueDate;
            task.category = category;
            task.priority = priority;
            task.recurring = recurring;
            
            // Update Hive
            await db.saveTask(task);
            
            // Update Firestore
            try { await _firestoreService.updateTask(task); } catch (_) {}
            
            // Reschedule notification
            if (task.id != null) {
              if (dueDate != null && !task.isCompleted) {
                await _notificationService.scheduleNotification(task.id!, task.name, dueDate);
              } else {
                await _notificationService.cancelNotification(task.id!);
              }
            }
            
            _controller.clear();
          },
        );
      },
    );
  }

  Future<void> deletefunc(Task task) async {
    if (task.id != null) {
      await _notificationService.cancelNotification(task.id!);
      try { await _firestoreService.deleteTask(task.id!); } catch (_) {}
      await db.deleteTask(task.id!);
    }
  }

  List<Task> _sortTasks(List<Task> tasks) {
    switch (_sortBy) {
      case 'priority':
        tasks.sort((a, b) => b.priority.compareTo(a.priority));
        break;
      case 'date':
        tasks.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
        break;
      case 'name':
        tasks.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      default: // 'manual'
        tasks.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    }
    return tasks;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Simplist',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: ValueListenableBuilder<ThemeMode>(
          valueListenable: themeNotifier,
          builder: (_, currentMode, _) {
            final isCurrentlyDark = currentMode == ThemeMode.dark || (currentMode == ThemeMode.system && MediaQuery.of(context).platformBrightness == Brightness.dark);
            return IconButton(
              icon: Icon(isCurrentlyDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
              onPressed: () {
                themeNotifier.value = isCurrentlyDark ? ThemeMode.light : ThemeMode.dark;
              },
            );
          },
        ),
        actions: [
          // Sort button
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort_rounded),
            tooltip: 'Sort tasks',
            onSelected: (value) {
              setState(() => _sortBy = value);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'manual',
                child: Row(
                  children: [
                    Icon(Icons.drag_indicator, size: 18, color: _sortBy == 'manual' ? Colors.indigoAccent : null),
                    const SizedBox(width: 8),
                    const Text('Manual Order'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'priority',
                child: Row(
                  children: [
                    Icon(Icons.flag_rounded, size: 18, color: _sortBy == 'priority' ? Colors.indigoAccent : null),
                    const SizedBox(width: 8),
                    const Text('Priority'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'date',
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 18, color: _sortBy == 'date' ? Colors.indigoAccent : null),
                    const SizedBox(width: 8),
                    const Text('Due Date'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'name',
                child: Row(
                  children: [
                    Icon(Icons.sort_by_alpha_rounded, size: 18, color: _sortBy == 'name' ? Colors.indigoAccent : null),
                    const SizedBox(width: 8),
                    const Text('Name'),
                  ],
                ),
              ),
            ],
          ),
          // Sign-in button
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              final user = snapshot.data;
              if (user != null && !user.isAnonymous) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Sign Out'),
                          content: const Text('Are you sure you want to sign out?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(ctx);
                                await _firestoreService.signOut();
                              },
                              child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 16,
                      backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                      child: user.photoURL == null ? const Icon(Icons.person, size: 20) : null,
                    ),
                  ),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: TextButton.icon(
                    icon: const Icon(Icons.login_rounded, size: 18),
                    label: const Text('Sign In'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.indigoAccent,
                    ),
                    onPressed: () async {
                      try {
                        await _firestoreService.signInWithGoogle();
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Sign-in failed: $e')),
                          );
                        }
                      }
                    },
                  ),
                );
              }
            },
          ),
        ],
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    size: 64,
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tasks yet. Enjoy your day!',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          _sortTasks(displayTasks);

          // Use regular ListView when sorting is not manual (drag makes no sense)
          if (_sortBy != 'manual') {
            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: displayTasks.length,
              itemBuilder: (context, index) {
                final task = displayTasks[index];
                return Tiles(
                  key: ValueKey(task.key),
                  tiletext: task.name,
                  tilebool: task.isCompleted,
                  dueDate: task.dueDate,
                  category: task.category,
                  priority: task.priority,
                  onChanged: (p0) => tilechange(task),
                  deletefunc: () => deletefunc(task),
                  editfunc: () => onedit(task),
                );
              },
            );
          }

          // Manual sorting — use ReorderableListView with proxyDecorator
          return ReorderableListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: displayTasks.length,
            buildDefaultDragHandles: false, // We use custom drag handles
            proxyDecorator: (child, index, animation) {
              return AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  return Material(
                    color: Colors.transparent,
                    elevation: 6,
                    shadowColor: Colors.black38,
                    child: child,
                  );
                },
                child: child,
              );
            },
            onReorder: (oldIndex, newIndex) async {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              final Task item = displayTasks.removeAt(oldIndex);
              displayTasks.insert(newIndex, item);

              for (int i = 0; i < displayTasks.length; i++) {
                displayTasks[i].orderIndex = i.toDouble();
                await db.saveTask(displayTasks[i]);
                try { await _firestoreService.updateTask(displayTasks[i]); } catch (_) {}
              }
            },
            itemBuilder: (context, index) {
              final task = displayTasks[index];
              return Tiles(
                key: ValueKey(task.key),
                tiletext: task.name,
                tilebool: task.isCompleted,
                dueDate: task.dueDate,
                category: task.category,
                priority: task.priority,
                dragIndex: index, // Pass index for ReorderableDragStartListener
                onChanged: (p0) => tilechange(task),
                deletefunc: () => deletefunc(task),
                editfunc: () => onedit(task),
              );
            },
          );
        },
      ),
    );
  }
}
