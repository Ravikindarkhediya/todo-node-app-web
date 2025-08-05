import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'models/task_model.dart';
import 'views/home_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await FirebaseMessaging.instance.requestPermission();

  setupFirebaseMessaging();

  runApp(const MyApp());
}

void setupFirebaseMessaging() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('📨 Foreground message received: ${message.notification?.title}');
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('📲 User opened notification: ${message.notification?.title}');
  });

  FirebaseMessaging.instance.getInitialMessage().then((message) {
    if (message != null) {
      print('🚀 App launched from notification: ${message.notification?.title}');
    }
  });
}

  class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ToDo',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }

  // (Optional if storing to Firebase Firestore)
  Future<void> getTokenAndSaveTask(Task task) async {
    final FirebaseMessaging messaging = FirebaseMessaging.instance;
    final String? token = await messaging.getToken();

    await FirebaseFirestore.instance.collection('tasks').add({
      'title': task.title,
      'message': task.message,
      'dueDate': task.dueDate?.toIso8601String(),
      'fcmToken': token,
    });
  }
}
