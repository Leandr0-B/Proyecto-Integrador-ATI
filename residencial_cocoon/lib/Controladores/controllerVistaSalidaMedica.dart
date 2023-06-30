import 'package:residencial_cocoon/Dominio/Exceptions/salidaMedicaException.dart';
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
  }

  List<Sucursal>? listaSucursales() {
    try {
      _sucursales ??= Fachada.getInstancia()?.getUsuario()?.sucursales;
      return _sucursales;
    } catch (e) {
      _vistaSalida?.mostrarMensaje(e.toString());
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
      _vistaSalida?.mostrarMensaje(e.toString());
      _vistaSalida?.limpiar();
    } on Exception catch (e) {
      _vistaSalida?.mostrarMensaje(e.toString());
    }
  }

  bool _controles(DateTime? fechaDesde, DateTime? fechaHasta,
      Sucursal? selectedSucursal, Usuario? residenteSeleccionado) {
    if (fechaDesde == null) {
      _vistaSalida?.mostrarMensaje("Tiene que seleccionar una fecha desde.");
      return false;
    } else if (fechaHasta == null) {
      _vistaSalida?.mostrarMensaje("Tiene que seleccionar una fecha hasta.");
      return false;
    } else if (fechaDesde.isAfter(fechaHasta)) {
      _vistaSalida?.mostrarMensaje(
          "La fecha desde no puede ser mayor a la fecha hasta.");
      return false;
    }
    if (selectedSucursal == null) {
      _vistaSalida?.mostrarMensaje("Tiene que seleccionar una sucursal.");
      return false;
    } else if (residenteSeleccionado == null) {
      _vistaSalida?.mostrarMensaje("Tiene que seleccionar un residente.");
      return false;
    }
    return true;
  }
}
