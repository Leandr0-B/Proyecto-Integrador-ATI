import 'package:flutter/material.dart';
import 'package:residencial_cocoon/Dominio/Modelo/familiar.dart';
import 'package:residencial_cocoon/Dominio/Modelo/residente.dart';
import 'package:residencial_cocoon/Dominio/Modelo/rol.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';
import 'package:residencial_cocoon/Servicios/fachada.dart';
import 'package:residencial_cocoon/UI/Inicio/vistaInicio.dart';
import 'package:residencial_cocoon/UI/Login/vistaLogin.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:convert';
import 'package:url_strategy/url_strategy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool isLoggedIn = false;
  Usuario? usuario;

  final localStorage = html.window.localStorage;
  final jsonString = localStorage['usuario'];
  if (jsonString != null) {
    isLoggedIn = true;
    final jsonData = json.decode(jsonString);
    String tokenUsuario = jsonData['authToken'];
    usuario = await Fachada.getInstancia()?.obtenerUsuarioToken(tokenUsuario);
    Fachada.getInstancia()?.setUsuario(usuario);
  }

  String initialRoute = isLoggedIn ? VistaInicio.id : VistaLogin.id;

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
  const MainApp({
    super.key,
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
        VistaLogin.id: (context) => VistaLogin(),
        VistaInicio.id: (context) => VistaInicio(usuario: usuario),
      },
      onUnknownRoute: (RouteSettings settings) {
        return MaterialPageRoute(
          builder: (BuildContext context) {
            return isLoggedIn ? VistaInicio(usuario: usuario) : VistaLogin();
          },
        );
      },
    );
  }
}
