class Administrador {
  String correo;
  String nombre;
  bool habilitado;

  Administrador(
      {required this.correo, required this.nombre, required this.habilitado});

  Map<String, dynamic> toJson() => {
        "nombre": nombre,
        "correo": correo,
        "habilitado": habilitado,
      };
}
