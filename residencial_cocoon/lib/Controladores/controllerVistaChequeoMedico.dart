import 'package:flutter/material.dart';
import 'package:residencial_cocoon/Dominio/Exceptions/chequeoMedicoException.dart';
import 'package:residencial_cocoon/Dominio/Exceptions/tokenException.dart';
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
    try {
      if (this._controles == null) {
        this._controles = await Fachada.getInstancia()?.listaControles();
      }
      return this._controles;
    } on TokenException catch (e) {
      _cerrarSesion(e.toString());
    }
  }

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

  Future<void> altaChequeoMedico(
      Sucursal? selectedSucursal, Usuario? selectedResidente, List<Control?> selectedControles, DateTime? fecha, TimeOfDay? hora, String descripcion, bool agregarControles) async {
    try {
      if (_controlesDatos(fecha, hora, selectedSucursal, selectedResidente, descripcion, selectedControles, agregarControles)) {
        await Fachada.getInstancia()?.altaChequeoMedico(selectedResidente, selectedControles, fecha, hora, descripcion);
      }
    } on ChequeoMedicoException catch (e) {
      _vistaChequeo?.mostrarMensaje(e.toString());
      _vistaChequeo?.limpiar();
    } on TokenException catch (e) {
      _cerrarSesion(e.toString());
    } on Exception catch (e) {
      _vistaChequeo?.mostrarMensajeError(e.toString());
    }
  }

  bool _controlesDatos(
      DateTime? fecha, TimeOfDay? hora, Sucursal? selectedSucursal, Usuario? residenteSeleccionado, String descripcion, List<Control?> selectedControles, bool agregarControles) {
    if (fecha == null) {
      _vistaChequeo?.mostrarMensajeError("Tiene que seleccionar la fecha.");
      return false;
    } else if (hora == null) {
      _vistaChequeo?.mostrarMensajeError("Tiene que seleccionar la hora.");
      return false;
    }
    if (selectedSucursal == null) {
      _vistaChequeo?.mostrarMensajeError("Tiene que seleccionar una sucursal.");
      return false;
    } else if (residenteSeleccionado == null) {
      _vistaChequeo?.mostrarMensajeError("Tiene que seleccionar un residente.");
      return false;
    } else if (agregarControles && selectedControles.isEmpty) {
      _vistaChequeo?.mostrarMensajeError("Tiene que seleccionar por lo menos un control.");
      return false;
    }
    return true;
  }

  void altaSelectedControl(Control? control, double primerValor, double segundoValor, List<Control?> selectedControl) {
    if (control != null) {
      if (control.valor_compuesto == 0) {
        control = Control.noCompuesto(control.id_control, control.unidad, control.nombre, primerValor);
      } else {
        control = Control.compuesto(control.id_control, control.unidad, control.nombre, primerValor, segundoValor);
      }
      if (!selectedControl.contains(control)) {
        selectedControl.add(control);
      } else {
        _vistaChequeo?.mostrarMensajeError("Ya ingresaste el control: " + control.nombre);
      }
    } else {
      _vistaChequeo?.mostrarMensajeError("Seleccione un control de la lista");
    }
  }

  void _cerrarSesion(String mensaje) {
    _vistaChequeo?.mostrarMensajeError(mensaje);
    _vistaChequeo?.cerrarSesion();
  }
}
