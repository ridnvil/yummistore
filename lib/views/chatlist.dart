import 'package:flutter/material.dart';

class ListChat extends StatefulWidget {
  ListChat({Key key}) : super(key: key);

  @override
  _ListChatState createState() => _ListChatState();
}

class _ListChatState extends State<ListChat> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Daftar Chat Saya"),
        centerTitle: true,
        flexibleSpace: Material(
          child: Padding(
            padding: const EdgeInsets.only(right: 350.0),
            child: ClipRRect(
              borderRadius: BorderRadius.only(topRight: Radius.circular(50.0)),
              child: Container(
                color: Colors.lime,
              ),
            ),
          ),
        ),
      ),
      body: Center(
        child: Text("Chat List"),
      ),
    );
  }
}