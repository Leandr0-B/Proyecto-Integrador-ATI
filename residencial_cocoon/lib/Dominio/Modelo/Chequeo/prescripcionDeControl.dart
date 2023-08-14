import 'package:flutter/material.dart';
import 'package:residencial_cocoon/Dominio/Modelo/control.dart';
import 'package:residencial_cocoon/Dominio/Modelo/geriatra.dart';
import 'package:residencial_cocoon/Dominio/Modelo/residente.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';

class PrescripcionDeControl {
  //Atributos
  int _id_prescripcion = 0;
  Residente _residente = Residente.empty();
  List<Control> _controles = [];
  String _descripcion = "";
  DateTime _fecha_desde = DateTime(0);
  DateTime _fecha_hasta = DateTime(0);
  DateTime _fecha_creacion = DateTime(0);
  Geriatra _geriatra = Geriatra.empty();
  int _frecuencia = 0;
  TimeOfDay _hora_comienzo = TimeOfDay(hour: 0, minute: 0);
  int _duracion = 0;
  int _cronica = 0;

  //Constructor
  PrescripcionDeControl.empty();
  PrescripcionDeControl(
    this._id_prescripcion,
    this._descripcion,
    this._fecha_desde,
    this._fecha_hasta,
    this._frecuencia,
    this._hora_comienzo,
    this._fecha_creacion,
    this._duracion,
    this._cronica,
    this._controles,
  );

  factory PrescripcionDeControl.fromJsonVistaPrevia(Map<String, dynamic> json) {
    Usuario geriatraAux = Usuario.empty();
    geriatraAux.ci = json['ci_geriatra'];
    geriatraAux.nombre = json['nombre_geriatra'];
    geriatraAux.apellido = json['apellido_geriatra'];

    Usuario residenteAux = Usuario.empty();
    residenteAux.ci = json['ci_residente'];
    residenteAux.nombre = json['nombre_residente'];
    residenteAux.apellido = json['apellido_residente'];

    String stringHoraComienzo = json['hora_comienzo'];
    List<String> partsHoraComienzo = stringHoraComienzo.split(':');
    int hourHoraComienzo = int.parse(partsHoraComienzo[0]);
    int minuteHoraComienzo = int.parse(partsHoraComienzo[1]);
    TimeOfDay hora_comienzo = TimeOfDay(hour: hourHoraComienzo, minute: minuteHoraComienzo);

    List<Control> controles = Control.fromJsonListPrescripcion(json['controles']);

    PrescripcionDeControl prescripcionAux = PrescripcionDeControl(
      json['id_prescripcion'],
      json['descripcion'],
      DateTime.parse(json['fecha_desde']),
      DateTime.parse(json['fecha_hasta']),
      json['frecuencia'],
      hora_comienzo,
      DateTime.parse(json['fecha_creacion']),
      json['duracion'] ?? 0,
      json['cronica'],
      controles,
    );
    prescripcionAux.agregarGeriatra(geriatraAux);
    prescripcionAux.agregarResidente(residenteAux);
    return prescripcionAux;
  }

  //Get Set
  int get id_prescripcion => this._id_prescripcion;
  set id_prescripcion(int value) => this._id_prescripcion = value;

  DateTime get fecha_desde => this._fecha_desde;
  set fecha_desde(DateTime value) => this._fecha_desde = value;

  get fecha_hasta => this._fecha_hasta;
  set fecha_hasta(value) => this._fecha_hasta = value;

  get fecha_creacion => this._fecha_creacion;
  set fecha_creacion(value) => this._fecha_creacion = value;

  get frecuencia => this._frecuencia;
  set frecuencia(value) => this._frecuencia = value;

  get hora_comienzo => this._hora_comienzo;
  set hora_comienzo(value) => this._hora_comienzo = value;

  get duracion => this._duracion;
  set duracion(value) => this._duracion = value;

  get cronica => this._cronica;
  set cronica(value) => this._cronica = value;

  get descripcion => this._descripcion;
  set descripcion(value) => this._descripcion = value;

  List<Control> get controles => this._controles;
  set controles(List<Control> value) => this._controles = value;

  //Funciones
  static List<PrescripcionDeControl> listaVistaPrevia(List jsonList) {
    return jsonList.cast<Map<String, dynamic>>().map<PrescripcionDeControl>((json) => PrescripcionDeControl.fromJsonVistaPrevia(json)).toList();
  }

  void agregarGeriatra(Usuario geriatra) {
    _geriatra.usuario = geriatra;
  }

  void agregarResidente(Usuario residente) {
    _residente.usuario = residente;
  }

  bool esCronica() {
    return _cronica == 1;
  }

  String nombreResidente() {
    return _residente.nombreUsuario();
  }

  String apellidoResidente() {
    return _residente.apellidoUsuario();
  }

  String ciResidente() {
    return _residente.ciUsuario();
  }

  String nombreGeriatra() {
    return _geriatra.nombreUsuario();
  }

  String apellidoGeriatra() {
    return _geriatra.apellidoUsuario();
  }

  String ciGeriatra() {
    return _geriatra.ciUsuario();
  }
}
