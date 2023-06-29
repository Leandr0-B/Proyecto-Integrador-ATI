import 'package:http/http.dart' as http;
import 'package:residencial_cocoon/Dominio/Exceptions/altaUsuarioException.dart';
import 'package:residencial_cocoon/Dominio/Exceptions/cambioContrasenaException.dart';
import 'dart:convert';
import 'package:residencial_cocoon/Dominio/Exceptions/loginException.dart';
import 'package:residencial_cocoon/Dominio/Exceptions/salidaMedicaException.dart';
import 'package:residencial_cocoon/Dominio/Exceptions/visitaMedicaExternaException.dart';
import 'package:residencial_cocoon/Dominio/Modelo/Notificacion/notificacion.dart';
import 'package:universal_html/html.dart';

class APIService {
  static String errorUsuarioClave = "Usuario o Contrseña incorrectos";
  static String errorObtenerToken = "Ha ocurrido un error al inciar Sesión";

  static Future<String> fetchAuth(String ci, String password) async {
    // const String ERROR_USUARIO_CLAVE = "Usuario o Contrseña incorrectos";

    final url = Uri.parse('https://residencialapi.azurewebsites.net/login');

    final response = await http.post(
      url,
      body: jsonEncode({'ci': ci, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final token = responseData['token'] as String;
      return fetchUserInfo(token);
    } else if (response.statusCode == 401) {
      throw LoginException(errorUsuarioClave);
    } else {
      throw Exception(errorObtenerToken);
    }
  }

  static Future<String> fetchUserInfo(String token) async {
    final url =
        Uri.parse('https://residencialapi.azurewebsites.net/usuario/info');

    final response = await http.post(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
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

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(errorObtenerToken);
    }
  }

  static Future<String> fetchSucursales(String? token) async {
    final url =
        Uri.parse('https://residencialapi.azurewebsites.net/sucursal/lista');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(errorObtenerToken);
    }
  }

  static Future<void> postAltaUsuario(
      String ci,
      String nombre,
      int administrador,
      List<int> roles,
      List<int> sucursales,
      String? token) async {
    // const String ERROR_USUARIO_CLAVE = "Usuario o Contrseña incorrectos";

    final url =
        Uri.parse('https://residencialapi.azurewebsites.net/usuario/crear');

    final response = await http.post(
      url,
      body: jsonEncode({
        'ci': ci,
        'nombre': nombre,
        'password': ci,
        'administrador': administrador,
        'sucursales': sucursales,
        'roles': roles,
      }),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );

    if (response.statusCode == 400) {
      throw Exception("El funcionario ya esta ingresado.");
    }

    if (response.statusCode == 200) {
      throw AltaUsuarioException("El funcionario fue ingresado correctamente.");
    }
  }

  static Future<void> postAltaUsuarioResidente(
      String ci,
      String nombre,
      List<Map<String, dynamic>> familiares,
      List<int?> sucursales,
      String? token) async {
    // const String ERROR_USUARIO_CLAVE = "Usuario o Contrseña incorrectos";

    final url =
        Uri.parse('https://residencialapi.azurewebsites.net/usuario/crear');

    final response = await http.post(
      url,
      body: jsonEncode({
        'ci': ci,
        'nombre': nombre,
        'password': ci,
        'administrador': 0,
        'sucursales': sucursales,
        'roles': [3],
        'familiares': familiares,
      }),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );

    if (response.statusCode == 400) {
      throw Exception("El residente ya esta ingresado.");
    }

    if (response.statusCode == 200) {
      throw AltaUsuarioException("El residente fue ingresado correctamente.");
    }
  }

  static Future<String> fetchUsuarios(String? token) async {
    final url =
        Uri.parse('https://residencialapi.azurewebsites.net/usuario/lista');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(errorObtenerToken);
    }
  }

