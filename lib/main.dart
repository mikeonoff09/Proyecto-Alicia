import 'dart:io';

import 'package:alicia/src/product_bloc/product_bloc.dart';
import 'package:alicia/src/ui/pages/home_products_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:window_size/window_size.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('Gestor Alicia');
    setWindowMinSize(const Size(1200, 800));
    setWindowMaxSize(Size.infinite);
  }
  runApp(MyApp());
}

final primaryColor = Color(0xff0B1C28);

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProductBloc(),
      child: MaterialApp(
        title: 'Alicia - Gestor Contenido',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomeProductsPage(),
      ),
    );
  }
}
