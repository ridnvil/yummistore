import 'dart:io';

import 'package:cakestore/views/chat.dart';
import 'package:cakestore/views/chatlist.dart';
import 'package:cakestore/views/comment.dart';
import 'package:cakestore/views/detailsorder.dart';
import 'package:cakestore/views/orderankeluar.dart';
import 'package:cakestore/views/orderanmasuk.dart';
import 'package:cakestore/views/orderproduct.dart';
import 'package:cakestore/views/post.dart';
import 'package:cakestore/views/profile.dart';
import 'package:cakestore/views/profileyum.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';

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

  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();
  // final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  // final TextEditingController _controllerTopic = TextEditingController();
  // String token = '';
  // bool isSubscribed = false;

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
      key: _scaffoldState,
      drawer: Drawer(
        child: Container(
          child: ListView(
            children: <Widget>[
              menuDrawwer("Orderan Masuk", Icons.store, OrderanMasuk(account: currentUser,)),
              SizedBox(height: 10.0,),
              menuDrawwer("Postingan Saya", Icons.screen_share, ProfileUser(account: currentUser, userID: currentUser.id, currentID: currentUser.id,)),
              SizedBox(height: 10.0,),
              menuDrawwer("Orderan Saya", Icons.store, OrderanSaya(account: currentUser,)),
              SizedBox(height: 10.0,),
              menuDrawwer("Chat", Icons.chat_bubble_outline, ListChat()),
              SizedBox(height: 10.0,),
              menuDrawwer("Profile Saya", Icons.person, Profiles(account: currentUser)),
              SizedBox(height: 10.0,),
              menuDrawwer("Product Report", Icons.report, null),
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
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.lime,
        title: Text("YUmmi", style: TextStyle(color: Theme.of(context).primaryColorDark),),
        actions: <Widget>[
          IconButton(
            icon: Image.network(currentUser.photoUrl),
            onPressed: () {
              print(currentUser.id);
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => Profiles(account: currentUser)
              ));
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
            return Center(child: CircularProgressIndicator());

          switch(snapshot.connectionState) {
            case ConnectionState.waiting: return Center(child: CircularProgressIndicator(),);
            default:
              return Stack(
                children: <Widget>[
                  Material(
                    color: Colors.lime,
                    child: Container(
                      height: 180.0,
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height,
                    child: ListView(
                      children: <Widget>[
                        // IconButton(
                        //   icon: Icon(Icons.video_library),
                        //   onPressed: () {
                        //     controller.value.isPlaying?controller.pause:controller.play;
                        //   },
                        // ),
                        // Padding(
                        //   padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0, top: 10.0),
                        //   child: Material(
                        //     elevation: 15.0,
                        //     child: Container(
                        //       // height: 300.0,
                        //       child: controller.value.initialized?AspectRatio(
                        //         aspectRatio: controller.value.aspectRatio,
                        //         child: VideoPlayer(controller),
                        //       ): Container(),
                        //     ),
                        //   ),
                        // ),
                        Column(
                          children: snapshot.data.documents.map((document) {
                            return Padding(
                              padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 5.0),
                              child: Material(
                                // borderRadius: BorderRadius.only(topLeft: Radius.circular(25.0)),
                                elevation: 15,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Center(
                                      child: Column(
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.of(context).push(MaterialPageRoute(
                                                    builder: (_) => ProfileUser(userID: document['idauthor'], currentID: currentUser.id, account: currentUser,)
                                                  ));
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.all(15.0),
                                                  child: CircleAvatar(
                                                    backgroundImage: NetworkImage(document['avatar']),
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.of(context).push(MaterialPageRoute(
                                                    builder: (_) => ProfileUser(userID: document['idauthor'], currentID: currentUser.id, account: currentUser,)
                                                  ));
                                                },
                                                child: Text('${document['author']}', style: TextStyle(fontSize: 15.0, color: Colors.black),)
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Stack(
                                      alignment: Alignment.topRight,
                                      children: <Widget>[
                                        Container(
                                          width: MediaQuery.of(context).size.width,
                                          height: 400.0,
                                          child: CachedNetworkImage(imageUrl: document['picture'], fit: BoxFit.cover,)
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
                                    Row(
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
                                                  // height: 100.0,
                                                  child: Text("Order", style: TextStyle(fontSize: 20.0, color: Colors.black)),
                                                  onPressed: () {
                                                    Navigator.of(context).push(MaterialPageRoute(
                                                      builder: (_) => OrderProduct(productID: document['postID'], account: currentUser,)
                                                    ));
                                                  },
                                                ),
                                              ),
                                              Material(
                                                color: Colors.transparent,
                                                child: MaterialButton(
                                                  // height: 100.0,
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
                                              // height: 100.0,
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
                                                Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    children: <Widget>[
                                                      Container(
                                                        width: 300.0,
                                                        height: 45.0,
                                                        alignment: Alignment.center,
                                                        child: TextField(
                                                          controller: commenttController,
                                                          decoration: InputDecoration(
                                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))
                                                          )
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: IconButton(
                                                          icon: Icon(Icons.chat_bubble),
                                                          onPressed: () async {
                                                            String commentsID = Uuid().v4();
                                                            // Navigator.pop(context);
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

                                                            commenttController.clear();
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                    // SizedBox(height: 10.0,)
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 100.0,),
                      ],
                    ),
                  ),
                ],
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