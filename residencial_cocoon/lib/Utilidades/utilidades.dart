import 'package:flutter/material.dart';
import 'package:residencial_cocoon/Servicios/fachada.dart';
import 'dart:html' as html;
import 'package:residencial_cocoon/UI/Login/vistaLogin.dart';

class Utilidades {
  static void cerrarSesion(BuildContext context) {
    Fachada.getInstancia()?.setUsuario(null);
    html.window.localStorage.remove('usuario');
    Navigator.pushReplacementNamed(context, VistaLogin.id);
  }
}
