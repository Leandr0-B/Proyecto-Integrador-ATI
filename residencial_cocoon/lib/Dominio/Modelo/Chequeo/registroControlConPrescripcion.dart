import 'package:flutter/material.dart';
import 'package:residencial_cocoon/Dominio/Modelo/Chequeo/prescripcionDeControl.dart';
import 'package:residencial_cocoon/Dominio/Modelo/enfermero.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';

class RegistroControlConPrescripcion {
  //Atributos
  int _id_registro_control_prescripcion = 0;
  DateTime _fecha_pactada = DateTime(0);
  DateTime _fecha_realizada = DateTime(0);
  TimeOfDay _hora_pactada = TimeOfDay(hour: 0, minute: 0);
  TimeOfDay _hora_de_realizacion = TimeOfDay(hour: 0, minute: 0);
  int _procesada = 0;
  String _descripcion = "";
  PrescripcionDeControl _prescripcion = PrescripcionDeControl.empty();
  Enfermero _enfermero = Enfermero.empty();

  //Constructor
  RegistroControlConPrescripcion.empty();
  RegistroControlConPrescripcion(
    this._id_registro_control_prescripcion,
    this._fecha_pactada,
    this._hora_pactada,
    this._procesada,
    this._prescripcion,
    this._descripcion,
    this._hora_de_realizacion,
    this._fecha_realizada,
    Usuario enfermero,
  ) {
    agregarEnfermero(enfermero);
  }

  //Get Set
  DateTime get fecha_pactada => this._fecha_pactada;
  set fecha_pactada(DateTime value) => this._fecha_pactada = value;

  get fecha_realizada => this._fecha_realizada;
  set fecha_realizada(value) => this._fecha_realizada = value;

  get hora_pactada => this._hora_pactada;
  set hora_pactada(value) => this._hora_pactada = value;

  get hora_de_realizacion => this._hora_de_realizacion;
  set hora_de_realizacion(value) => this._hora_de_realizacion = value;

  int get procesada => this._procesada;
  set procesada(int value) => this._procesada = value;

  get descripcion => this._descripcion;
  set descripcion(value) => this._descripcion = value;

  //Funciones
  String nombreEnfermero() {
    return _enfermero.nombreUsuario();
  }

  String apellidoEnfermero() {
    return _enfermero.apellidoUsuario();
  }

  String ciEnfermero() {
    return _enfermero.ciUsuario();
  }

  void agregarEnfermero(Usuario enfermero) {
    _enfermero.usuario = enfermero;
  }

  int idPrescripcion() {
    return _prescripcion.id_prescripcion;
  }
}
