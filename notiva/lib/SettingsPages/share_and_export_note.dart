import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class ShareAndExport extends StatefulWidget {
  final String data;
  const ShareAndExport({super.key, required this.data});

  @override
  State<StatefulWidget> createState() => _ShareAndExportState();
}

class _ShareAndExportState extends State<ShareAndExport> with SingleTickerProviderStateMixin {
  bool switchShare = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> exportAudio() async {
    String? result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      print(result);
    }
  }

  @override
  Widget build(context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            "Share&Export",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              letterSpacing: -0.5,
            )
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: Column(
          children: [
            const SizedBox(
              height: 16,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0), // Додав бокові відступи
              child: Container(
                height: 44, // Фіксована висота для кращого вигляду
                decoration: BoxDecoration(
                  color: Colors.grey.shade100, // Світліший відтінок
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all( // Додав тонку рамку
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: TabBar(
                  dividerHeight: 0,
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [ // Додав легку тінь для виділеного табу
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.black,
                  labelStyle: const TextStyle( // Стиль для активного табу
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    letterSpacing: -0.3,
                  ),
                  unselectedLabelStyle: const TextStyle( // Стиль для неактивного табу
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                    letterSpacing: -0.3,
                  ),
                  padding: const EdgeInsets.all(3), // Внутрішній відступ для табів
                  tabs: const [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 8),
                          Text("Share"),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 8),
                          Text("Export"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(
                            bottom: 8.0,
                            top: 16.0,
                            left: 4.0
                          ),
                          child: Text(
                            "File link",
                            style: TextStyle(
                              // fontWeight: FontWeight.w500,
                              color: Colors.black54,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.06,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: Text(
                                  "https://app.notiva.ai/share/${widget.data}",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: IconButton(
                                  onPressed: (){
                                    Clipboard.setData(ClipboardData(text: "https://app.notiva.ai/share/${widget.data}"));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Copied to clipboard"),
                                      )
                                    );
                                  },
                                  icon: const Icon(Icons.copy)
                                )
                              )
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            const Padding(
                              padding: EdgeInsets.only(left: 16.0),
                              child: Text(
                                "Anyone can access web link",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: CupertinoSwitch(
                                value: switchShare, 
                                onChanged: (value){
                                  setState(() {
                                    switchShare = value;
                                  });
                                },
                              ),
                            )
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.only(
                            bottom: 8.0,
                            top: 16.0,
                            left: 4.0
                          ),
                          child: Text(
                            "Sharing options",
                            style: TextStyle(
                              // fontWeight: FontWeight.w500,
                              color: Colors.black54,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.06,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                const Padding(
                                  padding: EdgeInsets.only(left: 16.0),
                                  child: Text(
                                    "Share note summary",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: IconButton(
                                    onPressed: () async {
                                      await Share.share(
                                        widget.data,
                                      );
                                    },
                                    icon: const Icon(Icons.ios_share)
                                  )
                                )
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.06,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                const Padding(
                                  padding: EdgeInsets.only(left: 16.0),
                                  child: Text(
                                    "Share note transcript",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: IconButton(
                                    onPressed: () async {
                                      await Share.share(
                                        widget.data,
                                      );
                                    },
                                    icon: const Icon(Icons.ios_share)
                                  )
                                )
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.06,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                const Padding(
                                  padding: EdgeInsets.only(left: 16.0),
                                  child: Text(
                                    "Share audio",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: IconButton(
                                    onPressed: () async {
                                      await Share.share(
                                        widget.data,
                                      );
                                    },
                                    icon: const Icon(Icons.ios_share)
                                  )
                                )
                              ],
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(
                            bottom: 8.0,
                            top: 16.0,
                            left: 4.0
                          ),
                          child: Text(
                            "Integration",
                            style: TextStyle(
                              // fontWeight: FontWeight.w500,
                              color: Colors.black54,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.06,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                const Padding(
                                  padding: EdgeInsets.only(left: 16.0),
                                  child: Text(
                                    "Notion",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: IconButton(
                                    onPressed: () {},
                                    icon: const Icon(Icons.note_rounded)
                                  )
                                )
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.06,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                const Padding(
                                  padding: EdgeInsets.only(left: 16.0),
                                  child: Text(
                                    "Google Docs",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: IconButton(
                                    onPressed: () {},
                                    icon: const Icon(Icons.edit_document)
                                  )
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(
                            bottom: 8.0,
                            top: 16.0,
                            left: 4.0
                          ),
                          child: Text(
                            "Audio",
                            style: TextStyle(
                              // fontWeight: FontWeight.w500,
                              color: Colors.black54,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.06,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                const Padding(
                                  padding: EdgeInsets.only(left: 16.0),
                                  child: Text(
                                    "Export audio",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: IconButton(
                                    onPressed: () {exportAudio();},
                                    icon: const Icon(Icons.ios_share)
                                  )
                                )
                              ],
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(
                            bottom: 8.0,
                            top: 16.0,
                            left: 4.0
                          ),
                          child: Text(
                            "Text",
                            style: TextStyle(
                              // fontWeight: FontWeight.w500,
                              color: Colors.black54,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.06,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                const Padding(
                                  padding: EdgeInsets.only(left: 16.0),
                                  child: Text(
                                    "Export as TXT",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: IconButton(
                                    onPressed: () {},
                                    icon: const Icon(Icons.ios_share)
                                  )
                                )
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.06,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                const Padding(
                                  padding: EdgeInsets.only(left: 16.0),
                                  child: Text(
                                    "Export as PDF",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: IconButton(
                                    onPressed: () {},
                                    icon: const Icon(Icons.ios_share)
                                  )
                                )
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.06,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                const Padding(
                                  padding: EdgeInsets.only(left: 16.0),
                                  child: Text(
                                    "Export as DOCX",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: IconButton(
                                    onPressed: () {},
                                    icon: const Icon(Icons.ios_share)
                                  )
                                )
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.06,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                const Padding(
                                  padding: EdgeInsets.only(left: 16.0),
                                  child: Text(
                                    "Export as STR",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: IconButton(
                                    onPressed: () {},
                                    icon: const Icon(Icons.ios_share)
                                  )
                                )
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.06,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                const Padding(
                                  padding: EdgeInsets.only(left: 16.0),
                                  child: Text(
                                    "Export as EXCEL",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: IconButton(
                                    onPressed: () {},
                                    icon: const Icon(Icons.ios_share)
                                  )
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ,]
              ),
            )
          ],
        ),
      )
    );
  }


  // @override
  // Widget build(context) {
  //   return SafeArea(
  //     child: DefaultTabController(
  //       initialIndex: 0,
  //       length: 2,
  //       animationDuration: Duration(milliseconds: 300),
  //       child: Scaffold(
  //         appBar: AppBar(
  //           title: Container(
  //             alignment: Alignment.center,
  //             decoration: const BoxDecoration(
  //               color: Colors.white,
  //             ),
  //             child: const Column(
  //               children: [
  //                 Text(
  //                   "Share&Export",
  //                   style: TextStyle(
  //                     fontWeight: FontWeight.bold,
  //                     fontSize: 18
  //                   )
  //                 ),
  //                 Divider(
  //                   color: Colors.black,
  //                   thickness: 2,
  //                   indent: 50,
  //                   endIndent: 50,
  //                 ),
  //               ],
  //             ),
  //           ),
  //           bottom: PreferredSize(
  //             preferredSize: const Size.fromHeight(50.0),
  //             child: Padding(
  //               padding: const EdgeInsets.all(8.0),
  //               child: Container(
  //                 decoration: BoxDecoration(
  //                   color: Colors.grey.shade400,
  //                   borderRadius: BorderRadius.circular(10)
  //                 ),
  //                 child: Padding(
  //                   padding: const EdgeInsets.all(2.0),
  //                   child: TabBar(
  //                     indicator: BoxDecoration(
  //                       color: Colors.white,
  //                       borderRadius: BorderRadius.circular(10.0),
  //                     ),
  //                     labelColor: Colors.black,
  //                     unselectedLabelColor: Colors.black87, 
  //                     tabs: const <Widget>[
  //                       SizedBox(
  //                         width: double.infinity,
  //                         child: Tab(text: 'Share')
  //                       ),
  //                       SizedBox(
  //                         width: double.infinity,
  //                         child: Tab(text: 'Export')
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //         body: TabBarView(
  //           children: <Widget>[
  //             GridView.count(
  //               crossAxisCount: 1,
  //               mainAxisSpacing: 10,
  //               childAspectRatio: 10,
  //               children: <Widget>[
  //                 const Text("File link"),
  //                 Container(
  //                   decoration: BoxDecoration(
  //                     color: Colors.white,
  //                     borderRadius: BorderRadius.circular(15),
  //                   ),
  //                   child: Row(
  //                     children: <Widget>[
  //                       Text("https://app.notiva.ai/share/${widget.data}"),
  //                       const Icon(Icons.copy),
  //                     ],
  //                   ),
  //                 ),
  //                 Row(
  //                   children: <Widget>[
  //                     const Text("Anyone can access web link"),
  //                     Switch(
  //                       value: switchShare, 
  //                       onChanged: (value){
  //                         setState(() {
  //                           switchShare = value;
  //                         });
  //                       },
  //                       activeColor: Colors.white,
  //                       activeTrackColor: Colors.greenAccent.shade700,
  //                       inactiveThumbColor: Colors.white,
  //                       inactiveTrackColor: Colors.grey,
  //                     )
  //                   ],
  //                 ),
  //                 const Text("Sharing options"),
  //                 Container(
  //                   decoration: BoxDecoration(
  //                     color: Colors.white,
  //                     borderRadius: BorderRadius.circular(15),
  //                   ),
  //                   child: const  Row(
  //                     children: <Widget>[
  //                       Text("Share note summary"),
  //                       Icon(Icons.ios_share),
  //                     ],
  //                   ),
  //                 ),
  //                 Container(
  //                   decoration: BoxDecoration(
  //                     color: Colors.white,
  //                     borderRadius: BorderRadius.circular(15),
  //                   ),
  //                   child: const  Row(
  //                     children: <Widget>[
  //                       Text("Share note transcript"),
  //                       Icon(Icons.ios_share),
  //                     ],
  //                   ),
  //                 ),
  //                 Container(
  //                   decoration: BoxDecoration(
  //                     color: Colors.white,
  //                     borderRadius: BorderRadius.circular(15),
  //                   ),
  //                   child: const  Row(
  //                     children: <Widget>[
  //                       Text("Share audio"),
  //                       Icon(Icons.ios_share),
  //                     ],
  //                   ),
  //                 ),
  //                 const Text("Integration"),
  //                 Container(
  //                   decoration: BoxDecoration(
  //                     color: Colors.white,
  //                     borderRadius: BorderRadius.circular(15),
  //                   ),
  //                   child: const  Row(
  //                     children: <Widget>[
  //                       Text("Notion"),
  //                       Icon(Icons.note_rounded),
  //                     ],
  //                   ),
  //                 ),
  //                 Container(
  //                   decoration: BoxDecoration(
  //                     color: Colors.white,
  //                     borderRadius: BorderRadius.circular(15),
  //                   ),
  //                   child: const  Row(
  //                     children: <Widget>[
  //                       Text("Google Docs"),
  //                       Icon(Icons.edit_document),
  //                     ],
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             GridView.count(
  //               crossAxisCount: 1,
  //               mainAxisSpacing: 10,
  //               childAspectRatio: 10,
  //               children: <Widget>[
  //                 const Text("Audio"),
  //                 Container(
  //                   decoration: BoxDecoration(
  //                     color: Colors.white,
  //                     borderRadius: BorderRadius.circular(15),
  //                   ),
  //                   child: const  Row(
  //                     children: <Widget>[
  //                       Text("Export audio"),
  //                       Icon(Icons.ios_share),
  //                     ],
  //                   ),
  //                 ),
  //                 const Text("Text"),
  //                 Container(
  //                   decoration: BoxDecoration(
  //                     color: Colors.white,
  //                     borderRadius: BorderRadius.circular(15),
  //                   ),
  //                   child: const  Row(
  //                     children: <Widget>[
  //                       Text("Export as TXT"),
  //                       Icon(Icons.ios_share),
  //                     ],
  //                   ),
  //                 ),
  //                 Container(
  //                   decoration: BoxDecoration(
  //                     color: Colors.white,
  //                     borderRadius: BorderRadius.circular(15),
  //                   ),
  //                   child: const  Row(
  //                     children: <Widget>[
  //                       Text("Export as PDF"),
  //                       Icon(Icons.ios_share),
  //                     ],
  //                   ),
  //                 ),
  //                 Container(
  //                   decoration: BoxDecoration(
  //                     color: Colors.white,
  //                     borderRadius: BorderRadius.circular(15),
  //                   ),
  //                   child: const  Row(
  //                     children: <Widget>[
  //                       Text("Export as DOCX"),
  //                       Icon(Icons.ios_share),
  //                     ],
  //                   ),
  //                 ),
  //                 Container(
  //                   decoration: BoxDecoration(
  //                     color: Colors.white,
  //                     borderRadius: BorderRadius.circular(15),
  //                   ),
  //                   child: const  Row(
  //                     children: <Widget>[
  //                       Text("Export as STR"),
  //                       Icon(Icons.ios_share),
  //                     ],
  //                   ),
  //                 ),
  //                 Container(
  //                   decoration: BoxDecoration(
  //                     color: Colors.white,
  //                     borderRadius: BorderRadius.circular(15),
  //                   ),
  //                   child: const  Row(
  //                     children: <Widget>[
  //                       Text("Export as EXCEL"),
  //                       Icon(Icons.ios_share),
  //                     ],
  //                   ),
  //                 ),
  //                 ],
  //             ),
  //           ]
  //         ),
  //       ),
  //     )
  //   );
  // }
}
