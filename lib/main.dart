import 'package:cakestore/views/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nvil',
      initialRoute: '/',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColorLight: Colors.white,
          primaryColorDark: Colors.black87),
      home: Login(
        logout: false,
      ),
    );
  }
}
