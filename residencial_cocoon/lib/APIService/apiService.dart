import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:residencial_cocoon/Dominio/Exceptions/altaMedicamentoException.dart';
import 'package:residencial_cocoon/Dominio/Exceptions/altaUsuarioException.dart';
import 'package:residencial_cocoon/Dominio/Exceptions/asociarMedicamentoException.dart';
import 'package:residencial_cocoon/Dominio/Exceptions/cambioContrasenaException.dart';
import 'package:residencial_cocoon/Dominio/Exceptions/chequeoMedicoException.dart';
import 'dart:convert';
import 'package:residencial_cocoon/Dominio/Exceptions/loginException.dart';
import 'package:residencial_cocoon/Dominio/Exceptions/medicacionPeriodicaException.dart';
import 'package:residencial_cocoon/Dominio/Exceptions/prescripcionMedicamentoException.dart';
import 'package:residencial_cocoon/Dominio/Exceptions/salidaMedicaException.dart';
import 'package:residencial_cocoon/Dominio/Exceptions/tokenException.dart';
import 'package:residencial_cocoon/Dominio/Exceptions/visitaMedicaExternaException.dart';
import 'package:residencial_cocoon/Dominio/Modelo/Medicacion/medicamento.dart';
import 'package:residencial_cocoon/Dominio/Modelo/Notificacion/notificacion.dart';
import 'package:residencial_cocoon/Dominio/Modelo/control.dart';
import 'package:residencial_cocoon/Dominio/Modelo/sucurusal.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';
import 'package:universal_html/html.dart';

class APIService {
  static String errorUsuarioClave = "Usuario o Contrseña incorrectos";
  static String errorObtenerToken = "Ha ocurrido un error intenta nuevamente";

  static Future<String> fetchAuth(String ci, String password) async {
    // const String ERROR_USUARIO_CLAVE = "Usuario o Contrseña incorrectos";

    final url = Uri.parse('https://residencialapi.azurewebsites.net/login');

    final response = await http.post(
      url,
      body: jsonEncode({'ci': ci, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 401) {
      throw TokenException("La sesion caduco. Vuelva a inciar sesion.");
    } else if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final token = responseData['token'] as String;
      return fetchUserInfo(token);
    } else if (response.statusCode == 403) {
      throw LoginException(errorUsuarioClave);
    } else {
      throw Exception(errorObtenerToken);
    }
  }

  static Future<String> fetchUserInfo(String token) async {
    final url = Uri.parse('https://residencialapi.azurewebsites.net/usuario/info');

    final response = await http.post(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 401) {
      throw TokenException("La sesion caduco. Vuelva a inciar sesion.");
    } else if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(errorObtenerToken);
    }
  }

