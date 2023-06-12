class Rol {
  int _idRol;
  String _descripcion;

  Rol({required int idRol, required String descripcion})
      : _idRol = idRol,
        _descripcion = descripcion;

  Rol.id(int idRol)
      : _idRol = idRol,
        _descripcion = "";

  int get idRol => _idRol;
  set idRol(int value) => _idRol = value;

  String get descripcion => _descripcion;
  set descripcion(String value) => _descripcion = value;

  factory Rol.fromJson(Map<String, dynamic> json) {
    return Rol(
      idRol: json['id_rol'],
      descripcion: json['descripcion'],
    );
  }

  @override
  String toString() {
    return 'Rol(idRol: $_idRol, descripcion: $_descripcion)';
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
