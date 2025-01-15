

import 'dart:convert';
import 'package:notiva/MainPages/ReviewingPages/note_review.dart';

import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;




class NewNoteCreation extends StatefulWidget {

  final FlutterSecureStorage secureStorage;
  const NewNoteCreation({super.key, required this.secureStorage});
  // const NewNoteCreation({super.key});

  @override
  State<StatefulWidget> createState() => _NewNoteCreationState();
}

class _NewNoteCreationState extends State<NewNoteCreation> {
  bool available = false;
  bool _isProccesing = false;
  late Icon playingIcon;
  final SpeechToText _speech = SpeechToText();
  String _recognitedSpeech = "";

  @override
  void initState() {
    super.initState();
    playingIcon = const Icon(Icons.play_arrow_rounded);
    initSpeechRecognizer();
  }

  Future<void> initSpeechRecognizer() async {
    try {
      print("Trying to initialize _speech");

      available = await _speech.initialize();

      setState(() {});
    } catch (e) {
      print("Error initializing speech recognition: $e");
    }
  }

  void startRecognition() {
    if (available) {
      _speech.listen(
        onResult: saveRecognitedSpeechToVar,
        localeId: "en_US", // Укажіть потрібну мову
      );
      setState(() {
        _isProccesing = true;
        playingIcon = const Icon(Icons.stop_rounded);
      });
    } else {
      print("Speech recognition is not available.");
    }
  }

  void saveRecognitedSpeechToVar(SpeechRecognitionResult result) {
    setState(() {
      _recognitedSpeech = result.recognizedWords;
    });
  }

  Future<void> stopRecognition() async {
    await _speech.stop();
    setState(() {
      _isProccesing = false;
      playingIcon = const Icon(Icons.play_arrow_rounded);
    });
  }

  Future<void> sendDataToServer() async {
    final response = await http.post(
      Uri.parse("http://localhost:8080/new/note"), 
      headers: {
          'Content-Type': 'application/json',
          'access_token': await widget.secureStorage.read(key: 'access_token') ?? ""
        },
      body: jsonEncode({
        'speech': _recognitedSpeech
        }
      )
    );

    switch (response.statusCode) {
      case 200:
        int newNoteId = int.parse(jsonDecode(response.body)['id']);
        Navigator.push(context, MaterialPageRoute(builder: (context) => NoteReview(secureStorage: widget.secureStorage, noteId: newNoteId)));
        break;
      default:
    }
  }

  @override
  Widget build(context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("New Note"),
          actions: <Widget>[
            IconButton(
              onPressed: (){
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close_rounded))
          ],
        ),
        body: Center(
          child: Text(_recognitedSpeech),
        ),
        bottomSheet: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          height: MediaQuery.of(context).size.height * 0.2,
          width: double.infinity,
          child: Center(
            child: FloatingActionButton(
              onPressed: (){
                _isProccesing? stopRecognition(): startRecognition();
              },
              shape: const CircleBorder(
                eccentricity: 0
              ),
              backgroundColor: Colors.blue.shade600,
              child: playingIcon,
            ),
          ),
        ),
      ),
    );
  }
}

