class SalidaMedica {
  //Atributos
  int _id_salida_medica = 0;
  String _descripcion = "";
  DateTime _fecha_desde = DateTime(0);
  DateTime _fecha_hasta = DateTime(0);

  //Constructor
  SalidaMedica(this._descripcion, this._fecha_desde, this._fecha_hasta);

  //Get Set
  int get idSalidaMedica => _id_salida_medica;
  set idSalidaMedica(int value) => _id_salida_medica = value;

  String get descripcion => _descripcion;
  set descripcion(String value) => _descripcion = value;

  DateTime get fechaDesde => _fecha_desde;
  set fechaDesde(DateTime value) => _fecha_desde = value;

  DateTime get fechaHasta => _fecha_hasta;
  set fechaHasta(DateTime value) => _fecha_hasta = value;
  //Funciones
}
