import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:barber/feature_home/widgets/drawer_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:barber/utils/globals.dart' as globals;

import '../../feature_home/widgets/bottom_navigation.dart';

class DailyReport extends StatefulWidget {
  final User user;
  const DailyReport({super.key, required this.user});

  @override
  State<DailyReport> createState() => _DailyReportState();
}

class _DailyReportState extends State<DailyReport> {
  late User _user;

  @override
  void initState() {
    _user = widget.user;
    globals.totalDelDia = 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //
    double heightMediaQuery = MediaQuery.of(context).size.height;
    double widthMediaQuery = MediaQuery.of(context).size.width;
    //
    String getFormattedDate(String year, String month, String day) {
      String fecha;
      String m = '';
      String d = '';
      if (month.length == 1) {
        m = '0$month';
      } else {
        m = month;
      }
      if (day.length == 1) {
        d = '0$day';
      } else {
        d = day;
      }
      fecha = '$year-$m-$d';
      return fecha;
    }

    String fecha = getFormattedDate(DateTime.now().year.toString(),
        DateTime.now().month.toString(), DateTime.now().day.toString());

    DateTime dateTimeFecha = DateTime.parse(fecha);
    dateTimeFecha.millisecondsSinceEpoch;
    //
    int montoTotal = 0;
    return Scaffold(
      drawer: DrawerUserWidget(user: _user),
      appBar: AppBar(backgroundColor: Colors.black87),
      body: Container(
        height: heightMediaQuery,
        width: widthMediaQuery,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Colors.black,
              Color.fromARGB(255, 104, 34, 4),
              Color.fromARGB(255, 187, 194, 188),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Citas del día',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontFamily: 'OpenSans',
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const Divider(
                  thickness: 0.5,
                  color: Colors.white,
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Hora',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontFamily: 'OpenSans',
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Servicio & Precio',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontFamily: 'OpenSans',
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Estado',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontFamily: 'OpenSans',
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 500,
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('Cita')
                        .where('fecha',
                            isEqualTo: Timestamp.fromDate(dateTimeFecha))
                        .orderBy('hora', descending: false)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (snapshot.hasData) {
                        return ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            final DocumentSnapshot documentSnapshot =
                                snapshot.data!.docs[index];

                            int total = documentSnapshot['precio'];

                            montoTotal = montoTotal + total;

                            globals.totalDelDia = montoTotal;

                            return FadeIn(
                              delay: const Duration(milliseconds: 100),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 5,
                                color: documentSnapshot['estadoCita'] ==
                                        'Finalizada'
                                    ? Colors.lightGreen
                                    : Colors.black45,
                                child: ListTile(
                                  leading: Text(
                                    '${documentSnapshot['hora']}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'OpenSans',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  title: Text(
                                    documentSnapshot['tipoServicio'] != ''
                                        ? '${documentSnapshot['tipoServicio']} / ${documentSnapshot['precio']}'
                                        : 'Espacio libre',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'OpenSans',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${documentSnapshot['nombreCliente']}\n${documentSnapshot['barbero']}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'OpenSans',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      overflow: TextOverflow.visible,
                                    ),
                                  ),
                                  isThreeLine: true,
                                  trailing: Text(
                                    documentSnapshot['estadoCita'] == 'Creada'
                                        ? ''
                                        : documentSnapshot['estadoCita'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'OpenSans',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Platform.isIOS
                                            ? cupertinoDialog(
                                                context,
                                                documentSnapshot[
                                                    'tipoServicio'],
                                                documentSnapshot['barbero'],
                                                documentSnapshot['hora'],
                                                documentSnapshot.id,
                                                documentSnapshot[
                                                    'nombreCliente'],
                                                documentSnapshot['precio'],
                                              ) //cupertinoDialog(context)
                                            : androidDialog(
                                                context,
                                                documentSnapshot[
                                                    'tipoServicio'],
                                                documentSnapshot['barbero'],
                                                documentSnapshot['hora'],
                                                documentSnapshot.id,
                                                documentSnapshot[
                                                    'nombreCliente'],
                                                documentSnapshot['precio'],
                                              ); //androidDialog(context)
                                      },
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      }
                      return const CircularProgressIndicator();
                    },
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [Text(globals.totalDelDia.toString())],
                )
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationWidget(user: _user),
    );
  }

  Widget cupertinoDialog(BuildContext context, String servicio, String barbero,
      String hora, String id, String cliente, int precio) {
    return CupertinoAlertDialog(
      title: const Text(
        '¿Desea finalizar, liberar o poner la cita como agendada nuevamente?',
        style: TextStyle(
            fontFamily: 'OpenSans', fontWeight: FontWeight.w900, fontSize: 20),
      ),
      // ignore: prefer_const_constructors
      content: Text(
        'Cliente: $cliente\nServicio: $servicio\nBarbero: $barbero\nHora: $hora\nPrecio: $precio\n',
        style: const TextStyle(
            fontFamily: 'OpenSans',
            fontWeight: FontWeight.w900,
            fontSize: 15,
            overflow: TextOverflow.visible),
      ),
      actions: [
        TextButton(
          onPressed: () {
            FirebaseFirestore.instance.collection('Cita').doc(id).update(
              {
                'estadoCita': 'Creada',
                'horaDisponible': true,
                'idCliente': '',
                'nombreCliente': '',
                'precio': 0,
                'tipoServicio': ''
              },
            );
            Navigator.of(context).pop();
          },
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Liberar espacio',
              style: TextStyle(
                  fontFamily: 'OpenSans',
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  overflow: TextOverflow.ellipsis),
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            FirebaseFirestore.instance
                .collection('Cita')
                .doc(id)
                .update({'estadoCita': 'Agendada'});
            Navigator.of(context).pop();
          },
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Agendar nuevamente',
              style: TextStyle(
                  fontFamily: 'OpenSans',
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  overflow: TextOverflow.visible),
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            FirebaseFirestore.instance
                .collection('Cita')
                .doc(id)
                .update({'estadoCita': 'Finalizada', 'horaDisponible': false});
            Navigator.of(context).pop();
          },
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Finalizar Cita',
              style: TextStyle(
                  fontFamily: 'OpenSans',
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  overflow: TextOverflow.ellipsis),
            ),
          ),
        ),
      ],
    );
  }

  Widget androidDialog(BuildContext context, String servicio, String barbero,
      String hora, String id, String cliente, int precio) {
    return AlertDialog(
      title: const Text(
        '¿Desea finalizar, liberar o poner la cita como agendada nuevamente?',
        style: TextStyle(
            fontFamily: 'OpenSans', fontWeight: FontWeight.w900, fontSize: 20),
      ),
      // ignore: prefer_const_constructors
      content: Text(
        'Cliente: $cliente\nServicio: $servicio\nBarbero: $barbero\nHora: $hora\nPrecio: $precio\n',
        style: const TextStyle(
            fontFamily: 'OpenSans',
            fontWeight: FontWeight.w900,
            fontSize: 15,
            overflow: TextOverflow.visible),
      ),
      actions: [
        TextButton(
          onPressed: () {
            FirebaseFirestore.instance.collection('Cita').doc(id).update(
              {
                'estadoCita': 'Creada',
                'horaDisponible': true,
                'idCliente': '',
                'nombreCliente': '',
                'precio': 0,
                'tipoServicio': ''
              },
            );
            Navigator.of(context).pop();
          },
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Liberar espacio',
              style: TextStyle(
                  fontFamily: 'OpenSans',
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  overflow: TextOverflow.ellipsis),
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            FirebaseFirestore.instance
                .collection('Cita')
                .doc(id)
                .update({'estadoCita': 'Agendada'});
            Navigator.of(context).pop();
          },
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Agendar nuevamente',
              style: TextStyle(
                  fontFamily: 'OpenSans',
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  overflow: TextOverflow.visible),
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            FirebaseFirestore.instance
                .collection('Cita')
                .doc(id)
                .update({'estadoCita': 'Finalizada', 'horaDisponible': false});
            Navigator.of(context).pop();
          },
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Finalizar Cita',
              style: TextStyle(
                  fontFamily: 'OpenSans',
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  overflow: TextOverflow.ellipsis),
            ),
          ),
        ),
      ],
    );
  }
}
