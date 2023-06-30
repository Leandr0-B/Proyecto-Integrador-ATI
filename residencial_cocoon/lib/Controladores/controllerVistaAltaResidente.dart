import 'package:residencial_cocoon/Dominio/Exceptions/altaUsuarioException.dart';
import 'package:residencial_cocoon/Dominio/Modelo/familiar.dart';
import 'package:residencial_cocoon/Dominio/Modelo/sucurusal.dart';
import 'package:residencial_cocoon/Servicios/fachada.dart';
import 'package:residencial_cocoon/UI/Usuarios/iVistaAltaResidente.dart';

class ControllerVistaAltaResidente {
  //Atributos
  List<Sucursal>? _sucursales;
  IvistaAltaResidente? _vistaAlta;

  //Constructor
  ControllerVistaAltaResidente.empty();
  ControllerVistaAltaResidente(this._vistaAlta);

  //Funciones
  Future<List<Sucursal>?> listaSucursales() async {
    if (this._sucursales == null) {
      this._sucursales = await Fachada.getInstancia()?.listaSucursales();
    }
    return this._sucursales;
  }

  Future<void> altaUsuario(List<Familiar> familiares, String ci, String nombre,
      int? selectedSucursal) async {
    try {
      if (!_controlAltaUsuario(familiares, ci)) {
        _vistaAlta?.mostrarMensaje(
            "El documento identificador del residente tiene que ser distinto al de los familiares.");
      } else if (!_controlPrimario(familiares)) {
        _vistaAlta?.mostrarMensaje(
            "La lista de familiares tiene que tener por lo menos un familiar primario.");
      } else {
        await Fachada.getInstancia()
            ?.altaUsuarioResidente(familiares, ci, nombre, selectedSucursal);
      }
    } on AltaUsuarioException catch (ex) {
      _vistaAlta?.mostrarMensaje(ex.mensaje);
      _vistaAlta?.limpiarDatos();
    } on Exception catch (ex) {
      _vistaAlta?.mostrarMensaje(ex.toString());
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

  bool controlAltaFamiliar(Familiar familiar, List<Familiar> lista) {
    if (!familiar.esEmailValido()) {
      _vistaAlta?.mostrarMensaje(
          "El email del familiar no tiene el formato correcto.");
      return false;
    }
    if (lista.contains(familiar)) {
      _vistaAlta?.mostrarMensaje(
          "Ya hay un familiar con el documento identificador ingresado.");
      return false;
    }
    lista.add(familiar);
    return true;
  }

  void eliminarFamiliar(List<Familiar> lista, int index) {
    lista.removeAt(index);
  }

  bool mostrarPrimario(List<Familiar>? lista) {
    return lista == null ||
        lista!.isEmpty ||
        lista!.every((familiar) => familiar.contactoPrimario != 1);
  }
}
