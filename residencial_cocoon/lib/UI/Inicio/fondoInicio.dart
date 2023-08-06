import 'package:flutter/material.dart';

class FondoInicio extends StatefulWidget {
  @override
  State<FondoInicio> createState() => _FondoInicioState();
}

class _FondoInicioState extends State<FondoInicio> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            decoration: const BoxDecoration(
      image: DecorationImage(
        image: AssetImage('assets/images/fondo.png'),
        fit: BoxFit.cover,
      ),
    )));
  }
}
