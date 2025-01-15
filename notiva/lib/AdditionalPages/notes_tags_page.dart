import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:notiva/MainPages/CreatingPages/new_tag.dart';
import 'package:notiva/MainPages/ReviewingPages/tag_review.dart';
import 'package:http/http.dart' as http;
import 'package:notiva/Entities/quick_tag.dart';


class NotesTagPage extends StatefulWidget {
  final FlutterSecureStorage secureStorage;
  const NotesTagPage({super.key, required this.secureStorage});

  @override
  _NotesTagPageState createState() => _NotesTagPageState();
}

class _NotesTagPageState extends State<NotesTagPage> {
  List<QuickTag> tags = <QuickTag>[];

  @override
  void initState() {
    super.initState();
    getInitialData();
  }

  Future<void> getInitialData() async {
    final response = await http.get(Uri.parse("http://localhost:8080/tags/get"), headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'access_token': await widget.secureStorage.read(key: 'access_token') ?? ''
  });

    print(response.statusCode);
    print(response.body);

    try {
      if (response.statusCode == 200) {
        List<dynamic> temp = jsonDecode(response.body);
        setState(() {
          tags = temp.map((tag) => QuickTag.fromJson(tag)).toList();
        });
      }
    } on Exception catch (e) {
      print(e);
    }
  }

  List<Widget> getTagsWidgets() {
    List<Widget> res = [];
    for (var tag in tags) {
      res.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context)=> TagReview(secureStorage: widget.secureStorage, tagId: tag.getId)
                      )
                    );
                  },
            child: Container(
              alignment: Alignment.center,
              child: Text(
                tag.getTag,
                style: const TextStyle(
                  fontWeight: FontWeight.bold
                )
              )
            ),
          ),
        )
      );
    }
    return res;
  }


  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Tags",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search in the tags",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: (){},
                  icon: const Icon(Icons.mic)
                )
              ),
            ),
          )
        ),
      ),
      body: GridView.count(
        crossAxisCount: 1,
        childAspectRatio: 5,
        children: getTagsWidgets(),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 30),
        child: SizedBox(
          width: double.infinity,
          height: 46,
          child: FloatingActionButton(
            onPressed: (){
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => NewTag(secureStorage: widget.secureStorage) )
                ).then((value) {
                  print("object");
                  getInitialData();
                });
            },
            backgroundColor: Colors.blue.shade700,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30))
            ),
            child: Text("Create New Tag", style: const TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }
}
