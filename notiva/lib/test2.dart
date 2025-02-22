import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyTest2(),
    );
  }
}

class MyTest2 extends StatefulWidget {
  const MyTest2({super.key});

  @override
  _MyTest2State createState() => _MyTest2State();
}

class _MyTest2State extends State<MyTest2> {
  double amplitude = 0;
  int index = 0;
  final List<double> lst = [0.1, 0.3, 0.8, 0.4, 1, 0.5, 0.3, 0.1, 0.5, 0.8];

  @override
  void initState() {
    super.initState();
    changingAmplitude();
  }

  void changingAmplitude() {
    Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        amplitude = lst[index];
        index = (index + 1) % lst.length;
      });
    });
  }

  @override
  Widget build(context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Container(),
        ),
      ),
    );
  }
}


