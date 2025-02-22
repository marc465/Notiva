

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:notiva/AdditionalPages/amplitude_wave_circle.dart';
import 'package:notiva/MainPages/ReviewingPages/note_review.dart';
import 'package:notiva/Service/service_api.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';




class NewNoteCreation extends StatefulWidget {

  final FlutterSecureStorage secureStorage;
  const NewNoteCreation({super.key, required this.secureStorage});

  @override
  State<StatefulWidget> createState() => _NewNoteCreationState();
}

class _NewNoteCreationState extends State<NewNoteCreation> {
  bool available = false;
  bool isRecording = false;
  bool wasRecording = false;
  bool _isProccesing = false;

  final recorder = AudioRecorder();
  final SpeechToText recogniser = SpeechToText();
  late ServiceAPI requestProvider;
  
  String userComment ="";
  String audioPath = "";
  String _recognitedSpeech = "";
  String notesName = "Change This Name";

  Timer? _timer;
  ValueNotifier<double> amplitudeNotifier = ValueNotifier(0.0);
  ValueNotifier<Duration> audioDuration = ValueNotifier(Duration.zero);
  Duration audioDurationTEMP = Duration.zero;

  String language = "en_US";
  Duration maxListen = const Duration(minutes: 30);
  Duration stopAfter = const Duration(minutes: 4);
  Uri adressForText = Uri.parse("http://localhost:8080/note/new");
  Uri adressForAudio = Uri.parse("http://localhost:8080/note/new/audio");

  
  @override
  void initState() {
    super.initState();
    initSpeechRecognizer();
    requestProvider = Provider.of<ServiceAPI>(context, listen: false);
  }

  @override
  void dispose() {
    super.dispose();
    recorder.dispose();
    recogniser.cancel();
  }

  void onError() {
    // Error in init recorder (file and recorder itself)
    // Error in init speech recognition
    // Error while listening
    // Error while uploading audio
  }

  Future<void> initSpeechRecognizer() async {
    try {
      available = await recogniser.initialize();
    } catch (e) {
      onError();
    }
  }



  void handlePlay() async {
    recognition();
    wasRecording
      ? recordAfterPause()
      : record();
  }

  void recognition() {
    // Розібратися з setState - треба щось більш ефективне
    if (available) {
      recogniser.listen(
        onResult: onRecognitedSpeech,
        localeId: language,
        listenFor: maxListen,
        pauseFor: stopAfter
      );

      setState(() {
        _isProccesing = true;
      });

    } else {
      onError();
    }
  }

  Future<void> record() async {
    // Розібратися з setState, іменем файлу, через помилку
    if (!(await recorder.hasPermission())) {
      askPermissions();
      return;
    }

    try {
      const recordConfigs = RecordConfig(
        encoder: AudioEncoder.aacEld,
        bitRate: 128000,
        numChannels: 1,
        sampleRate: 44100
      );
      
      String path = (await getTemporaryDirectory()).toString().replaceAll(RegExp(r'Directory: '), "").replaceAll(RegExp(r"'"), "").trim();
      
      await recorder.start(recordConfigs, path: "$path/${DateTime.now()}_$notesName.m4a");
      
      startAmplitudeTimer();
      
      setState(() {
        wasRecording = true;
        isRecording = true;
      });
    } on Exception catch (e) {
      print(e);
      onError();
    }
  }

  Future<void> recordAfterPause() async {
    // Розібратися з setState, через помилку
    try {
      await recorder.resume();
      startAmplitudeTimer();
      
      setState(() {
        isRecording = true;
      });
    } on Exception catch (e) {
      print(e);
      onError();
    }
  }

  // Handle erquest permissions for
  Future<void> askPermissions() async {}



  void handlePause() async {
    // Розібратися з setState
    await recogniser.stop();
    await recorderPause();

    setState(() {
      _isProccesing = false;
      isRecording = false;
    });
  }

  /// Sets recorder to pause. Also cancel timer for amplitude update (for animation), 
  /// and sets 0 value for amplitude animation
  Future<void> recorderPause() async {
    _timer?.cancel();
    amplitudeNotifier.value = 0.0;
    await recorder.pause();
  }



  /// Adds regognited words to `_recognitedSpeech`
  void onRecognitedSpeech(SpeechRecognitionResult result) {
    _recognitedSpeech += " ${result.recognizedWords}";
  }



