import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cakestore/views/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image/image.dart' as Im;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();

class Profiles extends StatefulWidget {
  final GoogleSignInAccount account;
  Profiles({Key key, this.account}) : super(key: key);

  @override
  _ProfilesState createState() => _ProfilesState();
}

class _ProfilesState extends State<Profiles> {
  File file;
  String imageURL;
  GoogleSignInAccount currentUser;
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController address = TextEditingController();
  StorageUploadTask goinguploadTask;
  String imageID = Uuid().v4();
  bool loading = false;
  final picker = ImagePicker();
  String avatar;

  @override
  void initState() {
    super.initState();

    currentUser = widget.account;
    getUserProfile(currentUser.id);
    print(currentUser.id);
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

  uploadPhoto(datafile) async {
    String filename = basename(datafile.path);
    StorageReference firebaseSorageref =
        FirebaseStorage.instance.ref().child(filename);
    StorageUploadTask uploadTask = firebaseSorageref.putFile(file);

    if (uploadTask.isInProgress) {
      setState(() {
        goinguploadTask = uploadTask;
        loading = true;
      });
    }

    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    setState(() {
      imageURL = downloadUrl;
    });
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
    final compressImageFile = File('$path/img_$imageID.jpg')
      ..writeAsBytesSync(Im.encodeJpg(
        imageFile,
        quality: 80,
      ));

    setState(() {
      file = compressImageFile;
    });
  }

  getUserProfile(id) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .get()
        .then((user) {
      setState(() {
        name.text = user.data()['nama'];
        email.text = user.data()['email'];
        phone.text = user.data()['phone'];
        address.text = user.data()['alamat'];
        imageURL = user.data()['photo'];
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
        title: Text("My Profile",
            style: TextStyle(
              color: Colors.lime,
            )),
        actions: <Widget>[
          FlatButton(
            child: Text(
              "Save",
              style: TextStyle(color: Colors.lime, fontSize: 18.0),
            ),
            onPressed: () async {
              await compressImage();
              await uploadPhoto(file);

              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUser.id)
                  .update({
                "nama": name.text,
                "email": email.text,
                "phone": phone.text,
                "alamat": address.text,
                "photo": imageURL
              }).then((data) async {
                return await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Save Succesfully.."),
                        actions: <Widget>[
                          FlatButton(
                            child: Text("OK"),
                            onPressed: () {
                              Navigator.pop(context);
                              setState(() {
                                loading = false;
                              });
                            },
                          )
                        ],
                      );
                    });
                }).then((value) async {
                  await FirebaseFirestore.instance
                      .collection('postingan')
                      .doc(currentUser.id)
                      .update({"avatar": imageURL}).then((value) {
                  });
                });
            },
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.width,
                  child: imageURL == null
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : file == null
                          ? CachedNetworkImage(
                              imageUrl: avatar,
                              fit: BoxFit.cover,
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) => Center(
                                child: CircularProgressIndicator(
                                    value: downloadProgress.progress),
                              ),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            )
                          : Image.file(
                              file,
                              fit: BoxFit.cover,
                            ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: Colors.lime,
                  ),
                  onPressed: () async {
                    print("object");
                    final pickedFile =
                        await picker.getImage(source: ImageSource.gallery);
                    setState(() {
                      if (pickedFile != null) {
                        file = File(pickedFile.path);
                      } else {
                        print('No image selected.');
                      }
                    });
                  },
                ),
                loading ? LinearProgressIndicator() : Text(""),
              ],
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 10.0),
            child: TextField(
              controller: name,
              decoration:
                  InputDecoration(border: InputBorder.none, labelText: 'Name'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 10.0),
            child: TextField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              decoration:
                  InputDecoration(border: InputBorder.none, labelText: 'Email'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 10.0),
            child: TextField(
              controller: phone,
              keyboardType: TextInputType.number,
              decoration:
                  InputDecoration(border: InputBorder.none, labelText: 'Phone'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 10.0),
            child: TextField(
              controller: address,
              decoration: InputDecoration(
                  border: InputBorder.none, labelText: 'Alamat / Address'),
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          MaterialButton(
            child: Text('Sign Out'),
            onPressed: () async {
              await Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => Login(
                            logout: true,
                          )));
            },
          ),
        ],
      ),
    );
  }
}
