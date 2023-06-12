import 'package:flutter/material.dart';
import 'package:residencial_cocoon/Dominio/Modelo/rol.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';
import 'package:residencial_cocoon/UI/SideBar/sideBarHeader.dart';

class InicioPage extends StatelessWidget {
  static String id = 'inicio';
  final Usuario? usuario;

  InicioPage({required this.usuario});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: Text("Rapid Tech"),
      ),
      body: Center(
        child: Text("Contenido de InicioPage"),
      ),
      drawer: MyDrawerList(context,
          usuario: usuario), // Pasar context como argumento
    );
  }
}

class MyHomePage extends StatefulWidget {
  final Usuario? usuario;

  MyHomePage({required this.usuario});

  @override
  _MyHomePageState createState() => _MyHomePageState(usuario: usuario);
}

class _MyHomePageState extends State<MyHomePage> {
  var currentPage = DrawerSections.inicio;
  final Usuario? usuario;

  _MyHomePageState({required this.usuario});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: Text("Rapid Tech"),
      ),
      body: Center(
        child: Text("Contenido de MyHomePage"),
      ),
      drawer: MyDrawerList(context,
          usuario: usuario), // Pasar context como argumento
    );
  }
}

class MyDrawerList extends StatelessWidget {
  final BuildContext context; // Agregar una propiedad context
  final Usuario? usuario;

  MyDrawerList(this.context,
      {required this.usuario}); // Constructor que recibe el argumento context

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: [
            MyHederDrawer(),
            //Botones y permisos de los botones
            menuItem(1, "Inicio", Icons.home),
            if (usuario?.administrador == 1) ...[
              menuItem(2, "Usuarios", Icons.people_alt_outlined),
            ],
          ],
        ),
      ),
    );
  }

  Widget menuItem(int id, String title, IconData icon) {
    return ListTile(
      onTap: () {
        Navigator.pop(context);
        // Aquí puedes agregar la lógica para manejar la selección del elemento del menú
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
  sucursales,
}
