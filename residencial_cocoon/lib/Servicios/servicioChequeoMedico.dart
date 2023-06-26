import 'package:intl/intl.dart';
import 'package:residencial_cocoon/APIService/apiService.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';
import 'package:residencial_cocoon/Servicios/fachada.dart';

class ServicioCequeoMedico {
  //Atributos

  //Constructor
  ServicioCequeoMedico();

  //Funciones
  Future<void> altaVisitaMedicaExt(
      Usuario? selectedResidente, String descripcion, DateTime? fecha) async {
    DateTime fecha_sin_hora = DateTime(fecha!.year, fecha!.month, fecha!.day);
    String fecha_desde_formateada =
        DateFormat('yyyy-MM-dd').format(fecha_sin_hora);
    Usuario? geriatra = Fachada.getInstancia()?.getUsuario();
    await APIService.postVisitaMedica(
        geriatra?.getToken(),
        selectedResidente?.ci,
        geriatra?.ci,
        descripcion,
        fecha_desde_formateada);
  }
}
