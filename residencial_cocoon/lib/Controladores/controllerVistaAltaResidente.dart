import 'package:residencial_cocoon/Dominio/Exceptions/altaUsuarioException.dart';
import 'package:residencial_cocoon/Dominio/Exceptions/tokenException.dart';
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
    try {
      if (this._sucursales == null) {
        this._sucursales = await Fachada.getInstancia()?.listaSucursales();
      }
      return this._sucursales;
    } on TokenException catch (e) {
      _cerrarSesion(e.toString());
    }
  }

  Future<void> altaUsuario(List<Familiar> familiares, String ci, String nombre, int? selectedSucursal, String apellido, DateTime? fechaNacimiento) async {
    nombre = _capitalize(nombre);
    apellido = _capitalize(apellido);
    try {
      if (selectedSucursal == null) {
        _vistaAlta?.mostrarMensajeError("Tiene que seleccionar una sucursal.");
      } else if (!_controlAltaUsuario(familiares, ci)) {
        _vistaAlta?.mostrarMensajeError("El documento identificador del residente tiene que ser distinto al de los familiares.");
      } else if (!_controlPrimario(familiares)) {
        _vistaAlta?.mostrarMensajeError("La lista de familiares tiene que tener por lo menos un familiar primario.");
      } else if (fechaNacimiento == null) {
        _vistaAlta?.mostrarMensajeError("Tiene que seleccionar la fecha de nacimiento.");
      } else {
        await Fachada.getInstancia()?.altaUsuarioResidente(familiares, ci, nombre, selectedSucursal, apellido, fechaNacimiento);
      }
    } on AltaUsuarioException catch (ex) {
      _vistaAlta?.mostrarMensaje(ex.mensaje);
      _vistaAlta?.limpiarDatos();
    } on TokenException catch (ex) {
      _cerrarSesion(ex.toString());
    } on Exception catch (ex) {
      _vistaAlta?.mostrarMensajeError(ex.toString());
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
      _vistaAlta?.mostrarMensajeError("El email del familiar no tiene el formato correcto.");
      return false;
    }
    if (lista.contains(familiar)) {
      _vistaAlta?.mostrarMensajeError("Ya hay un familiar con el documento identificador ingresado.");
      return false;
    }
    familiar.capitalizeAll();
    lista.add(familiar);
    _vistaAlta?.limpiarDatosFamiliar();
    return true;
  }

  void eliminarFamiliar(List<Familiar> lista, int index) {
    lista.removeAt(index);
  }

  bool mostrarPrimario(List<Familiar>? lista) {
    return lista == null || lista!.isEmpty || lista!.every((familiar) => familiar.contactoPrimario != 1);
  }

  void _cerrarSesion(String mensaje) {
    _vistaAlta?.mostrarMensajeError(mensaje);
    _vistaAlta?.cerrarSesion();
  }

  String _capitalize(String text) {
    List<String> words = text.split(' ');
    for (int i = 0; i < words.length; i++) {
      String word = words[i];
      if (word.isNotEmpty) {
        words[i] = word[0].toUpperCase() + word.substring(1);
      }
    }
    return words.join(' ');
  }
}
