import 'package:alicia/src/ui/pages/home_products_page.dart';
import 'package:flutter/material.dart';

void main() async {
  runApp(MyApp());
}

final primaryColor = Color(0xff0B1C28);

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alicia - Gestor Contenido',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeProductsPage(),
    );
  }
}
