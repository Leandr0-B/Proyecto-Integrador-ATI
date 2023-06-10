import 'package:residencial_cocoon/Modelo/rol.dart';

class Usuario {
  //Atributos
  String? nombre;
  String? apellido;
  String? contrasenia;
  String? ci;
  bool? inactivo;
  List<Rol>? roles;

  //Constructor
  Usuario.obtener(String nombre, String apellido, String ci, bool inactivo,
      List<Rol> roles) {
    this.nombre = nombre;
    this.apellido = apellido;
    this.ci = ci;
    this.inactivo = inactivo;
    this.roles = roles;
  }

  Usuario.login(String ci, String contrasenia) {
    this.ci = ci;
    this.contrasenia = contrasenia;
  }

  //Get Set
  String? get getNombre => this.nombre;

  set setNombre(String? nombre) => this.nombre = nombre;

  String? get getApellido => this.apellido;

  set setApellido(apellido) => this.apellido = apellido;

  String? get getContrasenia => this.contrasenia;

  set setContrasenia(contrasenia) => this.contrasenia = contrasenia;

  String? get getCi => this.ci;

  set setCi(ci) => this.ci = ci;

  bool? get getInactivo => this.inactivo;

  set setInactivo(inactivo) => this.inactivo = inactivo;

  List<Rol>? get getRoles => this.roles;

  set setRoles(List<Rol>? roles) => this.roles = roles;
}
