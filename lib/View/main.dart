import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:my_finance1/Contoller/SessionData.dart';
import 'package:my_finance1/View/splashscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    SessionData.initialize();
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: Splash()),
    );
  }
}
