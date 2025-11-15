class Doctor {
  final String id;
  final String nombre;
  final String apellidos;

  Doctor(this.id, this.nombre, this.apellidos);

  String get fullName => "$nombre $apellidos";
}
