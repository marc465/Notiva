import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:notiva/Entities/quick_folder.dart';
import 'package:http/http.dart' as http;
import 'package:notiva/Interfaces/providers_delete.dart';
import 'package:notiva/Service/service_api.dart';
import 'package:provider/provider.dart';

class FoldersProvider extends ChangeNotifier with ProvidersDeleteMixin {
  List<QuickFolder> folders = [];
  List<Map<QuickFolder, int>> foldersToDelete = [];
  Timer? timer;
  int totalTime = 5;
  late FlutterSecureStorage secureStorage;
  late BuildContext context;
  late ServiceAPI requestProvider;
  bool wasInitialized = false;

  FoldersProvider(BuildContext givenContext, FlutterSecureStorage storage) {
    secureStorage = storage;
    context = givenContext;
    requestProvider = Provider.of<ServiceAPI>(context, listen: false);
  }

  List<QuickFolder> get foldersList => folders;
  @override
  String get deletionMessage => "Folder deleted.";


  Future<int> getFolders() async {
    print("in get Folders");

    final response = await http.get(Uri.parse("http://localhost:8080/folders/get"), headers: {
        'Content-Type': 'application/json',
        'access_token': await secureStorage.read(key: 'access_token') ?? ""
    });

    if (response.statusCode == 200) {
      print(jsonDecode(response.body));
      List<dynamic> _folders = jsonDecode(response.body);
      folders = _folders.map((folder) => QuickFolder.fromJson(folder)).toList();
      if (!wasInitialized) wasInitialized = true;
      notifyListeners();
    }
    return response.statusCode;
  }

  void deleteStart(Map<int, AnimationController>? animationControllers, int index) async {


    foldersToDelete.add({folders.removeAt(index): index});
    
    await animationControllers?[index]?.forward();
    animationControllers?[index]?.dispose();
    animationControllers?.remove(index);


    print(foldersToDelete);

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

    for (final folderIndexPair in foldersToDelete) {
      final folder = folderIndexPair.keys.first;
      
      final code = await requestProvider.handleRequest(() async {
        final response = await http.delete(
          Uri.parse("http://localhost:8080/delete/folder"),
          headers: {
            'Content-Type': 'application/json',
            'access_token': await secureStorage.read(key: 'access_token') ?? '',
            'folder_id': folder.getId.toString()
          }
        );
        return response.statusCode;
      }, context);

      if (code != 200) {
        final index = folderIndexPair.values.first;
        folders.insert(index, folder);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to delete folder ${folder.getFolderName}"),
            duration: const Duration(seconds: 3),
          )
        );
      }
    }
    foldersToDelete.clear();
    notifyListeners(); // Додати цей виклик
  }

  @override
  void deleteCancel() {
    if (foldersToDelete.isEmpty) return;

    timer?.cancel();
    for (final noteIndexPair in foldersToDelete) {
      final note = noteIndexPair.keys.first;
      final index = noteIndexPair.values.first;
      folders.insert(index, note);
    }

    foldersToDelete.clear();
    isTimerStart = false;
    remainingTime = totalTime.toDouble();
    progress = 0;
    notifyListeners();
  }

}
