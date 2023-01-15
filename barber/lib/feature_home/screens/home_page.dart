import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:barber/feature_home/models/color_filter.dart';
import 'package:barber/feature_home/widgets/bottom_navigation.dart';
import 'package:barber/feature_home/widgets/drawer_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:barber/utils/globals.dart' as globals;

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<HomePageScreen> {
  String imageFromStorage = '';

  //
  late User _user;

  /// > The initState() function is called when the widget is first created
  @override
  void initState() {
    _user = FirebaseAuth.instance.currentUser!;
    globals.servicioSeleccionado = '';
    Firebase.initializeApp();
    validateAdminUser();
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

    String fecha = getFormattedDate(DateTime.now().year.toString(),
        DateTime.now().month.toString(), DateTime.now().day.toString());

    DateTime dateTimeFecha = DateTime.parse(fecha);
    dateTimeFecha.millisecondsSinceEpoch;

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.black87),
      drawer: DrawerUserWidget(user: _user),
      body: Container(
        height: heightMediaQuery,
        width: widthMediaQuery,
        padding: const EdgeInsets.all(20),
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
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Hola, ${_user.displayName}',
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                        fontFamily: 'OpenSans',
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Divider(
                thickness: 0.2,
                color: Colors.white,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: const [
                  Text(
                    'Mi proxima cita:',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'OpenSans'),
                  )
                ],
              ),

              SizedBox(
                height: 120,
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('Cita')
                      .where('idCliente', isEqualTo: _user.uid.toString())
                      .where('estadoCita', isEqualTo: 'Agendada')
                      .where('fecha',
                          isGreaterThanOrEqualTo:
                              Timestamp.fromDate(dateTimeFecha))
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
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final DocumentSnapshot documentSnapshot =
                              snapshot.data!.docs[index];

                          String imagen = documentSnapshot['tipoServicio'];
                          imagen =
                              '${imagen.replaceAll(" ", "").toLowerCase()}.png';

                          DateTime fechaDesdeBD =
                              DateTime.fromMillisecondsSinceEpoch(
                                  documentSnapshot['fecha']
                                      .millisecondsSinceEpoch);

                          String fechaFormateada =
                              '${fechaDesdeBD.day.toString()}/${fechaDesdeBD.month.toString()}/${fechaDesdeBD.year.toString()}';

                          return FadeInLeft(
                            delay: Duration(milliseconds: 200 * index),
                            child: SizedBox(
                              child: Dismissible(
                                key: Key(documentSnapshot.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  color: Colors.red,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: const [
                                      Text(
                                        'Cancelar cita',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'OpenSans',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                      Icon(
                                        Icons.delete_outline,
                                        size: 45,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                                onDismissed: (direction) {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Platform.isIOS
                                            ? _deleteAppointment(
                                                documentSnapshot.id,
                                                context) //cupertinoDialog(context)
                                            : _deleteAppointmentAndroid(
                                                documentSnapshot.id, context);
                                      }); //androidDialog(context);
                                },
                                child: ListTile(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  leading: const CircleAvatar(
                                    backgroundImage:
                                        AssetImage("Assets/Images/logo2.jpeg"),
                                    radius: 25,
                                  ),
                                  title: Text(
                                    'Fecha: $fechaFormateada\nBarbero: ${documentSnapshot['barbero']}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'OpenSans',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                  subtitle: Text(
                                    'Servicio: ${documentSnapshot['tipoServicio']}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'OpenSans',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                  isThreeLine: true,
                                  //dense: true,
                                  trailing: Text(
                                    documentSnapshot['hora'],
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'OpenSans',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                ),
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
              const Divider(
                thickness: 0.2,
                color: Colors.white,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Servicios y productos:',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontFamily: 'OpenSans',
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  Icon(
                    Icons.navigate_next_sharp,
                    color: Colors.white,
                    size: 40,
                  )
                ],
              ),

              //GRIDVIEW PARA PONER TODOS LOS SERVICIOS

              SizedBox(
                width: double.infinity,
                height: 400,
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('ProductoServicio')
                      .where('disponible', isEqualTo: true)
                      .orderBy('tipo', descending: true)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    return GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: snapshot.data!.docs.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                      ),
                      itemBuilder: (context, index) {
                        final DocumentSnapshot documentSnapshot =
                            snapshot.data!.docs[index];

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 160,
                              child: Center(
                                child: FadeIn(
                                  delay: Duration(milliseconds: 100 * index),
                                  child: Card(
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Stack(
                                      alignment: Alignment.bottomCenter,
                                      children: [
                                        Ink.image(
                                          image: NetworkImage(
                                            documentSnapshot['imageURL'],
                                          ),
                                          colorFilter: ColorFilters.greyScale,
                                          height: 130,
                                          width: 180,
                                          fit: BoxFit.fill,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  '${documentSnapshot['nombre']}',
                                  style: const TextStyle(
                                    fontFamily: 'OpenSans',
                                    color: Colors.white54,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  '₡ ${documentSnapshot['precio']}',
                                  style: const TextStyle(
                                    fontFamily: 'OpenSans',
                                    color: Colors.white54,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
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
    );
  }

  /// Check If Document Exists
  void validateAdminUser() async {
    // Get reference to Firestore collection

    CollectionReference admin =
        FirebaseFirestore.instance.collection('Administrador');
    QuerySnapshot query =
        await admin.where('correo', isEqualTo: _user.email.toString()).get();

    if (query.docs.isNotEmpty) {
      globals.isAdmin = true;
    }
  }

  Widget _deleteAppointment(String id, BuildContext context) {
    return CupertinoAlertDialog(
      title: const Text(
        '¿Desea cancelar la cita?',
        style: TextStyle(
            fontFamily: 'OpenSans', fontWeight: FontWeight.w900, fontSize: 20),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            setState(() {});
          },
          child: const Text(
            'No',
            style: TextStyle(color: Colors.red),
          ),
        ),
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
              'Sí',
            ),
          ),
        ),
      ],
    );
  }

  Widget _deleteAppointmentAndroid(String id, BuildContext context) {
    return AlertDialog(
      title: const Text(
        '¿Desea cancelar la cita?',
        style: TextStyle(
            fontFamily: 'OpenSans', fontWeight: FontWeight.w900, fontSize: 20),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            setState(() {});
          },
          child: const Text(
            'No',
            style: TextStyle(color: Colors.red),
          ),
        ),
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
              'Sí',
            ),
          ),
        ),
      ],
    );
  }
}
