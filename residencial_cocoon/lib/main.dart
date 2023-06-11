import 'package:flutter/material.dart';
import 'package:residencial_cocoon/UI/vistaInicio.dart';
import 'package:residencial_cocoon/UI/vistaLogin.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Residencial Cocoon',
      debugShowCheckedModeBanner: false,
      initialRoute: LoginPage.id,
      routes: {
        LoginPage.id: (context) => LoginPage(),
        InicioPage.id: (context) => InicioPage(),
      },
    );
  }
}
