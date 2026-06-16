import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'Client-Jittered-Backoff-and-Jitter-Lockshield/JitterBackoffScreen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Distributed Systems Tasks',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: JitterBackoffScreen(),
    );
  }
}