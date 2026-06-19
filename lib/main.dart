import 'package:flutter/material.dart';
import 'package:practice5/pages/mainpage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:practice5/database/task_model.dart';
import 'package:practice5/services/notification_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
  // Initialize Notifications
  await NotificationService().init();

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  
  // Opens a box, delete if type mismatch occurs
  try {
    await Hive.openBox<Task>('mybox');
  } catch (e) {
    debugPrint("Failed to open Hive box with new schema, deleting and starting fresh. Error: $e");
    await Hive.deleteBoxFromDisk('mybox');
    await Hive.openBox<Task>('mybox');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Mainpage(),
    );
  }
}