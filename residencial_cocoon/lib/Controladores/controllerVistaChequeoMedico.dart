import 'package:residencial_cocoon/Dominio/Exceptions/chequeoMedicoException.dart';
import 'package:residencial_cocoon/Dominio/Modelo/control.dart';
import 'package:residencial_cocoon/Dominio/Modelo/sucurusal.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';
import 'package:residencial_cocoon/Servicios/fachada.dart';
import 'package:residencial_cocoon/UI/Geriatra/iVistaChequeoMedico.dart';

class ControllerVistaChequeoMedico {
  //Atributos
  IvistaChequeoMedico? _vistaChequeo;
  List<Sucursal>? _sucursales;
  List<Control>? _controles;
  Sucursal? _selectedSucursal;
  List<Usuario>? _residentes;

  //Constructor
  ControllerVistaChequeoMedico.empty();
  ControllerVistaChequeoMedico(this._vistaChequeo);

  //Funciones
  Future<List<Control>?> listaControles() async {
    if (this._controles == null) {
      this._controles = await Fachada.getInstancia()?.listaControles();
    }
    return this._controles;
  }

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
    _sucursales ??= Fachada.getInstancia()?.getUsuario()?.sucursales;
    return _sucursales;
  }

  Future<void> altaChequeoMedico(
      Sucursal? selectedSucursal,
      Usuario? selectedResidente,
      List<Control?> selectedControles,
      DateTime? fecha,
      String descripcion) async {
    try {
      if (_controlesDatos(
          fecha, selectedSucursal, selectedResidente, descripcion)) {
        await Fachada.getInstancia()?.altaChequeoMedico(
            selectedResidente, selectedControles, fecha, descripcion);
      }
    } on ChequeoMedicoException catch (e) {
      _vistaChequeo?.mostrarMensaje(e.toString());
      _vistaChequeo?.limpiar();
    } on Exception catch (e) {
      _vistaChequeo?.mostrarMensaje(e.toString());
    }
  }

  bool _controlesDatos(DateTime? fecha, Sucursal? selectedSucursal,
      Usuario? residenteSeleccionado, String descripcion) {
    if (descripcion == null || descripcion == "") {
      _vistaChequeo?.mostrarMensaje("Tiene que ingresar una descripción.");
      return false;
    } else if (descripcion == null || descripcion == "") {
      _vistaChequeo?.mostrarMensaje("Tiene que ingresar una descripción.");
      return false;
    } else if (fecha == null) {
      _vistaChequeo?.mostrarMensaje("Tiene que seleccionar la fecha.");
      return false;
    }
    if (selectedSucursal == null) {
      _vistaChequeo?.mostrarMensaje("Tiene que seleccionar una sucursal.");
      return false;
    } else if (residenteSeleccionado == null) {
      _vistaChequeo?.mostrarMensaje("Tiene que seleccionar un residente.");
      return false;
    }
    return true;
  }

  void altaSelectedControl(
      Control? control, String valor, List<Control?> selectedControl) {
    if (control != null) {
      control = Control.sinUnidad(control.id_control, control.nombre, valor);
      if (!selectedControl.contains(control)) {
        selectedControl.add(control);
      } else {
        _vistaChequeo
            ?.mostrarMensaje("Ya ingresaste el control: " + control.nombre);
      }
    } else {
      _vistaChequeo?.mostrarMensaje("Seleccione un control de la lista");
    }
  }
}
