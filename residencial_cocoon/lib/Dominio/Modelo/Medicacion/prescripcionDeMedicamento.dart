import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:residencial_cocoon/Dominio/Modelo/Medicacion/medicamento.dart';
import 'package:residencial_cocoon/Dominio/Modelo/geriatra.dart';
import 'package:residencial_cocoon/Dominio/Modelo/residente.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';

class PrescripcionDeMedicamento {
  //Atributos
  int _id_prescripcion = 0;
  Residente _residente = Residente.empty();
  Medicamento _medicamento = Medicamento.empty();
  String _descripcion = "";
  DateTime _fecha_desde = DateTime(0);
  DateTime _fecha_hasta = DateTime(0);
  DateTime _fecha_creacion = DateTime(0);
  Geriatra _geriatra = Geriatra.empty();
  int _cantidad = 0;
  int _frecuencia = 0;
  TimeOfDay _hora_comienzo = TimeOfDay(hour: 0, minute: 0);
  int _duracion = 0;
  int _cronica = 0;
  int _stock = 0;

  //Constructor
  PrescripcionDeMedicamento.empty();

  PrescripcionDeMedicamento(this._id_prescripcion, this._descripcion, this._fecha_desde, this._fecha_hasta, this._cantidad, this._frecuencia, this._hora_comienzo,
      this._fecha_creacion, this._duracion, this._cronica);

  factory PrescripcionDeMedicamento.fromJsonVistaPrevia(Map<String, dynamic> json) {
    Usuario geriatraAux = Usuario.empty();
    geriatraAux.ci = json['ci_geriatra'];
    geriatraAux.nombre = json['nombre_geriatra'];
    geriatraAux.apellido = json['apellido_geriatra'];

    Usuario residenteAux = Usuario.empty();
    residenteAux.ci = json['ci_residente'];
    residenteAux.nombre = json['nombre_residente'];
    residenteAux.apellido = json['apellido_residente'];

    Medicamento medicamentoAux = Medicamento.empty();
    medicamentoAux.nombre = json['nombre_medicamento'];
    medicamentoAux.setUnidad(json['unidad_medicamento']);
    medicamentoAux.stock = json['stock'];
    medicamentoAux.stockNotificacion = json['stock_notificacion'];
    medicamentoAux.stockAnterior = json['stock_anterior'];

    //Convierto la hora de string a TimeOfDay
    String timeString = json['hora_comienzo'];
    List<String> timeParts = timeString.split(':');

    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);

    TimeOfDay time = TimeOfDay(hour: hour, minute: minute);

    DateTime fecha_desde;
    DateTime fecha_hasta;
    if (json['fecha_desde'] != null && json['fecha_hasta'] != null) {
      fecha_desde = DateTime.parse(json['fecha_desde']);
      fecha_hasta = DateTime.parse(json['fecha_hasta']);
    } else {
      fecha_desde = DateTime(0);
      fecha_hasta = DateTime(0);
    }

    PrescripcionDeMedicamento prescripcionAux = PrescripcionDeMedicamento(
      json['id_prescripcion'] ?? 0, ////////////
      json['descripcion'],
      fecha_desde,
      fecha_hasta,
      json['cantidad'],
      json['frecuencia'],
      time,
      DateTime.parse(json['fecha_creacion']),
      json['duracion'] ?? 0,
      json['cronica'],
    );
    prescripcionAux.stock = json['stock'];
    prescripcionAux.agregarGeriatra(geriatraAux);
    prescripcionAux.agregarResidente(residenteAux);
    prescripcionAux.medicamento = medicamentoAux;

    return prescripcionAux;
  }

  //Get Set
  Medicamento get medicamento => this._medicamento;
  set medicamento(Medicamento value) => this._medicamento = value;

  int get id_prescripcion => this._id_prescripcion;
  set id_prescripcion(int value) => this._id_prescripcion = value;

  Residente get residente => this._residente;
  set residente(Residente value) => this._residente = value;

  String get descripcion => this._descripcion;
  set descripcion(String value) => this._descripcion = value;

  DateTime get fecha_desde => this._fecha_desde;
  set fecha_desde(DateTime value) => this._fecha_desde = value;

  DateTime get fecha_hasta => this._fecha_hasta;
  set fecha_hasta(DateTime value) => this._fecha_hasta = value;

  get geriatra => this._geriatra;
  set geriatra(value) => this._geriatra = value;

  int get cantidad => this._cantidad;
  set cantidad(int value) => this._cantidad = value;

  int get frecuencia => this._frecuencia;
  set frecuencia(int value) => this._frecuencia = value;

  TimeOfDay get hora_comienzo => this._hora_comienzo;
  set hora_comienzo(TimeOfDay value) => this._hora_comienzo = value;

  DateTime get fecha_creacion => this._fecha_creacion;
  set fecha_creacion(DateTime value) => this._fecha_creacion = value;

  set cronica(int value) => this._cronica = value;
  int get cronica => this._cronica;

  set stock(int value) => this._stock = value;
  int get stock => this._stock;

  set duracion(int value) => this._duracion = value;
  int get duracion => this._duracion;

  //Funciones
  void agregarGeriatra(Usuario geriatra) {
    _geriatra.usuario = geriatra;
  }

  void agregarResidente(Usuario residente) {
    _residente.usuario = residente;
  }

  void agregarMedicamento(Medicamento medicamento) {
    _medicamento = medicamento;
  }

  bool esCronica() {
    return _cronica == 1;
  }

  static List<PrescripcionDeMedicamento> listaVistaPrevia(List jsonList) {
    return jsonList.cast<Map<String, dynamic>>().map<PrescripcionDeMedicamento>((json) => PrescripcionDeMedicamento.fromJsonVistaPrevia(json)).toList();
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

  //ToString
  @override
  String toString() {
    String cronicaStr = _cronica == 1 ? "Cronica: Si" : "Cronica: No";
    return nombreResidente() + '  ' + apellidoResidente() + ' | ' + _descripcion + ' | ' + DateFormat('dd/MM/yyyy').format(_fecha_creacion) + '  ' + cronicaStr;
  }
}
