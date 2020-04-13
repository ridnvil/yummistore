import 'dart:async';

import 'package:cakestore/views/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn();
final FirebaseAuth _auth = FirebaseAuth.instance;

class Login extends StatefulWidget {
  final bool logout;
  Login({Key key, this.logout}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  GoogleSignInAccount currentUser;
  GoogleSignInAccount currentUser2;
  bool isSignin = false;
  String userid = "";
  double count = 0;
  String idSelect;


  @override
  void initState() { 
    super.initState();
    if(widget.logout == false){
      autoSignin();
    }else{
      // print("Hello Tong");
      signOut();
    }
  }

  signOut() async {
      await _googleSignIn.signOut();
      await _auth.signOut();
  }

  Future autoSignin() async {
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account){
      print(account.id);
      setState(() {
        currentUser = account;
      });
      if(currentUser != null){
        isSignin = true;
        handleSignIn()
            .then((FirebaseUser user) { 
              print(user.uid);
              Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (context) => Home(googleSignIn: currentUser)
              ));
            })
            .catchError((e) => print("Error : $e"));
      }else{
        print("Hello Dev");
      }
    });
    _googleSignIn.signInSilently();
  }

  Future<bool> userCheck(id) async {
    await Firestore.instance.collection('users').document(id).get().then((DocumentSnapshot user) {
      if(user.exists){
        return true;
      }else{
        return false;
      }
    });
  }

  Future registerUser(id, name, email, photo, phone) async {
    await Firestore.instance.collection('users').document(id)
        .setData({ 
          'id': id,
          'alamat': '', 
          'nama': name, 
          'email': email, 
          'photo': photo,
          'phone': phone,
          'seller': false,
          'publish': DateTime.now() 
        });

  }

  Future<FirebaseUser> handleSignIn() async {

    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    setState(() {
      isSignin = true;
      currentUser2 = googleUser;
    });
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final FirebaseUser user = (await _auth.signInWithCredential(credential)).user;

    return user;
  }

  // Future<FirebaseUser> _signinbyPhone() async {
  //   FirebaseAuth auth;
  //   await auth.verifyPhoneNumber(
  //     phoneNumber: null, 
  //     timeout: null, 
  //     verificationCompleted: null, 
  //     verificationFailed: null, 
  //     codeSent: null, 
  //     codeAutoRetrievalTimeout: null
  //   );
  // }

  Widget spalsScreen() {
    if(currentUser == null){
      return Container(
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [Colors.white, Colors.lime,Colors.white]
                  )
                ),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("YUmmi", style: TextStyle(fontSize: 60.0, color: Colors.white, fontWeight: FontWeight.bold),),
                      Material(
                        borderRadius: BorderRadius.circular(8.0),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("STORE", style: TextStyle(fontSize: 25.0, color: Colors.red, fontWeight: FontWeight.bold),),
                        )
                      ),
                    ],
                  ),
                  SizedBox(height: 100.0,),
                  isSignin ? Center(child: CircularProgressIndicator()) : Column(
                    children: <Widget>[
                      Material(
                        borderRadius: BorderRadius.circular(8.0),
                        color: Colors.white,
                        child: MaterialButton(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: Row(
                              children: <Widget>[
                                Text("Sign In", style: TextStyle(fontSize: 25.0, color: Colors.red),),
                                SizedBox(width: 10.0,),
                                Expanded(child: Image.network('http://pngimg.com/uploads/google/google_PNG19630.png', width: 20.0, height: 20.0,)),
                              ],
                            ),
                          ),
                          height: 55.0,
                          minWidth: 50.0,
                          onPressed: () async {
                            await handleSignIn()
                                .then((FirebaseUser user) async {
                                  await registerUser(currentUser2.id, user.displayName, user.email, user.photoUrl, user.phoneNumber);
                                  await Navigator.pushReplacement(context, MaterialPageRoute(
                                        builder: (context) => Home(googleSignIn: currentUser2)));
                                })
                                .catchError((e) => print("Error : $e"));
                          },
                        ),
                      ),
                      SizedBox(height: 10.0,),
                      // Material(
                      //   borderRadius: BorderRadius.circular(8.0),
                      //   color: Colors.white,
                      //   child: MaterialButton(
                      //     child: Container(
                      //       width: MediaQuery.of(context).size.width * 0.3,
                      //       child: Row(
                      //         children: <Widget>[
                      //           Text("Sign In", style: TextStyle(fontSize: 25.0, color: Colors.black54),),
                      //           SizedBox(width: 10.0,),
                      //           Expanded(child: Icon(Icons.phone_android))
                      //         ],
                      //       ),
                      //     ),
                      //     height: 55.0,
                      //     minWidth: 50.0,
                      //     onPressed: () async {

                      //     },
                      //   ),
                      // ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }else{
      return Container(
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [Colors.white, Colors.lime,Colors.white]
                  )
                ),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("YUmmi", style: TextStyle(fontSize: 60.0, color: Colors.white, fontWeight: FontWeight.bold),),
                      Material(
                        borderRadius: BorderRadius.circular(8.0),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("STORE", style: TextStyle(fontSize: 25.0, color: Colors.red, fontWeight: FontWeight.bold),),
                        )
                      ),
                    ],
                  ),
                  SizedBox(height: 100.0,),
                  Center(child: CircularProgressIndicator(
                    backgroundColor: Colors.white,
                  ),)
                ],
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ConstrainedBox(
        constraints: BoxConstraints.expand(),
        child: spalsScreen(),
      )
    );
  }
}