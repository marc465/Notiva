import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:notiva/Entities/quick_folder.dart';
import 'package:notiva/MainPages/ReviewingPages/folder_review.dart';
import 'package:notiva/Providers/folders_provider.dart';
// import 'package:notiva/Providers/universal_collection_provider.dart';
import 'package:notiva/Service/service_api.dart';
import 'package:provider/provider.dart';

class Folders extends StatefulWidget {

  final FlutterSecureStorage secureStorage;

  const Folders({super.key, required this.secureStorage});

  @override
  State<StatefulWidget> createState() => FoldersState();
}

class FoldersState extends State<Folders> with TickerProviderStateMixin {
  late FoldersProvider provider;
  late ServiceAPI requestProvider;
  OverlayEntry? overlayEntry;
  final Map<int, AnimationController> _animationControllers = {};


  @override
  void initState() {
    super.initState();
    provider = context.read<FoldersProvider>();
    requestProvider = Provider.of<ServiceAPI>(context, listen: false);
    if (!provider.wasInitialized) {
      initialization();
    }
  }

  void initialization() async {
    await requestProvider.handleRequest(provider.getFolders, context);
    
    if (mounted) {
      setState(() {});
    }
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
                      provider.deleteStart(_animationControllers, index);
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
    _animationControllers[index] ??= AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    return SizeTransition(
      sizeFactor: Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(
          parent: _animationControllers[index]!,
          curve: Curves.easeInOut,
        ),
      ),
      child: GestureDetector(
        onTap: () async {
          // final providerTemp = Provider.of<NotesCollectionProvider>(context, listen: false);
          // String token = await widget.secureStorage.read(key: 'access_token') ?? '';
          // CollectionItem tempType = FolderItem();
          // providerTemp.initialization(token, tempType);

          // final requestProvider = Provider.of<ServiceAPI>(context, listen: false);

          // await requestProvider.handleRequest(
          //   () async {return await providerTemp.getInitialData(folder.getId);}, 
          //   context
          // );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FolderReview(
                folderId: folder.getId,
                secureStorage: widget.secureStorage,
              ),
            ),
          );
        },
        onLongPressStart: (details) {
          showCupertinoContextMenu(context, details, index);
        },

        // The folder card
        child: Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(12),
          // If you want a fixed size for uniform cards, uncomment the next lines:
          // width: 160,
          // height: 140,
          decoration: BoxDecoration(
            color: CupertinoColors.white,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: CupertinoColors.systemGrey6,
              width: 1,
            ),
            // Optional subtle shadow for a slightly elevated look
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: icon at top-left
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        folder.icon,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Folder name in bold
              Text(
                folder.folderName,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Description or note count
              Text(
                '${folder.count_notes} note${folder.count_notes > 1? 's': ''}',
                style: const TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.inactiveGray,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {await requestProvider.handleRequest(provider.getFolders, context);},
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5
          ),
          itemCount: provider.folders.length,
          itemBuilder: (context, index) {
            return foldersGenerator(context, provider.folders[index], index);
          }
        ),
      ),
    );
  }
}
