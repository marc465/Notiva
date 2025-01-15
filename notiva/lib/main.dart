import 'package:flutter/material.dart';
// import 'package:notiva/StartingPages/login.dart';
import 'package:notiva/start.dart';

void main() {
  runApp(const NotivaApp());
}

class NotivaApp extends StatelessWidget {
  const NotivaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Notiva",
      home: const Start(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.lightBlue),
          useMaterial3: true),
      debugShowCheckedModeBanner: false,
      );
  }
}

