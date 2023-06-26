import 'package:flutter/material.dart';
import 'package:residencial_cocoon/Controladores/controllerVistaInicio.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';
import 'package:residencial_cocoon/UI/Geriatra/vistaSalidaMedica.dart';
import 'package:residencial_cocoon/UI/Geriatra/vistaVisitaMedicaExterna.dart';
import 'package:residencial_cocoon/UI/Inicio/iVistaInicio.dart';
import 'package:residencial_cocoon/UI/SideBar/sideBarHeader.dart';
import 'package:residencial_cocoon/UI/Usuarios/vistaAltaFuncionario.dart';
import 'package:residencial_cocoon/UI/Usuarios/vistaAltaResidente.dart';
import 'package:residencial_cocoon/UI/Usuarios/vistaCambioContrasena.dart';
import 'package:residencial_cocoon/UI/Usuarios/vistaListaUsuario.dart';
import 'dart:html' as html;

class VistaInicio extends StatefulWidget {
  static String id = '/inicio';

  VistaInicio();

  @override
  _VistaInicioState createState() => _VistaInicioState();
}

//Get set

class _VistaInicioState extends State<VistaInicio>
    with WidgetsBindingObserver
    implements IVistaInicio {
  var currentPage = DrawerSections.inicio;
  Usuario? _usuario;
  ControllerVistaInicio _controller = ControllerVistaInicio.empty();
  Future<int?> _cantidadNotificaciones = Future.value(0);
  bool _isPageVisible = true;

  @override
  void initState() {
    super.initState();
    _controller = ControllerVistaInicio(this);
    _usuario = _controller.obtenerUsuario();
    _controller.inicializarFirebase(_usuario);
    _controller.escucharNotificacionEnPrimerPlano();
    obtenerCantidadNotificacionesSinLeer();

    // esto lo usamos para solucionar el problema de las notificaciones en segundo plano y la conexion con flutter
    // cuando maximizas la aplicacion o regresas a la pestania, hara el chequeo de cuantas notificaciones sin leer tienes para poder
    // actualizar la campanita
    WidgetsBinding.instance?.addObserver(this);
    html.document.onVisibilityChange.listen((event) {
      setState(() {
        _isPageVisible = _isPageVisible =
            html.document.hidden != null ? !html.document.hidden! : true;
      });
      if (_isPageVisible) {
        obtenerCantidadNotificacionesSinLeer();
      } else {}
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // La página se ha mostrado nuevamente
      setState(() {
        _isPageVisible = true;
      });
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      setState(() {
        _isPageVisible = false;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void obtenerCantidadNotificacionesSinLeer() {
    _cantidadNotificaciones =
        _controller.obtenerCantidadNotificacionesSinLeer();
    setState(() {});
  }

  @override
  void aumentarEnUnoNotificacionesSinLeer() {
    _cantidadNotificaciones =
        _cantidadNotificaciones.then((valor) => valor! + 1);
    setState(() {});
  }

  @override
  void mostrarMensaje(String mensaje) {
    final snackBar = SnackBar(content: Text(mensaje));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void onPageSelected(DrawerSections page) {
    setState(() {
      currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget container;

    switch (currentPage) {
      case DrawerSections.inicio:
        container = Container();
        break;
      case DrawerSections.listaUsuarios:
        container = VistaListaUsuario();
        break;
      case DrawerSections.altaFuncionario:
        container = VistaAltaFuncionario();
        break;
      case DrawerSections.altaResidente:
        container = VistaAltaResidente();
        break;
      case DrawerSections.cambioContrasena:
        container = VistaCambioContrasena();
        break;
      case DrawerSections.salidaMedica:
        container = VistaSalidaMedica();
        break;
      case DrawerSections.visitaMedica:
        container = VistaVisitaMedicaExterna();
        break;
      default:
        container = Container();
        break;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(225, 183, 72, 1),
        title: const Text("Grupo Cocoon"),
        actions: [
          Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(right: 30, top: 5),
                child: IconButton(
                  iconSize: 28, // Ajusta el tamaño del ícono de notificación
                  icon: const Icon(Icons.notifications),
                  onPressed: () {
                    // Acción al hacer clic en el ícono de campana
                    onPageSelected(DrawerSections.notificaciones);
                  },
                ),
              ),
              FutureBuilder<int?>(
                future: _cantidadNotificaciones,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final int cantidadNotificaciones = snapshot.data!;
                    return Positioned(
                      top: 5,
                      right: 32,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 21,
                          minHeight: 21,
                        ),
                        child: Center(
                          child: Text(
                            cantidadNotificaciones < 99
                                ? cantidadNotificaciones.toString()
                                : "99+",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return const Text("Error al cargar las notificaciones");
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ],
          ),
        ],
      ),
      body: container,
      drawer: MyDrawerList(
        context: context,
        usuario: _usuario,
        onPageSelected: onPageSelected,
      ),
    );
  }
}

class MyDrawerList extends StatelessWidget {
  final BuildContext context;
  final Usuario? usuario;
  final ValueChanged<DrawerSections> onPageSelected;

  const MyDrawerList({
    super.key,
    required this.context,
    required this.usuario,
    required this.onPageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.black, width: 0.25),
                ),
              ),
              child: const SideBarHeader(),
            ),
            menuItem(1, "Inicio", Icons.home, DrawerSections.inicio),
            if (usuario?.administrador == 1) ...[
              ExpansionTile(
                leading: const Icon(Icons.people_alt_outlined,
                    size: 20, color: Colors.black),
                title: const Text("Usuarios",
                    style: TextStyle(color: Colors.black, fontSize: 16)),
                children: [
                  menuItem(2, "Lista de Usuarios", Icons.list,
                      DrawerSections.listaUsuarios),
                  menuItem(3, "Alta de Funcionario", Icons.person_add,
                      DrawerSections.altaFuncionario),
                  menuItem(4, "Alta de Residente", Icons.person_add,
                      DrawerSections.altaResidente),
                ],
              ),
            ],
            if (usuario!.esGeriatra() || usuario?.administrador == 1) ...[
              ExpansionTile(
                leading: const Icon(Icons.badge_sharp,
                    size: 20, color: Colors.black),
                title: const Text("Geriatra",
                    style: TextStyle(color: Colors.black, fontSize: 16)),
                children: [
                  menuItem(
                      6,
                      "Registrar Salida Medica",
                      Icons.emoji_transportation_outlined,
                      DrawerSections.salidaMedica),
                  menuItem(
                      7,
                      "Registrar Visita Medica Externa",
                      Icons.medical_services_sharp,
                      DrawerSections.visitaMedica),
                ],
              ),
            ],
            menuItem(5, "Cambio de contraseña", Icons.password,
                DrawerSections.cambioContrasena),
          ],
        ),
      ),
    );
  }

  Widget menuItem(int id, String title, IconData icon, DrawerSections page) {
    return ListTile(
      onTap: () {
        Navigator.pop(context);
        onPageSelected(page);
      },
      leading: Icon(
        icon,
        size: 20,
        color: Colors.black,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
        ),
      ),
    );
  }
}

enum DrawerSections {
  inicio,
  listaUsuarios,
  altaFuncionario,
  altaResidente,
  cambioContrasena,
  salidaMedica,
  visitaMedica,
  notificaciones
}
