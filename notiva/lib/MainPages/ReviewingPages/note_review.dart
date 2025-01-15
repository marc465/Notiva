import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:notiva/Entities/note.dart';
import 'package:notiva/SettingsPages/share_and_export_note.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:notiva/Service/websocket_service.dart';
// import 'package:notiva/Service/custom_audio_source.dart';


class NoteReview extends StatefulWidget {
  final int noteId;
  final FlutterSecureStorage secureStorage;
  const NoteReview({super.key, required this.noteId, required this.secureStorage});

  @override
  State<StatefulWidget> createState() => _NoteReviewState();
}

class _NoteReviewState extends State<NoteReview> with TickerProviderStateMixin{
  late TabController _tabController;
  Note? note;
  Icon favouriteIcon = const Icon(Icons.favorite_border);
  Icon playingIcon = const Icon(Icons.play_arrow_rounded);
  AudioPlayer? player;
  Duration currentPosition = Duration.zero;
  late Duration totalDuration;
  late WebSocketService service;
  bool _isInitializing = true;
  String? _error;
  bool isPlaying = false;

  @override
  void initState(){
    super.initState();
    _initializeAll();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
    stop();
  }

  Future<void> _initializeAll() async {
    try {
      await getNoteData();
      await initSocket();
      await initPlayer();

      setState(() {
        _isInitializing = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _isInitializing = false;
        _error = e.toString();
      });
      print('Initialization error: $e');
    }
  }

  Future<void> initSocket() async {
    service = WebSocketService("ws://localhost:8080/note/audio/${await widget.secureStorage.read(key: 'access_token') ?? ''}/${widget.noteId.toString()}");
    await service.connect();
  }

