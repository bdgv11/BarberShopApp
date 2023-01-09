class ProductService {
  String nombre;
  int precio;
  String? imageURL;
  bool disponible;
  String tipo;

  ProductService(
      {required this.nombre,
      required this.precio,
      required this.imageURL,
      required this.disponible,
      required this.tipo});

  ProductService.withOutImage(
      {required this.nombre,
      required this.precio,
      required this.disponible,
      required this.tipo});

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'precio': precio,
        'imageURL': imageURL,
        'disponible': disponible,
        'tipo': tipo,
      };

  Map<String, dynamic> toJsonWithOutImage() => {
        'nombre': nombre,
        'precio': precio,
        'disponible': disponible,
        'tipo': tipo,
      };
}