  static Future<String> fetchRoles(String? token) async {
    final url = Uri.parse('https://residencialapi.azurewebsites.net/rol/lista');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      throw TokenException("La sesion caduco. Vuelva a inciar sesion.");
    } else if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(errorObtenerToken);
    }
  }

  static Future<String> fetchSucursales(String? token) async {
    final url = Uri.parse('https://residencialapi.azurewebsites.net/sucursal/lista');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      throw TokenException("La sesion caduco. Vuelva a inciar sesion.");
    } else if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(errorObtenerToken);
    }
  }

  static Future<void> postAltaUsuario(
      String ci, String nombre, int administrador, List<int> roles, List<int> sucursales, String? token, String apellido, String telefono, String email) async {
    // const String ERROR_USUARIO_CLAVE = "Usuario o Contrseña incorrectos";

    final url = Uri.parse('https://residencialapi.azurewebsites.net/usuario/crear');

    final response = await http.post(
      url,
      body: jsonEncode({
        'ci': ci,
        'nombre': nombre,
        'apellido': apellido,
        'telefono': telefono,
        'email': email,
        'password': ci,
        'administrador': administrador,
        'sucursales': sucursales,
        'roles': roles,
      }),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      throw TokenException("La sesion caduco. Vuelva a inciar sesion.");
    }

    if (response.statusCode == 400) {
      throw Exception("El funcionario ya esta ingresado.");
    }

    if (response.statusCode == 200) {
      throw AltaUsuarioException("El funcionario fue ingresado correctamente.");
    }
  }

  static Future<void> postAltaUsuarioResidente(String ci, String nombre, List<Map<String, dynamic>> familiares, List<int?> sucursales, String? token, String apellido) async {
    // const String ERROR_USUARIO_CLAVE = "Usuario o Contrseña incorrectos";

    final url = Uri.parse('https://residencialapi.azurewebsites.net/usuario/crear');

    final response = await http.post(
      url,
      body: jsonEncode({
        'ci': ci,
        'nombre': nombre,
        'apellido': apellido,
        'password': ci,
        'administrador': 0,
        'sucursales': sucursales,
        'roles': [3],
        'familiares': familiares,
      }),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      throw TokenException("La sesion caduco. Vuelva a inciar sesion.");
    }

    if (response.statusCode == 400) {
      throw Exception("El residente ya esta ingresado.");
    }

    if (response.statusCode == 200) {
      throw AltaUsuarioException("El residente fue ingresado correctamente.");
    }
  }

  static Future<String> fetchUsuarios(String? token) async {
    final url = Uri.parse('https://residencialapi.azurewebsites.net/usuario/lista');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      throw TokenException("La sesion caduco. Vuelva a inciar sesion.");
    } else if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(errorObtenerToken);
    }
  }

  static Future<void> putUserPass(String actual, String nueva, String? token) async {
    final url = Uri.parse('https://residencialapi.azurewebsites.net/usuario/cambiar-pass');

    final response = await http.put(
      url,
      body: jsonEncode({
        'oldPassword': actual,
        'newPassword': nueva,
      }),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 401) {
      throw TokenException("La sesion caduco. Vuelva a inciar sesion.");
    } else if (response.statusCode != 200) {
      throw CambioContrsenaException("Contraseña actual incorrecta.");
    }
  }

  static Future<String> fetchUsuariosSucursal(String? token, int? idSucursal) async {
    final url = Uri.parse('https://residencialapi.azurewebsites.net/residente/sucursal/$idSucursal');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      throw TokenException("La sesion caduco. Vuelva a inciar sesion.");
    } else if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(errorObtenerToken);
    }
  }

  static Future<void> postSalidaMedica(String? token, String? ci_residente, String? ci_geriatra, String descripcion, String fecha_desde, String fecha_hasta) async {
    //print(DateTime(fecha_desde!.year, fecha_desde!.month, fecha_desde!.day));
    //print(DateTime(fecha_hasta!.year, fecha_hasta!.month, fecha_hasta!.day));
    final url = Uri.parse('https://residencialapi.azurewebsites.net/salida-medica/crear');

    final response = await http.post(
      url,
      body: jsonEncode({
        'ci_residente': ci_residente,
        'ci_geriatra': ci_geriatra,
        'descripcion': descripcion,
        'fecha_desde': fecha_desde.toString(),
        'fecha_hasta': fecha_hasta.toString(),
      }),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      throw TokenException("La sesion caduco. Vuelva a inciar sesion.");
    } else if (response.statusCode == 200) {
      throw SalidaMedicaException("Se ingreso la salida medica.");
    } else {
      throw Exception(errorObtenerToken);
    }
  }

  static Future<void> actualizarTokenNotificaciones(String notificationToken, String? authorizationToken) async {
    final url = Uri.parse('https://residencialapi.azurewebsites.net/usuario/modificar-token');

    final response = await http.put(
      url,
      body: jsonEncode({
        'tokenNotificacion': notificationToken,
      }),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $authorizationToken'},
    );

    if (response.statusCode == 401) {
      throw TokenException("La sesion caduco. Vuelva a inciar sesion.");
    } else if (response.statusCode != 200) {
      throw Exception("ha ocurrido un error al actualizar el token de notificaciones.");
    }
  }

  static Future<void> postVisitaMedica(String? token, String? ci_residente, String? ci_geriatra, String descripcion, String fecha) async {
    final url = Uri.parse('https://residencialapi.azurewebsites.net/visita-medica-externa/crear');

    final response = await http.post(
      url,
      body: jsonEncode({
        'ci_residente': ci_residente,
        'ci_geriatra': ci_geriatra,
        'descripcion': descripcion,
        'fecha': fecha.toString(),
      }),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      throw TokenException("La sesion caduco. Vuelva a inciar sesion.");
    } else if (response.statusCode == 200) {
      throw visitaMedicaExternaException("Se ingreso la visita medica externa.");
    } else {
      throw Exception(errorObtenerToken);
    }
  }

  static Future<String> fetchNotificacionesSinLeer(String? token) async {
    final url = Uri.parse('https://residencialapi.azurewebsites.net/notificacion/notificaciones-no-leidas');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      throw TokenException("La sesion caduco. Vuelva a inciar sesion.");
    } else if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(errorObtenerToken);
    }
  }

  static Future<String> fetchUltimasNotificaciones(String? token) async {
    final url = Uri.parse('https://residencialapi.azurewebsites.net/notificacion/ultimas-notificaciones');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      throw TokenException("La sesion caduco. Vuelva a inciar sesion.");
    } else if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(errorObtenerToken);
    }
  }

  static void marcarNotificacionComoLeida(Notificacion notificacion, String? token) async {
    final url = Uri.parse('https://residencialapi.azurewebsites.net/notificacion/marcar-leida/${notificacion.idNotificacion}');
    final response = await http.put(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      throw TokenException("La sesion caduco. Vuelva a inciar sesion.");
    }
  }

  static Future<String> fetchControles(String? token) async {
    final url = Uri.parse('https://residencialapi.azurewebsites.net/control/lista');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      throw TokenException("La sesion caduco. Vuelva a inciar sesion.");
    } else if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(errorObtenerToken);
    }
  }

  static Future<void> postChequeoMedico(String? token, String? ci_residente, String? ci_geriatra, String descripcion, String fecha, List<Map<String, dynamic>> controles) async {
    final url = Uri.parse('https://residencialapi.azurewebsites.net/chequeo-medico/crear');

    final response = await http.post(
      url,
      body: jsonEncode({
        'ci_residente': ci_residente,
        'ci_geriatra': ci_geriatra,
        'descripcion': descripcion,
        'fecha': fecha.toString(),
        'controles': controles,
      }),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      throw TokenException("La sesion caduco. Vuelva a inciar sesion.");
    } else if (response.statusCode == 200) {
      throw ChequeoMedicoException("Se ingreso el chequeo médico.");
    } else {
      throw Exception(errorObtenerToken);
    }
  }

  static obtenerNotificacionesPaginadasConFiltros(int page, int limit, DateTime? desde, DateTime? hasta, String? palabras, String? token) async {
    final url = Uri.parse('https://residencialapi.azurewebsites.net/notificacion?page=$page&pageSize=$limit'
        '${desde != null ? '&fechaDesde=${desde.toIso8601String()}' : ''}'
        '${hasta != null ? '&fechaHasta=${hasta.toIso8601String()}' : ''}'
        '${palabras != null ? '&palabrasParam=${Uri.encodeComponent(palabras)}' : ''}');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      throw TokenException("La sesion caduco. Vuelva a inciar sesion.");
    } else if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(errorObtenerToken);
    }
  }

  static obtenerNotificacionesPaginadasConFiltrosCantidadTotal(DateTime? desde, DateTime? hasta, String? palabras, String? token) async {
    final url = Uri.parse('https://residencialapi.azurewebsites.net/notificacion/count?page=1'
        '${desde != null ? '&fechaDesde=${desde.toIso8601String()}' : ''}'
        '${hasta != null ? '&fechaHasta=${hasta.toIso8601String()}' : ''}'
        '${palabras != null ? '&palabrasParam=${Uri.encodeComponent(palabras)}' : ''}');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      throw TokenException("La sesion caduco. Vuelva a inciar sesion.");
    } else if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(errorObtenerToken);
    }
  }

  static obtenerSalidasMedicasPaginadasConFiltros(int page, int limit, DateTime? desde, DateTime? hasta, String? ciResidente, String? palabraClave, String? token) async {
    final url = Uri.parse('https://residencialapi.azurewebsites.net/salida-medica?page=$page&pageSize=$limit'
        '${desde != null ? '&fechaDesde=${desde.toIso8601String()}' : ''}'
        '${hasta != null ? '&fechaHasta=${hasta.toIso8601String()}' : ''}'
        '${ciResidente != null ? '&ciResidente=$ciResidente' : ''}'
        '${palabraClave != null ? '&palabraClave=${Uri.encodeComponent(palabraClave)}' : ''}');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      throw TokenException("La sesion caduco. Vuelva a inciar sesion.");
    } else if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(errorObtenerToken);
    }
  }

  static obtenerSalidasMedicasPaginadasConFiltrosCantidadTotal(DateTime? fechaDesde, DateTime? fechaHasta, String? ciResidente, String? palabraClave, String? token) async {
    final url = Uri.parse('https://residencialapi.azurewebsites.net/salida-medica/count?page=1'
        '${fechaDesde != null ? '&fechaDesde=${fechaDesde.toIso8601String()}' : ''}'
        '${fechaHasta != null ? '&fechaHasta=${fechaHasta.toIso8601String()}' : ''}'
        '${ciResidente != null ? '&ciResidente=$ciResidente' : ''}'
        '${palabraClave != null ? '&palabraClave=${Uri.encodeComponent(palabraClave)}' : ''}');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      throw TokenException("La sesion caduco. Vuelva a inciar sesion.");
    } else if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(errorObtenerToken);
    }
  }

  static obtenerVisitasMedicasExternasPaginadasConFiltros(
      int paginaActual, int elementosPorPagina, DateTime? fechaDesde, DateTime? fechaHasta, String? ciResidente, String? palabraClave, String? token) async {
    final url = Uri.parse('https://residencialapi.azurewebsites.net/visita-medica-externa?page=$paginaActual&pageSize=$elementosPorPagina'
        '${fechaDesde != null ? '&fechaDesde=${fechaDesde.toIso8601String()}' : ''}'
        '${fechaHasta != null ? '&fechaHasta=${fechaHasta.toIso8601String()}' : ''}'
        '${ciResidente != null ? '&ciResidente=$ciResidente' : ''}'
        '${palabraClave != null ? '&palabraClave=${Uri.encodeComponent(palabraClave)}' : ''}');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      throw TokenException("La sesion caduco. Vuelva a inciar sesion.");
    } else if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(errorObtenerToken);
    }
  }

  static obtenerVisitasMedicasExternasPaginadasConFiltrosCantidadTotal(DateTime? fechaDesde, DateTime? fechaHasta, String? ciResidente, String? palabraClave, String? token) async {
    final url = Uri.parse('https://residencialapi.azurewebsites.net/visita-medica-externa/count?page=1'
        '${fechaDesde != null ? '&fechaDesde=${fechaDesde.toIso8601String()}' : ''}'
        '${fechaHasta != null ? '&fechaHasta=${fechaHasta.toIso8601String()}' : ''}'
        '${ciResidente != null ? '&ciResidente=$ciResidente' : ''}'
        '${palabraClave != null ? '&palabraClave=${Uri.encodeComponent(palabraClave)}' : ''}');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      throw TokenException("La sesion caduco. Vuelva a inciar sesion.");
    } else if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(errorObtenerToken);
    }
  }

  static obtenerChequeosMedicosPaginadosConFiltrosCantidadTotal(DateTime? fechaDesde, DateTime? fechaHasta, String? ciResidente, String? palabraClave, String? token) async {
    final url = Uri.parse('https://residencialapi.azurewebsites.net/chequeo-medico/count?page=1'
        '${fechaDesde != null ? '&fechaDesde=${fechaDesde.toIso8601String()}' : ''}'
        '${fechaHasta != null ? '&fechaHasta=${fechaHasta.toIso8601String()}' : ''}'
        '${ciResidente != null ? '&ciResidente=$ciResidente' : ''}'
        '${palabraClave != null ? '&palabraClave=${Uri.encodeComponent(palabraClave)}' : ''}');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      throw TokenException("La sesion caduco. Vuelva a inciar sesion.");
    } else if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(errorObtenerToken);
    }
  }

  static obtenerChequeosMedicosPaginadosConFiltros(
      int paginaActual, int elementosPorPagina, DateTime? fechaDesde, DateTime? fechaHasta, String? ciResidente, String? palabraClave, String? token) async {
    final url = Uri.parse('https://residencialapi.azurewebsites.net/chequeo-medico?page=$paginaActual&pageSize=$elementosPorPagina'
        '${fechaDesde != null ? '&fechaDesde=${fechaDesde.toIso8601String()}' : ''}'
        '${fechaHasta != null ? '&fechaHasta=${fechaHasta.toIso8601String()}' : ''}'
        '${ciResidente != null ? '&ciResidente=$ciResidente' : ''}'
        '${palabraClave != null ? '&palabraClave=${Uri.encodeComponent(palabraClave)}' : ''}');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      throw TokenException("La sesion caduco. Vuelva a inciar sesion.");
    } else if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(errorObtenerToken);
    }
  }

  static Future<void> eliminarTokenNotificaciones(String? token) async {
    final url = Uri.parse('https://residencialapi.azurewebsites.net/usuario/eliminar-token');

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception("ha ocurrido un error al actualizar el token de notificaciones.");
    }
  }

  static Future<void> postMedicamento(
    String? nombre,
    String? unidad,
    String? token,
  ) async {
    final url = Uri.parse('https://residencialapi.azurewebsites.net/medicamento/crear');

    final response = await http.post(
      url,
      body: jsonEncode({
        'nombre': nombre,
        'unidad': unidad,
      }),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      throw TokenException("La sesion caduco. Vuelva a inciar sesion.");
    } else if (response.statusCode == 200) {
      throw AltaMedicamentoException("Se ingreso el medicamento correctamente.");
    } else if (response.statusCode == 400) {
      throw Exception("El medicamento ya existe en la base de datos.");
    } else {
      throw Exception(errorObtenerToken);
    }
  }

  static Future<String> fetchMedicamentos(int paginaActual, int elementosPorPagina, String cedulaResidente, String palabraClave, String? token) async {
    final url = Uri.parse('https://residencialapi.azurewebsites.net/medicamento/medicamentos-sin-asociar/${cedulaResidente}?page=$paginaActual&pageSize=$elementosPorPagina'
        '${palabraClave != null ? '&palabraClave=${Uri.encodeComponent(palabraClave)}' : ''}');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      throw TokenException("La sesion caduco. Vuelva a inciar sesion.");
    } else if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(errorObtenerToken);
    }
  }

  static obtenerMedicamentosPaginadosConFiltrosCantidadTotal(String? ciResidente, String? palabraClave, String? token) async {
    final url = Uri.parse('https://residencialapi.azurewebsites.net/medicamento/medicamentos-sin-asociar/count/${ciResidente}?page=1'
        '${palabraClave != null ? '&palabraClave=${Uri.encodeComponent(palabraClave)}' : ''}');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      throw TokenException("La sesion caduco. Vuelva a inciar sesion.");
    } else if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(errorObtenerToken);
    }
  }

  static postAsociarMedicamento(Medicamento? selectedMedicamento, Usuario? selectedResidente, int stock, int stockNotificacion, String? token) async {
    final url = Uri.parse('https://residencialapi.azurewebsites.net/medicamento/asociar-medicamento');

    final response = await http.post(
      url,
      body: jsonEncode({
        'ci_residente': selectedResidente?.ci,
        'id_medicamento': selectedMedicamento?.id_medicamento,
        'stock': stock,
        'stock_notificacion': stockNotificacion,
      }),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      throw TokenException("La sesion caduco. Vuelva a inciar sesion.");
    } else if (response.statusCode == 200) {
      throw AsociarMedicamentoException("Se asocio el medicamento al residente.");
    } else {
      throw Exception(errorObtenerToken);
    }
  }

  static fetchMedicamentosAsociados(int paginaActual, int elementosPorPagina, String cedulaResidente, String palabraClave, String? token) async {
    final url = Uri.parse('https://residencialapi.azurewebsites.net/medicamento/medicamentos-asociados/${cedulaResidente}?page=$paginaActual&pageSize=$elementosPorPagina'
        '${palabraClave != null ? '&palabraClave=${Uri.encodeComponent(palabraClave)}' : ''}');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      throw TokenException("La sesion caduco. Vuelva a inciar sesion.");
    } else if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(errorObtenerToken);
    }
  }

  static obtenerMedicamentosAsociadosPaginadosConFiltrosCantidadTotal(String? ciResidente, String? palabraClave, String? token) async {
    final url = Uri.parse('https://residencialapi.azurewebsites.net/medicamento/medicamentos-asociados/count/${ciResidente}?page=1'
        '${palabraClave != null ? '&palabraClave=${Uri.encodeComponent(palabraClave)}' : ''}');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      throw TokenException("La sesion caduco. Vuelva a inciar sesion.");
    } else if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(errorObtenerToken);
    }
  }

  static postPrescripcion(Medicamento? selectedMedicamento, Usuario? selectedResidente, String? geriatraCi, int cantidad, String descripcion, String fecha_desde_formateada,
      String fecha_hasta_formateada, int frecuencia, String horaSeleccionadaString, String? token) async {
    final url = Uri.parse('https://residencialapi.azurewebsites.net/prescripcion-medicacion/crear');

    final response = await http.post(
      url,
      body: jsonEncode({
        'ci_residente': selectedResidente?.ci,
        'ci_geriatra': geriatraCi,
        'id_medicamento': selectedMedicamento?.id_medicamento,
        'cantidad': cantidad,
        'descripcion': descripcion,
        'fecha_desde': fecha_desde_formateada,
        'fecha_hasta': fecha_hasta_formateada,
        'frecuencia': frecuencia,
        'hora_comienzo': horaSeleccionadaString,
      }),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      throw TokenException("La sesion caduco. Vuelva a inciar sesion.");
    } else if (response.statusCode == 200) {
      throw PrescripcionMedicamentoException("Se ingreso la prescripción del medicamento al residente.");
    } else {
      throw Exception(errorObtenerToken);
    }
  }

  static obtenerRegistrosMedicamentosConPrescripcion(DateTime? fechaFiltro, String? ciFiltro, String? token) async {
    final url = Uri.parse(
        'https://residencialapi.azurewebsites.net/registro-medicacion/listado-del-dia?page=1${fechaFiltro != null ? '&fecha=${fechaFiltro.toString().split(' ')[0]}' : ''}${ciFiltro != null ? '&ci_residente=$ciFiltro' : ''}');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 401) {
      throw TokenException("La sesion caduco. Vuelva a inciar sesion.");
    } else if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(errorObtenerToken);
    }
  }

  static procesarMedicacion(int id, String horaRealizacion, String fechaRealizacion, int cantidadDada, String descripcion, String? token) async {
    final url = Uri.parse('https://residencialapi.azurewebsites.net/registro-medicacion/realizar-ingreso/$id');
    final response = await http.put(
      url,
      body: jsonEncode({
        'horaDeRealizacion': horaRealizacion,
        'fechaRealizacion': fechaRealizacion,
        'cantidadDada': cantidadDada,
        'descripcion': descripcion,
      }),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 401) {
      throw TokenException("La sesion caduco. Vuelva a inciar sesion.");
    } else if (response.statusCode == 200) {
      throw MedicacionPeriodicaException("Se registro correctamente la medicacion periodica.");
    } else {
      throw Exception(errorObtenerToken);
    }
  }

  static obtenerPrescripcionesMedicamentosPaginadosConfiltros(
      int paginaActual, int elementosPorPagina, DateTime? fechaDesde, DateTime? fechaHasta, String? ciResidente, String? palabraClave, String? token) async {
    final url = Uri.parse('https://residencialapi.azurewebsites.net/prescripcion-medicacion?page=$paginaActual&pageSize=$elementosPorPagina'
        '${fechaDesde != null ? '&fechaDesde=${DateFormat('yyyy-MM-dd').format(fechaDesde)}' : ''}'
        '${fechaHasta != null ? '&fechaHasta=${DateFormat('yyyy-MM-dd').format(fechaHasta)}' : ''}'
        '${ciResidente != null ? '&ciResidente=$ciResidente' : ''}'
        '${palabraClave != null ? '&palabraClave=${Uri.encodeComponent(palabraClave)}' : ''}');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      throw TokenException("La sesion caduco. Vuelva a inciar sesion.");
    } else if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(errorObtenerToken);
    }
  }

  static obtenerPrescripcionesMedicamentosPaginadosConfiltrosCantidadTotal(
      DateTime? fechaDesde, DateTime? fechaHasta, String? ciResidente, String? palabraClave, String? token) async {
    final url = Uri.parse('https://residencialapi.azurewebsites.net/prescripcion-medicacion/count?page=1'
        '${fechaDesde != null ? '&fechaDesde=${DateFormat('yyyy-MM-dd').format(fechaDesde)}' : ''}'
        '${fechaHasta != null ? '&fechaHasta=${DateFormat('yyyy-MM-dd').format(fechaHasta)}' : ''}'
        '${ciResidente != null ? '&ciResidente=$ciResidente' : ''}'
        '${palabraClave != null ? '&palabraClave=${Uri.encodeComponent(palabraClave)}' : ''}');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      throw TokenException("La sesion caduco. Vuelva a inciar sesion.");
    } else if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(errorObtenerToken);
    }
  }
}
