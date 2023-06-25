import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';
import 'package:residencial_cocoon/Servicios/fachada.dart';
import '../../Firebase/firebase_options.dart';

class ControllerVistaInicio {
  String? token;
  //Atributos

  //Constructor
  ControllerVistaInicio();

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
      if (settings.authorizationStatus == AuthorizationStatus.authorized &&
          token == null) {
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
      print('Token de Firebase: $token');
      if (usuario?.tokenNotificacion != token) {
        print("hay que actualizar el token ${usuario?.tokenNotificacion}");
        usuario?.tokenNotificacion = token!;
        Fachada.getInstancia()?.actualizarTokenNotificaciones(token!);
      }
    } catch (error) {
      print('Error al obtener el token de Firebase: $error');
      // Manejar el error de solicitud del token de Firebase
      return null;
    }
  }
}
