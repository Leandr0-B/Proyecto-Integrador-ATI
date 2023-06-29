import 'package:residencial_cocoon/Dominio/Exceptions/chequeoMedicoException.dart';
import 'package:residencial_cocoon/Dominio/Modelo/control.dart';
import 'package:residencial_cocoon/Dominio/Modelo/residente.dart';
import 'package:residencial_cocoon/Dominio/Modelo/sucurusal.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';
import 'package:residencial_cocoon/Servicios/fachada.dart';

class ControllerVistaChequeoMedico {
  //Atributos
  Function(String mensaje) mostrarMensaje;
  Function() limpiar;
  List<Sucursal>? _sucursales;
  List<Control>? _controles;
  List<Control> _controlesCargados = [];

  //Constructor
  ControllerVistaChequeoMedico(
    this.mostrarMensaje,
    this.limpiar,
  );

  //Funciones
  Future<List<Control>?> listaControles() async {
    if (this._controles == null) {
      this._controles = await Fachada.getInstancia()?.listaControles();
    }
    return this._controles;
  }

  Future<List<Usuario>?> listaResidentes(Sucursal? suc) async {
    return await Fachada.getInstancia()?.residentesSucursal(suc);
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
      if (_controlesDatos(fecha, selectedSucursal, selectedResidente)) {
        await Fachada.getInstancia()?.altaChequeoMedico(
            selectedResidente, selectedControles, fecha, descripcion);
      }
    } on ChequeoMedicoException catch (e) {
      mostrarMensaje(e.toString());
      limpiar();
    } on Exception catch (e) {
      mostrarMensaje(e.toString());
    }
  }

  bool _controlesDatos(DateTime? fecha, Sucursal? selectedSucursal,
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

  void altaSelectedControl(Control? control, List<Control?> selectedControl) {
    if (control != null) {
      if (!selectedControl.contains(control)) {
        selectedControl.add(control);
      } else {
        mostrarMensaje("Ya ingresaste el control: " + control.nombre);
      }
    } else {
      mostrarMensaje("Seleccione un control de la lista");
    }
  }
}
