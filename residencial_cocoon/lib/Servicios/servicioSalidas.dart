import 'package:intl/intl.dart';
import 'package:residencial_cocoon/APIService/apiService.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';
import 'package:residencial_cocoon/Servicios/fachada.dart';

class ServicioSalidas {
  //Atributos

  //Constructor
  ServicioSalidas();

  //Funciones
  Future<void> altaSalidaMedica(Usuario? selectedResidente, String descripcion,
      DateTime? fechaDesde, DateTime? fechaHasta) async {
    // Crear una nueva instancia de DateTime con la hora, minuto y segundo establecidos en cero
    DateTime fecha_desde_sin_hora =
        DateTime(fechaDesde!.year, fechaDesde!.month, fechaDesde!.day);
    String fecha_desde_formateada =
        DateFormat('yyyy-MM-dd').format(fecha_desde_sin_hora);

    DateTime fecha_hasta_sin_hora =
        DateTime(fechaHasta!.year, fechaHasta!.month, fechaHasta!.day);
    String fecha_hasta_formateada =
        DateFormat('yyyy-MM-dd').format(fecha_hasta_sin_hora);

    Usuario? geriatra = Fachada.getInstancia()?.getUsuario();
    await APIService.postSalidaMedica(
        geriatra?.getToken(),
        selectedResidente?.ci,
        geriatra?.ci,
        descripcion,
        fecha_desde_formateada,
        fecha_hasta_formateada);
  }
}
