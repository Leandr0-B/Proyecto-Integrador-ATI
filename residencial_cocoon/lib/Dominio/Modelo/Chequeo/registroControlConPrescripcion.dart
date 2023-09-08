import 'package:flutter/material.dart';
import 'package:residencial_cocoon/Dominio/Modelo/Chequeo/prescripcionDeControl.dart';
import 'package:residencial_cocoon/Dominio/Modelo/Medicacion/prescripcionDeMedicamento.dart';
import 'package:residencial_cocoon/Dominio/Modelo/control.dart';
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

  factory RegistroControlConPrescripcion.fromJsonVistaPrevia(Map<String, dynamic> json) {
    Usuario enfermeroAux = Usuario.empty();
    enfermeroAux.ci = json['ci_enfermero'] ?? "";
    enfermeroAux.nombre = json['nombre_enfermero'] ?? "";
    enfermeroAux.apellido = json['apellido_enfermero'] ?? "";

    DateTime fecha_realizacion;
    if (json['fecha_realizacion'] == null) {
      fecha_realizacion = DateTime(0);
    } else {
      fecha_realizacion = DateTime.parse(json['fecha_realizacion']);
    }

    String stringHoraPactada = json['hora_pactada'];
    List<String> partsHoraPactada = stringHoraPactada.split(':');
    int hourHoraPactada = int.parse(partsHoraPactada[0]);
    int minuteHoraPactada = int.parse(partsHoraPactada[1]);
    TimeOfDay hora_pactada = TimeOfDay(hour: hourHoraPactada, minute: minuteHoraPactada);

    TimeOfDay hora_realizada;
    if (json['hora_de_realizacion'] == null) {
      hora_realizada = TimeOfDay(hour: 0, minute: 0);
    } else {
      String stringHoraRealizada = json['hora_de_realizacion'];
      List<String> partsHoraRealizada = stringHoraRealizada.split(':');
      int hourHoraRealizada = int.parse(partsHoraRealizada[0]);
      int minuteHoraRealizada = int.parse(partsHoraRealizada[1]);
      hora_realizada = TimeOfDay(hour: hourHoraRealizada, minute: minuteHoraRealizada);
    }

    //Prescripcion
    PrescripcionDeControl prescripcionAux = PrescripcionDeControl.empty();
    prescripcionAux.descripcion = json['descripcion_prescripcion'];
    prescripcionAux.fecha_desde = DateTime.parse(json['fecha_desde']);
    prescripcionAux.fecha_hasta = DateTime.parse(json['fecha_hasta']);
    //prescripcionAux.fecha_creacion = DateTime.parse(json['fecha_creacion']);
    //prescripcionAux.cronica = json['cronica'] ;

    String stringHoraComienzo = json['hora_comienzo'];
    List<String> partsHoraComienzo = stringHoraComienzo.split(':');
    int hourHoraComienzo = int.parse(partsHoraComienzo[0]);
    int minuteHoraComienzo = int.parse(partsHoraComienzo[1]);
    TimeOfDay hora_comienzo = TimeOfDay(hour: hourHoraComienzo, minute: minuteHoraComienzo);
    prescripcionAux.hora_comienzo = hora_comienzo;

    prescripcionAux.frecuencia = json['frecuencia'];
    prescripcionAux.controles = Control.fromJsonListPrescripcion(json['controles']);

    Usuario geriatraAux = Usuario.empty();
    geriatraAux.ci = json['ci_geriatra'];
    geriatraAux.nombre = json['nombre_geriatra'];
    geriatraAux.apellido = json['apellido_geriatra'];

    Usuario residenteAux = Usuario.empty();
    residenteAux.ci = json['ci_residente'];
    residenteAux.nombre = json['nombre_residente'];
    residenteAux.apellido = json['apellido_residente'];

    prescripcionAux.agregarGeriatra(geriatraAux);
    prescripcionAux.agregarResidente(residenteAux);

    RegistroControlConPrescripcion registroAux = RegistroControlConPrescripcion(
      json['id_registro_control_prescripcion'],
      DateTime.parse(json['fecha_pactada']),
      hora_pactada,
      json['procesada'],
      prescripcionAux,
      json['descripcion'] ?? "",
      hora_realizada,
      fecha_realizacion,
      enfermeroAux,
    );
    return registroAux;
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

  int get id_registro_control_prescripcion => this._id_registro_control_prescripcion;
  set id_registro_control_prescripcion(int value) => this._id_registro_control_prescripcion = value;

  //Funciones
  static List<RegistroControlConPrescripcion> listaVistaPrevia(List jsonList) {
    return jsonList.cast<Map<String, dynamic>>().map<RegistroControlConPrescripcion>((json) => RegistroControlConPrescripcion.fromJsonVistaPrevia(json)).toList();
  }

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

  bool esCronica() {
    return _prescripcion.esCronica();
  }

  String nombreResidente() {
    return _prescripcion.nombreResidente();
  }

  String apellidoResidente() {
    return _prescripcion.apellidoResidente();
  }

  String ciResidente() {
    return _prescripcion.ciResidente();
  }

  String nombreGeriatra() {
    return _prescripcion.nombreGeriatra();
  }

  String apellidoGeriatra() {
    return _prescripcion.apellidoGeriatra();
  }

  String ciGeriatra() {
    return _prescripcion.ciGeriatra();
  }

  DateTime fechaCracion() {
    return _prescripcion.fecha_creacion;
  }

  String descripcionPrescripcion() {
    return _prescripcion.descripcion;
  }

  DateTime fechaDesde() {
    return _prescripcion.fecha_desde;
  }

  DateTime fechaHasta() {
    return _prescripcion.fecha_hasta;
  }

  List<Control> controles() {
    return _prescripcion.controles;
  }

  bool esProcesada() {
    return _procesada == 1;
  }

  void procesar() {
    this._procesada = 1;
  }
}
