import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:notiva/Entities/folder.dart';
import 'package:notiva/Entities/quick_note.dart';
import 'package:notiva/Entities/tag.dart';
import 'package:http/http.dart' as http;

abstract class CollectionItem {
  final String endpoint;
  final String idHeaderName;  // for API headers (folder_id or tag_id)

  CollectionItem({
    required this.endpoint,
    required this.idHeaderName,
  });
}

class FolderItem extends CollectionItem {
  FolderItem() : super(
    endpoint: 'folder',
    idHeaderName: 'folder_id',
  );
}

class TagItem extends CollectionItem {
  TagItem() : super(
    endpoint: 'tag',
    idHeaderName: 'tag_id',
  );
}


class NotesCollectionProvider extends ChangeNotifier {
  late CollectionItem type;
  FlutterSecureStorage? secureStorage;
  int? collectionId;
  
  // Collection item (Folder or Tag)
  dynamic collection;
  
  // Notes management
  List<QuickNote> availableNotes = [];
  List<QuickNote> notesInCollection = [];
  List<QuickNote> initialNotesCollection = [];
  
  // Search related
  List<QuickNote> searchResults = [];
  List<QuickNote> collectionSearchResults = [];
  bool isSearchActive = false;
  bool isCollectionSearchActive = false;
  Timer? _debounceTimer;
  
  // State management
  bool isLoading = true;
  Map<String, bool> changes = {
    'name': false,
    'description': false,
    'icon': false,
    'list': false,
  };

  NotesCollectionProvider();

  void initialization(FlutterSecureStorage storage, CollectionItem givenType) {
    secureStorage = storage;
    type = givenType;
  }

  Future<int> getInitialData(int id) async {
    collectionId = id;
    if (!isLoading) {
      isLoading = true;
      notifyListeners(); 
    }

    print("in get initial data");
    
    final response = await http.get(
      Uri.parse("http://localhost:8080/${type.endpoint}/view"),
      headers: {
        'Content-Type': 'application/json',
        'access_token': await secureStorage!.read(key: 'access_token')?? '',
        type.idHeaderName: id.toString()
      }
    );

    if (response.statusCode == 200) {
      print(200);
      final body = jsonDecode(response.body);
      collection = type.endpoint == 'folder' 
          ? Folder.fromJson(body['folder'])
          : Tag.fromJson(body['tag']);

      final notesData = body['notes_inside'];
      notesInCollection = notesData.map<QuickNote>((note) => QuickNote.fromJson(note)).toList();
      initialNotesCollection = List.from(notesInCollection);

      isLoading = false;
      notifyListeners();
    }
    return response.statusCode;
  }

  Future<int> loadAvailableNotes() async {
    // if (!isLoading) {
    //   isLoading = true;
    //   notifyListeners();
    // }

    print("in load available");
    print(type.endpoint);
    
    final response = await http.get(
      Uri.parse("http://localhost:8080/${type.endpoint}/view/avaiable"),
      headers: {
        'Content-Type': 'application/json',
        'access_token': await secureStorage!.read(key: 'access_token')?? '',
        type.idHeaderName: collectionId.toString(),
        'except': notesInCollection.map((note) => note.getId).toList().toString(),
      }
    );

    if (response.statusCode == 200) {
      print("everything was good");
      final notesList = jsonDecode(response.body);
      print(notesList);
      availableNotes = notesList.map<QuickNote>((note) => QuickNote.fromJson(note)).toList();
      isLoading = false;
      notifyListeners();
    }
    return response.statusCode;
  }

  Future<int> searchNotes(String query) async {
    if (query.isEmpty) return 0;
    _debounceTimer?.cancel();
    
    // Create a Completer to handle the async result
    final completer = Completer<int>();
    
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      // Assuming _performSearch returns the status code
      final statusCode = await _performSearch(query, isInCollection: false);
      completer.complete(statusCode);
    });
    
    return completer.future;
  }

  Future<int> searchInsideCollection(String query) async {
    if (query.isEmpty) return 0;

    _debounceTimer?.cancel();
    await Future.delayed(const Duration(milliseconds: 300));

    return await _performSearch(query, isInCollection: true);
  }

  Future<int> _performSearch(String query, {required bool isInCollection}) async {
    isLoading = true;
    isInCollection ? isCollectionSearchActive = true : isSearchActive = true;
    notifyListeners();

    final endpoint = isInCollection 
        ? "search/in/${type.endpoint}/notes"
        : "search/in/notes";
    
    final response = await http.get(
      Uri.parse("http://localhost:8080/$endpoint"),
      headers: {
        'Content-Type': 'application/json',
        'access_token': await secureStorage!.read(key: 'access_token')?? '',
        if (isInCollection) type.idHeaderName: collectionId.toString(),
        'query': query
      }
    );

    if (response.statusCode == 200) {
      final results = jsonDecode(response.body);
      if (isInCollection) {
        collectionSearchResults = results.map<QuickNote>((note) => QuickNote.fromJson(note)).toList();
      } else {
        searchResults = results.map<QuickNote>((note) => QuickNote.fromJson(note)).toList();
      }
      isLoading = false;
      notifyListeners();
    }
    return response.statusCode;
  }

  void addNoteToCollection(int index) {
    final note = isSearchActive 
        ? searchResults.removeAt(index)
        : availableNotes.removeAt(index);
    
    if (isSearchActive) {
      availableNotes.remove(note);
    }

    if (!notesInCollection.contains(note)) {
      notesInCollection.add(note);
      _updateListChangeStatus();
    }
    notifyListeners();
  }

  void removeNoteFromCollection(int index) {
    notesInCollection.removeAt(index);
    _updateListChangeStatus();
    notifyListeners();
  }

  void clearSearch({bool inCollection = false}) {
    _debounceTimer?.cancel();
    print("in clearSearch");

    if (inCollection && !isCollectionSearchActive) {
      print(1);
      return;
    }
    if (!inCollection && !isSearchActive) {
      print(2);
      return;
    }

    if (inCollection) {
      isCollectionSearchActive = false;
      collectionSearchResults.clear();
      print(3);
    } else {
      isSearchActive = false;
      searchResults.clear();
      print(4);
    }
    notifyListeners();
  }

  void _updateListChangeStatus() {
    final currentSet = Set.from(notesInCollection);
    final initialSet = Set.from(initialNotesCollection);
    
    changes['list'] = !(currentSet.length == initialSet.length && 
                       initialSet.containsAll(currentSet));
    notifyListeners();
  }

  void updateFieldStatus(String field, bool changed) {
    if (changes.containsKey(field) && changes[field] != changed) {
      changes[field] = changed;
      notifyListeners();
    }
  }

  void update({String? name, String? description, String? icon}) {
    if (type.endpoint == 'folder') {
      final folder = collection as Folder;
      if (name != null) folder.folderName = name;
      if (description != null) folder.folderDescription = description;
      if (icon != null) folder.icon = icon;
    } else {
      final tag = collection as Tag;
      if (name != null) tag.tag = name;
    }

    initialNotesCollection = List.from(notesInCollection);
    changes.updateAll((_, __) => false);
    notifyListeners();
  }

  void reset() {
    collection = null;
    collectionId = null;
    secureStorage = null;
    availableNotes.clear();
    notesInCollection.clear();
    searchResults.clear();
    collectionSearchResults.clear();
    isLoading = true;
    isSearchActive = false;
    isCollectionSearchActive = false;
    _debounceTimer = null;
    changes.updateAll((_, __) => false);
  }
}
