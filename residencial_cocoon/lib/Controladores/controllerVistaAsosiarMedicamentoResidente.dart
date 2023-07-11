import 'package:residencial_cocoon/Dominio/Exceptions/tokenException.dart';
import 'package:residencial_cocoon/Dominio/Modelo/Medicacion/medicamento.dart';
import 'package:residencial_cocoon/Dominio/Modelo/sucurusal.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';
import 'package:residencial_cocoon/Servicios/fachada.dart';
import 'package:residencial_cocoon/UI/Geriatra/Medicamentos/iVistaAsociarMedicamentoResidente.dart';

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

  Future<List<Medicamento>?> listaMedicamentos() async {
    try {
      return _medicamentos ??=
          await Fachada.getInstancia()?.listaMedicamentos();
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

  Future<int> cantidadPaginas() {
    if (_medicamentos != null) {
      return _medicamentos?.length;
    } else {
      return 0;
    }
  }
}
