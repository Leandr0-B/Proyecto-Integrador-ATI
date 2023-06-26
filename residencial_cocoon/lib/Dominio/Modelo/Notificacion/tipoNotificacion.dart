class TipoNotificacion {
  //Atributos
  int _idTipoNotificacion = 0;
  String _nombre = "";

  //Constructor
  TipoNotificacion(this._idTipoNotificacion, this._nombre);

  TipoNotificacion.empty();

  factory TipoNotificacion.fromJson(Map<String, dynamic> json) {
    return TipoNotificacion(
      json['id_tipo_notificacion'],
      json['nombre_tipo'],
    );
  }

  //Get set
  int get idTipoNotificacion => _idTipoNotificacion;
  set idTipoNotificacion(int value) => _idTipoNotificacion = value;

  String get nombre => _nombre;
  set nombre(String value) => _nombre = value;

  static List<TipoNotificacion> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .cast<Map<String, dynamic>>()
        .map<TipoNotificacion>((json) => TipoNotificacion.fromJson(json))
        .toList();
  }

  //ToString
  @override
  String toString() {
    String retorno = "";
    retorno += "idTipoNotificacion: $idTipoNotificacion, ";
    retorno += "nombre: $nombre, ";
    return retorno;
  }
}
