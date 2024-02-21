import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:secondtwo/screens/LoginScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ERP',
      theme: ThemeData(
        colorSchemeSeed: Colors.blueGrey,
        scaffoldBackgroundColor: Colors.blueGrey.shade50,
      ),
      home: const SplashScreen(),
    );
  }
}

// Splash Screen Activity

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Login()));
    });
    return Scaffold(
      backgroundColor: Color(0xFFEAFAFF),
      body: Center(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/softtouch_black.png',
                  scale: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
