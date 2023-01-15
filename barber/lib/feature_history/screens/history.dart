import 'package:animate_do/animate_do.dart';
import 'package:barber/feature_home/widgets/bottom_navigation.dart';
import 'package:barber/utils/general.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:barber/utils/globals.dart' as globals;

import '../../feature_home/widgets/drawer_widget.dart';

class UserHistory extends StatefulWidget {
  const UserHistory({super.key, required this.user});
  final User user;

  @override
  State<UserHistory> createState() => _UserHistoryState();
}

class _UserHistoryState extends State<UserHistory> {
  late User _user;

  @override
  void initState() {
    _user = widget.user;
    infoCantCitas();
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
    return Scaffold(
      drawer: DrawerUserWidget(user: _user),
      appBar: AppBar(backgroundColor: Colors.black87),
      body: Container(
        height: heightMediaQuery,
        width: widthMediaQuery,
        decoration: myBoxDecoration,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Historial de Citas',
                      textAlign: TextAlign.left,
                      style: myTextH1,
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
                    children: [
                      Text(
                        'Fecha',
                        textAlign: TextAlign.left,
                        style: myTextH1,
                      ),
                      Text(
                        'Servicio & Barbero',
                        textAlign: TextAlign.left,
                        style: myTextH1,
                      ),
                      Text(
                        'Monto',
                        textAlign: TextAlign.left,
                        style: myTextH1,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 500,
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('Cita')
                        .where('idCliente', isEqualTo: _user.uid)
                        .where('estadoCita', isEqualTo: 'Finalizada')
                        .orderBy('fecha', descending: false)
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

                            Timestamp fecha = documentSnapshot['fecha'];
                            DateTime date = fecha.toDate();

                            return FadeIn(
                              //delay: const Duration(milliseconds: 100),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 5,
                                color: Colors.black45,
                                child: ListTile(
                                  leading: Text(
                                    '${date.day.toString()}/${date.month.toString()}/${date.year.toString()}',
                                    style: mySmallStyle,
                                  ),
                                  title: Text(
                                    'Servicio: ${documentSnapshot['tipoServicio']}',
                                    style: mySmallStyle,
                                  ),
                                  subtitle: Text(
                                    'Barbero: ${documentSnapshot['barbero']}',
                                    style: mySmallStyle,
                                  ),
                                  dense: true,
                                  trailing: Text(
                                    '₡ ${documentSnapshot['precio'].toString()}',
                                    style: mySmallStyle,
                                  ),
                                  onTap: () {},
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
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Cantidad de citas: ',
                            style: myTextH1,
                          ),
                          Text(
                            globals.cantHistCitas.toString(),
                            style: myTextH1,
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationWidget(
        user: _user,
      ),
    );
  }

  void infoCantCitas() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Cita')
        .where('idCliente', isEqualTo: _user.uid)
        .where('estadoCita', isEqualTo: 'Finalizada')
        .orderBy('fecha', descending: false)
        .get();

    setState(() {
      globals.cantHistCitas = 0;
    });

    for (var doc in querySnapshot.docs) {
      // Getting data directly

      //String name = doc.get('name');

      // Getting data from map
      /*Map<String, dynamic> data = doc.data();
        int age = data['age'];*/
      if (doc.get('estadoCita') == 'Finalizada') {
        setState(() {
          globals.cantHistCitas++;
        });
      }
    }
  }
}
