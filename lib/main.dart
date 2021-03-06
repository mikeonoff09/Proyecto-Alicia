import 'package:alicia/src/ui/pages/home_products_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'src/blocs/features_bloc/features_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
/*   if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('Gestor Alicia');
    setWindowMinSize(const Size(1054, 800));
    setWindowMaxSize(Size.infinite);
  } */
  runApp(MyApp());
}

final primaryColor = Color(0xff0B1C28);

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FeaturesBloc(),
      child: MaterialApp(
        title: 'Alicia - Gestor Contenido',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primarySwatch: Colors.blue,
            snackBarTheme: SnackBarThemeData(elevation: 6)),
        home: HomeProductsPage(),
      ),
    );
  }
}
