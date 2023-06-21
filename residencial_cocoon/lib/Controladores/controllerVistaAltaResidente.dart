import 'package:residencial_cocoon/Dominio/Exceptions/altaUsuarioException.dart';
import 'package:residencial_cocoon/Dominio/Modelo/familiar.dart';
import 'package:residencial_cocoon/Dominio/Modelo/sucurusal.dart';
import 'package:residencial_cocoon/Servicios/fachada.dart';

class ControllerVistaAltaResidente {
  //Atributos
  Function(String mensaje) mostrarMensaje;
  List<Sucursal>? _sucursales;

  //Constructor
  ControllerVistaAltaResidente({required this.mostrarMensaje});

  //Funciones
  Future<List<Sucursal>?> listaSucursales() async {
    if (this._sucursales == null) {
      this._sucursales = await Fachada.getInstancia()?.listaSucursales();
    }
    return this._sucursales;
  }

  Future<bool> altaUsuario(List<Familiar> familiares, String ci, String nombre,
      int? selectedSucursal) async {
    try {
      if (!_controlAltaUsuario(familiares, ci)) {
        mostrarMensaje(
            "El documento identificador del residente tiene que ser distinto al de los familiares.");
      } else if (!_controlPrimario(familiares)) {
        mostrarMensaje(
            "La lista de familiares tiene que tener por lo menos un familiar primario.");
      } else {
        await Fachada.getInstancia()
            ?.altaUsuarioResidente(familiares, ci, nombre, selectedSucursal);
      }
      return false;
    } on AltaUsuarioException catch (ex) {
      mostrarMensaje(ex.mensaje);
      return true;
    } on Exception catch (ex) {
      mostrarMensaje(ex.toString());
      return false;
    }
  }

  bool _controlAltaUsuario(List<Familiar> familiares, String ci) {
    bool resultado = true;
    familiares.forEach((fam) {
      if (fam.ci == ci) {
        resultado = false;
        return;
      }
    });
    return resultado;
  }

  bool _controlPrimario(List<Familiar> familiares) {
    bool resultado = false;
    familiares.forEach((fam) {
      if (fam.contactoPrimario == 1) {
        resultado = true;
        return;
      }
    });
    return resultado;
  }

  bool controlAltaFamiliar(Familiar familiares, List<Familiar> lista) {
    bool resultado = true;
    if (!familiares.esEmailValido()) {
      mostrarMensaje("El email del familiar no tiene el formato correcto.");
      resultado = false;
    }
    if (lista.contains(familiares)) {
      mostrarMensaje(
          "Ya hay un familiar con el documento identificador ingresado.");
      resultado = false;
    }
    return resultado;
  }
}
