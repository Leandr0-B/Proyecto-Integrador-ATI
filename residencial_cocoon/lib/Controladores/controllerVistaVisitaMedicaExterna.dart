import 'package:residencial_cocoon/Dominio/Exceptions/visitaMedicaExternaException.dart';
import 'package:residencial_cocoon/Dominio/Modelo/sucurusal.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';
import 'package:residencial_cocoon/Servicios/fachada.dart';

class ControllerVistaVisitaMedicaExterna {
  //Atributos
  Function(String mensaje) mostrarMensaje;
  Function() limpiar;
  List<Sucursal>? _sucursales;

  //Constructor
  ControllerVistaVisitaMedicaExterna(
    this.mostrarMensaje,
    this.limpiar,
  );

  //Funciones
  Future<List<Usuario>?> listaResidentes(Sucursal? suc) async {
    return await Fachada.getInstancia()?.residentesSucursal(suc);
  }

  List<Sucursal>? listaSucursales() {
    try {
      _sucursales ??= Fachada.getInstancia()?.getUsuario()?.sucursales;
      return _sucursales;
    } catch (e) {
      mostrarMensaje(e.toString());
    }
  }

  Future<void> altaVisitaMedicaExt(Usuario? selectedResidente,
      String descripcion, DateTime? fecha, Sucursal? selectedSucursal) async {
    try {
      if (_controles(fecha, selectedSucursal, selectedResidente)) {
        await Fachada.getInstancia()
            ?.altaVisitaMedicaExt(selectedResidente, descripcion, fecha);
      }
    } on visitaMedicaExternaException catch (e) {
      mostrarMensaje(e.toString());
      limpiar();
    } on Exception catch (e) {
      mostrarMensaje(e.toString());
    }
  }

  bool _controles(DateTime? fecha, Sucursal? selectedSucursal,
      Usuario? residenteSeleccionado) {
    if (fecha == null) {
      mostrarMensaje("Tiene que seleccionar la fecha.");
      return false;
    }
    if (selectedSucursal == null) {
      mostrarMensaje("Tiene que seleccionar una sucursal.");
      return false;
    } else if (residenteSeleccionado == null) {
      mostrarMensaje("Tiene que seleccionar un residente.");
      return false;
    }
    return true;
  }
}
