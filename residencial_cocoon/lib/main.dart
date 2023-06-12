import 'package:flutter/material.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';
import 'package:residencial_cocoon/UI/Inicio/vistaInicio.dart';
import 'package:residencial_cocoon/UI/Login/vistaLogin.dart';
import 'package:universal_html/html.dart' as html;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  bool isLoggedIn =
      html.window.localStorage.containsKey('isLoggedIn') ? true : false;
  String initialRoute = isLoggedIn ? InicioPage.id : LoginPage.id;

  runApp(MainApp(
    initialRoute: initialRoute,
    isLoggedIn: isLoggedIn,
  ));
}

class MainApp extends StatelessWidget {
  final String initialRoute;
  final bool isLoggedIn; // Agregar esta propiedad
  MainApp({
    required this.initialRoute,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Residencial Cocoon',
        debugShowCheckedModeBanner: false,
        initialRoute: initialRoute,
        routes: {
          LoginPage.id: (context) => LoginPage(),
          InicioPage.id: (context) => InicioPage(usuario: Usuario.vacio()),
        });
  }
}
