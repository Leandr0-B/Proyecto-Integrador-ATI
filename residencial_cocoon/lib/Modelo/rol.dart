class Rol {
  //Atributos
  int? id_Rol;
  String? descripcion;
  bool? inactivo;

  //Constructor
  Rol(int id_Rol, String descripcion, bool inactivo) {
    this.id_Rol = id_Rol;
    this.descripcion = descripcion;
    this.inactivo = inactivo;
  }

  //Get Set
  int? get idRol => this.id_Rol;

  String? get getDescripcion => this.descripcion;

  bool? get getInactivo => this.inactivo;
}
