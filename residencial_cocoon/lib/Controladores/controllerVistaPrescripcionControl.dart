import 'package:flutter/src/material/time.dart';
import 'package:residencial_cocoon/Dominio/Exceptions/controlException.dart';
import 'package:residencial_cocoon/Dominio/Exceptions/prescripcionControlException.dart';
import 'package:residencial_cocoon/Dominio/Exceptions/tokenException.dart';
import 'package:residencial_cocoon/Dominio/Modelo/control.dart';
import 'package:residencial_cocoon/Dominio/Modelo/sucurusal.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';
import 'package:residencial_cocoon/Servicios/fachada.dart';
import 'package:residencial_cocoon/UI/Chequeo/iVistaPrescripcionControl.dart';

class ControllerVistaPrescripcionControl {
  //Atributos
  IvistaPrescripcionControl? _vista;
  List<Sucursal>? _sucursales;
  Sucursal? _selectedSucursal;
  List<Usuario>? _residentes;

  //Constructor
  ControllerVistaPrescripcionControl.empty();
  ControllerVistaPrescripcionControl(this._vista);

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

  Future<List<Control>?> listaControles() async {
    try {
      return await Fachada.getInstancia()?.listaControles();
    } on TokenException catch (e) {
      _cerrarSesion(e.toString());
    }
  }

  List<Sucursal>? listaSucursales() {
    _sucursales ??= Fachada.getInstancia()?.getUsuario()?.sucursales;
    return _sucursales;
  }

  void _cerrarSesion(String mensaje) {
    _vista?.mostrarMensajeError(mensaje);
    _vista?.cerrarSesion();
  }

  Future<void> registrarControl(String nombreControl, String unidadControl, int compuestoControl, double valorReferenciaMinimo, double valorReferenciaMaximo,
      double maximoValorReferenciaMinimo, double maximoValorReferenciaMaximo) async {
    try {
      if (_controlesControl(compuestoControl, valorReferenciaMinimo, valorReferenciaMaximo, maximoValorReferenciaMinimo, maximoValorReferenciaMaximo)) {
        await Fachada.getInstancia()?.registrarControl(
            nombreControl, unidadControl, compuestoControl, valorReferenciaMinimo, valorReferenciaMaximo, maximoValorReferenciaMinimo, maximoValorReferenciaMaximo);
      }
    } on TokenException catch (e) {
      _cerrarSesion(e.toString());
    } on ControlException catch (e) {
      _vista?.mostrarMensaje(e.toString());
      _vista?.limpiarControl();
    } on Exception catch (e) {
      _vista?.mostrarMensajeError(e.toString());
    }
  }

  bool _controlesControl(int compuestoControl, double valorReferenciaMinimo, double valorReferenciaMaximo, double maximoValorReferenciaMinimo, double maximoValorReferenciaMaximo) {
    if (compuestoControl == 0) {
      if (valorReferenciaMinimo > valorReferenciaMaximo) {
        _vista?.mostrarMensajeError("Valor minimo no puede ser mayor al valor maximo.");
        return false;
      }
    } else {
      if (valorReferenciaMinimo > valorReferenciaMaximo) {
        _vista?.mostrarMensajeError("Valor minimo1 no puede ser mayor al valor maximo1.");
        return false;
      }
      if (maximoValorReferenciaMinimo > maximoValorReferenciaMaximo) {
        _vista?.mostrarMensajeError("Valor minimo2 no puede ser mayor al valor maximo2.");
        return false;
      }
    }
    return true;
  }

  Future<void> altaPrescripcion(List<Control?> selectedControles, Usuario? selectedResidente, Sucursal? selectedSucursal, String descripcion, int frecuencia,
      int prescripcionCronica, TimeOfDay? horaComienzo, int duracion) async {
    try {
      if (_controlesPrescripcion(selectedResidente, selectedSucursal, selectedControles, horaComienzo)) {
        await Fachada.getInstancia()
            ?.registrarPrescripcionControl(selectedResidente, selectedSucursal, selectedControles, horaComienzo, descripcion, frecuencia, prescripcionCronica, duracion);
      }
    } on TokenException catch (e) {
      _cerrarSesion(e.toString());
    } on PrescripcionControlException catch (e) {
      _vista?.mostrarMensaje(e.toString());
      _vista?.limpiar();
    } on Exception catch (e) {
      _vista?.mostrarMensajeError(e.toString());
    }
  }

  bool _controlesPrescripcion(Usuario? selectedResidente, Sucursal? selectedSucursal, List<Control?> selectedControles, TimeOfDay? horaComienzo) {
    if (selectedSucursal == null) {
      _vista?.mostrarMensajeError("Tiene que seleccionar una sucursal.");
      return false;
    } else if (selectedResidente == null) {
      _vista?.mostrarMensajeError("Tiene que seleccionar un residente.");
      return false;
    } else if (selectedControles.isEmpty) {
      _vista?.mostrarMensajeError("Tiene que seleccionar los controles.");
      return false;
    } else if (horaComienzo == null) {
      _vista?.mostrarMensajeError("Tiene que seleccionar un hora de comienzo.");
      return false;
    }
    return true;
  }
}
