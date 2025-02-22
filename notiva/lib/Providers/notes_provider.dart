import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:notiva/Entities/quick_note.dart';
import 'package:http/http.dart' as http;
import 'package:notiva/Interfaces/providers_delete.dart';
import 'package:notiva/Service/service_api.dart';
import 'package:provider/provider.dart';

class NotesProvider extends ChangeNotifier with  ProvidersDeleteMixin {
  List<QuickNote> notes = [];
  List<Map<QuickNote, int>> notesToDelete = [];
  Timer? timer;
  int totalTime = 5;
  late FlutterSecureStorage secureStorage;
  late BuildContext context;
  late ServiceAPI requestProvider;
  bool wasInitialized = false;

  NotesProvider(BuildContext givenContext, FlutterSecureStorage storage) {
    secureStorage = storage;
    context = givenContext;
    requestProvider = Provider.of<ServiceAPI>(context, listen: false);
  }

  List<QuickNote> get notesList => notes;
  @override
  String get deletionMessage => "Note deleted.";
  
  Future<int> getNotes() async {
    print("in get Notes");
    
    final response = await http.get(Uri.parse("http://localhost:8080/notes/get"), headers: {
        'Content-Type': 'application/json',
        'access_token': await secureStorage.read(key: 'access_token') ?? ""
    });

    if (response.statusCode == 200) {
      List<dynamic> _notes = jsonDecode(response.body);
      notes = _notes.map((note) => QuickNote.fromJson(note)).toList();
      if (!wasInitialized) wasInitialized = true;
      notifyListeners();
    }
    return response.statusCode;
  }

  void deleteStart(Map<int, AnimationController>? animationControllers, int index) async {

    notesToDelete.add({notes.removeAt(index): index});
    
    await animationControllers?[index]?.forward();
    animationControllers?[index]?.dispose();
    animationControllers?.remove(index);


    print(notesToDelete);

    timer?.cancel();
    remainingTime = totalTime.toDouble();
    isTimerStart = true;
    notifyListeners();

    timer = Timer.periodic(const Duration(milliseconds: 10), (timer) async {
      if (remainingTime > 0.01) {
        remainingTime -= 0.01;
        progress = 1 - remainingTime / totalTime;
        notifyListeners();
      } else {
        timer.cancel();
        await deleteEnd();
        notifyListeners();
      }
    });
  }

  Future<void> deleteEnd() async {
    isTimerStart = false;
    notifyListeners();

    for (final noteIndexPair in notesToDelete) {
      final note = noteIndexPair.keys.first;

      final code = await requestProvider.handleRequest(() async {
        final response = await http.delete(
          Uri.parse("http://localhost:8080/delete/note"),
          headers: {
            'Content-Type': 'application/json',
            'access_token': await secureStorage.read(key: 'access_token') ?? '',
            'note_id': note.getId.toString()
          }
        );
        return response.statusCode;
      }, context);

      if (code != 200) {
        final index = noteIndexPair.values.first;
        notes.insert(index, note);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to delete note ${note.getNotesName}"),
            duration: const Duration(seconds: 3),
          )
        );
        continue;
      }
      print("note ${note.getId} deleted succesfuly");
    }
    notesToDelete.clear();
    notifyListeners(); // Додати цей виклик
  }

  @override
  void deleteCancel() {
    if (notesToDelete.isEmpty) return;

    timer?.cancel();
    for (final noteIndexPair in notesToDelete.reversed) {
      final note = noteIndexPair.keys.first;
      final index = noteIndexPair.values.first;
      notes.insert(index, note);
    }

    notesToDelete.clear();
    isTimerStart = false;
    remainingTime = totalTime.toDouble();
    progress = 0;
    notifyListeners();
  }

}
