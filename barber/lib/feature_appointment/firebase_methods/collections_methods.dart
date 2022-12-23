import 'package:cloud_firestore/cloud_firestore.dart';

List<String> horas = [
  '10:00 am',
  '11:00 am',
  '12:00 md',
  '1:00 pm',
  '2:00 pm',
  '3:00 pm',
  '4:00 pm',
  '5:00 pm',
  '6:00 pm'
];

//List<String> barberos = ['Barbero1', 'Barbero2'];

class CollectionMethods {
  void addHours(
      String barbero, String cliente, Timestamp fecha, String tipoServicio) {
    for (var i = 0; i < horas.length; i++) {
      FirebaseFirestore.instance.collection('Cita').add({
        'Barbero': barbero,
        'Cliente': '',
        'Fecha': fecha,
        'Hora': horas[i],
        'HoraDisponible': true,
        'DiaDisponible': true,
        'TipoServicio': ''
      });
    }
  }
}
