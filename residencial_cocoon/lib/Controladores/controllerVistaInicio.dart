import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:residencial_cocoon/Dominio/Exceptions/tokenException.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';
import 'package:residencial_cocoon/Servicios/fachada.dart';
import 'package:residencial_cocoon/UI/Inicio/iVistaInicio.dart';
import '../../Firebase/firebase_options.dart';
import 'package:universal_html/html.dart' as html;

class ControllerVistaInicio {
  //Atributos
  String? token = null;
  IVistaInicio? _vistaInicio;

  //Constructor
  ControllerVistaInicio.empty();
  ControllerVistaInicio(this._vistaInicio);

  //Funciones
  void inicializarFirebase(Usuario? usuario) async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    final messaging = FirebaseMessaging.instance;

    messaging
        .requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    )
        .then((settings) {
      if (settings.authorizationStatus == AuthorizationStatus.authorized && token == null && usuario != null) {
        obtenerTokenFirebase(usuario);
      }
    }).catchError((error) {
      print('Error al solicitar los permisos: $error');
      // Manejar el error de solicitud de permisos
    });
    return null;
  }

  void obtenerTokenFirebase(Usuario? usuario) async {
    final messaging = FirebaseMessaging.instance;
    const vapidKey =
        "BEFBbZpzZnDl-RhLiOFuppuuUb-bllW0g3skh2rzUwV2GeRpvyPxzCkibX7Wr7qz_xlE3wkCdR9cZWe4pCJszP8";

    try {
      token = await messaging.getToken(vapidKey: vapidKey);
      if (usuario?.tokenNotificacion != token) {
        usuario?.tokenNotificacion = token!;
        Fachada.getInstancia()?.actualizarTokenNotificaciones(token!);
      }
    } on TokenException catch (e) {
      _cerrarSesionToken(e.toString());
    } catch (error) {
      print('Error al obtener el token de Firebase: $error');
      // Manejar el error de solicitud del token de Firebase
      return null;
    }
  }

  Future<int?> obtenerCantidadNotificacionesSinLeer() async {
    try {
      return Fachada.getInstancia()?.cantidadNotifiacionesSinLeer();
    } on TokenException catch (e) {
      _cerrarSesionToken(e.toString());
    }
  }

  Usuario? obtenerUsuario() {
    return Fachada.getInstancia()?.getUsuario();
  }

  void escucharNotificacionEnPrimerPlano() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _vistaInicio?.aumentarEnUnoNotificacionesSinLeer();
        _vistaInicio?.mostrarMensaje("Has recibido una nueva notificacion");
      }
    });
  }

  void cerrarSesion() {
    html.window.localStorage.remove('usuario');
    Fachada.getInstancia()?.setUsuario(null);
  }

  void eliminarTokenNotificaciones() async {
    return Fachada.getInstancia()?.eliminarTokenNotificaciones();
  }

  void _cerrarSesionToken(String mensaje) {
    _vistaInicio?.mostrarMensajeError(mensaje);
    _vistaInicio?.cerrarSesion();
  }
}
