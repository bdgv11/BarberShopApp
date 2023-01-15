import 'dart:io';
import 'package:barber/feature_appointment/models/appointment.dart';
import 'package:barber/feature_home/widgets/bottom_navigation.dart';
import 'package:barber/feature_home/widgets/drawer_widget.dart';
import 'package:barber/utils/general.dart';
import 'package:barber/utils/globals.dart' as globals;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../widgets/service_widget.dart';

class AppointmentScreen extends StatefulWidget {
  final User user;
  const AppointmentScreen({super.key, required this.user});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  //

  late User _user;
  DateTime today = DateTime.now();

  bool existInfo = false;
  String barberoSeleccionado = '';
  int indexBarber = 100;
  late String _hora;

  @override
  void initState() {
    _user = widget.user;
    globals.indexServicio = 100;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double heightMediaQuery = MediaQuery.of(context).size.height;
    double widthMediaQuery = MediaQuery.of(context).size.width;
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

    String fecha = getFormattedDate(
        today.year.toString(), today.month.toString(), today.day.toString());
    String fechaShowDialog = '${today.day}/${today.month}/${today.year}';

    DateTime dateTimeFecha = DateTime.parse(fecha);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black87,
        ),
        drawer: DrawerUserWidget(user: _user),
        body: Container(
          height: heightMediaQuery,
          width: widthMediaQuery,
          padding: const EdgeInsets.all(20),
          decoration: myBoxDecoration,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Divider(
                  thickness: 1,
                  color: Colors.white,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Fecha: ${today.day}/${today.month}/${today.year}',
                      textAlign: TextAlign.left,
                      style: myTextH1,
                    ),
                  ],
                ),
                const Divider(
                  thickness: 1,
                  color: Colors.white,
                ),
                const Padding(padding: EdgeInsets.all(2)),
                TableCalendar(
                  //Available days
                  enabledDayPredicate: (date) {
                    return (date.weekday != DateTime.sunday);
                  },
                  //
                  selectedDayPredicate: (day) => isSameDay(day, today),
                  focusedDay: today,
                  firstDay: DateTime.now(),
                  lastDay: DateTime.now().add(const Duration(days: 15)),
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  locale: 'es_ES',
                  onDaySelected: _focusDaySelected,
                  calendarFormat: CalendarFormat.twoWeeks,
                  weekendDays: const <int>[DateTime.sunday],
                  //Header Style
                  headerStyle: HeaderStyle(
                    headerPadding: const EdgeInsets.all(8),
                    rightChevronIcon: const Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                    ),
                    leftChevronIcon: const Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                    ),
                    titleCentered: true,
                    formatButtonVisible: false,
                    titleTextStyle: myTextH1,
                  ),

                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekdayStyle: TextStyle(color: Colors.white),
                    weekendStyle: TextStyle(color: Colors.white),
                  ),
                  calendarStyle: const CalendarStyle(
                    defaultDecoration: BoxDecoration(
                        shape: BoxShape.rectangle, color: Colors.white70),
                    defaultTextStyle: TextStyle(color: Colors.black),
                    selectedTextStyle: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                    selectedDecoration: BoxDecoration(
                        color: Colors.teal, shape: BoxShape.rectangle),
                    todayTextStyle: TextStyle(color: Colors.black),
                    todayDecoration: BoxDecoration(
                        shape: BoxShape.rectangle, color: Colors.white70),
                  ),
                ),
                const Padding(padding: EdgeInsets.all(5)),
                const ServiceWidget(),

                const Padding(padding: EdgeInsets.all(8)),
                const Divider(
                  thickness: 1,
                  color: Colors.white,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Barbero: $barberoSeleccionado',
                      textAlign: TextAlign.right,
                      style: myTextH1,
                    ),
                  ],
                ),
                const Divider(
                  thickness: 1,
                  color: Colors.white,
                ),
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('Barbero')
                      .where('disponible', isEqualTo: true)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final DocumentSnapshot documentSnapshot =
                            snapshot.data!.docs[index];
                        return SizedBox(
                          height: 67,
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            leading: CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(
                                documentSnapshot['imagenUrl'],
                              ),
                            ),
                            title: Row(
                              children: <Widget>[
                                Text(
                                  documentSnapshot['nombre'],
                                  style: myTextH1,
                                ),
                                Icon(Icons.check_circle,
                                    color: indexBarber == index
                                        ? Colors.teal
                                        : Colors.grey),
                              ],
                            ),
                            subtitle: Text(
                              documentSnapshot['descripcion'],
                              style: myTextH1,
                            ),
                            isThreeLine: true,
                            onTap: () {
                              setState(() {
                                indexBarber = index;
                                barberoSeleccionado =
                                    documentSnapshot['nombre'].toString();
                                getInfo(fecha, barberoSeleccionado);
                              });
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
                // test stream Builder

                // TIME SELECTION
                const Divider(
                  thickness: 1,
                  color: Colors.white,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Hora: ',
                      textAlign: TextAlign.right,
                      style: myTextH1,
                    ),
                  ],
                ),
                const Divider(
                  thickness: 1,
                  color: Colors.white,
                ),
                const Padding(padding: EdgeInsets.all(8)),

                SizedBox(
                  height: 300,
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('Cita')
                        .where('fecha',
                            isEqualTo: Timestamp.fromMillisecondsSinceEpoch(
                                dateTimeFecha.millisecondsSinceEpoch))
                        .where('barbero', isEqualTo: barberoSeleccionado)
                        .orderBy('hora', descending: false)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      return GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final DocumentSnapshot documentSnapshot =
                              snapshot.data!.docs[index];

                          if (documentSnapshot['horaDisponible'] == true) {
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
                                  _hora = documentSnapshot['hora'];
                                  String id =
                                      snapshot.data!.docs[index].reference.id;

                                  if (globals.servicioSeleccionado == '') {
                                    const snack = SnackBar(
                                      content:
                                          Text('Debe seleccionar un servicio'),
                                      duration: Duration(seconds: 2),
                                      backgroundColor: Colors.red,
                                    );
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snack);
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Platform.isIOS
                                            ? cupertinoDialog(
                                                context,
                                                fechaShowDialog,
                                                globals.servicioSeleccionado,
                                                barberoSeleccionado,
                                                _hora,
                                                id,
                                                _user.uid.toString(),
                                              ) //cupertinoDialog(context)
                                            : androidDialog(
                                                context,
                                                fechaShowDialog,
                                                globals.servicioSeleccionado,
                                                barberoSeleccionado,
                                                _hora,
                                                id,
                                                _user.uid.toString(),
                                              ); //androidDialog(context);
                                      },
                                    );
                                  }
                                },
                                child: Text(
                                  documentSnapshot['hora'],
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'OpenSans',
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
                                  documentSnapshot['hora'],
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'OpenSans',
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationWidget(
          user: _user,
        ),
      ),
    );
  }

  /// _focusDaySelected(DateTime day, DateTime focusedDay) is a function that takes two parameters, day
  /// and focusedDay, and sets the state of the app to the day selected
  ///
  /// Args:
  ///   day (DateTime): The day that was selected.
  ///   focusedDay (DateTime): The day that is currently focused.
  void _focusDaySelected(DateTime day, DateTime focusedDay) {
    setState(() {
      today = day;
      barberoSeleccionado = '';
      indexBarber = 100;
    });
  }

  /// It checks if there is information in the database for the selected date and barber.
  ///
  /// Args:
  ///   fecha (String): The date selected by the user.
  ///   barbero (String): Barber's name
  void getInfo(String fecha, String barbero) async {
    DateTime dateTimeFecha = DateTime.parse(fecha);
    CollectionReference citas = FirebaseFirestore.instance.collection('Cita');
    QuerySnapshot query = await citas
        .where('fecha',
            isEqualTo: Timestamp.fromMillisecondsSinceEpoch(
                dateTimeFecha.millisecondsSinceEpoch))
        .where('barbero', isEqualTo: barbero)
        .orderBy('hora', descending: false)
        .get();

    if (query.docs.isNotEmpty) {
      // SI NO ESTA VACIO CAMBIA EL FLAG A TRUE, PARA QUE PINTE LAS HORAS
      //for (var doc in query.docs) {
      //print('HAY INFO: ${doc['Fecha']}');
      //}
      existInfo = true;
    } else {
      DateTime dateTimeFecha = DateTime.parse(fecha);

      List<String> horas = [
        '09:00 am',
        '10:00 am',
        '11:00 am',
        '12:00 md',
        '1:00 pm',
        '2:00 pm',
        '3:00 pm',
        '4:00 pm',
        '5:00 pm',
        '6:00 pm',
        '7:00 pm'
      ];

      for (var i = 0; i < horas.length; i++) {
        final appointment = Appointment(
          barbero: barbero,
          idCliente: '',
          diaDisponible: true,
          fecha: Timestamp.fromMillisecondsSinceEpoch(
              dateTimeFecha.millisecondsSinceEpoch),
          hora: horas[i],
          horaDisponible: true,
          tipoServicio: '',
          precio: 0,
          nombreCliente: '',
          estadoCita: 'Creada',
        );

        final jsonDataToAdd = appointment.toJson();

        await citas.add(jsonDataToAdd);
      }
    }
  }

  /// It takes in a service, client, and id, and updates the document with the id with the service,
  /// client, and sets the hour to false
  ///
  /// Args:
  ///   servicio (String): The type of service the user wants to book.
  ///   cliente (String): The name of the client
  ///   id (String): The id of the document to update.
  void _updateHour(String servicio, String cliente, String id, int precio) {
    // Este metodo va a poner en false (ocupada) el valor de la hora de ese dia en especifico!
    FirebaseFirestore.instance.collection('Cita').doc(id).update({
      'tipoServicio': globals.servicioSeleccionado,
      'horaDisponible': false,
      'idCliente': _user.uid,
      'nombreCliente': _user.displayName,
      'precio': precio,
      'estadoCita': 'Agendada'
    });
  }

  /// It returns an AlertDialog widget that contains a title, a content, and two actions
  ///
  /// Args:
  ///   context (BuildContext): The context of the widget that is calling the dialog.
  ///   fecha (String): Date
  ///   servicio (String): The service that the user selected.
  ///   barbero (String): The name of the barber
  ///   horaSeleccionada (String): The hour selected by the user.
  ///   id (String): The id of the hour that the user selected.
  ///   cliente (String): The name of the client
  ///
  /// Returns:
  ///   A widget that is an AlertDialog.
  Widget androidDialog(BuildContext context, String fecha, String servicio,
      String barbero, String horaSeleccionada, String id, String cliente) {
    return AlertDialog(
      title: Text(
        'Resumen',
        style: myShowDialogStyle,
      ),
      content: Text(
        'Fecha: $fecha\nServicio: $servicio\nBarbero: $barbero\nHora: $horaSeleccionada\n¿Desea agendar la cita?',
        style: myShowDialogStyle,
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
            _updateHour(servicio, cliente, id, globals.precioServicio);
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
    );
  }

  /// It returns a CupertinoAlertDialog widget with a title, content, and two actions
  ///
  /// Args:
  ///   context (BuildContext): The current BuildContext.
  ///   fecha (String): The date selected by the user.
  ///   servicio (String): The service that the user selected.
  ///   barbero (String): The name of the barber
  ///   horaSeleccionada (String): The hour selected by the user.
  ///   id (String): The id of the hour that the user selected.
  ///   cliente (String): The name of the client
  ///
  /// Returns:
  ///   A CupertinoAlertDialog widget.
  Widget cupertinoDialog(BuildContext context, String fecha, String servicio,
      String barbero, String horaSeleccionada, String id, String cliente) {
    return CupertinoAlertDialog(
      title: Text(
        'Resumen',
        style: myShowDialogStyle,
      ),
      // ignore: prefer_const_constructors
      content: Text(
        'Fecha: $fecha\nServicio: $servicio\nBarbero: $barbero\nHora: $horaSeleccionada\n¿Desea agendar la cita?',
        style: myShowDialogStyle,
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
            _updateHour(servicio, cliente, id, globals.precioServicio);
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
    );
  }
}
