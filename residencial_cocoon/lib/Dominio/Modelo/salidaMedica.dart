class SalidaMedica {
  //Atributos
  int? _id_salida_medica;
  String _descripcion;
  DateTime _fecha_desde;
  DateTime _fecha_hasta;

  //Constructor
  SalidaMedica(
      {required String descripcion,
      required DateTime fecha_desde,
      required DateTime fecha_hasta})
      : _descripcion = descripcion,
        _fecha_desde = fecha_desde,
        _fecha_hasta = fecha_hasta;

  //Get Set

  //Funciones
}
