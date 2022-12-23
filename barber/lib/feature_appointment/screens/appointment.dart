import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:barber/feature_appointment/firebase_methods/collections_methods.dart';
import 'package:barber/feature_appointment/models/services.dart';
import 'package:barber/feature_home/widgets/bottom_navigation.dart';
import 'package:barber/feature_home/widgets/drawer_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

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
  void _focusDaySelected(DateTime day, DateTime focusedDay) {
    setState(() {
      today = day;
      servicioSeleccionado = '';
      barberoSeleccionado = '';
      indexServicio = 100;
    });
  }

  bool existInfo = false;
  String servicioSeleccionado = '';
  String barberoSeleccionado = '';
  int indexServicio = 100;
  late String _hora;

  //
  final List _services = [
    KindOfServices('Corte', 30, Image.asset('Assets/Images/haircut.png'), 5500),
    KindOfServices('Barba', 30, Image.asset('Assets/Images/logo2.jpeg'), 5500),
    KindOfServices(
        'Corte y Barba', 45, Image.asset('Assets/Images/logo1.png'), 5500),
    KindOfServices('Cejas', 15, Image.asset('Assets/Images/logo2.jpeg'), 5500)
  ];

  @override
  void initState() {
    _user = widget.user;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //String fecha = "${today.day}/${today.month}/${today.year}";

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
                          fontSize: 25,
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
                      fontSize: 25,
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
                const Divider(
                  thickness: 1,
                  color: Colors.white,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Servicio: $servicioSeleccionado',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                          fontFamily: 'Barlow',
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold),
                    ),
                    const Icon(
                      Icons.navigate_next_sharp,
                      color: Colors.white,
                      size: 40,
                    )
                  ],
                ),
                const Divider(
                  thickness: 1,
                  color: Colors.white,
                ),
                SizedBox(
                  height: 175,
                  //width: 390,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: _services.length,
                    itemBuilder: (context, index) {
                      final item = _services.elementAt(index);

                      return FadeInLeft(
                        delay: Duration(milliseconds: 100 * index),
                        child: Card(
                          color: indexServicio == index
                              ? Colors.teal
                              : Colors.transparent,
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                indexServicio = index;
                                servicioSeleccionado = item.nombre;
                              });
                            },
                            child: Column(
                              children: [
                                //const Padding(padding: EdgeInsets.all(8)),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    CircleAvatar(
                                      backgroundImage: AssetImage(
                                          "Assets/Images/logo2.jpeg"),
                                      radius: 50,
                                    ),
                                  ],
                                ),
                                const Padding(padding: EdgeInsets.all(8)),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    //Padding(padding: EdgeInsets.only(top: 80)),
                                    Text(
                                      '${item.nombre}',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Barlow',
                                          fontSize: 20),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
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
                          fontSize: 25,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const Divider(
                  thickness: 1,
                  color: Colors.white,
                ),
                const Padding(padding: EdgeInsets.all(5)),
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('Barbero')
                      .where('Disponible', isEqualTo: true)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return ListView.builder(
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
                            leading: const Icon(
                              Icons.person,
                              color: Colors.white70,
                              size: 50,
                            ),
                            title: Text(
                              documentSnapshot['Nombre'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Barlow',
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              documentSnapshot['Descripcion'],
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Barlow',
                                  fontSize: 20),
                            ),
                            isThreeLine: true,
                            onTap: () {
                              setState(() {
                                barberoSeleccionado =
                                    documentSnapshot['Nombre'].toString();
                                getInfo(fecha, barberoSeleccionado);
                              });
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
                const Padding(padding: EdgeInsets.all(8)),
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
                          fontSize: 25,
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
                        .where('Fecha',
                            isEqualTo: Timestamp.fromMillisecondsSinceEpoch(
                                dateTimeFecha.millisecondsSinceEpoch))
                        .where('Barbero', isEqualTo: barberoSeleccionado)
                        .orderBy('Hora', descending: false)
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
                                crossAxisCount: 3),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final DocumentSnapshot documentSnapshot =
                              snapshot.data!.docs[index];

                          if (documentSnapshot['HoraDisponible'] == true) {
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
                                  _hora = documentSnapshot['Hora'];
                                  String id =
                                      snapshot.data!.docs[index].reference.id;
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Platform.isIOS
                                          ? cupertinoDialog(
                                              context,
                                              fecha,
                                              servicioSeleccionado,
                                              barberoSeleccionado,
                                              _hora,
                                              id,
                                              _user.displayName
                                                  .toString()) //cupertinoDialog(context)
                                          : androidDialog(
                                              context,
                                              fecha,
                                              servicioSeleccionado,
                                              barberoSeleccionado,
                                              _hora,
                                              id,
                                              _user.displayName
                                                  .toString()); //androidDialog(context);
                                    },
                                  );
                                },
                                child: Text(
                                  documentSnapshot['Hora'],
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
                                  documentSnapshot['Hora'],
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

  void getInfo(String fecha, String barbero) async {
    DateTime dateTimeFecha = DateTime.parse(fecha);
    CollectionReference citas = FirebaseFirestore.instance.collection('Cita');
    QuerySnapshot query = await citas
        .where('Fecha',
            isEqualTo: Timestamp.fromMillisecondsSinceEpoch(
                dateTimeFecha.millisecondsSinceEpoch))
        .where('Barbero', isEqualTo: barbero)
        .orderBy('Hora', descending: false)
        .get();

    if (query.docs.isNotEmpty) {
      // SI NO ESTA VACIO CAMBIA EL FLAG A TRUE, PARA QUE PINTE LAS HORAS
      //for (var doc in query.docs) {
      //print('HAY INFO: ${doc['Fecha']}');
      //}
      existInfo = true;
    } else {
      DateTime dateTimeFecha = DateTime.parse(fecha);
      CollectionMethods().addHours(
          barberoSeleccionado,
          _user.displayName!,
          Timestamp.fromMillisecondsSinceEpoch(
              dateTimeFecha.millisecondsSinceEpoch),
          servicioSeleccionado);
    }
  }
}

void _updateHour(String servicio, String cliente, String id) {
  // Este metodo va a poner en false (ocupada) el valor de la hora de ese dia en especifico!
  FirebaseFirestore.instance.collection('Cita').doc(id).update({
    'TipoServicio': servicio,
    'HoraDisponible': false,
    'Cliente': cliente,
  });
}

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