  /// Set periodic timer to update normalized 
  /// amplitude value (from 0 to 1) of recorder 
  /// for listening effect (animation).
  /// 
  /// Also it updates `audioDuration` to see duration of recorded audio
  void startAmplitudeTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) async {
      double dbAmplitude = (await recorder.getAmplitude()).current;
      double normalizedAmplitude = normalizeAmplitude(dbAmplitude);
      amplitudeNotifier.value = normalizedAmplitude;

      audioDurationTEMP += const Duration(milliseconds: 50);
      if (audioDurationTEMP.inSeconds > audioDuration.value.inSeconds) {
        audioDuration.value = audioDurationTEMP;
      }
    });
  }

  /// Gets dBfs amplitude in range -160:0 and 
  /// returns apropriate value in range 0:1
  double normalizeAmplitude(double dbAmplitude) {
    const double minDbfs = -160.0;
    const double maxDbfs = 0.0;

    double clampedDbfs = dbAmplitude.clamp(minDbfs, maxDbfs);
    double normalized = (clampedDbfs - minDbfs) / (maxDbfs - minDbfs);

    return normalized.clamp(0.0, 1.0);
  }



  /// Sends recognited speech, notes name and user comment to server. 
  /// After calls upload audio that send multipart request.
  /// On all done Navigator is pushed to new Note (`NoteReview`).
  /// 
  /// On error while accessing file system for audio file or while sending data to server 
  /// calls `onError` function. Server side deletes unfinished note.
  Future<void> sendData() async {
    final token = await widget.secureStorage.read(key: 'access_token') ?? "";
    final newNoteId = Completer<int>();

    await requestProvider.handleRequest(
      () async {return await sendText(token, newNoteId);},
      context
    );

    await uploadAudio(await newNoteId.future)
      .then((_) async {
        int id = await newNoteId.future;
        Navigator.push(context, MaterialPageRoute(builder: (context) => NoteReview(secureStorage: widget.secureStorage, id: id)));
      });

  }

  Future<int> sendText(String token, Completer<int> newNoteId) async {
    final response = await http.post(
      Uri.parse("http://localhost:8080/note/new"), 
      headers: {
          'Content-Type': 'application/json',
          'access_token': token,
        },
      body: jsonEncode({
        'name': notesName,
        'speech': _recognitedSpeech,
        if (userComment.isNotEmpty) 'user_comment': userComment
        }
      )
    );

    if (response.statusCode == 200) {
      newNoteId.complete(int.parse(jsonDecode(response.body)['id']));
    }

    return response.statusCode;
  }

  /// Uploads audiofile in chunks to server using MultipartRequest
  /// 
  /// On error calls `onError` function. Server side deletes unfinished note.
  Future<void> uploadAudio(int noteId) async {
    File file = File(audioPath);
  
    int fileSize = await file.length();

    int chunkSize = 1024 * 1024; // 1MB chunk
    int offset = 0;
    int count = 1;

    String fileName = file.path.split('/').last;

    while (offset < fileSize) {
      int size = offset + chunkSize;
      int end = (size > fileSize) ? fileSize : size;

      List<int> chunk = await file.readAsBytes().then((bytes) => bytes.sublist(offset, end));

      final request = http.MultipartRequest('POST', adressForAudio);
      
      request.headers['id'] = noteId.toString();
      request.headers['part'] = count.toString();
      request.headers['access_token'] = await widget.secureStorage.read(key: 'access_token') ?? '';
      
      request.fields['offset'] = offset.toString();
      request.fields['filename'] = fileName;
      
      request.files.add(http.MultipartFile.fromBytes(
        'file', 
        chunk, 
        filename: fileName
      ));

      try {
        int code = await requestProvider.handleRequest(
          () async {
            final response = await request.send();
            return response.statusCode;}, 
          context
        );
        
        // final responseBody = await response.stream.bytesToString();

        switch (code) {
          case 200:
            print("Chunk uploaded: $offset - $end");
            break;

          case 401:
            print("need to update tokens");
            break;

          case 500:
            onError();
            break;

          default:
            print("Failed to upload chunk. Status: $code");
            break;
        }
      } catch (e) {
        onError();
        break;
      }

      offset = end;
      count += 1;
    }
  }

  void submit() async {
    if (_isProccesing) recogniser.stop();

    audioPath = (await recorder.stop())!;
    sendData();
  }

  Future<void> onWillPop() async {
    final shouldPop = await _showExitDialog();
    if (shouldPop && context.mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<bool> _showExitDialog() async {
    // Check if there are any changes
    if (notesName.isEmpty 
        && _recognitedSpeech.isEmpty 
        && userComment.isEmpty) {
      return true;
    }

    try {
      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Unsaved Changes'),
          content: const Text(
            'Unsaved changes will be lost. Are you sure you want to leave?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                'Leave',
                style: TextStyle(color: Colors.red[700]),
              ),
            ),
          ],
        ),
      );
      
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (!didPop) {
          await onWillPop();
        } 
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () async {
                await onWillPop();
              },
              child: const Icon(
                CupertinoIcons.back,
                size: 30,
              ),
            ),
            title: Center(
              child: TextField(
                controller: TextEditingController(text: notesName),
                textAlign: TextAlign.center, // Center text
                textAlignVertical: TextAlignVertical.center,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                onChanged: (value) => notesName = value,
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: wasRecording ? submit : (){},
                child: Text(
                  "Submit",
                  style: TextStyle(
                    color: wasRecording ? Colors.blue[600] : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                    fontSize: 16
                  ),
                ),
              ),
            ],
          ),
          body: Align(
            alignment: Alignment.topCenter,
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 80,),
                SizedBox(
                  height: 300,
                  width: 300,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AmplitudeWaveCircle(amplitude: amplitudeNotifier),
                      GestureDetector(
                        onTap: () async {
                          _isProccesing ? handlePause() : handlePlay();
                        },
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isRecording
                                ? CupertinoColors.white
                                : CupertinoColors.activeBlue,
                            boxShadow: [
                              BoxShadow(
                                color: CupertinoColors.black.withOpacity(0.15),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            CupertinoIcons.mic_fill,
                            size: 64,
                            color: isRecording
                                ? CupertinoColors.activeBlue
                                : CupertinoColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // const SizedBox(height: 20,),
                ValueListenableBuilder<Duration>(
                  valueListenable: audioDuration,
                  builder: (context, duration, child) {
                    String minutes = "${duration.inMinutes % 60}".padLeft(2, "0");
                    String seconds = "${duration.inSeconds % 60}".padLeft(2, "0");
                
                    return Text(
                      "$minutes:$seconds",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: CupertinoColors.secondaryLabel,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          bottomSheet: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 50),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CupertinoTextField(
                maxLength: 4096,
                maxLines: 3,
                placeholder: "Write your comment for Notiva AI. AI will take it into account",
                placeholderStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: CupertinoColors.placeholderText),
                padding: const EdgeInsets.all(14),
                style: const TextStyle(fontSize: 16),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(20),
                ),
                onChanged: (value) => userComment = value,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

