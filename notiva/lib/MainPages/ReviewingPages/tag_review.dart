import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:notiva/Entities/quick_note.dart';
import 'package:notiva/MainPages/ReviewingPages/note_review.dart';

class TagReview extends StatefulWidget {
  final FlutterSecureStorage secureStorage;
  final int tagId;

  const TagReview({super.key, required this.secureStorage, required this.tagId});

  @override
  _TagReviewState createState() => _TagReviewState();
}

class _TagReviewState extends State<TagReview> {
  final String _hintText = "Search in tag...";
  final ScrollController _scrollController = ScrollController();
  List<QuickNote> _notesInTag = <QuickNote>[];

  @override
  void initState() {
    super.initState();
    getInitialDataFromServer();
  }

  Future<void> getInitialDataFromServer() async {
    final response = await http.get(Uri.parse("http://localhost:8080/tag/view"), headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'access_token': await widget.secureStorage.read(key: 'access_token') ?? '',
      'tag_id': widget.tagId.toString()
    });

    print(response.statusCode);
    print(response.body);

    try {
      if (response.statusCode == 200) {
        List<dynamic> temp = jsonDecode(response.body);
        setState(() {
          _notesInTag = temp.map((note) => QuickNote.fromJson(note)).toList();
        });
      }
    } on Exception catch (e) {
      print(e);
    }
  }

  List<Widget> getNotesInTag() {
    List<Widget> res = [];

    for (var note in _notesInTag) {
      res.add(Padding(
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
            child: ListTile(
              title: Text(note.getNotesName),
              subtitle: Text(note.getTranscript),
              onTap: () {Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => NoteReview(secureStorage: widget.secureStorage, noteId: note.getId))
              );},
            ),
          ),
        ),
      ));
    }

    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
          title: const Text('MyTag'),
          actions: <Widget>[
            IconButton(
              onPressed: (){},
              icon:  const Icon(
                Icons.settings_outlined
              )
            )
          ],
        // Search bar and tags button
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  // Search bar
                  Expanded(child: TextField(
                    decoration: InputDecoration(
                      hintText: _hintText,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.mic),
                        onPressed: () {},
                      ), 
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        borderSide: BorderSide.none
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      contentPadding: const EdgeInsets.all(8.0),
                    ),
                    onSubmitted: (textToSearch){},
                  )
                  ),
                  // Tags button
                  const SizedBox(width: 8,),
                ]
              ),
            ),
          ),
        ),
        // body
        body: GridView.count(
          crossAxisCount: 1,
          controller: _scrollController,
          childAspectRatio: 4,
          children: getNotesInTag(),
          ),
    );
  }
}
