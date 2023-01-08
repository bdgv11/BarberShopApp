import 'dart:io';
import 'package:barber/feature_appointment/models/appointment.dart';
import 'package:barber/feature_home/widgets/bottom_navigation.dart';
import 'package:barber/feature_home/widgets/drawer_widget.dart';
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
    //globals.servicioSeleccionado = '';
    globals.indexServicio = 100;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
          title: const Text(
            '',
            style: TextStyle(fontFamily: 'Barlow'),
          ),
        ),
        drawer: DrawerUserWidget(user: _user),
        body: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            //color: Color.fromARGB(234, 57, 5, 2)
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
                      style: const TextStyle(
                          fontFamily: 'Barlow',
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
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
                  lastDay: DateTime.now().add(const Duration(days: 60)),
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  locale: 'es_ES',
                  onDaySelected: _focusDaySelected,
                  calendarFormat: CalendarFormat.twoWeeks,
                  weekendDays: const <int>[DateTime.sunday],
                  //Header Style
                  headerStyle: const HeaderStyle(
                    headerPadding: EdgeInsets.all(8),
                    rightChevronIcon: Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                    ),
                    leftChevronIcon: Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                    ),
                    titleCentered: true,
                    formatButtonVisible: false,
                    titleTextStyle: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Barlow',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
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
                      style: const TextStyle(
                          fontFamily: 'Barlow',
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
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
                                )
                                //AssetImage("Assets/Images/corteybarba.png"),
                                ),
                            title: Row(
                              children: <Widget>[
                                Text(
                                  documentSnapshot['nombre'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Barlow',
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(Icons.check_circle,
                                    color: indexBarber == index
                                        ? Colors.teal
                                        : Colors.grey),
                              ],
                            ),
                            subtitle: Text(
                              documentSnapshot['descripcion'],
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Barlow',
                                  fontSize: 20),
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
                  children: const [
                    Text(
                      'Hora: ',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontFamily: 'Barlow',
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
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
                                              _user.uid
                                                  .toString()) //cupertinoDialog(context)
                                          : androidDialog(
                                              context,
                                              fechaShowDialog,
                                              globals.servicioSeleccionado,
                                              barberoSeleccionado,
                                              _hora,
                                              id,
                                              _user.uid
                                                  .toString()); //androidDialog(context);
                                    },
                                  );
                                },
                                child: Text(
                                  documentSnapshot['hora'],
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
                                  documentSnapshot['hora'],
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'Barlow',
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

      final appointment = Appointment(
          barbero: barbero,
          cliente: '',
          diaDisponible: true,
          fecha: Timestamp.fromMillisecondsSinceEpoch(
              dateTimeFecha.millisecondsSinceEpoch),
          hora: '10:00 am',
          horaDisponible: true,
          tipoServicio: '');

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
void _updateHour(String servicio, String cliente, String id) {
  // Este metodo va a poner en false (ocupada) el valor de la hora de ese dia en especifico!
  FirebaseFirestore.instance.collection('Cita').doc(id).update({
    'tipoServicio': globals.servicioSeleccionado,
    'horaDisponible': false,
    'cliente': cliente,
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
    title: const Text(
      'Resumen',
      style: TextStyle(
          fontFamily: 'Barlow', fontWeight: FontWeight.w900, fontSize: 20),
    ),
    content: Text(
      'Fecha: $fecha\nServicio: $servicio\nBarbero: $barbero\nHora: $horaSeleccionada\n¿Desea agendar la cita?',
      style: const TextStyle(
          fontFamily: 'Barlow', fontWeight: FontWeight.w900, fontSize: 20),
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
          _updateHour(servicio, cliente, id);
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
    title: const Text(
      'Resumen',
      style: TextStyle(
          fontFamily: 'Barlow', fontWeight: FontWeight.w900, fontSize: 20),
    ),
    // ignore: prefer_const_constructors
    content: Text(
      'Fecha: $fecha\nServicio: $servicio\nBarbero: $barbero\nHora: $horaSeleccionada\n¿Desea agendar la cita?',
      style: const TextStyle(
          fontFamily: 'Barlow', fontWeight: FontWeight.w900, fontSize: 20),
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
          _updateHour(servicio, cliente, id);
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
