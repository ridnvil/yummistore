import 'package:cakestore/views/comment.dart';
import 'package:cakestore/views/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ProfileUser extends StatefulWidget {
  final String userID;
  final String currentID;
  final GoogleSignInAccount account;
  ProfileUser({Key key, this.userID, this.currentID, this.account}) : super(key: key);

  @override
  _ProfileUserState createState() => _ProfileUserState();
}

class _ProfileUserState extends State<ProfileUser> {
  String iduser;
  String idcurrentuser;
  bool thismineuser = false;

  @override
  void initState() {
    super.initState();
    iduser = widget.userID;
    idcurrentuser = widget.currentID;

    if(iduser == idcurrentuser){
      thismineuser = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: thismineuser ? Text("Postingan Saya", style: TextStyle(color: Colors.black),): Text("YUmmi User", style: TextStyle(color: Colors.black),),
        centerTitle: true,
        actions: <Widget>[
          thismineuser ? IconButton(
            icon: Text('EDIT', style: TextStyle(color: Colors.lime),),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => Profiles(account: widget.account,)
              ));
            },
          ): Text('')
        ],
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
      body: StreamBuilder(
        stream: Firestore.instance.collection('users').document(iduser).snapshots(),
        builder: (context, snapshot) {
          if(snapshot.hasError)
            return Center(child: Text("${snapshot.error}"),);

          if(snapshot.data == null)
            return Center(child: CircularProgressIndicator(),);

          var document = snapshot.data;

          return ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    CircleAvatar(
                      maxRadius: 50.0,
                      backgroundImage: NetworkImage(document['photo']),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('${document['nama']}'),
                          SizedBox(height: 3.0,),
                          Text('Phone: ${document['phone']}'),
                          SizedBox(height: 3.0,),
                          Text('Email: ${document['email']}'),
                          SizedBox(height: 3.0,),
                          Text('Alamat: ${document['alamat']}'),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.lime,
                    borderRadius: BorderRadius.circular(10.0)
                  ),
                  height: 100.0,
                  child: Row(
                    children: <Widget>[
                      Expanded(child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Material(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.lime[300],
                          child: StreamBuilder(
                            stream: Firestore.instance.collection('products').where('idauthor', isEqualTo: iduser).snapshots(),
                            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                              if(snapshot.hasError)
                                return Center(child: Text("${snapshot.error}"),);
                              
                              if(snapshot.data == null)
                                return Center(child: CircularProgressIndicator(),);

                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Text('Postingan', style: TextStyle(fontSize: 20),),
                                    Text('${snapshot.data.documents.length}', style: TextStyle(fontSize: 50),),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      )),
                      Expanded(child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Material(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.lime[300],
                          child: StreamBuilder(
                            stream: Firestore.instance.collection('orders').where('ownerid', isEqualTo: iduser).snapshots(),
                            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                              if(snapshot.hasError)
                                return Center(child: Text("${snapshot.error}"),);

                              if(snapshot.data == null)
                                return Center(child: CircularProgressIndicator(),);

                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Text('Orderan', style: TextStyle(fontSize: 20),),
                                    Text('${snapshot.data.documents.length}', style: TextStyle(fontSize: 50),),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
              ),
              StreamBuilder(
                stream: Firestore.instance.collection('products').where('idauthor', isEqualTo: iduser).orderBy('publish', descending: true).snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if(snapshot.hasError)
                    return Center(child: Text("${snapshot.error}"),);

                  if(snapshot.data == null)
                    return Center(child: Text('Postingan Kosong'),);

                  return Column(
                    children: snapshot.data.documents.map((doc){
                      return Material(
                        // color: Colors.lime,
                        child: Column(
                          children: <Widget>[
                            ExpansionTile(
                              title: Text('${doc['product']}'),
                              leading: Image.network(doc['picture']),
                              subtitle: Text('Stock ${doc['stock']}'),
                              children: <Widget>[
                                Image.network(doc['picture'])
                              ],
                            ),
                            ExpansionTile(
                              title: Text('Show Comment'),
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CommentMessage(postID: doc['postID'],),
                                )
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}