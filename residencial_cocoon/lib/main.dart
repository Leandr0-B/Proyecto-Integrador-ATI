import 'package:flutter/material.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';
import 'package:residencial_cocoon/Servicios/fachada.dart';
import 'package:residencial_cocoon/UI/Inicio/vistaInicio.dart';
import 'package:residencial_cocoon/UI/Login/vistaLogin.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool isLoggedIn = false;
  Usuario? usuario;

  final localStorage = html.window.localStorage;
  final jsonString = localStorage['usuario'];
  if (jsonString != null) {
    try {
      final jsonData = json.decode(jsonString);
      String tokenUsuario = jsonData['authToken'];
      usuario = await Fachada.getInstancia()?.obtenerUsuarioToken(tokenUsuario);
      isLoggedIn = true;
      Fachada.getInstancia()?.setUsuario(usuario);
    } on Exception catch (ex) {
      // se borran la informacion de la local storage para que el usuario se vuelva a loguear
      isLoggedIn = false;

      // cerrar sesion
      html.window.localStorage.remove('usuario');
      Fachada.getInstancia()?.setUsuario(null);
    }
  }

  String initialRoute = isLoggedIn ? VistaInicio.id : VistaLogin.id;

  //setPathUrlStrategy();
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
        VistaInicio.id: (context) {
          if (estaAutenticado()) {
            return VistaInicio();
          } else {
            return VistaLogin();
          }
        },
      },
      onUnknownRoute: (RouteSettings settings) {
        return MaterialPageRoute(
          builder: (BuildContext context) {
            return isLoggedIn ? VistaInicio() : VistaLogin();
          },
        );
      },
    );
  }

  bool estaAutenticado() {
    return Fachada.getInstancia()?.getUsuario() != null;
  }
}
