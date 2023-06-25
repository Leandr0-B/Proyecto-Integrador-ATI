import 'package:residencial_cocoon/Dominio/Exceptions/salidaMedicaException.dart';
import 'package:residencial_cocoon/Dominio/Modelo/sucurusal.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';
import 'package:residencial_cocoon/Servicios/fachada.dart';

class ControllerVistaSalidaMedica {
  //Atributos
  Function(String mensaje) mostrarMensaje;
  Function() limpiar;
  List<Sucursal>? _sucursales;

  //Constructor
  ControllerVistaSalidaMedica(
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

  Future<void> altaSalidaMedica(
      Usuario? selectedResidente,
      String descripcion,
      DateTime? fechaDesde,
      DateTime? fechaHasta,
      Sucursal? selectedSucursal) async {
    try {
      if (_controles(
          fechaDesde, fechaHasta, selectedSucursal, selectedResidente)) {
        await Fachada.getInstancia()?.altaSalidaMedica(
            selectedResidente, descripcion, fechaDesde, fechaHasta);
      }
    } on SalidaMedicaException catch (e) {
      mostrarMensaje(e.toString());
      limpiar();
    } on Exception catch (e) {
      mostrarMensaje(e.toString());
    }
  }

  bool _controles(DateTime? fechaDesde, DateTime? fechaHasta,
      Sucursal? selectedSucursal, Usuario? residenteSeleccionado) {
    if (fechaDesde == null) {
      mostrarMensaje("Tiene que seleccionar una fecha desde.");
      return false;
    } else if (fechaHasta == null) {
      mostrarMensaje("Tiene que seleccionar una fecha hasta.");
      return false;
    } else if (fechaDesde.isAfter(fechaHasta)) {
      mostrarMensaje("La fecha desde no puede ser mayor a la fecha hasta.");
      return false;
    }
    if (residenteSeleccionado == null) {
      mostrarMensaje("Tiene que seleccionar un residente.");
      return false;
    } else if (selectedSucursal == null) {
      mostrarMensaje("Tiene que seleccionar una sucursal.");
      return false;
    }
    return true;
  }
}
