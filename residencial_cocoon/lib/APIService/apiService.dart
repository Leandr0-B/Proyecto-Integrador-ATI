import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:residencial_cocoon/Dominio/Exceptions/loginException.dart';

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

  static Future<void> fetchAltaUsuario(String ci, String nombre,
      int administrador, String roles, String sucursales, String? token) async {
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

    if (response.statusCode != 200) {
      throw Exception(errorObtenerToken);
    }
  }
}
