import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:notiva/Entities/quick_folder.dart';
import 'package:notiva/MainPages/ReviewingPages/folder_review.dart';
import 'package:notiva/Providers/folders_provider.dart';
import 'package:notiva/StartingPages/home.dart';
import 'package:provider/provider.dart';


class FoldersSearchResults extends StatefulWidget {
  final FlutterSecureStorage secureStorage;
  final SearchProviderFolders searchProvFolders;

  const FoldersSearchResults({super.key, required this.secureStorage, required this.searchProvFolders});

  @override
  State<FoldersSearchResults> createState() => _FoldersSearchResultsState();
}


class _FoldersSearchResultsState extends State<FoldersSearchResults> {
  OverlayEntry? overlayEntry;
  final Map<int, AnimationController> _animationControllers = {};


  @override
  void initState() {
    super.initState();
    print("in new folders page");
  }

  void showCupertinoContextMenu(BuildContext context, LongPressStartDetails details, int index) {
    final overlay = Overlay.of(context);
    final targetPosition = details.globalPosition;
    
    overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Blurred background
          Positioned.fill(
            child: GestureDetector(
              onTap: () => removeOverlay(),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(color: Colors.black.withOpacity(0.2)),
              ),
            ),
          ),
          
          // Floating menu
          AnimatedPositioned(
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            left: (targetPosition.dx + 175 + 10 > MediaQuery.of(context).size.width)? MediaQuery.of(context).size.width - 185: targetPosition.dx + 10,
            top: targetPosition.dy - 60,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    cupertinoMenuButton("Reply", Icons.reply, () {
                      print("Reply tapped");
                      removeOverlay();
                    }),
                    cupertinoMenuButton("Copy", Icons.copy, () {
                      print("Copy tapped");
                      removeOverlay();
                    }),
                    cupertinoMenuButton("Delete", Icons.delete, () {
                      print("Delete tapped");
                      Provider.of<FoldersProvider>(context, listen: false).deleteStart(_animationControllers, index);
                      removeOverlay();
                    }, color: CupertinoColors.systemRed),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    overlay.insert(overlayEntry!);
  }

  void removeOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  Widget cupertinoMenuButton(String text, IconData icon, VoidCallback onTap, {Color color = CupertinoColors.activeBlue}) {
    return CupertinoButton(
      padding: EdgeInsets.symmetric(horizontal: 10),
      onPressed: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          SizedBox(height: 4),
          Text(text, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }

  Widget foldersGenerator(BuildContext context, QuickFolder folder, int index) {
    return GestureDetector(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => FolderReview(folderId: folder.getId, secureStorage: widget.secureStorage,)));
      },
      onLongPressStart: (details) {
        showCupertinoContextMenu(context, details, index);
      },
      child: Container(
        margin: const EdgeInsets.all(5),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(16.0)),
          border: Border(
            top: BorderSide(color: Colors.grey.shade200, width: 1),
            right: BorderSide(color: Colors.grey.shade200, width: 1),
            left: BorderSide(color: Colors.grey.shade200, width: 1),
            bottom: BorderSide(color: Colors.grey.shade200, width: 1),
            )
        ),
        child: Row(
          children: <Widget>[
            Text(folder.icon, style: const TextStyle(fontSize: 30)),
            Expanded(child: Text(folder.folderName)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    if (widget.searchProvFolders.isLoading) {
      print("is loading");
      return const Center(
        child: CircularProgressIndicator(),
      );
    }


    if (widget.searchProvFolders.result.isEmpty) {
      print("nothing found");
      return const Center(
        child: Text("Nothing was find :(")
      );
    }

    print("everything is correct");

    return Scaffold(
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.5
        ),
        itemCount: widget.searchProvFolders.result.length,
        itemBuilder: (context, index) {
          return foldersGenerator(context, widget.searchProvFolders.result[index], index);
        }
      ),
    );
  }
}
