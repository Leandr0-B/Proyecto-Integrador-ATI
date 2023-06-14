import 'package:flutter/material.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';
import 'package:residencial_cocoon/UI/SideBar/sideBarHeader.dart';
import 'package:residencial_cocoon/UI/Usuarios/vistaAltaUsuario.dart';

class InicioPage extends StatefulWidget {
  static String id = 'inicio';
  final Usuario? usuario;

  InicioPage({required this.usuario});

  @override
  _InicioPageState createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  var currentPage = DrawerSections.inicio;

  @override
  Widget build(BuildContext context) {
    var container;
    switch (currentPage) {
      case (DrawerSections.inicio):
        container =
            Container(); // Aquí, muestra algo diferente. La línea anterior causaba un bucle infinito.
        break;
      case (DrawerSections.usuarios):
        container = NuevoUsuarioPage();
        break;
      default:
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(225, 183, 72, 1),
        title: Text("Grupo Cocoon"),
      ),
      body: container,
      drawer: MyDrawerList(
        context: context,
        usuario: widget.usuario,
        onPageSelected: (page) {
          setState(() {
            currentPage = page;
          });
        },
      ),
    );
  }
}

class MyDrawerList extends StatelessWidget {
  final BuildContext context;
  final Usuario? usuario;
  final ValueChanged<DrawerSections> onPageSelected;

  MyDrawerList({
    required this.context,
    required this.usuario,
    required this.onPageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: [
            MyHederDrawer(),
            menuItem(1, "Inicio", Icons.home, DrawerSections.inicio),
            if (usuario?.administrador == 1) ...[
              menuItem(2, "Usuarios", Icons.people_alt_outlined,
                  DrawerSections.usuarios),
            ],
          ],
        ),
      ),
    );
  }

  Widget menuItem(int id, String title, IconData icon, DrawerSections page) {
    return ListTile(
      onTap: () {
        Navigator.pop(context);
        onPageSelected(
            page); // Aquí cambiamos la página usando el callback en lugar de hacer la navegación
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
}
