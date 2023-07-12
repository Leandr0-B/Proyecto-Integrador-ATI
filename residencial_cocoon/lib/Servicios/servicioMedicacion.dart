import 'dart:convert';

import 'package:residencial_cocoon/APIService/apiService.dart';
import 'package:residencial_cocoon/Dominio/Modelo/Medicacion/medicamento.dart';
import 'package:residencial_cocoon/Servicios/fachada.dart';

class ServicioMedicacion {
  //Atributos

  //Constructor
  ServicioMedicacion();

  //Funciones
  Future<void> altaMedicamento(String nombre, String? unidad) async {
    await APIService.postMedicamento(nombre, unidad, Fachada.getInstancia()?.getUsuario()?.getToken());
  }

  Future<List<Medicamento>?> listaMedicamentos(int paginaActual, int elementosPorPagina, String cedulaResidente, String palabraClave) async {
    String medicamentos = await APIService.fetchMedicamentos(paginaActual, elementosPorPagina, cedulaResidente, palabraClave, Fachada.getInstancia()?.getUsuario()?.getToken());
    List<dynamic> jsonList = jsonDecode(medicamentos);
    return Medicamento.fromJsonList(jsonList);
  }

  Future<int?> obtenerMedicamentosPaginadosConFiltrosCantidadTotal(String? ciResidente, String? palabraClave) async {
    String cantidadTotal = await APIService.obtenerMedicamentosPaginadosConFiltrosCantidadTotal(ciResidente, palabraClave, Fachada.getInstancia()?.getUsuario()!.getToken());
    int? total = jsonDecode(cantidadTotal)['total'];
    return total;
  }
}
