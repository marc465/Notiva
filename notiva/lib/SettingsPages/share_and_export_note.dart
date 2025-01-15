import 'package:flutter/material.dart';

class ShareAndExport extends StatefulWidget {
  final String data;
  const ShareAndExport({super.key, required this.data});

  @override
  State<StatefulWidget> createState() => _ShareAndExportState();
}

class _ShareAndExportState extends State<ShareAndExport> {
  bool switchShare = false;

  @override
  Widget build(context) {
    return SafeArea(
      child: DefaultTabController(
        initialIndex: 0,
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              "Share&Export",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18
              )
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: TabBar(
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.black87, 
                      tabs: const <Widget>[
                        SizedBox(
                          width: double.infinity,
                          child: Tab(text: 'Share')
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: Tab(text: 'Export')
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          body: TabBarView(
            children: <Widget>[
              GridView.count(
                crossAxisCount: 1,
                mainAxisSpacing: 10,
                childAspectRatio: 10,
                children: <Widget>[
                  const Text("File link"),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: <Widget>[
                        Text("https://app.notiva.ai/share/${widget.data}"),
                        const Icon(Icons.copy),
                      ],
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      const Text("Anyone can access web link"),
                      Switch(
                        value: switchShare, 
                        onChanged: (value){
                          setState(() {
                            switchShare = value;
                          });
                        },
                        activeColor: Colors.white,
                        activeTrackColor: Colors.greenAccent.shade700,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: Colors.grey,
                      )
                    ],
                  ),
                  const Text("Sharing options"),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const  Row(
                      children: <Widget>[
                        Text("Share note summary"),
                        Icon(Icons.ios_share),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const  Row(
                      children: <Widget>[
                        Text("Share note transcript"),
                        Icon(Icons.ios_share),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const  Row(
                      children: <Widget>[
                        Text("Share audio"),
                        Icon(Icons.ios_share),
                      ],
                    ),
                  ),
                  const Text("Integration"),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const  Row(
                      children: <Widget>[
                        Text("Notion"),
                        Icon(Icons.note_rounded),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const  Row(
                      children: <Widget>[
                        Text("Google Docs"),
                        Icon(Icons.edit_document),
                      ],
                    ),
                  ),
                ],
              ),
              GridView.count(
                crossAxisCount: 1,
                mainAxisSpacing: 10,
                childAspectRatio: 10,
                children: <Widget>[
                  const Text("Audio"),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const  Row(
                      children: <Widget>[
                        Text("Export audio"),
                        Icon(Icons.ios_share),
                      ],
                    ),
                  ),
                  const Text("Text"),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const  Row(
                      children: <Widget>[
                        Text("Export as TXT"),
                        Icon(Icons.ios_share),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const  Row(
                      children: <Widget>[
                        Text("Export as PDF"),
                        Icon(Icons.ios_share),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const  Row(
                      children: <Widget>[
                        Text("Export as DOCX"),
                        Icon(Icons.ios_share),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const  Row(
                      children: <Widget>[
                        Text("Export as STR"),
                        Icon(Icons.ios_share),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const  Row(
                      children: <Widget>[
                        Text("Export as EXCEL"),
                        Icon(Icons.ios_share),
                      ],
                    ),
                  ),
                  ],
              ),
            ]
          ),
        ),
      )
    );
  }
}
