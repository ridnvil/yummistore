import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:cached_network_image/cached_network_image.dart';

final money = new NumberFormat("#,##0.00", "en_US");

class OrderProduct extends StatefulWidget {
  final String productID;
  final GoogleSignInAccount account;

  OrderProduct({Key key, this.productID, this.account}) : super(key: key);

  @override
  _OrderProductState createState() => _OrderProductState();
}

class _OrderProductState extends State<OrderProduct> {
  int orderqty = 0;
  int stock = 0;
  TextEditingController qty = TextEditingController();
  GoogleSignInAccount currentUser;
  bool isOrderProc = false;

  @override
  void initState() {
    super.initState();
    currentUser = widget.account;
    qty.text = orderqty.toString();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Order", style: TextStyle(color: Colors.black),),
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
        stream: Firestore.instance.collection('products').document(widget.productID).snapshots(),
        builder: (context, snapshot) {
          if(snapshot.hasError)
            return Center(child: Text('${snapshot.error}'),);

          if(!snapshot.hasData)
            return Center(child: CircularProgressIndicator(),);

          var document = snapshot.data;
          stock = int.parse(document['stock']);

          return ListView(
            children: <Widget>[
              Stack(
                alignment: Alignment.topCenter,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Material(
                      elevation: 10,
                      child: Container(
                        height: 300.0,
                        width: MediaQuery.of(context).size.width,
                        child: CachedNetworkImage(imageUrl: document['picture'], fit: BoxFit.cover,)
                      ),
                    ),
                  ),
                  isOrderProc ? Center(child: LinearProgressIndicator(),): Text(''),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 5.0),
                child: Material(
                  child: Text(document['product'], style: TextStyle(fontSize: 30.0),),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text('Harga \nRp. ${money.format(double.parse(document['prices']))}', style: TextStyle(fontSize: 18.0),),
                        ),
                        SizedBox(height: 10.0,),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 100.0,
                              child: Text('Deskripsi \n${document['description']}', style: TextStyle(fontSize: 18.0),
                            )
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text('Penjual', style: TextStyle(fontSize: 18.0),),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Row(
                            children: <Widget>[
                              CircleAvatar(
                                backgroundImage: NetworkImage(document['avatar']),
                                maxRadius: 15.0,
                              ),
                              SizedBox(width: 5.0,),
                              Text('${document['author']}', style: TextStyle(fontSize: 18.0), overflow: TextOverflow.ellipsis,),
                            ],
                          ),
                        ),
                        SizedBox(height: 10.0,),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text('Stock Ready \n${document['stock']}', style: TextStyle(fontSize: 18.0),),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              // SizedBox(height: 10.0,),
              Row(
                children: <Widget>[
                  Expanded(
                    child: IconButton(
                      icon: Text('+', style: TextStyle(fontSize:30.0),),
                      onPressed: () {
                        setState(() async {

                          if(orderqty >= stock)
                            return showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  content: Text('Stock Kurang'),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: Text('OK'),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    )
                                  ],
                                );
                              }
                            );

                          orderqty = int.parse(qty.text);
                          orderqty++;
                          qty.text = orderqty.toString();
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: qty,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 40.0),
                      onChanged: (val) {
                        setState(() async {
                          // orderqty = int.parse(qty.text);
                          if(int.parse(val) > stock)
                            return showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  content: Text('Stock Kurang'),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: Text('OK'),
                                      onPressed: () {
                                        qty.text = stock.toString();
                                        Navigator.pop(context);
                                      },
                                    )
                                  ],
                                );
                              }
                            );
                        });
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Expanded(
                    child: IconButton(
                      icon: Text('-', style: TextStyle(fontSize:30.0),),
                      onPressed: () {
                        setState(() {
                          if(orderqty != 0){  
                            orderqty = int.parse(qty.text);
                            orderqty--;
                            qty.text = orderqty.toString();
                          }
                        });
                      },
                    ),
                  )
                ],
              ),
              SizedBox(height: 20.0,),
              MaterialButton(
                child: Text('ORDER'),
                height: 50.0,
                onPressed: () async {
                  // print(currentUser.email);
                  setState(() {
                    isOrderProc = true;
                  });
                  double totalprice = double.parse(document['prices']) * orderqty;
                  String orderid = Uuid().v4();
                  await Firestore.instance.collection('orders')
                        .document(orderid)
                        .setData({
                          'orderid': orderid,
                          'ownerid': document['idauthor'],
                          'owneravatar': document['avatar'],
                          'ownername': document['author'],
                          'product': document['product'],
                          'picture': document['picture'],
                          'productid': widget.productID,
                          'userorderid': currentUser.id,
                          'userorder': currentUser.displayName,
                          'useravatar': currentUser.photoUrl,
                          'qty': orderqty.toString(),
                          'totalbayar': totalprice.toString(),
                          'status': 0,
                          'publish': DateTime.now()
                        }).then((data){
                          return showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                content: Text('Order Success..!'),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text('OK'),
                                    onPressed: () async {
                                      setState(() {
                                        isOrderProc = false;
                                      });
                                      await Firestore.instance.collection('products')
                                            .document(document['postID'])
                                            .updateData({
                                              'stock': (stock - orderqty).toString()
                                            }).then((data){
                                              setState(() {
                                                orderqty = 0;
                                                qty.text = orderqty.toString();
                                              });
                                            });
                                      Navigator.pop(context);
                                    },
                                  )
                                ],
                              );
                            }
                          );
                        });
                },
              ),
            ],

          );
        },
      ),
    );
  }
}