import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';

final money = new NumberFormat("#,##0.00", "en_US");

class OrderanSaya extends StatefulWidget {
  final GoogleSignInAccount account;
  OrderanSaya({Key key, this.account}) : super(key: key);

  @override
  _OrderanSayaState createState() => _OrderanSayaState();
}

class _OrderanSayaState extends State<OrderanSaya> {
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
        title: Text("Orderan Saya", style: TextStyle(color: Colors.black),),
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
        stream: Firestore.instance.collection('orders').where('userorderid', isEqualTo: currentUser.id).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if(snapshot.hasError)
            return Center(child: Text('${snapshot.error}'),);

          if(!snapshot.hasData)
            return Center(child: CircularProgressIndicator(),);

          switch(snapshot.connectionState){
            case ConnectionState.waiting: return Center(child: CircularProgressIndicator(),);
            default:
              return ListView(
                children: snapshot.data.documents.map((document){
                  return Column(
                    children: <Widget>[
                      ExpansionTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(document['picture']),
                        ),
                        title: Text('${document['product']} / ${document['userorder']}'),
                        subtitle: Text('Jumlah: ${document['qty']} / Total: ${document['totalbayar']}'),
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: <Widget>[
                                Text('Detail Order'),
                                Row(
                                  children: <Widget>[
                                    SizedBox(width: 20.0,),
                                    Text('Penjual: '),
                                    CircleAvatar(
                                      backgroundImage: NetworkImage(document['owneravatar']),
                                      maxRadius: 12.0,
                                    ),
                                    SizedBox(width: 5.0,),
                                    Text('${document['ownername']}'),
                                  ],
                                ),
                                SizedBox(height: 5.0,),
                                Row(
                                  children: <Widget>[
                                    SizedBox(width: 20.0,),
                                    Expanded(child: Text('Jumlah Pesanan ${document['qty']} dengan total Pembayaran Rp.${money.format(double.parse(document['totalbayar']))}')),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    SizedBox(width: 20.0,),
                                    Expanded(child: document['status'] == 1 ? Text('Status: Pesanan Sedang di Proses'): Text('Status: Menunggu di Proses')),
                                  ],
                                )
                              ],
                            ),
                          ),
                          // MaterialButton(
                          //   child: Text('Proses Pesanan'),
                          //   onPressed: () async {

                          //   },
                          // ),
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