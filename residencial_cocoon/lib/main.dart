import 'package:flutter/material.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';
import 'package:residencial_cocoon/Servicios/fachada.dart';
import 'package:residencial_cocoon/UI/Inicio/vistaInicio.dart';
import 'package:residencial_cocoon/UI/Login/vistaLogin.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:convert';
import 'package:url_strategy/url_strategy.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  bool isLoggedIn = false;
  Usuario? usuario;

  final localStorage = html.window.localStorage;
  final jsonString = localStorage['usuario'];
  if (jsonString != null) {
    final userData = json.decode(jsonString);
    usuario = Usuario.fromJson(userData);
    print(usuario.toString());
    Fachada.getInstancia()?.setUsuario(usuario);
    isLoggedIn = true;
  }

  String initialRoute = isLoggedIn ? InicioPage.id : LoginPage.id;

  setPathUrlStrategy();
  runApp(MainApp(
    initialRoute: initialRoute,
    isLoggedIn: isLoggedIn,
    usuario: usuario,
  ));
}

class MainApp extends StatelessWidget {
  final String initialRoute;
  final bool isLoggedIn; // Agregar esta propiedad
  final Usuario? usuario;
  MainApp({
    required this.initialRoute,
    required this.isLoggedIn,
    required this.usuario,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Residencial Cocoon',
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      routes: {
        LoginPage.id: (context) => LoginPage(),
        InicioPage.id: (context) => InicioPage(usuario: usuario),
      },
      onUnknownRoute: (RouteSettings settings) {
        return MaterialPageRoute(
          builder: (BuildContext context) {
            return isLoggedIn ? InicioPage(usuario: usuario) : LoginPage();
          },
        );
      },
    );
  }
}
