import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:notiva/Service/websocket_service.dart';
import 'package:http/http.dart' as http;


void main() {
  runApp(const MaterialApp(
    home: Scaffold(
      body: TestPage(),
    ),
  ));
}

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<StatefulWidget> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> with TickerProviderStateMixin{
  String url = "http://localhost:8080/note/audio";
  String access_token = "sadfasv.sadfsa.23fvf";
  String note_id = "2";


  AudioPlayer? player;
  Duration currentPosition = Duration.zero;
  late Duration totalDuration;
  late WebSocketService service;

  @override
  void initState() {
    super.initState();
    initsome();
  }

  Future<void> initsome() async {
    final resp = await http.get(Uri.parse(url), headers: {'access_token': access_token, 'note_id': note_id});
    print(resp.statusCode);
    print(resp.body);
  }

  // Future<void> initPlayer() {
  //   player = AudioPlayer();
  // }

  @override
  Widget build(context) {
    return Scaffold();
  }
}