  Future<void> getNoteData() async {
    print("getNote press");

    try {
      final response = await http.get(Uri.parse("http://localhost:8080/note/view"), headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'access_token': await widget.secureStorage.read(key: 'access_token') ?? '',
        'note_id': widget.noteId.toString()
      });

      
      if (response.statusCode == 200) {

        print(jsonDecode(response.body));
        note = await Note.fromJson(jsonDecode(response.body));
        totalDuration = Duration(seconds: (note!.fileSize * 8) ~/ (note!.bps * 1000));

        print(note!.getIcon);
        print(note!.getNotesName);
        

        print('Файл успішно завантажено:');
      } else {
        print('Помилка: ${response.statusCode}');
      }
    } catch (e) {
      print('Помилка: $e');
    }
  }

  Future<void> initPlayer() async {
  if (note == null) {
    throw Exception("note must be initializated first");
  }

  try {
    // First dispose of any existing player to prevent conflicts
    if (player != null) {
        await player!.stop();
        await player!.dispose();
    }  
    // Create new player instance
    player = AudioPlayer(
      // useProxyForRequestHeaders: false,
    );

    // Set up streams before setting the audio source

    // Get token right before creating the source
    final token = await widget.secureStorage.read(key: "access_token") ?? '';
    
    await Future.delayed(Duration(milliseconds: 100));  // Add small delay

    // Create audio source with fresh token
    // final source = CustomAudioSource("http://localhost:8080/note/audio", await widget.secureStorage.read(key: "access_token") ?? '', widget.noteId.toString());
    
    final source = AudioSource.uri(
      Uri.parse("http://localhost:8080/note/audio"),
      headers: {
        "access_token": token,
        "note_id": widget.noteId.toString()
      }
    );

    // Set source and load with error handling
    await player!.setAudioSource(
      source,
      preload: false,
      initialPosition: Duration.zero
    );

    player!.positionStream.listen(
      (position) {
        if (mounted) {  // Check if widget is still mounted
          setState(() {
            currentPosition = position;
          });
        }
      },
      onError: (error) {
        print("Position stream error: $error");
      },
      cancelOnError: false
    );

    player!.playbackEventStream.listen(
      (event) {
        print(event.processingState);
        print('Buffered up to: ${event.bufferedPosition}');
        print(event);
      },
      onError: (error) {
        print("Playback event error: $error");
      },
      cancelOnError: false
    );

    await player!.setPreferredPeakBitRate(96000); // Adjust this value as needed

    // Only load if setAudioSource was successful
    await player!.load();

  } catch (e) {
    print("Error initializing player: $e");
    // Clean up on error
    await player?.dispose();
    player = null;
    rethrow;
  }
}
  
  Future<void> play() async {
    print("play press");
    await service.sendPlay();
    await player!.play();
  }

  Future<void> pause() async {
    print("pause press");
    await service.sendPause();
    await player!.pause();
  }

  Future<void> seek(Duration value) async {
    print("seek press");

    await service.sendPause();
    await service.sendPlay();
    await player!.seek(value);
  }

  Future<void> stop() async {
    print("stop press");

    await service.sendPause();
    await service.sendStop();
    await player!.stop();
    player!.dispose();
  }

  Future<void> moveTo(double value) async {

    Duration moveToValue = Duration(seconds: value.toInt());
    print("moving to value $moveToValue");

    seek(moveToValue);
    setState(() {
      currentPosition = moveToValue;
    });
 
  }


  void somethingWentWrong() => print("something wrong");


  List<Widget> getSummary() {
    List<Widget> result = [];
    result.add(Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10.0)),
              child: Text(note!.summary)
            ));
    return result;
  }

  List<List<String>> proccessSummary(String summary) {
    List<String> data = summary.split('\n\n');
    List<List<String>> res = [];
    List<String> temp = [];
    for (var i = 0; i < data.length; i++) {
      temp.add(data[i]);
      if (i % 2 == 0) {
        res.add(temp);
        temp = [];
      }
    }
    return res;
  }

  List<Widget> getTranscript() {
    List<Widget> result = [];
    result.add(Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10.0)),
          child: Text(note!.getTranscript)
        ));
    return result;
  }

  List<String> proccessTranscript(String transcript) {
    return transcript.split('\n');
  }

  String getTotalDuration() {
    return '${(totalDuration.inMinutes).toString().padLeft(2, '0')}:${(totalDuration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  String getCurrentDuration() {
    return '${(currentPosition.inMinutes).toString().padLeft(2, '0')}:${(currentPosition.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  String extractTimeOfCreation() {
    String res = "${note!.getTimeOfCreation.month}.${note!.getTimeOfCreation.day}.${note!.getTimeOfCreation.year}";
    return res;
  }

  String extractTimeOfLastEdit() {
    String res = "${note!.getTimeOfLastChanges.minute}:${note!.getTimeOfLastChanges.hour} ${note!.getTimeOfLastChanges.month}.${note!.getTimeOfLastChanges.day}.${note!.getTimeOfLastChanges.year}";
    return res;
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $_error'),
              ElevatedButton(
                onPressed: _initializeAll,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
      return SafeArea(
      child: Scaffold(
      // Part of Appbar with more and back buttons
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
              onPressed: (){
                Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (context) => ShareAndExport(data: note!.getNotesName)
                  )
                );
              },
              icon: const Icon(Icons.more_horiz_rounded)
            )
          ],
        ),
        body: note == null ? const Center(child: CircularProgressIndicator()): Column(
          children: <Widget>[
            // Search field
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    onPressed: (){},
                    icon: const Icon(Icons.mic)
                  ),
                  hintText: "Search in the note"
                ),
              ),
            ),
            // Some other data from note in appBar with favourite
            Row(
              children: <Widget>[
                Text(note!.getIcon),
                Text(
                  note!.getNotesName, 
                  style: const TextStyle(fontWeight: FontWeight.bold)
                ),
                Expanded(flex: 4, child: Container()),
                IconButton(
                  onPressed: (){
                    setState(() {
                      print(note!.getIsFavourite);
                      print(favouriteIcon);
                      if (note!.getIsFavourite) {
                        favouriteIcon = const Icon(Icons.favorite_border);
                        note!.setIsFavourite = false; 

                      }
                      else {
                        favouriteIcon = const Icon(Icons.favorite);
                        note!.setIsFavourite = true;
                      }
                    });
                  }, 
                  icon: favouriteIcon
                )
              ],
            ),
            Row(
              children: <Widget>[
                const Icon(Icons.calendar_today_rounded),
                Text(extractTimeOfCreation()),
                Expanded(flex: 1, child: Container()),
                const Icon(Icons.watch_later_outlined),
                Text(getTotalDuration()),
                Expanded(flex: 1, child: Container()),
                const Icon(Icons.edit),
                Text(extractTimeOfLastEdit()),
                Expanded(flex: 4, child: Container()),
              ],
            ),
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: "Summary"),
                Tab(text: "Transcript"),
              ]
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: <Widget>[
                  GridView.count(
                    crossAxisCount: 1,
                    childAspectRatio: 4,
                    children: getSummary(),
                  ),
                  GridView.count(
                    crossAxisCount: 1,
                    childAspectRatio: 4,
                    children: getTranscript(),
                  ),
                ]
              ),
            )
          ],
        ),
        bottomSheet: Container(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    SizedBox(child: Text(getCurrentDuration())),
                    Expanded(
                      child: Slider(
                        min: 0.0,
                        max: totalDuration.inSeconds.toDouble(),
                        value: currentPosition.inSeconds.toDouble().clamp(0.0, totalDuration.inSeconds.toDouble()),
                        onChanged: moveTo),
                    ),
                    SizedBox(child: Text(getTotalDuration()))
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: (){
                        setState(() {
                          Duration newPostition = currentPosition - const Duration(seconds: 10);
                          currentPosition = (newPostition > Duration.zero) ? newPostition: Duration.zero;
                        });
                        seek((currentPosition));
                      },  
                      icon: const Icon(Icons.replay_10_rounded)
                    ),
                    FloatingActionButton(
                      onPressed: () {
                        if (isPlaying) {
                          pause();
                          setState(() {
                            playingIcon = const Icon(Icons.play_arrow_rounded);
                            isPlaying = false;
                          });
                          return;
                        }
                          play();
                          setState(() {
                            playingIcon = const Icon(Icons.pause);
                            isPlaying = true;
                          });
                          return;
                      },
                      backgroundColor: Colors.blue,
                      shape: const CircleBorder(),
                      child: playingIcon
                    ),
                    IconButton(
                      onPressed: (){
                        Duration newPostition = currentPosition + const Duration(seconds: 10);
                        setState(() {
                          currentPosition = (newPostition > totalDuration) ? totalDuration: newPostition;
                        });
                        seek((currentPosition));
                      }, 
                      icon: const Icon(Icons.forward_10_rounded)
                    ),
                  ],
                )
              ],
            ),
          ),
        )
      );
      }

  }

