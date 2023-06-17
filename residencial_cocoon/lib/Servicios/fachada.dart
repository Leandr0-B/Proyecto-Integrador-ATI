import 'package:residencial_cocoon/Dominio/Modelo/rol.dart';
import 'package:residencial_cocoon/Dominio/Modelo/sucurusal.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';
import 'package:residencial_cocoon/Servicios/servicioSucursal.dart';
import 'package:residencial_cocoon/Servicios/servicioUsuario.dart';

class Fachada {
  //Atributos
  Usuario? _usuario;
  static Fachada? _instancia;
  ServicioUsuario? _servicioUsuario;
  ServicioSucursal? _servicioSucursal;

  //Constructor
  Fachada._() {
    _servicioUsuario = ServicioUsuario();
    _servicioSucursal = ServicioSucursal();
  }

  static Fachada? getInstancia() {
    _instancia ??= Fachada._();
    return _instancia;
  }

  //Funciones
  //Usuario
  Future<Usuario?> login(String ci, String clave) async {
    return await _servicioUsuario?.login(ci, clave);
  }

  Usuario? getUsuario() {
    return this._usuario;
  }

  void setUsuario(Usuario? usuario) {
    this._usuario = usuario;
  }

  Future<List<Rol>?> listaRoles() async {
    return await _servicioUsuario?.listaRoles();
  }

  Future<void> altaUsuario(String ci, String nombre, int administrador,
      List<int> selectedRoles, List<int> selectedSucursales) async {
    await _servicioUsuario?.altaUsuario(
        ci, nombre, administrador, selectedRoles, selectedSucursales);
  }

  Future<List<Usuario>?> obtenerUsuarios() async {
    return await _servicioUsuario?.obtenerUsuarios();
  }

  //Sucursal
  Future<List<Sucursal>?> listaSucursales() async {
    return await _servicioSucursal?.listaSucursales();
  }
}
