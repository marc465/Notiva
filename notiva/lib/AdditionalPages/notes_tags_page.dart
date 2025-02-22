import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:notiva/MainPages/CreatingPages/new_tag.dart';
import 'package:notiva/MainPages/ReviewingPages/tag_review.dart';
import 'package:http/http.dart' as http;
import 'package:notiva/Entities/quick_tag.dart';
import 'package:notiva/Service/service_api.dart';
import 'package:provider/provider.dart';
// import 'package:notiva/Providers/universal_collection_provider.dart';
// import 'package:notiva/Service/service_api.dart';
// import 'package:provider/provider.dart';


class NotesTagPage extends StatefulWidget {
  final FlutterSecureStorage secureStorage;
  const NotesTagPage({super.key, required this.secureStorage});

  @override
  _NotesTagPageState createState() => _NotesTagPageState();
}

class _NotesTagPageState extends State<NotesTagPage> {
  late TagsProvider provider;
  late ServiceAPI requestProvider;
  // final DraggableScrollableController _grabberController = DraggableScrollableController();

  @override
  void initState() {
    provider = Provider.of<TagsProvider>(context, listen: false);
    requestProvider = Provider.of<ServiceAPI>(context, listen: false);
    initialization();
    super.initState();
    // _grabberController.addListener(_draggableListener);
  }

  void initialization() async {
    provider.initial(widget.secureStorage);
    await requestProvider.handleRequest(provider.getInitialData, context);
  }

  @override
  void dispose() {
    provider.clear();
    super.dispose();
  }

  Future<void> refreshData() async {
    try {
      provider.setLoading(true);
      await requestProvider.handleRequest(
        provider.getInitialData, 
        context
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading tags: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        provider.setLoading(false);
      }
    }
  }

  Widget tagsGenerator(BuildContext context, QuickTag tag, TagsProvider tempProvider) {
    return Slidable(
      key: ValueKey(tag.getId),
      endActionPane: ActionPane(
        dismissible: DismissiblePane(
          onDismissed: () {tempProvider.deleteTag(tag.getId);},
        ),
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (context){tempProvider.deleteTag(tag.getId);},
            label: 'Delete',
            icon: Icons.delete_outline_rounded,
            backgroundColor: Colors.red.shade700,
            foregroundColor: Colors.white,
          )
        ]),
      child: GestureDetector(
        onTap: () async {
          Navigator.push(context, MaterialPageRoute(builder: (context) => TagReview(secureStorage: widget.secureStorage, tagId: tag.getId)));
        },
        child: Container(
          height: 50,
          width: double.infinity,
          margin: const EdgeInsets.all(5),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300, width: 1),
            )
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "#${tag.getTag}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16
              ),
            ),
          ),
        ),
      )
    );

  }


  @override
  Widget build(context) {
    return Consumer<TagsProvider>(
      builder: (context, buildProvider, child) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
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
          body: buildProvider.isLoading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 1,),)      
          : Padding(
            padding: const EdgeInsets.only(bottom: 60),
            child: RefreshIndicator(
              onRefresh: refreshData,
              child: ListView.builder(
                itemCount: buildProvider.tags.length,
                itemBuilder: (context, index) {
                  return tagsGenerator(context, buildProvider.tags[index], buildProvider);
                },
              ),
            ),
          ),
          floatingActionButton: 
          Padding(
            padding: const EdgeInsets.only(left: 30),
            child: SizedBox(
              width: double.infinity,
              height: 46,
              child: FloatingActionButton(
                onPressed: (){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => NewTag(secureStorage: widget.secureStorage)));
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
    );
  }
}

class TagsProvider extends ChangeNotifier {
  List<QuickTag> tags = <QuickTag>[];
  late FlutterSecureStorage secureStorage;
  bool isLoading = true;

  TagsProvider();

  void initial(FlutterSecureStorage storage) {
    secureStorage = storage;
  }

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future<int> getInitialData() async {
    
    final response = await http.get(Uri.parse("http://localhost:8080/tags/get"), headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'access_token': await secureStorage.read(key: 'access_token') ?? ''
    });

    if (response.statusCode == 200) {
      List<dynamic> temp = jsonDecode(response.body);
      tags = temp.map((tag) => QuickTag.fromJson(tag)).toList();
      isLoading = false;
      notifyListeners();
    }

    return response.statusCode;
  }

  Future<int> deleteTag(int id) async {
    final response = await http.delete(Uri.parse("http://localhost:8080/tags/delete"), headers: {
        'Content-Type': 'application/json',
        'access_token': await secureStorage.read(key: 'access_token') ?? "",
        'tag_id': id.toString()
    });

    tags.removeWhere((tag) => tag.getId == id);
    notifyListeners();

    return response.statusCode;
  }

  void clear() {
   tags = <QuickTag>[];
  }
}