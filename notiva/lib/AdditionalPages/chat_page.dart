import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget{
  final int noteId;
  const ChatPage({super.key, required this.noteId});

  @override
  State<ChatPage> createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
  
  @override
  Widget build(context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(),
        body: Container(),
        bottomSheet: Container(
          width: double.infinity,
          height: 140,
          decoration: const BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.all(Radius.circular(8.0)) 
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                padding: const EdgeInsets.only(left: 20.0),
                  child: TextField(
                    maxLength: 4096,
                    decoration: InputDecoration(
                      hintText: "Ask me anything",
                      suffixIcon: IconButton(
                        icon: Icon(Icons.mic),
                        onPressed: (){}
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide(
                          color: Colors.blue,
                          width: 1,
                        )
                      )
                    ),
                  ),
                )
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right:  20.0),
                child: IconButton(
                  iconSize: 36,
                  icon: Icon(Icons.send_rounded),
                  onPressed: (){},
                ),
              )
            ],
          ),
        ),
      )
    );
  }
}
