import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:notiva/Entities/quick_note.dart';
import 'package:http/http.dart' as http;
import 'package:notiva/Interfaces/providers_delete.dart';
import 'package:notiva/Service/service_api.dart';
import 'package:provider/provider.dart';

class FavouritesProvider extends ChangeNotifier with ProvidersDeleteMixin {
  List<QuickNote> favNotes = [];
  List<Map<QuickNote, int>> favNotesToDelete = [];
  Timer? timer;
  int totalTime = 5;
  late FlutterSecureStorage secureStorage;
  late BuildContext context;
  late ServiceAPI requestProvider;
  bool wasInitialized = false;

  FavouritesProvider(BuildContext givenContext, FlutterSecureStorage storage) {
    secureStorage = storage;
    context = givenContext;
    requestProvider = Provider.of<ServiceAPI>(context, listen: false);
  }

  @override
  String get deletionMessage => "Note deleted.";

  List<QuickNote> get notesList => favNotes;


  Future<int> getFavourites() async {
    
    final response = await http.get(Uri.parse("http://localhost:8080/favourites/get"), headers: {
        'Content-Type': 'application/json',
        'access_token': await secureStorage.read(key: 'access_token') ?? ''
    });

    if (response.statusCode == 200) {
      List<dynamic> _notes = jsonDecode(response.body);
      favNotes = _notes.map((note) => QuickNote.fromJson(note)).toList();
      if (!wasInitialized) wasInitialized = true;
      notifyListeners();
    }

    return response.statusCode;
  }

  void deleteStart(Map<int, AnimationController>? animationControllers, int index) async {

    favNotesToDelete.add({favNotes.removeAt(index): index});
    
    await animationControllers?[index]?.forward();
    animationControllers?[index]?.dispose();
    animationControllers?.remove(index);

    print(favNotesToDelete);

    timer?.cancel();
    remainingTime = totalTime.toDouble();
    isTimerStart = true;
    notifyListeners();

    timer = Timer.periodic(const Duration(milliseconds: 10), (timer) async {
      if (remainingTime > 0) {
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

    for (final favNoteIndexPair in favNotesToDelete) {
      final note = favNoteIndexPair.keys.first;

      final code = await requestProvider.handleRequest(() async {
        final response = await http.delete(
          Uri.parse("http://localhost:8080/delete/notes"),
          headers: {
            'Content-Type': 'application/json',
            'access_token': await secureStorage.read(key: 'access_token') ?? '',
            'note_id': note.getId.toString()
          }
        );
        return response.statusCode;
      }, context);

      if (code != 200) {
        final index = favNoteIndexPair.values.first;
        favNotes.insert(index, note);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to delete note ${note.getNotesName}"),
            duration: const Duration(seconds: 3),
          )
        );
      }
    }

    favNotesToDelete.clear();
    notifyListeners();
  }

  @override
  void deleteCancel() {
    if (favNotesToDelete.isEmpty) return;

    timer?.cancel();
    for (final favNoteIndexPair in favNotesToDelete) {
      final note = favNoteIndexPair.keys.first;
      final index = favNoteIndexPair.values.first;
      favNotes.insert(index, note);
    }

    favNotesToDelete.clear();
    isTimerStart = false;
    remainingTime = totalTime.toDouble();
    progress = 0;
    notifyListeners();
  }

}
