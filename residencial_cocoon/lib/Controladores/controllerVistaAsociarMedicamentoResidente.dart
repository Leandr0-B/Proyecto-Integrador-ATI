import 'package:residencial_cocoon/Dominio/Exceptions/altaMedicamentoException.dart';
import 'package:residencial_cocoon/Dominio/Exceptions/asociarMedicamentoException.dart';
import 'package:residencial_cocoon/Dominio/Exceptions/tokenException.dart';
import 'package:residencial_cocoon/Dominio/Modelo/Medicacion/medicamento.dart';
import 'package:residencial_cocoon/Dominio/Modelo/sucurusal.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';
import 'package:residencial_cocoon/Servicios/fachada.dart';
import 'package:residencial_cocoon/UI/Medicamentos/iVistaAsociarMedicamentoResidente.dart';

class ControllerVistaAsociarMedicamento {
  //Atributos
  IvistaAsociarMedicamento? _vista;
  List<Sucursal>? _sucursales;
  Sucursal? _selectedSucursal;
  List<Usuario>? _residentes;

  //Constructor
  ControllerVistaAsociarMedicamento.empty();
  ControllerVistaAsociarMedicamento(this._vista);

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

  Future<List<Medicamento>?> obtenerMedicamentosPaginadosConFiltros(int paginaActual, int elementosPorPagina, String? palabraClave) async {
    try {
      return await Fachada.getInstancia()?.obtenerMedicamentosPaginadosConFiltros(paginaActual, elementosPorPagina, palabraClave);
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

  Future<int> calcularTotalPaginas(int elementosPorPagina, String? palabraClave) async {
    try {
      int totalMedicamentos = await Fachada.getInstancia()?.obtenerMedicamentosPaginadosConFiltrosCantidadTotal(palabraClave) ?? 0;
      return (totalMedicamentos / elementosPorPagina).ceil();
    } on TokenException catch (e) {
      _cerrarSesion(e.toString());
      return 0;
    }
  }

  Future<void> asociarMedicamento(Medicamento? selectedMedicamento, Usuario? selectedResidente, Sucursal? selectedSucursal) async {
    try {
      if (_controles(selectedMedicamento, selectedResidente, selectedSucursal)) {
        await Fachada.getInstancia()?.asociarMedicamento(selectedMedicamento, selectedResidente);
      }
    } on TokenException catch (e) {
      _cerrarSesion(e.toString());
    } on AsociarMedicamentoException catch (e) {
      _vista?.mostrarMensaje(e.toString());
      _vista?.limpiar();
    } on Exception catch (e) {
      _vista?.mostrarMensajeError(e.toString());
    }
  }

  bool _controles(Medicamento? selectedMedicamento, Usuario? selectedResidente, Sucursal? selectedSucursal) {
    if (selectedSucursal == null) {
      _vista?.mostrarMensajeError("Tiene que seleccionar una sucursal.");
      return false;
    } else if (selectedResidente == null) {
      _vista?.mostrarMensajeError("Tiene que seleccionar un residente.");
      return false;
    } else if (selectedMedicamento == null) {
      _vista?.mostrarMensajeError("Tiene que seleccionar un medicamento.");
      return false;
    }
    return true;
  }

  Future<void> altaMedicamento(String nombreMedicamento, String? selectedUnidad) async {
    if (_controlesAltaMedicamento(selectedUnidad)) {
      try {
        await Fachada?.getInstancia()?.altaMedicamento(nombreMedicamento, selectedUnidad);
      } on AltaMedicamentoException catch (e) {
        _vista?.mostrarMensaje(e.toString());
      } on TokenException catch (e) {
        _cerrarSesion(e.toString());
      } on Exception catch (ex) {
        _vista?.mostrarMensajeError(ex.toString());
      }
    }
  }

  bool _controlesAltaMedicamento(String? uniadad) {
    if (uniadad == null || uniadad.isEmpty) {
      _vista?.mostrarMensajeError("Tiene que seleccionar la unidad del medicamento");
      return false;
    }
    return true;
  }
}
