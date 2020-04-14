import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';
import 'package:geolocator/geolocator.dart';

class PostProducts extends StatefulWidget {
  final GoogleSignInAccount account;
  final bool userSeller;
  PostProducts({Key key, this.account, this.userSeller}) : super(key: key);

  @override
  _PostProductsState createState() => _PostProductsState();
}

class _PostProductsState extends State<PostProducts> {
  File file;
  String imageURL;
  String imageID = Uuid().v4();
  String postID = Uuid().v4();
  GoogleSignInAccount currentUser;
  bool loading = false;
  StorageUploadTask goinguploadTask;

  TextEditingController productName = TextEditingController();
  TextEditingController prices = TextEditingController();
  TextEditingController stock = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  void initState() { 
    super.initState();
    currentUser = widget.account;
    getUserLocation();
  }

  uploadPhoto(datafile) async {
    String filename = basename(datafile.path);
    StorageReference firebaseSorageref = FirebaseStorage.instance.ref().child(filename);
    StorageUploadTask uploadTask = firebaseSorageref.putFile(file);

    if(uploadTask.isInProgress){
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
    final compressImageFile = File('$path/img_$imageID.jpg')..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 80,));

    setState(() {
      file = compressImageFile;
    });
  }

  getUserLocation() async {
    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks = await Geolocator().placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placemarks[0];
    String completeAddress = '${placemark.subThoroughfare}, ${placemark.thoroughfare}, ${placemark.subLocality}, ${placemark.locality}, ${placemark.subAdministrativeArea}, ${placemark.administrativeArea}, ${placemark.postalCode}, ${placemark.country}';
    // String formattedAddress = "${placemark.locality}, ${placemark.country}, ${placemark.postalCode}";

    locationController.text = completeAddress;
  }

  postProduct() async {
    DateTime timestamp = DateTime.now();

    await Firestore.instance.collection('products').document(postID)
        .setData({
          'postID': postID,
          'avatar': currentUser.photoUrl,
          'author': currentUser.displayName, 
          'idauthor': currentUser.id, 
          'picture': imageURL,
          'description': descriptionController.text,
          'location': locationController.text,
          'imagename': imageID,
          'prices': prices.text, 
          'product': productName.text, 
          'stock': stock.text,
          'publish': timestamp
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            Material(
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
            loading ? LinearProgressIndicator(): Text(""),
          ],
        ),
        actions: <Widget>[
          FlatButton(
            child: Text("POST", style: TextStyle(color: Colors.lime),),
            onPressed: () async {
              if(file == await null || productName.text == "" || prices.text == "" || stock.text == ""){
                return await showDialog(
                  context: context,
                  builder: (context){
                    return AlertDialog(
                      title: Text("Field Kosong"),
                      content: Container(
                        height: 50.0,
                        width: 250.0,
                        child: ListView(
                          children: <Widget>[
                            Text("Semua Field harus di isi!!, tidak boleh ada yang kosong...")
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        FlatButton(
                          child: Text("OK"),
                          onPressed: () => Navigator.pop(context),
                        )
                      ],
                    );
                  }
                );
              }

              await compressImage();
              await uploadPhoto(file);
              await postProduct();

              Navigator.pop(context);

              if(goinguploadTask.isSuccessful){
                setState(() {
                  loading = false;
                  file = null;
                });
              }
            },
          )
        ],
        title: Text("Posting Cake", style: TextStyle(color: Colors.black),),
      ),
      body: widget.userSeller ? ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Material(
              elevation: 15,
              borderRadius: BorderRadius.circular(10.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 300.0,
                        child: file == null ? Text(""): Image.file(file, fit: BoxFit.cover,),
                      ),
                      file == null ? GestureDetector(
                        onTap: () async {
                          File fileCapture = await ImagePicker.pickImage(source: ImageSource.camera);
                          setState(() {
                            file = fileCapture;
                          });
                        },
                        child: Icon(Icons.camera_alt, size: 50.0,)
                      ): Text(""),
                      file == null ? Text("") : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Material(
                            borderRadius: BorderRadius.only(topRight: Radius.circular(10.0), bottomRight: Radius.circular(10.0)),
                            color: Colors.black54,
                            child: IconButton(
                              icon: Icon(Icons.close, color: Colors.white,),
                              onPressed: () {
                                setState(() {
                                  file = null;
                                });
                              },
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              controller: locationController,
              maxLines: 2,
              decoration: InputDecoration(
                border: InputBorder.none,
                labelText: 'Address / Location'
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text('Description / Deskripsi', style: TextStyle(fontSize: 17.0, color: Colors.black54),),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0),
            child: TextField(
              controller: descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                // labelText: 'type'
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              controller: productName,
              decoration: InputDecoration(
                border: InputBorder.none,
                labelText: 'Nama Product / Product Name'
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              controller: prices,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: InputBorder.none,
                labelText: 'Harga / Price'
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              controller: stock,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: InputBorder.none,
                labelText: 'Persediaan / Stock'
              ),
            ),
          ),
          SizedBox(height: 20.0,),
        ],
      ): Center(
        child: Text("Anda Bukan Penjual..  Silahkan aktifasi di Profile!"),
      ),
    );
  }
}