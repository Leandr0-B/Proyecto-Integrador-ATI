import 'package:residencial_cocoon/Dominio/Exceptions/visitaMedicaExternaException.dart';
import 'package:residencial_cocoon/Dominio/Modelo/sucurusal.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';
import 'package:residencial_cocoon/Servicios/fachada.dart';
import 'package:residencial_cocoon/UI/Geriatra/iVistaVisitaMedicaExterna.dart';

class ControllerVistaVisitaMedicaExterna {
  //Atributos
  List<Sucursal>? _sucursales;
  IvistaVisitaMedicaExterna? vistaVisita;
  Sucursal? _selectedSucursal;
  List<Usuario>? _residentes;

  //Constructor
  ControllerVistaVisitaMedicaExterna(this.vistaVisita);
  ControllerVistaVisitaMedicaExterna.empty();

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
      vistaVisita?.mostrarMensaje(e.toString());
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
      vistaVisita?.mostrarMensaje(e.toString());
      vistaVisita?.limpiar();
    } on Exception catch (e) {
      vistaVisita?.mostrarMensaje(e.toString());
    }
  }

  bool _controles(DateTime? fecha, Sucursal? selectedSucursal,
      Usuario? residenteSeleccionado) {
    if (fecha == null) {
      vistaVisita?.mostrarMensaje("Tiene que seleccionar la fecha.");
      return false;
    }
    if (selectedSucursal == null) {
      vistaVisita?.mostrarMensaje("Tiene que seleccionar una sucursal.");
      return false;
    } else if (residenteSeleccionado == null) {
      vistaVisita?.mostrarMensaje("Tiene que seleccionar un residente.");
      return false;
    }
    return true;
  }
}
