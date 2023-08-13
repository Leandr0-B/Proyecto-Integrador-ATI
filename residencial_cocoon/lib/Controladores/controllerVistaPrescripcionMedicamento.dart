import 'package:flutter/material.dart';
import 'package:residencial_cocoon/Dominio/Exceptions/asociarMedicamentoException.dart';
import 'package:residencial_cocoon/Dominio/Exceptions/prescripcionMedicamentoException.dart';
import 'package:residencial_cocoon/Dominio/Exceptions/tokenException.dart';
import 'package:residencial_cocoon/Dominio/Modelo/Medicacion/medicamento.dart';
import 'package:residencial_cocoon/Dominio/Modelo/sucurusal.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';
import 'package:residencial_cocoon/Servicios/fachada.dart';
import 'package:residencial_cocoon/UI/Medicamentos/iVistaAsociarMedicamentoResidente.dart';
import 'package:residencial_cocoon/UI/Medicamentos/iVistaPrescripcionMedicamento.dart';

class ControllerVistaPrescripcionMedicamento {
  //Atributos
  IvistaPrescripcionMedicamento? _vista;
  List<Sucursal>? _sucursales;
  Sucursal? _selectedSucursal;
  List<Usuario>? _residentes;
  List<Medicamento>? _medicamentos;

  //Constructor
  ControllerVistaPrescripcionMedicamento.empty();
  ControllerVistaPrescripcionMedicamento(this._vista);

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

  Future<List<Medicamento>?> listaMedicamentos(int paginaActual, int elementosPorPagina, Usuario residente, String? palabraClave) async {
    try {
      return _medicamentos = await Fachada.getInstancia()?.listaMedicamentosAsociados(paginaActual, elementosPorPagina, residente.ci, palabraClave);
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

  Future<int> calcularTotalPaginas(int elementosPorPagina, String? ciResidente, String? palabraClave) async {
    try {
      int totalMedicamentos = await Fachada.getInstancia()?.obtenerMedicamentosAsociadosPaginadosConFiltrosCantidadTotal(ciResidente, palabraClave) ?? 0;
      return (totalMedicamentos / elementosPorPagina).ceil();
    } on TokenException catch (e) {
      _cerrarSesion(e.toString());
      return 0;
    }
  }

  Future<void> registrarPrescripcion(Medicamento? selectedMedicamento, Usuario? selectedResidente, Sucursal? selectedSucursal, int cantidad, String descripcion,
      int notificacionStock, int prescripcionCronica, int duracion, int _frecuencia, TimeOfDay? hora_comienzo) async {
    try {
      if (_controles(selectedMedicamento, selectedResidente, selectedSucursal, cantidad, hora_comienzo)) {
        await Fachada.getInstancia()
            ?.registrarPrescripcion(selectedMedicamento, selectedResidente, cantidad, descripcion, notificacionStock, prescripcionCronica, duracion, _frecuencia, hora_comienzo);
      }
    } on TokenException catch (e) {
      _cerrarSesion(e.toString());
    } on PrescripcionMedicamentoException catch (e) {
      _vista?.mostrarMensaje(e.toString());
      _vista?.limpiar();
    } on Exception catch (e) {
      _vista?.mostrarMensajeError(e.toString());
    }
  }

  bool _controles(Medicamento? selectedMedicamento, Usuario? selectedResidente, Sucursal? selectedSucursal, int cantidad, TimeOfDay? hora_comienzo) {
    if (selectedSucursal == null) {
      _vista?.mostrarMensajeError("Tiene que seleccionar una sucursal.");
      return false;
    } else if (selectedResidente == null) {
      _vista?.mostrarMensajeError("Tiene que seleccionar un residente.");
      return false;
    } else if (selectedMedicamento == null) {
      _vista?.mostrarMensajeError("Tiene que seleccionar un medicamento.");
      return false;
    } else if (hora_comienzo == null) {
      _vista?.mostrarMensajeError("Tiene que seleccionar un hora de comienzo.");
      return false;
    }
    return true;
  }
}
