class Rol {
  //Atributos
  int _idRol;
  String _descripcion;

  //Constructores
  Rol({required int idRol, required String descripcion})
      : _idRol = idRol,
        _descripcion = descripcion;

  Rol.id(int idRol)
      : _idRol = idRol,
        _descripcion = "";

  factory Rol.fromJson(Map<String, dynamic> json) {
    return Rol(
      idRol: json['id_rol'],
      descripcion: json['descripcion'],
    );
  }

  //Get Set
  int get idRol => _idRol;
  set idRol(int value) => _idRol = value;

  String get descripcion => _descripcion;
  set descripcion(String value) => _descripcion = value;

  //Funciones
  Map<String, dynamic> toJson() {
    return {
      'id_rol': _idRol,
      'descripcion': _descripcion,
    };
  }

  Map<String, dynamic> toIdJson() {
    return {
      'id_rol': _idRol,
    };
  }

  static List<Rol> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .cast<Map<String, dynamic>>()
        .map<Rol>((json) => Rol.fromJson(json))
        .toList();
  }

  //ToString
  @override
  String toString() {
    return toJson().toString();
  }

  //Equals
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Rol && _idRol == other.idRol;
  }

  @override
  int get hashCode => _idRol.hashCode;
}
