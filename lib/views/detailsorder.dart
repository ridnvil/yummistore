import 'package:flutter/material.dart';

class DetailsProduct extends StatefulWidget {
  DetailsProduct({Key key}) : super(key: key);

  @override
  _DetailsProductState createState() => _DetailsProductState();
}

class _DetailsProductState extends State<DetailsProduct> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.amber,
        title: Text("Detail Pesanan"),
      ),
    );
  }
}