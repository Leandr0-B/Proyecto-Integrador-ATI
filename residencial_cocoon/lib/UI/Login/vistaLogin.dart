import 'package:flutter/material.dart';
import 'package:residencial_cocoon/Controladores/controllerVistaLogin.dart';
import 'package:residencial_cocoon/UI/Login/iVistaLogin.dart';
import 'package:residencial_cocoon/UI/Inicio/vistaInicio.dart';
import 'package:residencial_cocoon/Dominio/Modelo/usuario.dart';

class LoginPage extends StatefulWidget {
  static String id = '/login';

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> implements IVistaLogin {
  String _ci = '';
  String _clave = '';
  ControllerUsuario? controller;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    controller = ControllerUsuario(mostrarMensaje: mostrarMensaje);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final maxWidth = constraints.maxWidth;

              final isMobile = maxWidth <= 600;
              final isTablet = maxWidth > 600 && maxWidth <= 1024;
              final isLargeScreen = maxWidth > 1024;

              double formWidthFactor;

              if (isMobile) {
                formWidthFactor = 0.8;
              } else if (isTablet) {
                formWidthFactor = 0.6;
              } else if (isLargeScreen) {
                formWidthFactor = 0.4;
              } else {
                formWidthFactor = 0.3;
              }

              return FractionallySizedBox(
                widthFactor: formWidthFactor,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Iniciar Sesión',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15.0),
                      _userTextField(),
                      const SizedBox(height: 15.0),
                      _passwordTextField(),
                      const SizedBox(height: 50.0),
                      _bottonLogin(),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _userTextField() {
    return StreamBuilder(
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: TextField(
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              icon: Icon(Icons.account_box),
              labelText: 'Cedula de identidad',
            ),
            onChanged: (value) {
              _ci = value;
            },
          ),
        );
      },
      stream: null,
    );
  }

  Widget _passwordTextField() {
    return StreamBuilder(
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: TextField(
            keyboardType: TextInputType.emailAddress,
            obscureText: true,
            decoration: const InputDecoration(
              icon: Icon(Icons.lock),
              labelText: 'Contraseña',
            ),
            onChanged: (value) {
              _clave = value;
            },
          ),
        );
      },
      stream: null,
    );
  }

  Widget _bottonLogin() {
    return StreamBuilder(
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: _isLoading ? null : _eventoLogin,
              style: TextButton.styleFrom(
                backgroundColor: Colors.amber,
                elevation: 10.0,
                padding: const EdgeInsets.symmetric(vertical: 15.0),
              ),
              child: _isLoading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Cargando...'),
                        SizedBox(width: 10),
                        CircularProgressIndicator(),
                      ],
                    )
                  : const Text(
                      'Ingresar',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        );
      },
      stream: null,
    );
  }

  void _eventoLogin() async {
    setState(() {
      _isLoading = true;
    });

    Usuario? u = await controller?.loginUsuario(_ci, _clave);
    if (u != null) {
      ingreso(u);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void ingreso(Usuario usuario) {
    Navigator.pushReplacementNamed(
      context,
      InicioPage.id,
      arguments: usuario,
    );
  }

  @override
  void mostrarMensaje(String mensaje) {
    final snackBar = SnackBar(content: Text(mensaje));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
