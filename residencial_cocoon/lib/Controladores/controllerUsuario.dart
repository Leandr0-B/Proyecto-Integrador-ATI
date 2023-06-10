import 'package:flutter/material.dart';
import 'package:residencial_cocoon/Modelo/usuario.dart';
import 'package:residencial_cocoon/Servicios/fachada.dart';

class ControllerUsuario {
  //Atributos
  Function(String mensaje) mostrarMensaje;
  Function() ingreso;

  //Constructor
  ControllerUsuario({
    required this.mostrarMensaje,
    required this.ingreso,
  });

  //Funciones
  void loginUsuario(String ci, String clave) {
    //Hace el pasamanos del login
    ci = _limpieza(ci);
    String? control = _controlDatos(ci, clave);
    if (control == null) {
      Usuario? usuario = Fachada.getInstancia()?.login(ci, clave);
      if (usuario == null) {
        mostrarMensaje("Los datos ingresados no estan en el sistema.");
      } else {
        ingreso();
      }
    } else {
      mostrarMensaje(control);
    }
  }

  String? _controlDatos(String ci, String clave) {
    //Controla los valores de cedula y clave
    String? respuesta;
    if (ci == "" || clave == "") {
      respuesta = "Los datos de ingreso no pueden estar vacios.";
    }
    return respuesta;
  }

  String _limpieza(String ci) {
    //Limpia los puntos y guiones de la cedula
    if (ci.contains(".")) {
      ci = ci.replaceAll(".", "");
    }
    if (ci.contains("-")) {
      ci = ci.replaceAll("-", "");
    }
    return ci;
  }
}
