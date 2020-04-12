import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfileUser extends StatefulWidget {
  final String userID;
  ProfileUser({Key key, this.userID}) : super(key: key);

  @override
  _ProfileUserState createState() => _ProfileUserState();
}

class _ProfileUserState extends State<ProfileUser> {
  String iduser;

  @override
  void initState() {
    super.initState();
    iduser = widget.userID;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile", style: TextStyle(color: Colors.black),),
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
      body: StreamBuilder(
        stream: Firestore.instance.collection('users').document(iduser).snapshots(),
        builder: (context, snapshot) {
          if(snapshot.hasError)
            return Center(child: Text("${snapshot.error}"),);

          if(!snapshot.hasData)
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
                          Text(document['nama']),
                          Text(document['phone']),
                          Text(document['email']),
                          Text(document['alamat']),
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
                  height: 200.0,
                  child: Row(
                    children: <Widget>[
                      Expanded(child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Material(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.lime[300],
                          child: StreamBuilder(
                            stream: Firestore.instance.collection('products').where('idauthor', isEqualTo: document['usrid']).snapshots(),
                            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                              if(snapshot.hasError)
                                return Center(child: Text("${snapshot.error}"),);
                              
                              if(!snapshot.hasData)
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
                            stream: Firestore.instance.collection('products').where('idouthor', isEqualTo: document['usrid']).snapshots(),
                            builder: (context, snapshot) {
                              if(snapshot.hasError)
                                return Center(child: Text("${snapshot.error}"),);

                              List<QuerySnapshot> data = [];
                              data.add(snapshot.data);
                              int orderan = 0;

                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Text('Orderan', style: TextStyle(fontSize: 20),),
                                    Text('$orderan', style: TextStyle(fontSize: 50),),
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
                stream: Firestore.instance.collection('products').where('idauthor', isEqualTo: document['usrid']).snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if(snapshot.hasError)
                    return Center(child: Text("${snapshot.error}"),);

                  if(!snapshot.hasData)
                    return Center(child: CircularProgressIndicator(),);

                  return Column(
                    children: snapshot.data.documents.map((doc){
                      return ExpansionTile(
                        title: Text('${doc['product']}'),
                        leading: Image.network(doc['picture']),
                        subtitle: Text('Stock ${doc['stock']}'),
                        children: <Widget>[
                          Image.network(doc['picture'])
                        ],
                      );
                    }).toList(),
                  );
                },
              )
            ],
          );
        },
      ),
    );
  }
}