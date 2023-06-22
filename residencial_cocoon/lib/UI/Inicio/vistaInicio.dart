import 'package:flutter/material.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';
import 'package:residencial_cocoon/UI/SideBar/sideBarHeader.dart';
import 'package:residencial_cocoon/UI/Usuarios/vistaAltaFuncionario.dart';
import 'package:residencial_cocoon/UI/Usuarios/vistaAltaResidente.dart';
import 'package:residencial_cocoon/UI/Usuarios/vistaCambioContrasena.dart';
import 'package:residencial_cocoon/UI/Usuarios/vistaListaUsuario.dart';

class VistaInicio extends StatefulWidget {
  static String id = '/inicio';
  final Usuario? usuario;

  VistaInicio({this.usuario});

  @override
  _VistaInicioState createState() => _VistaInicioState();
}

class _VistaInicioState extends State<VistaInicio> {
  var currentPage = DrawerSections.inicio;
  Usuario? usuario;
  bool isUsuariosSubMenuVisible = false;

  void onPageSelected(DrawerSections page) {
    setState(() {
      if (page == DrawerSections.usuarios) {
        isUsuariosSubMenuVisible = !isUsuariosSubMenuVisible;
      } else {
        currentPage = page;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    usuario = ModalRoute.of(context)?.settings.arguments as Usuario?;
    usuario ??= widget.usuario;

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
      default:
        container = Container();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(225, 183, 72, 1),
        title: Text("Grupo Cocoon"),
      ),
      body: container,
      drawer: MyDrawerList(
        context: context,
        usuario: usuario,
        onPageSelected: onPageSelected,
        isUsuariosSubMenuVisible: isUsuariosSubMenuVisible,
      ),
    );
  }
}

class MyDrawerList extends StatelessWidget {
  final BuildContext context;
  final Usuario? usuario;
  final ValueChanged<DrawerSections> onPageSelected;
  final bool isUsuariosSubMenuVisible;

  MyDrawerList({
    required this.context,
    required this.usuario,
    required this.onPageSelected,
    required this.isUsuariosSubMenuVisible,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.black, width: 0.25),
                ),
              ),
              child: SideBarHeader(),
            ),
            menuItem(1, "Inicio", Icons.home, DrawerSections.inicio),
            if (usuario?.administrador == 1) ...[
              ExpansionTile(
                leading: Icon(Icons.people_alt_outlined,
                    size: 20, color: Colors.black),
                title: Text("Usuarios",
                    style: TextStyle(color: Colors.black, fontSize: 16)),
                onExpansionChanged: (expanded) {
                  onPageSelected(DrawerSections.usuarios);
                },
                children: [
                  menuItem(2, "Lista de Usuarios", Icons.list,
                      DrawerSections.listaUsuarios),
                  menuItem(3, "Alta de Funcionario", Icons.person_add,
                      DrawerSections.altaFuncionario),
                  menuItem(4, "Alta de Residente", Icons.person_add,
                      DrawerSections.altaResidente),
                ],
              ),
            ] else
              ...[],
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
        style: TextStyle(
          color: Colors.black,
          fontSize: 16,
        ),
      ),
    );
  }
}

enum DrawerSections {
  inicio,
  usuarios,
  altaFuncionario,
  altaResidente,
  listaUsuarios,
  cambioContrasena,
}
