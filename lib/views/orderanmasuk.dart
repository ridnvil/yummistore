import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';

final money = new NumberFormat("#,##0.00", "en_US");

class OrderanMasuk extends StatefulWidget {
  final GoogleSignInAccount account;
  OrderanMasuk({Key key, this.account}) : super(key: key);

  @override
  _OrderanMasukState createState() => _OrderanMasukState();
}

class _OrderanMasukState extends State<OrderanMasuk> {
  GoogleSignInAccount currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = widget.account;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Order Masuk", style: TextStyle(color: Colors.black),),
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
        stream: FirebaseFirestore.instance.collection('orders').where('ownerid', isEqualTo: currentUser.id).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if(snapshot.hasError)
            return Center(child: Text('${snapshot.error}'),);

          if(!snapshot.hasData)
            return Center(child: CircularProgressIndicator(),);

          switch(snapshot.connectionState){
            case ConnectionState.waiting: return Center(child: CircularProgressIndicator(),);
            default:
              return ListView(
                children: snapshot.data.docs.map((document){
                  return Column(
                    children: <Widget>[
                      ExpansionTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(document.data()['picture']),
                        ),
                        title: Text('${document.data()['product']} / ${document.data()['userorder']}'),
                        subtitle: Text('Jumlah: ${document.data()['qty']} / Total: ${document.data()['totalbayar']}'),
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: <Widget>[
                                Text('Detail Order'),
                                Row(
                                  children: <Widget>[
                                    SizedBox(width: 20.0,),
                                    Text('Pemesan: '),
                                    CircleAvatar(
                                      backgroundImage: NetworkImage(document.data()['useravatar']),
                                      maxRadius: 12.0,
                                    ),
                                    SizedBox(width: 5.0,),
                                    Text('${document.data()['userorder']}'),
                                  ],
                                ),
                                SizedBox(height: 5.0,),
                                Row(
                                  children: <Widget>[
                                    SizedBox(width: 20.0,),
                                    Expanded(child: Text('Jumlah Pesanan ${document.data()['qty']} dengan total Pembayaran Rp.${money.format(double.parse(document.data()['totalbayar']))}')),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    SizedBox(width: 20.0,),
                                    Expanded(child: document.data()['status'] == 1 ? Text('Status: Pesanan Sedang di Proses'): Text('Status: Menunggu di Proses')),
                                  ],
                                )
                              ],
                            ),
                          ),
                          MaterialButton(
                            child: Text('Proses Pesanan'),
                            onPressed: () async {
                              return showDialog(
                                context: context,
                                builder: (context){
                                  return AlertDialog(
                                    content: Text('Mulai Proses Pesanan ini?'),
                                    actions: <Widget>[
                                      FlatButton(
                                        child: Text('Tidak'),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                      FlatButton(
                                        child: Text('OK'),
                                        onPressed: () async {
                                          await Firestore.instance.collection('orders')
                                                .document(document.documentID)
                                                .updateData({
                                                  'status': 1
                                                }).then((data){
                                                  Navigator.pop(context);
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
                  );
                }).toList(),
              );
          }
        },
      ),
    );
  }
}