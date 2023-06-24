class Sucursal {
  //Atributos
  int _idSucursal = 0;
  String _nombre = "";
  String _direccion = "";

  //Constructor
  Sucursal(this._idSucursal, this._nombre, this._direccion);

  factory Sucursal.fromJson(Map<String, dynamic> json) {
    return Sucursal(
      json['id_sucursal'],
      json['nombre'],
      json['direccion'],
    );
  }

  //Get set
  int get idSucursal => _idSucursal;
  set idSucursal(int value) => _idSucursal = value;

  String get nombre => _nombre;
  set nombre(String value) => _nombre = value;

  String get direccion => _direccion;
  set direccion(String value) => _direccion = value;

  //Funciones
  Map<String, dynamic> toJson() {
    return {
      'id_sucursal': _idSucursal,
      'nombre': _nombre,
      'direccion': _direccion,
    };
  }

  static List<Sucursal> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .cast<
            Map<String,
                dynamic>>() // cast the dynamic List to a List<Map<String, dynamic>>
        .map<Sucursal>(
            (json) => Sucursal.fromJson(json)) // convert each Map to a Rol
        .toList();
  }

  //ToString
  @override
  String toString() {
    String retorno = "";
    retorno += "idSucursal: $idSucursal, ";
    retorno += "nombre: $nombre, ";
    retorno += "direccion: $direccion";
    return retorno;
  }

  String toStringMostrar() {
    return "$_nombre direccion: $_direccion";
  }
}
