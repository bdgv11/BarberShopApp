class Barber {
  String nombre;
  String descripcion;
  String? imagenUrl;
  bool disponible;
  String correoElectronico;

  Barber(
      {required this.nombre,
      required this.descripcion,
      required this.correoElectronico,
      required this.disponible,
      required this.imagenUrl});

  Barber.withOutImage({
    required this.nombre,
    required this.descripcion,
    required this.correoElectronico,
    required this.disponible,
  });

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'descripcion': descripcion,
        'correoElectronico': correoElectronico,
        'disponible': disponible,
        'imagenUrl': imagenUrl,
      };

  Map<String, dynamic> toJsonWithoutImage() => {
        'nombre': nombre,
        'descripcion': descripcion,
        'correoElectronico': correoElectronico,
        'disponible': disponible,
      };
}
