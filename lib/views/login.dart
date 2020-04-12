import 'package:cakestore/views/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn();
final FirebaseAuth _auth = FirebaseAuth.instance;

class Login extends StatefulWidget {
  Login({Key key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  GoogleSignInAccount currentUser;
  bool isSignin = false;
  String userid = "";

  @override
  void initState() { 
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account){
      setState(() {
        currentUser = account;
      });
      if(currentUser != null){
        isSignin = true;
        _handleSignIn()
            .then((FirebaseUser user) => Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) => Home(googleSignIn: currentUser)
            )))
            .catchError((e) => print("Error : $e"));
      }
    });
    _googleSignIn.signInSilently();
  }

  Future registerUser(id, name, email, photo) async {
    DateTime timestamp = DateTime.now();
    Firestore.instance.collection('users').document(id)
      .setData({ 'alamat': 'unknown', 'nama': name, 'email': email, 'photo': photo,'phone': '000000000000', 'seller': false,'publish': timestamp });
  }

  Future<FirebaseUser> _handleSignIn() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final FirebaseUser user = (await _auth.signInWithCredential(credential)).user;
    return user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                  isSignin ? Center(child: CircularProgressIndicator()) : Material(
                    borderRadius: BorderRadius.circular(8.0),
                    color: Colors.red,
                    child: MaterialButton(
                      child: Text("Login With Google", style: TextStyle(fontSize: 25.0, color: Colors.white),),
                      height: 55.0,
                      minWidth: 50.0,
                      onPressed: () async {
                        await _handleSignIn()
                            .then((FirebaseUser user) async {
                              await registerUser(currentUser.id, currentUser.displayName, currentUser.email, currentUser.photoUrl);
                              await Navigator.pushReplacement(context, MaterialPageRoute(
                                    builder: (context) => Home(googleSignIn: currentUser)));
                            })
                            .catchError((e) => print("Error : $e"));
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}