  static Future<void> putUserPass(
      String actual, String nueva, String? token) async {
    final url = Uri.parse(
        'https://residencialapi.azurewebsites.net/usuario/cambiar-pass');

    final response = await http.put(
      url,
      body: jsonEncode({
        'oldPassword': actual,
        'newPassword': nueva,
      }),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );

    if (response.statusCode != 200) {
      throw CambioContrsenaException("Contraseña actual incorrecta.");
    }
  }

  static Future<String> fetchUsuariosSucursal(
      String? token, int? idSucursal) async {
    final url = Uri.parse(
        'https://residencialapi.azurewebsites.net/residente/sucursal/$idSucursal');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(errorObtenerToken);
    }
  }

  static Future<void> postSalidaMedica(
      String? token,
      String? ci_residente,
      String? ci_geriatra,
      String descripcion,
      String fecha_desde,
      String fecha_hasta) async {
    //print(DateTime(fecha_desde!.year, fecha_desde!.month, fecha_desde!.day));
    //print(DateTime(fecha_hasta!.year, fecha_hasta!.month, fecha_hasta!.day));
    final url = Uri.parse(
        'https://residencialapi.azurewebsites.net/salida-medica/crear');

    final response = await http.post(
      url,
      body: jsonEncode({
        'ci_residente': ci_residente,
        'ci_geriatra': ci_geriatra,
        'descripcion': descripcion,
        'fecha_desde': fecha_desde.toString(),
        'fecha_hasta': fecha_hasta.toString(),
      }),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );

    if (response.statusCode == 200) {
      throw SalidaMedicaException("Se ingreso la salida medica.");
    } else {
      throw Exception(errorObtenerToken);
    }
  }

  static Future<void> actualizarTokenNotificaciones(
      String notificationToken, String? authorizationToken) async {
    final url = Uri.parse(
        'https://residencialapi.azurewebsites.net/usuario/modificar-token');

    final response = await http.put(
      url,
      body: jsonEncode({
        'tokenNotificacion': notificationToken,
      }),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authorizationToken'
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
          "ha ocurrido un error al actualizar el token de notificaciones.");
    }
  }

  static Future<void> postVisitaMedica(String? token, String? ci_residente,
      String? ci_geriatra, String descripcion, String fecha) async {
    //print(DateTime(fecha_desde!.year, fecha_desde!.month, fecha_desde!.day));
    //print(DateTime(fecha_hasta!.year, fecha_hasta!.month, fecha_hasta!.day));
    final url = Uri.parse(
        'https://residencialapi.azurewebsites.net/visita-medica-externa/crear');

    final response = await http.post(
      url,
      body: jsonEncode({
        'ci_residente': ci_residente,
        'ci_geriatra': ci_geriatra,
        'descripcion': descripcion,
        'fecha': fecha.toString(),
      }),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );

    if (response.statusCode == 200) {
      throw visitaMedicaExternaException(
          "Se ingreso la visita medica externa.");
    } else {
      throw Exception(errorObtenerToken);
    }
  }

  static Future<String> fetchNotificacionesSinLeer(String? token) async {
    final url = Uri.parse(
        'https://residencialapi.azurewebsites.net/notificacion/notificaciones-no-leidas');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(errorObtenerToken);
    }
  }

  static Future<String> fetchUltimasNotificaciones(String? token) async {
    final url = Uri.parse(
        'https://residencialapi.azurewebsites.net/notificacion/ultimas-notificaciones');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(errorObtenerToken);
    }
  }

  static void marcarNotificacionComoLeida(
      Notificacion notificacion, String? token) async {
    final url = Uri.parse(
        'https://residencialapi.azurewebsites.net/notificacion/marcar-leida/${notificacion.idNotificacion}');
    await http.put(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  static obtenerNotificacionesPaginadas(
      int page, int limit, String? token) async {
    final url = Uri.parse(
        'http://localhost:3000/notificacion?page=$page&pageSize=$limit');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(errorObtenerToken);
    }
  }
}
