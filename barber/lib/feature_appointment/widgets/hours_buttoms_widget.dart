import 'package:barber/feature_appointment/widgets/hour_item.dart';
import 'package:barber/firebase/connection_error.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class HorasWidget extends StatelessWidget {
  HorasWidget(
      {super.key,
      required this.barberoSeleccionado,
      required this.fecha,
      required this.servicioSeleccionado,
      required this.clienteDesdeSeleccionDeCita,
      required this.servicioDesdeSeleccionDeCita});

  String barberoSeleccionado;
  String fecha;
  String servicioSeleccionado;
  String clienteDesdeSeleccionDeCita;
  String servicioDesdeSeleccionDeCita;

  Stream<QuerySnapshot> getStream() => FirebaseFirestore.instance
      .collection("Cita")
      .where('Fecha', isEqualTo: fecha)
      .where('Barbero', isEqualTo: barberoSeleccionado)
      .orderBy('Hora', descending: false)
      .limit(9)
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: getStream(),
      builder: (context, horas) {
        if (horas.hasError) {
          return const ConnectionError();
        }
        if (horas.hasData) {
          final data = horas.data;

          if (data != null) {
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4),
              itemCount: data.docs.length,
              itemBuilder: (context, index) {
                return HourItem(data.docs[index], clienteDesdeSeleccionDeCita,
                    servicioDesdeSeleccionDeCita);
              },
            );
          }
        }
        return const CircularProgressIndicator();
      },
    );
  }
}
