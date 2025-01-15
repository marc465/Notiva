import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:notiva/Entities/quick_note.dart';
import 'package:notiva/MainPages/ReviewingPages/note_review.dart';
import 'dart:convert';

class Favourites extends StatefulWidget {

  final FlutterSecureStorage secureStorage;

  const Favourites({super.key, required this.secureStorage});

  @override
  State<StatefulWidget> createState() => _FavouritesState();
}

class _FavouritesState extends State<Favourites> {

  List<QuickNote> favNotes = [];

  // void _loadMoreItems() {}

  void getNotes() async {
    
    final response = await http.get(Uri.parse("http://localhost:8080/favourites/get"), headers: {
        'Content-Type': 'application/json',
        'access_token': await widget.secureStorage.read(key: 'access_token') ?? ""
    });

    // print(response.statusCode);
    // print(response.body);

    List<dynamic> decodedFavNotes = jsonDecode(response.body);
    setState(() {
      favNotes = decodedFavNotes.map((note) => QuickNote.fromJson(note)).toList();
    });
  }

    List<Widget> getFavNotesWidgets() {
    List<Widget> notesWidgets = [];
    for (QuickNote note in favNotes) {
      notesWidgets.add(
        Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            height: 10,
            width: double.infinity,
            child: Container(
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(20.0))
              ),
              child: ElevatedButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => NoteReview(secureStorage: widget.secureStorage, noteId: note.getId)));
                },
                child: Row(
                  children: <Widget>[
                    Text(note.getIcon),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Text(note.getNotesName)
                          ),
                          Expanded(
                            child: Text(note.getTranscript)
                          )
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_outlined)
                  ],
                ),
              )
            ),
          )
        )
      );
    }
    return notesWidgets;
  }

    @override
    void initState() {
      super.initState();
      getNotes();
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.count(
        crossAxisCount: 1,
        childAspectRatio: 4,
        // List of notes
        children: getFavNotesWidgets()
      ),
    );
  }

}