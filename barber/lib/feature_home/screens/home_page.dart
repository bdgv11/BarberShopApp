import 'package:animate_do/animate_do.dart';
import 'package:barber/feature_home/models/color_filter.dart';
import 'package:barber/feature_home/widgets/bottom_navigation.dart';
import 'package:barber/feature_home/widgets/drawer_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

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
