import 'package:flutter/material.dart';

class OrderProduct extends StatefulWidget {
  OrderProduct({Key key}) : super(key: key);

  @override
  _OrderProductState createState() => _OrderProductState();
}

class _OrderProductState extends State<OrderProduct> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order'), 
      ),
      body: Center(
        child: Text("Order Page"),
      ),
    );
  }
}