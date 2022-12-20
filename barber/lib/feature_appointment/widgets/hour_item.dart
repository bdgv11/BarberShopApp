import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class HourItem extends StatelessWidget {
  //
  final String barbero;
  final String cliente;
  final String fecha;
  final String hora;
  final bool horaDisponible;
  final String tipoServicio;
  final bool diaDisponible;
  final QueryDocumentSnapshot _snapshot;
  final String clienteDesdeSeleccionDeCita;
  final String servicioDesdeSeleccionDeCita;

  HourItem(this._snapshot, this.clienteDesdeSeleccionDeCita,
      this.servicioDesdeSeleccionDeCita,
      {super.key})
      : barbero = _snapshot.get('Barbero') as String,
        cliente = _snapshot.get('Cliente') as String,
        fecha = _snapshot.get('Fecha') as String,
        hora = _snapshot.get('Hora') as String,
        horaDisponible = _snapshot.get('HoraDisponible') as bool,
        diaDisponible = _snapshot.get('DiaDisponible') as bool,
        tipoServicio = _snapshot.get('TipoServicio') as String;

  late String _hora;

  @override
  Widget build(BuildContext context) {
    if (horaDisponible) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 50,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          onPressed: () {
            _hora = hora;

            showDialog(
              context: context,
              builder: (BuildContext context) {
                return Platform.isIOS
                    ? cupertinoDialog(context)
                    : androidDialog(context);
              },
            );
          },
          child: Text(
            hora,
            style: const TextStyle(
                color: Colors.black,
                fontFamily: 'Barlow',
                fontWeight: FontWeight.bold),
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 30,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          onPressed: null,
          child: Text(
            hora,
            style: const TextStyle(
                color: Colors.black,
                fontFamily: 'Barlow',
                fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }

  Widget errorServicioVacio(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoAlertDialog(
        title: const Text(
          'Error',
          style: TextStyle(
              fontFamily: 'Barlow', fontWeight: FontWeight.w900, fontSize: 20),
        ),
        content: const Text(
          'Asegurese de seleccionar el servicio y barbero.',
          style: TextStyle(
              fontFamily: 'Barlow', fontWeight: FontWeight.w900, fontSize: 20),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      );
    } else {
      return const AlertDialog(
        title: Text(
          'Error',
          style: TextStyle(
              fontFamily: 'Barlow', fontWeight: FontWeight.w900, fontSize: 20),
        ),
        content: Text(
          'Asegurese de seleccionar el servicio y barbero.',
          style: TextStyle(
              fontFamily: 'Barlow', fontWeight: FontWeight.w900, fontSize: 20),
        ),
      );
    }
  }

  Widget cupertinoDialog(BuildContext context) {
    return servicioDesdeSeleccionDeCita.isNotEmpty
        ? CupertinoAlertDialog(
            title: const Text(
              'Resumen',
              style: TextStyle(
                  fontFamily: 'Barlow',
                  fontWeight: FontWeight.w900,
                  fontSize: 20),
            ),
            content: Text(
              'Fecha: $fecha\nServicio: $servicioDesdeSeleccionDeCita\nBarbero: $barbero\nHora: $_hora\n¿Desea agendar la cita?',
              style: const TextStyle(
                  fontFamily: 'Barlow',
                  fontWeight: FontWeight.w900,
                  fontSize: 20),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              TextButton(
                onPressed: () {
                  _updateHour();
                  Navigator.of(context).pop();
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Agendar',
                  ),
                ),
              ),
            ],
          )
        : errorServicioVacio(context);
  }

  Widget androidDialog(BuildContext context) {
    return servicioDesdeSeleccionDeCita.isNotEmpty
        ? AlertDialog(
            title: const Text(
              'Resumen',
              style: TextStyle(
                  fontFamily: 'Barlow',
                  fontWeight: FontWeight.w900,
                  fontSize: 20),
            ),
            content: Text(
              'Fecha: $fecha\nServicio: $tipoServicio\nBarbero: $barbero\nHora: $_hora\n¿Desea agendar la cita?',
              style: const TextStyle(
                  fontFamily: 'Barlow',
                  fontWeight: FontWeight.w900,
                  fontSize: 20),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              TextButton(
                onPressed: () {
                  _updateHour();
                  Navigator.of(context).pop();
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Agendar',
                  ),
                ),
              ),
            ],
          )
        : errorServicioVacio(context);
  }

  void _updateHour() {
    // Este metodo va a poner en false (ocupada) el valor de la hora de ese dia en especifico!
    FirebaseFirestore.instance.collection('Cita').doc(_snapshot.id).update({
      'TipoServicio': servicioDesdeSeleccionDeCita,
      'HoraDisponible': false,
      'Cliente': clienteDesdeSeleccionDeCita,
    });
  }
}
