import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// import 'package:uuid/uuid.dart';

class ChatMessage extends StatefulWidget {
  final String outhorID;
  ChatMessage({Key key, this.outhorID}) : super(key: key);

  @override
  _ChatMessageState createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat", style: TextStyle(color: Colors.black),),
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
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          StreamBuilder(
            stream: Firestore.instance.collection('chats').document(widget.outhorID).collection('chats').snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot){
              if(snapshot.hasError)
                return Center(child: Text("${snapshot.error}"),);

              switch(snapshot.connectionState){
                case ConnectionState.waiting: return Center(child: CircularProgressIndicator(),);
                default:
                  return ListView(
                    children: snapshot.data.documents.map((msg){
                      
                    }).toList()
                  );
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0 ,bottom: 20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: TextField(
                    // controller: locationController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0))
                      ),
                      labelText: 'Type'
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, size: 30.0,),
                  onPressed: () {
                    // String chatID = Uuid().v4();
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}