import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  String barbero;
  String idCliente;
  bool diaDisponible;
  Timestamp fecha;
  String hora;
  bool horaDisponible;
  String tipoServicio;
  int precio;
  String nombreCliente;
  String estadoCita;

  Appointment({
    required this.barbero,
    required this.idCliente,
    required this.diaDisponible,
    required this.fecha,
    required this.hora,
    required this.horaDisponible,
    required this.tipoServicio,
    required this.precio,
    required this.nombreCliente,
    required this.estadoCita,
  });

  Map<String, dynamic> toJson() => {
        'barbero': barbero,
        'idCliente': idCliente,
        'disDisponible': diaDisponible,
        'fecha': fecha,
        'hora': hora,
        'horaDisponible': horaDisponible,
        'tipoServicio': tipoServicio,
        'precio': precio,
        'nombreCliente': nombreCliente,
        'estadoCita': estadoCita
      };
}
