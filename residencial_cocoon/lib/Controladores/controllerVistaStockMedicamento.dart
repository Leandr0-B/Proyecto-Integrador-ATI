import 'package:residencial_cocoon/Dominio/Exceptions/altaFamiliarException.dart';
import 'package:residencial_cocoon/Dominio/Exceptions/prescripcionStockException.dart';
import 'package:residencial_cocoon/Dominio/Exceptions/tokenException.dart';
import 'package:residencial_cocoon/Dominio/Modelo/Medicacion/prescripcionDeMedicamento.dart';
import 'package:residencial_cocoon/Dominio/Modelo/familiar.dart';
import 'package:residencial_cocoon/Dominio/Modelo/sucurusal.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';
import 'package:residencial_cocoon/Servicios/fachada.dart';
import 'package:residencial_cocoon/UI/Medicamentos/iVistaStockMedicamento.dart';

class ControllerVistaStockMedicamento {
  //Atributos
  IvistaStockMedicamento? _vista;
  List<Sucursal>? _sucursales;
  Sucursal? _selectedSucursal;
  List<Usuario>? _residentes;

  //Constructor
  ControllerVistaStockMedicamento.empty();
  ControllerVistaStockMedicamento(this._vista);

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

  List<Sucursal>? listaSucursales() {
    _sucursales ??= Fachada.getInstancia()?.getUsuario()?.sucursales;
    return _sucursales;
  }

  void _cerrarSesion(String mensaje) {
    _vista?.mostrarMensajeError(mensaje);
    _vista?.cerrarSesion();
  }

  Future<List<PrescripcionDeMedicamento>> obtenerPrescripcionesActivasPaginadosConfiltros(
      int paginaActual, int elementosPorPagina, String? ciResidente, String? palabraClave) async {
    try {
      return await Fachada.getInstancia()?.obtenerPrescripcionesActivasPaginadosConfiltros(paginaActual, elementosPorPagina, ciResidente, palabraClave) ?? [];
    } on TokenException catch (e) {
      _cerrarSesion(e.toString());
      return [];
    }
  }

  Future<int> calcularTotalPaginas(int elementosPorPagina, String? ciResidente, String? palabraClave) async {
    try {
      int totalMedicamentos = await Fachada.getInstancia()?.obtenerPrescripcionesActivasPaginadosConFiltrosCantidadTotal(ciResidente, palabraClave) ?? 0;
      return (totalMedicamentos / elementosPorPagina).ceil();
    } on TokenException catch (e) {
      _cerrarSesion(e.toString());
      return 0;
    }
  }

  Future<List<Familiar>?> obtenerFamiliaresPaginadosConfiltros(int paginaActual, int elementosPorPagina, String? ciResidente, String? ciFamiliar) async {
    try {
      return await Fachada.getInstancia()?.obtenerFamiliaresPaginadosConfiltros(paginaActual, elementosPorPagina, ciResidente, ciFamiliar);
    } on TokenException catch (e) {
      _cerrarSesion(e.toString());
    }
  }

/*
  Future<int> calcularTotalPaginasFamiliares(int elementosPorPagina, String? ciResidente, String? ciFamiliar) async {
    try {
      int totalMedicamentos = await Fachada.getInstancia()?.obtenerFamiliaresPaginadosConfiltrosCantidadTotal(ciResidente, ciFamiliar) ?? 0;
      return (totalMedicamentos / elementosPorPagina).ceil();
    } on TokenException catch (e) {
      _cerrarSesion(e.toString());
      return 0;
    }
  }
*/

  Future<void> altaFamiliar(
      String? ciResidente, String ciFamiliarAlta, String nombreFamiliarAlta, String apellidoFamiliarAlta, String emailFamiliarAlta, String telefonoFamiliarAlta) async {
    try {
      await Fachada?.getInstancia()?.altaFamiliar(ciResidente, ciFamiliarAlta, nombreFamiliarAlta, apellidoFamiliarAlta, emailFamiliarAlta, telefonoFamiliarAlta);
    } on AltaFamiliarException catch (e) {
      _vista?.mostrarMensaje(e.toString());
    } on TokenException catch (e) {
      _cerrarSesion(e.toString());
    } on Exception catch (ex) {
      _vista?.mostrarMensajeError(ex.toString());
    }
  }

  Future<void> cargarStock(PrescripcionDeMedicamento? selectedPrescripcion, int stock, int stockNotificacion, Familiar? selectedFamiliar, int stockAnterior) async {
    try {
      if (_controles(selectedPrescripcion, selectedFamiliar, stock, stockAnterior)) {
        await Fachada.getInstancia()?.cargarStock(selectedPrescripcion?.id_prescripcion, stock, stockNotificacion, selectedFamiliar?.ci, stockAnterior);
      }
    } on PrescripcionStockException catch (e) {
      _vista?.mostrarMensaje(e.toString());
      _vista?.limpiar();
    } on TokenException catch (e) {
      _cerrarSesion(e.toString());
    } on Exception catch (e) {
      _vista?.mostrarMensajeError(e.toString());
    }
  }

  bool _controles(PrescripcionDeMedicamento? prescripcion, Familiar? familiar, int stock, int stockAnterior) {
    if (prescripcion == null) {
      _vista?.mostrarMensajeError("Tiene que seleccionar una prescripción.");
      return false;
    } else if (familiar == null && stockAnterior == 0) {
      _vista?.mostrarMensajeError("Tiene que seleccionar un familiar.");
      return false;
    }
    if (stockAnterior == 1 && prescripcion.medicamento.stockAnterior < stock) {
      _vista?.mostrarMensajeError("El stock ingresado no puede ser mayor al que se tiene almacenado.");
      return false;
    }
    return true;
  }
}
