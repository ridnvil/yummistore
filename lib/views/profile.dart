import 'package:cakestore/views/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
class Profiles extends StatefulWidget {
  final GoogleSignInAccount account;
  Profiles({Key key, this.account}) : super(key: key);

  @override
  _ProfilesState createState() => _ProfilesState();
}

class _ProfilesState extends State<Profiles> {
  GoogleSignInAccount currentUser;
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController address = TextEditingController();
  bool seller = false;

  @override
  void initState() {
    super.initState();
    
    currentUser = widget.account;
    getUserProfile(currentUser.id);
    print(currentUser.id);
  }

  getUserProfile(id) async {
    await Firestore.instance.collection('users')
        .document(id)
        .get()
        .then((user) {
          setState(() {
            name.text = user['nama'];
            email.text = user['email'];
            phone.text = user['phone'];
            address.text = user['alamat'];
            seller = user['seller'];
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        // backgroundColor: Colors.lime,
        elevation: 0,
        title: Text("My Profile", style: TextStyle(color: Colors.lime,)),
        actions: <Widget>[
          FlatButton(
            child: Text("Save", style: TextStyle(color: Colors.lime, fontSize: 18.0),),
            onPressed: () async {

              await Firestore.instance.collection('users')
                  .document(currentUser.id)
                  .updateData({
                    "nama": name.text,
                    "email": email.text,
                    "phone": phone.text,
                    "alamat": address.text,
                    "seller": seller,
                  }).then((data){
                    return showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text("Save Succesfully.."),
                          actions: <Widget>[
                            FlatButton(
                              child: Text("OK"),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            )
                          ],
                        );
                      }
                    );
                  });
            },
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          Container(
            child: Padding(
              padding: const EdgeInsets.only(left: 100.0, right: 100.0, top: 10.0),
              child: Material(
                elevation: 5,
                child: Image.network(currentUser.photoUrl, height: 200.0, fit: BoxFit.cover,)
              ),
            ),
          ),
          SizedBox(height: 10.0,),
          Padding(
            padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 10.0),
            child: TextField(
              controller: name,
              decoration: InputDecoration(
                border: InputBorder.none,
                labelText: 'Name'
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 10.0),
            child: TextField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                border: InputBorder.none,
                labelText: 'Email'
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 10.0),
            child: TextField(
              controller: phone,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: InputBorder.none,
                labelText: 'Phone'
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 10.0),
            child: TextField(
              controller: address,
              decoration: InputDecoration(
                border: InputBorder.none,
                labelText: 'Alamat / Address'
              ),
            ),
          ),
          SizedBox(height: 10.0,),
          Padding(
            padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                seller? Text('Anda Penjual', style: TextStyle(fontSize: 16.0),): Text('Anda Bukan Penjual!', style: TextStyle(fontSize: 16.0)),
                Switch(
                  onChanged: (val) {
                    setState(() {
                      seller = val;
                    });
                  },
                  value: seller,
                  activeTrackColor: Colors.lightGreenAccent, 
                  activeColor: Colors.green,
                )
              ],
            ),
          ),
          SizedBox(height: 20.0,),
          MaterialButton(
            child: Text('Sign Out'),
            onPressed: () async {
              await Navigator.pushReplacement(context, MaterialPageRoute(
                  builder: (_) => Login(logout: true,)
                ));
            },
          ),
        ],
      ),
    );
  }
}