import 'package:animate_do/animate_do.dart';
import 'package:barber/feature_home/models/color_filter.dart';
import 'package:barber/feature_home/widgets/bottom_navigation.dart';
import 'package:barber/feature_home/widgets/drawer_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class HomePageScreen extends StatefulWidget {
  final User user;
  const HomePageScreen({super.key, required this.user});

  @override
  State<HomePageScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<HomePageScreen> {
  late User _user;

  /// > The initState() function is called when the widget is first created
  @override
  void initState() {
    _user = widget.user;
    Firebase.initializeApp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    print('DateTime.Now == ${DateTime.now()}');
    print('TimeStamp.Now == ${Timestamp.now()}');
    print('DateTime.Now,milisse == ${DateTime.now().millisecondsSinceEpoch}');

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
    print(Timestamp.fromDate(dateTimeFecha));

    print('Este es === $dateTimeFecha');

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.black87),
      drawer: DrawerUserWidget(user: _user),
      body: Container(
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
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Hola, ${_user.displayName}',
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                      fontFamily: 'Barlow',
                      color: Colors.white,
                      fontSize: 18,
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
                      fontFamily: 'Barlow'),
                )
              ],
            ),
            SizedBox(
              height: 180,
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('Cita')
                    .where('Cliente', isEqualTo: _user.displayName.toString())
                    .where('Fecha',
                        isGreaterThanOrEqualTo:
                            DateTime.now().millisecondsSinceEpoch)
                    .limit(1)
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
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final DocumentSnapshot documentSnapshot =
                            snapshot.data!.docs[index];

                        DateTime fechaDesdeBD =
                            DateTime.fromMillisecondsSinceEpoch(
                                documentSnapshot['Fecha']
                                    .millisecondsSinceEpoch);
                        print('Fecha desde DB $fechaDesdeBD');
                        print(documentSnapshot['Fecha']);

                        String fechaFormateada =
                            '${fechaDesdeBD.day.toString()}/${fechaDesdeBD.month.toString()}/${fechaDesdeBD.year.toString()}';

                        return FadeIn(
                          delay: Duration(milliseconds: 200 * index),
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            leading: const Icon(
                              Icons.apple_outlined,
                              color: Colors.white70,
                              //size: 50,
                            ),
                            title: Text(
                              fechaFormateada,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Barlow',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                            subtitle: Text(
                              documentSnapshot['TipoServicio'],
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Barlow',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                            trailing: Text(
                              documentSnapshot['Hora'],
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Barlow',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25),
                            ),
                            onTap: () {
                              setState(() {});
                            },
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
                  'Servicios mas solicitados',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontFamily: 'Barlow',
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
                Icon(
                  Icons.navigate_next_sharp,
                  color: Colors.white,
                  size: 40,
                )
              ],
            ),
            SizedBox(
              height: 170,
              width: width * 0.9,
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('Servicio')
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
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final DocumentSnapshot documentSnapshot =
                          snapshot.data!.docs[index];
                      String nombreImagen = documentSnapshot['Imagen'];
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Center(
                            child: FadeInLeft(
                              delay: Duration(milliseconds: 100 * index),
                              child: Card(
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                                child: Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    Ink.image(
                                      //image: AssetImage('\'${item.image.name}\''),
                                      image: AssetImage(
                                          'Assets/Images/$nombreImagen'),
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
                          Center(
                            child: Text(
                              documentSnapshot['Nombre'],
                              style: const TextStyle(
                                  fontFamily: 'Barlow',
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            ),
                          )
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
      bottomNavigationBar: BottomNavigationWidget(
        user: _user,
      ),
    );
  }
}
