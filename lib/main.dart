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
    await Hive.openBox('settings');
  } catch (e) {
    debugPrint("Failed to open Hive box with new schema, deleting and starting fresh. Error: $e");
    try {
      await Hive.deleteBoxFromDisk('mybox');
    } catch (e2) {
      debugPrint("Could not cleanly delete box from disk: $e2");
    }
    await Hive.openBox<Task>('mybox');
  }
  
  runApp(const MyApp());
}

// Light mode by default
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, currentMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Simplist',
          themeMode: currentMode,
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF8F9FB),
            primarySwatch: Colors.indigo,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.indigoAccent,
              brightness: Brightness.light,
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            // Cool midnight blue-grey — feels premium, not harsh
            scaffoldBackgroundColor: const Color(0xFF0F1123),
            canvasColor: const Color(0xFF161830),
            cardColor: const Color(0xFF1D1F36),
            primarySwatch: Colors.indigo,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6C63FF), // Soft purple-indigo
              brightness: Brightness.dark,
              surface: const Color(0xFF1D1F36),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: Color(0xFF1D1F36),
            ),
            popupMenuTheme: const PopupMenuThemeData(
              color: Color(0xFF1D1F36),
            ),
            bottomSheetTheme: const BottomSheetThemeData(
              backgroundColor: Color(0xFF1D1F36),
            ),
            dividerColor: Colors.white10,
            checkboxTheme: CheckboxThemeData(
              fillColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const Color(0xFF6C63FF);
                }
                return Colors.transparent;
              }),
            ),
          ),
          home: const Mainpage(),
        );
      },
    );
  }
}