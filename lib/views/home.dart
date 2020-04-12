import 'package:cakestore/views/chat.dart';
import 'package:cakestore/views/chatlist.dart';
import 'package:cakestore/views/comment.dart';
import 'package:cakestore/views/detailsorder.dart';
import 'package:cakestore/views/orderproduct.dart';
import 'package:cakestore/views/post.dart';
import 'package:cakestore/views/profile.dart';
import 'package:cakestore/views/profileyum.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

final money = new NumberFormat("#,##0.00", "en_US");

class Home extends StatefulWidget {
  final GoogleSignInAccount googleSignIn;

  Home({this.googleSignIn});
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int btnnavbar = 0;
  Firestore firestore;
  GoogleSignInAccount currentUser;
  bool sellerActive = false;
  TextEditingController commenttController = TextEditingController();
  TextEditingController reportController = TextEditingController();

  @override
  void initState() {
    super.initState();
    currentUser = widget.googleSignIn;
    checkSeller(currentUser);
  }

  checkSeller(thisuser) async {
    await Firestore.instance.collection('users')
        .document(thisuser.id)
        .get()
        .then((user){
          if(user['seller']){
            setState(() {
              sellerActive = user['seller'];
            });
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Container(
          child: ListView(
            children: <Widget>[
              menuDrawwer("My Posting", Icons.screen_share, null),
              SizedBox(height: 10.0,),
              menuDrawwer("Chat", Icons.chat_bubble_outline, ListChat()),
              SizedBox(height: 10.0,),
              menuDrawwer("My Profile", Icons.person, Profiles(account: currentUser)),
              SizedBox(height: 10.0,),
              menuDrawwer("Product Report", Icons.report, null)
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: StreamBuilder(
        stream: Firestore.instance.collection('users').document(currentUser.id).snapshots(),
        builder: (context, snapshot) {
          if(snapshot.hasError)
            return Center(child: Text("${snapshot.error}"),);

          return FloatingActionButton(
            backgroundColor: Colors.white,
            child: Icon(Icons.add, color: Colors.black,),
            onPressed: () {
              print(snapshot.data['seller']);
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => PostProducts(account: currentUser, userSeller: snapshot.data['seller'],)
              ));
            },
          );
        },
      ),
      appBar: AppBar(
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
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text("YUmmi", style: TextStyle(color: Theme.of(context).primaryColorDark),),
        actions: <Widget>[
          IconButton(
            icon: Image.network(currentUser.photoUrl),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => Profiles(account: currentUser)
              ));
              print(currentUser.displayName);
            },
          )
        ],
      ),
      body: StreamBuilder(
        stream: Firestore.instance.collection('products').orderBy("publish", descending: true).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if(snapshot.hasError)
            return Text('Error: ${snapshot.error}');
          
          if(!snapshot.hasData)
            return Center(child: Text("No Products"));

          switch(snapshot.connectionState) {
            case ConnectionState.waiting: return Center(child: CircularProgressIndicator(),);
            default:
              return Container(
                height: MediaQuery.of(context).size.height,
                child: ListView(
                  children: snapshot.data.documents.map((document) {
                    return Material(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(10.0),
                            child: Center(
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      GestureDetector(
                                        onTap: () {
                                          if(currentUser.id == document['idauthor']){
                                            Navigator.of(context).push(MaterialPageRoute(
                                              builder: (_) => Profiles(account: currentUser,)
                                            ));
                                          }else{
                                            Navigator.of(context).push(MaterialPageRoute(
                                              builder: (_) => ProfileUser(userID: document['idauthor'],)
                                            ));
                                          }
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: CircleAvatar(
                                            backgroundImage: NetworkImage(document['avatar']),
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          if(currentUser.id == document['idauthor']){
                                            Navigator.of(context).push(MaterialPageRoute(
                                              builder: (_) => Profiles(account: currentUser,)
                                            ));
                                          }else{
                                            Navigator.of(context).push(MaterialPageRoute(
                                              builder: (_) => ProfileUser(userID: document['idauthor'],)
                                            ));
                                          }
                                        },
                                        child: Text('${document['author']}', style: TextStyle(fontSize: 15.0, color: Colors.black),)
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Stack(
                            alignment: Alignment.topRight,
                            children: <Widget>[
                              Container(
                                width: MediaQuery.of(context).size.width,
                                height: 400.0,
                                child: Image.network(document['picture'], fit: BoxFit.cover,)
                              ),
                              IconButton(
                                icon: Icon(Icons.report, color: Colors.blue,),
                                onPressed: () {
                                  return showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog( 
                                        title: Text("Laporkan Product!"),
                                        content: Container(
                                          width: MediaQuery.of(context).size.width,
                                          height: 110.0,
                                          child: Column(
                                            children: <Widget>[
                                              TextField(
                                                maxLines: 4,
                                                controller: reportController,
                                                decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  labelText: 'Ketik Laporan disini..'
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        actions: <Widget>[
                                          FlatButton(
                                            child: Text("Lapor"),
                                            onPressed: () async {
                                              String reportID = Uuid().v4();
                                              
                                              await Firestore.instance.collection('reports')
                                                    .document(currentUser.id)
                                                    .collection('reports')
                                                    .document(reportID)
                                                    .setData({
                                                      "productID": document['postID'],
                                                      "report": reportController.text,
                                                      "user": currentUser.displayName,
                                                      "publish": DateTime.now()
                                                    }).then((data) => Navigator.pop(context));
                                            },
                                          )
                                        ],
                                      );
                                    }
                                  );
                                },
                              )
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => DetailsProduct()
                              ));
                              print(document['product']);
                            },
                            child: ClipRRect(
                              // borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10.0), bottomRight: Radius.circular(10.0)),
                              child: Container(
                                height: 70.0,
                                width: MediaQuery.of(context).size.width,
                                // color: Colors.black54,
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                                            child: Text(document['product'], style: TextStyle(fontSize: 20.0, color: Colors.black), overflow: TextOverflow.ellipsis,),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 8.0),
                                            child: Text('Rp. ${money.format(int.parse(document['prices']))}', style: TextStyle(fontSize: 15.0, color: Colors.black),),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 8.0),
                                            child: Text('Stock: ${document['stock']}', style: TextStyle(fontSize: 15.0, color: Colors.black),),
                                          ),
                                        ],
                                      ),
                                    ),
                                    currentUser.id != document['idauthor'] ? Expanded(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Material(
                                            color: Colors.transparent,
                                            child: MaterialButton(
                                              height: 100.0,
                                              child: Text("Order", style: TextStyle(fontSize: 20.0, color: Colors.black)),
                                              onPressed: () {
                                                Navigator.of(context).push(MaterialPageRoute(
                                                  builder: (_) => OrderProduct()
                                                ));
                                              },
                                            ),
                                          ),
                                          Material(
                                            color: Colors.transparent,
                                            child: MaterialButton(
                                              height: 100.0,
                                              child: Text("Chat", style: TextStyle(fontSize: 20.0, color: Colors.black)),
                                              onPressed: () {
                                                Navigator.of(context).push(MaterialPageRoute(
                                                  builder: (_) => ChatMessage(outhorID: document['idauthor'],)
                                                ));
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                    : Expanded(
                                      child: Material(
                                        color: Colors.transparent,
                                        child: MaterialButton(
                                          height: 100.0,
                                          child: Text("Delete", style: TextStyle(fontSize: 20.0, color: Colors.black)),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: Text("Delete Posting?"),
                                                  actions: <Widget>[
                                                    FlatButton(
                                                      child: Text("Tidak"),
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                    ),
                                                    FlatButton(
                                                      child: Text("Ya"),
                                                      onPressed: () async {
                                                        String filePath = "img_${document['imagename']}.jpg";
                                                        Navigator.pop(context);
                                                        await FirebaseStorage.instance.ref().child(filePath).delete();
                                                        await Firestore.instance.collection('products').document(document['postID']).delete().then((data){
                                                          print("Delete Success!");
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ),
                            ),
                          ),
                          ExpansionTile(
                            title: Text("Show More", overflow: TextOverflow.ellipsis,),
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("Alamat: ${document['location']}"),
                                  ),
                                  ExpansionTile(
                                    title: Text("Show Comment"),
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: CommentMessage(postID: document['postID'],),
                                      ),
                                      Row(
                                        children: <Widget>[
                                          FlatButton(
                                            child: Row(
                                              children: <Widget>[
                                                Icon(Icons.chat_bubble),
                                                SizedBox(width: 5.0,),
                                                Text("Comment"),
                                              ],
                                            ),
                                            onPressed: () {
                                              return showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return SimpleDialog(
                                                    title: Text("Tulis Comment!"),
                                                    children: <Widget>[
                                                      Divider(),
                                                      Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: Container(
                                                          width: 200.0,
                                                          height: 100.0,
                                                          child: ListView(
                                                            children: <Widget>[
                                                              TextField(
                                                                controller: commenttController,
                                                                maxLines: 5,
                                                                keyboardType: TextInputType.text,
                                                                decoration: InputDecoration(
                                                                  labelText: 'Comment Type'
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Divider(),
                                                      FlatButton(
                                                        child: Text("Comment!"),
                                                        onPressed: () async {
                                                          String commentsID = Uuid().v4();
                                                            Navigator.pop(context);
                                                            await Firestore.instance.collection('comments')
                                                                  .document(document['postID'])
                                                                  .collection('comments')
                                                                  .document(commentsID)
                                                                  .setData({
                                                                    "commentsID": commentsID,
                                                                    "userComment": currentUser.id,
                                                                    "comment": commenttController.text,
                                                                    "user": currentUser.displayName,
                                                                    "avatar": currentUser.photoUrl,
                                                                    "publish": DateTime.now()
                                                                  });
                                                        },
                                                      )
                                                    ],
                                                  );
                                                }
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 10.0,)
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
          }
        },
      ),
    );
  }

  Widget menuDrawwer(String title, IconData icon, callback) {
    return InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => callback)).then((data) => Navigator.pop(context));
        },
        child: Stack(
        alignment: Alignment.centerLeft,
        children: <Widget>[
          Material(
            borderRadius: BorderRadius.only(topRight: Radius.circular(20.0), bottomRight: Radius.circular(20.0)),
            color: Colors.lime,
            child: Padding(
              padding: const EdgeInsets.all(30.0),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                children: <Widget>[
                  SizedBox(width: 10.0,),
                  Icon(icon, color: Colors.white,),
                  SizedBox(width: 15.0,),
                  Text(title, style: TextStyle(fontSize: 18.0),),
                ],
              ),
            )
          ),
        ],
      ),
    );
  }
}