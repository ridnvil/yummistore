import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
      stream: FirebaseFirestore.instance.collection('comments').doc(widget.postID).collection('comments').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot){
        if(snapshot.hasError)
          return Center(child: Text("${snapshot.error}"),);

        switch(snapshot.connectionState){
          case ConnectionState.waiting: return Center(child: LinearProgressIndicator(),);
          case ConnectionState.none: return Center(child: Text('Kosong'),);
          default:
            return Column(
              children: snapshot.data.docs.map((doc){
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        CircleAvatar(
                          backgroundImage: NetworkImage(doc.data()['avatar']),
                          maxRadius: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Text('${doc.data()['user']} : ', style: TextStyle(fontWeight: FontWeight.bold),),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Text(doc.data()['comment']),
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