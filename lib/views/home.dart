import 'package:cakestore/views/about.dart';
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
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:cached_network_image/cached_network_image.dart';

final money = new NumberFormat("#,##0.00", "en_US");

class Home extends StatefulWidget {
  final GoogleSignInAccount googleSignIn;

  Home({this.googleSignIn});
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int btnnavbar = 0;
  FirebaseFirestore firestore;
  GoogleSignInAccount currentUser;
  bool sellerActive = false;
  TextEditingController commenttController = TextEditingController();
  TextEditingController reportController = TextEditingController();
  String avatar;

  @override
  void initState() {
    super.initState();
    currentUser = widget.googleSignIn;
    getuserPhoto(currentUser.id);
  }

  getuserPhoto(String id) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .get()
        .then((DocumentSnapshot value) {
      print(value);
      setState(() {
        avatar = value.data()['photo'];
      });
    });
  }

  checkSeller(thisuser) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(thisuser.id)
        .get()
        .then((userx) {
      var user = userx.data();
      if (user['seller']) {
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
              menuDrawwer(
                  "Postingan Saya",
                  Icons.screen_share,
                  ProfileUser(
                    account: currentUser,
                    userID: currentUser.id,
                    currentID: currentUser.id,
                  )),
              SizedBox(
                height: 10.0,
              ),
              menuDrawwer("Chat", Icons.chat_bubble_outline, ListChat()),
              SizedBox(
                height: 10.0,
              ),
              menuDrawwer(
                  "Profile Saya", Icons.person, Profiles(account: currentUser)),
              SizedBox(
                height: 10.0,
              ),
              menuDrawwer("Tentang Apps", Icons.report, About())
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.id)
            .snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError)
            return Center(
              child: Text("${snapshot.error}"),
            );

          return FloatingActionButton(
            backgroundColor: Colors.white,
            child: Icon(
              Icons.add,
              color: Colors.black,
            ),
            onPressed: () {
              print(snapshot.data.data()['seller']);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => PostProducts(
                        account: currentUser,
                        userSeller: snapshot.data.data()['seller'],
                      )));
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
        title: Text(
          "Divca App",
          style: TextStyle(color: Theme.of(context).primaryColorDark),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.send, color: Colors.black54,),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => ListChat()));
            },
          ),
          IconButton(
            icon: avatar == null ? CircularProgressIndicator()
                : ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    child: Image.network(avatar)
                ),
            onPressed: () {
              print(currentUser.id);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => Profiles(account: currentUser)));
            },
          )
        ],
      ),
      body: SafeArea(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('postingan')
              .orderBy('createat', descending: true)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) return Text('Error: ${snapshot.error}');

            if (!snapshot.hasData) return Center(child: Text("No Products"));

            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Center(
                  child: CircularProgressIndicator(),
                );
              default:
                return Container(
                  height: MediaQuery.of(context).size.height,
                  child: ListView(
                    children: snapshot.data.docs.map((documentx) {
                      var document = documentx.data();
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
                                            Navigator.of(context)
                                                .push(MaterialPageRoute(
                                                    builder: (_) => ProfileUser(
                                                          userID: document['idauthor'],
                                                          currentID:
                                                              currentUser.id,
                                                          account: currentUser,
                                                        )));
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: CircleAvatar(
                                              backgroundImage:
                                                  CachedNetworkImageProvider(
                                                      document['avatar']),
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (_) =>
                                                          ProfileUser(
                                                            userID: document['idauthor'],
                                                            currentID:
                                                                currentUser.id,
                                                            account:
                                                                currentUser,
                                                          )));
                                            },
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${document['author']}',
                                                  style: TextStyle(
                                                      fontSize: 15.0,
                                                      color: Colors.black),
                                                ),
                                                Container(
                                                  width: 300,
                                                  child: Text(
                                                    document['location'],
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            )),
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
                                  child: CachedNetworkImage(
                                    imageUrl: document['picture'],
                                    fit: BoxFit.cover,
                                    progressIndicatorBuilder:
                                        (context, url, downloadProgress) =>
                                            Center(
                                      child: CircularProgressIndicator(
                                          value: downloadProgress.progress),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.report,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () {
                                    return showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text("Laporkan Content!"),
                                            content: Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              height: 110.0,
                                              child: Column(
                                                children: <Widget>[
                                                  TextField(
                                                    maxLines: 4,
                                                    controller:
                                                        reportController,
                                                    decoration: InputDecoration(
                                                        border:
                                                            InputBorder.none,
                                                        labelText:
                                                            'Ketik Laporan disini..'),
                                                  )
                                                ],
                                              ),
                                            ),
                                            actions: <Widget>[
                                              FlatButton(
                                                child: Text("Lapor"),
                                                onPressed: () async {
                                                  String reportID = Uuid().v4();

                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('reports')
                                                      .doc(currentUser.id)
                                                      .collection('reports')
                                                      .doc(reportID)
                                                      .set({
                                                    "productID":
                                                        document['postID'],
                                                    "report":
                                                        reportController.text,
                                                    "user":
                                                        currentUser.displayName,
                                                    "publish": DateTime.now()
                                                  }).then((data) =>
                                                          Navigator.pop(
                                                              context));
                                                },
                                              )
                                            ],
                                          );
                                        });
                                  },
                                )
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => DetailsProduct()));
                              },
                              child: ClipRRect(
                                // borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10.0), bottomRight: Radius.circular(10.0)),
                                child: Container(
                                    // height: 60.0,
                                    width: MediaQuery.of(context).size.width,
                                    // color: Colors.black54,
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8.0, top: 8.0),
                                                child: Text(
                                                  document['description'],
                                                  style: TextStyle(
                                                      fontSize: 20.0,
                                                      color: Colors.black),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )),
                              ),
                            ),
                            ExpansionTile(
                              title: Text(
                                "Show More",
                                overflow: TextOverflow.ellipsis,
                              ),
                              children: <Widget>[
                                Column(
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                          "Alamat: ${document['location']}"),
                                    ),
                                    ExpansionTile(
                                      title: Text("Show Comment"),
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: CommentMessage(
                                            postID: document['postID'],
                                          ),
                                        ),
                                        Row(
                                          children: <Widget>[
                                            IconButton(
                                              icon: Icon(Icons.insert_comment),
                                              onPressed: () {},
                                            ),
                                            Expanded(
                                              child: TextField(
                                                controller: commenttController,
                                                decoration: InputDecoration(
                                                  hintText: 'Comment',
                                                  border: OutlineInputBorder(
                                                      borderSide:
                                                          BorderSide.none),
                                                  // labelText: 'type'
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.send),
                                              onPressed: () async {
                                                String commentsID = Uuid().v4();

                                                await FirebaseFirestore.instance
                                                    .collection('comments')
                                                    .doc(document['postID'])
                                                    .collection('comments')
                                                    .doc(commentsID)
                                                    .set({
                                                      "commentsID": commentsID,
                                                      "userComment": currentUser.id,
                                                      "comment":
                                                          commenttController.text,
                                                      "user":
                                                          currentUser.displayName,
                                                      "avatar":
                                                          avatar,
                                                      "publish": DateTime.now()
                                                    });

                                                commenttController.text = "";
                                              },
                                            )
                                          ],
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10.0,
                            )
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                );
            }
          },
        ),
      ),
    );
  }

  Widget menuDrawwer(String title, IconData icon, callback) {
    return InkWell(
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => callback))
            .then((data) => Navigator.pop(context));
      },
      child: Stack(
        alignment: Alignment.centerLeft,
        children: <Widget>[
          Material(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(20.0),
                bottomRight: Radius.circular(20.0)),
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
                    SizedBox(
                      width: 10.0,
                    ),
                    Icon(
                      icon,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 15.0,
                    ),
                    Text(
                      title,
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
