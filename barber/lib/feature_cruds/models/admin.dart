class Administrador {
  String correo;
  String nombre;

  Administrador({required this.correo, required this.nombre});

  Map<String, dynamic> toJson() => {
        "nombre": nombre,
        "correo": correo,
      };
}
