import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CommentMessage extends StatefulWidget {
  final String postID;
  CommentMessage({Key key, this.postID}) : super(key: key);

  @override
  _CommentMessageState createState() => _CommentMessageState();
}

class _CommentMessageState extends State<CommentMessage> {

  @override
  void initState() {
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Firestore.instance.collection('comments').document(widget.postID).collection('comments').orderBy('publish', descending: true).snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot){
        if(snapshot.hasError)
          return Center(child: Text("${snapshot.error}"),);

        switch(snapshot.connectionState){
          case ConnectionState.waiting: return Center(child: LinearProgressIndicator(),);
          case ConnectionState.none: return Center(child: Text('Kosong'),);
          default:
            return Column(
              children: snapshot.data.documents.map((doc){
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        CircleAvatar(
                          backgroundImage: NetworkImage(doc['avatar']),
                          maxRadius: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Text('${doc['user']} : ', style: TextStyle(fontWeight: FontWeight.bold),),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Text(doc['comment']),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }).toList(),
            );
        }
      },
    );
  }
}