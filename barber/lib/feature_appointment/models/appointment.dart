import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  String barbero;
  String cliente;
  bool diaDisponible;
  Timestamp fecha;
  String hora;
  bool horaDisponible;
  String tipoServicio;

  Appointment({
    required this.barbero,
    required this.cliente,
    required this.diaDisponible,
    required this.fecha,
    required this.hora,
    required this.horaDisponible,
    required this.tipoServicio,
  });

  Map<String, dynamic> toJson() => {
        'barbero': barbero,
        'cliente': cliente,
        'disDisponible': diaDisponible,
        'fecha': fecha,
        'hora': hora,
        'horaDisponible': horaDisponible,
        'tipoServicio': tipoServicio,
      };
}
