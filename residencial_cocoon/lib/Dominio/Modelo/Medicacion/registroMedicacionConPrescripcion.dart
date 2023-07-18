import 'package:flutter/material.dart';
import 'package:residencial_cocoon/Dominio/Modelo/Medicacion/medicamento.dart';
import 'package:residencial_cocoon/Dominio/Modelo/Medicacion/prescripcionDeMedicamento.dart';
import 'package:residencial_cocoon/Dominio/Modelo/enfermero.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';

class RegistroMedicacionConPrescripcion {
  //Atributos
  int _id_registro_medicacion_con_prescripcion = 0;
  int _procesada = 0;
  DateTime _fecha_pactada = DateTime(0);
  DateTime _fecha_de_realizacion = DateTime(0);
  String _descripcion = "";
  PrescripcionDeMedicamento _prescripcion = PrescripcionDeMedicamento.empty();
  TimeOfDay _hora_pactada = TimeOfDay(hour: 0, minute: 0);
  TimeOfDay _hora_de_realizacion = TimeOfDay(hour: 0, minute: 0);
  int _cantidad_sugerida = 0;
  int _cantidad_dada = 0;
  Enfermero _enfermero = Enfermero.empty();

  //Constructor
  RegistroMedicacionConPrescripcion.empty();
  RegistroMedicacionConPrescripcion(
    this._id_registro_medicacion_con_prescripcion,
    this._fecha_pactada,
    this._hora_pactada,
    this._cantidad_sugerida,
    this._procesada,
    this._prescripcion,
    this._descripcion,
    this._cantidad_dada,
    this._hora_de_realizacion,
  );

  factory RegistroMedicacionConPrescripcion.fromJsonVistaPrevia(Map<String, dynamic> json) {
    Usuario geriatraAux = Usuario.empty();
    geriatraAux.ci = json['ci_geriatra'];
    geriatraAux.nombre = json['nombre_geriatra'];
    geriatraAux.apellido = json['apellido_geriatra'];

    Usuario residenteAux = Usuario.empty();
    residenteAux.ci = json['ci_residente'];
    residenteAux.nombre = json['nombre_residente'];
    residenteAux.apellido = json['apellido_residente'];

    Medicamento medicamentoAux = Medicamento.empty();
    String uni = json['unidad_medicamento'];
    medicamentoAux.nombre = json['nombre_medicamento'];
    medicamentoAux.setUnidad(uni);
    medicamentoAux.stock = json['stock_medicamento'] ?? 0;

    PrescripcionDeMedicamento prescripcionAux = PrescripcionDeMedicamento.empty();
    prescripcionAux.descripcion = json['descripcion_prescripcion'];
    prescripcionAux.fecha_desde = DateTime.parse(json['fecha_desde']);
    prescripcionAux.fecha_hasta = DateTime.parse(json['fecha_hasta']);
    //Convierto la hora de string a TimeOfDay
    String stringHoraComienzo = json['hora_comienzo'];
    List<String> partsHoraComienzo = stringHoraComienzo.split(':');

    int hourHoraComienzo = int.parse(partsHoraComienzo[0]);
    int minuteHoraComienzo = int.parse(partsHoraComienzo[1]);

    TimeOfDay hora_comienzo = TimeOfDay(hour: hourHoraComienzo, minute: minuteHoraComienzo);
    prescripcionAux.hora_comienzo = hora_comienzo;
    prescripcionAux.frecuencia = json['frecuencia'];
    prescripcionAux.cantidad = json['cantidad'];

    prescripcionAux.agregarGeriatra(geriatraAux);
    prescripcionAux.agregarResidente(residenteAux);
    prescripcionAux.agregarMedicamento(medicamentoAux);

    //Convierto la hora de string a TimeOfDay
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

    RegistroMedicacionConPrescripcion registroAux = RegistroMedicacionConPrescripcion(
      json['id_registro_medicacion_con_prescripcion'],
      DateTime.parse(json['fecha_pactada']),
      hora_pactada,
      json['cantidad_sugerida'],
      json['procesada'],
      prescripcionAux,
      json['descripcion'] ?? "",
      json['cantidad_dada'] ?? 0,
      hora_realizada,
    );
    return registroAux;
  }

  //Get Set
  int get idRegistroMedicacionConPrescripcion => _id_registro_medicacion_con_prescripcion;
  set idRegistroMedicacionConPrescripcion(int value) => _id_registro_medicacion_con_prescripcion = value;

  int get procesada => _procesada;
  set procesada(int value) => _procesada = value;

  DateTime get fecha_pactada => this._fecha_pactada;
  set fecha_pactada(DateTime value) => this._fecha_pactada = value;

  String get descripcion => _descripcion;
  set descripcion(String value) => _descripcion = value;

  PrescripcionDeMedicamento get prescripcion => _prescripcion;
  set prescripcion(PrescripcionDeMedicamento value) => _prescripcion = value;

  TimeOfDay get horaPactada => _hora_pactada;
  set horaPactada(TimeOfDay value) => _hora_pactada = value;

  TimeOfDay get horaDeRealizacion => _hora_de_realizacion;
  set horaDeRealizacion(TimeOfDay value) => _hora_de_realizacion = value;

  int get cantidadSugerida => _cantidad_sugerida;
  set cantidadSugerida(int value) => _cantidad_sugerida = value;

  int get cantidadDada => _cantidad_dada;
  set cantidadDada(int value) => _cantidad_dada = value;

  Enfermero get enfermero => _enfermero;
  set enfermero(Enfermero value) => _enfermero = value;

  DateTime get fecha_de_realizacion => this._fecha_de_realizacion;
  set fecha_de_realizacion(DateTime value) => this._fecha_de_realizacion = value;

  //Funciones
  static List<RegistroMedicacionConPrescripcion> listaVistaPrevia(List jsonList) {
    return jsonList.cast<Map<String, dynamic>>().map<RegistroMedicacionConPrescripcion>((json) => RegistroMedicacionConPrescripcion.fromJsonVistaPrevia(json)).toList();
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
}
