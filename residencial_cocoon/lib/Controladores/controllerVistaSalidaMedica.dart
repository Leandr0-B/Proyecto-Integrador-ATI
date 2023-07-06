import 'package:residencial_cocoon/Dominio/Exceptions/salidaMedicaException.dart';
import 'package:residencial_cocoon/Dominio/Exceptions/tokenException.dart';
import 'package:residencial_cocoon/Dominio/Modelo/sucurusal.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';
import 'package:residencial_cocoon/Servicios/fachada.dart';
import 'package:residencial_cocoon/UI/Geriatra/iVistaSalidaMedica.dart';

class ControllerVistaSalidaMedica {
  //Atributos
  IvistaSalidaMedica? _vistaSalida;
  List<Sucursal>? _sucursales;
  Sucursal? _selectedSucursal;
  List<Usuario>? _residentes;

  //Constructor
  ControllerVistaSalidaMedica(this._vistaSalida);
  ControllerVistaSalidaMedica.empty();

  //Funciones
  Future<List<Usuario>?> listaResidentes(Sucursal? suc) async {
    try {
      if (suc != null) {
        if (suc != _selectedSucursal) {
          _residentes = await Fachada.getInstancia()?.residentesSucursal(suc);
          _selectedSucursal = suc;
          return _residentes;
        } else {
          return _residentes;
        }
      }
      return [];
    } on TokenException catch (e) {
      _cerrarSesion(e.toString());
    }
  }

  List<Sucursal>? listaSucursales() {
    _sucursales ??= Fachada.getInstancia()?.getUsuario()?.sucursales;
    return _sucursales;
  }

  Future<void> altaSalidaMedica(
      Usuario? selectedResidente,
      String descripcion,
      DateTime? fechaDesde,
      DateTime? fechaHasta,
      Sucursal? selectedSucursal) async {
    try {
      if (_controles(fechaDesde, fechaHasta, selectedSucursal,
          selectedResidente, descripcion)) {
        await Fachada.getInstancia()?.altaSalidaMedica(
            selectedResidente, descripcion, fechaDesde, fechaHasta);
      }
    } on SalidaMedicaException catch (e) {
      _vistaSalida?.mostrarMensaje(e.toString());
      _vistaSalida?.limpiar();
    } on TokenException catch (e) {
      _cerrarSesion(e.toString());
    } on Exception catch (e) {
      _vistaSalida?.mostrarMensajeError(e.toString());
    }
  }

  bool _controles(
      DateTime? fechaDesde,
      DateTime? fechaHasta,
      Sucursal? selectedSucursal,
      Usuario? residenteSeleccionado,
      String descripcion) {
    if (descripcion == null || descripcion == "") {
      _vistaSalida?.mostrarMensajeError("Tiene que ingresar una descripción.");
      return false;
    } else if (fechaDesde == null) {
      _vistaSalida
          ?.mostrarMensajeError("Tiene que seleccionar una fecha desde.");
      return false;
    } else if (fechaHasta == null) {
      _vistaSalida
          ?.mostrarMensajeError("Tiene que seleccionar una fecha hasta.");
      return false;
    } else if (fechaDesde.isAfter(fechaHasta)) {
      _vistaSalida?.mostrarMensajeError(
          "La fecha desde no puede ser mayor a la fecha hasta.");
      return false;
    }
    if (selectedSucursal == null) {
      _vistaSalida?.mostrarMensajeError("Tiene que seleccionar una sucursal.");
      return false;
    } else if (residenteSeleccionado == null) {
      _vistaSalida?.mostrarMensajeError("Tiene que seleccionar un residente.");
      return false;
    }
    return true;
  }

  void _cerrarSesion(String mensaje) {
    _vistaSalida?.mostrarMensajeError(mensaje);
    _vistaSalida?.cerrarSesion();
  }
}
