import 'package:residencial_cocoon/Dominio/Modelo/familiar.dart';

abstract class IRol {
  bool esResidente();
  List<Familiar> getFamiliares();
  Map<String, dynamic> toJson();
}
