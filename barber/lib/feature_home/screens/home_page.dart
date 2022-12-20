import 'package:barber/feature_appointment/models/services.dart';
import 'package:barber/feature_home/widgets/bottom_navigation.dart';
import 'package:barber/feature_home/widgets/drawer_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePageScreen extends StatefulWidget {
  final User user;
  const HomePageScreen({super.key, required this.user});

  @override
  State<HomePageScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<HomePageScreen> {
  //
  final List _services = [
    KindOfServices('Corte', 30, Image.asset('Assets/Images/haircut.png'), 5500),
    KindOfServices(
        'Corte y Barba', 30, Image.asset('Assets/Images/logo2.jpeg'), 5500),
    KindOfServices(
        'Cambio de color', 45, Image.asset('Assets/Images/logo1.png'), 5500),
  ];
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
                  'Hola,\n${_user.displayName}',
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
            const Padding(padding: EdgeInsets.all(8)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Servicios mas solicitados',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontFamily: 'Barlow',
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
            const Padding(padding: EdgeInsets.all(8)),
            SizedBox(
              height: 200,
              width: width * 0.9,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: _services.length,
                itemBuilder: (context, index) {
                  final item = _services.elementAt(index);
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Card(
                          color: Colors.amber[100],
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          child: SizedBox(
                            height: 150,
                            width: 200,
                            child: Center(
                              child: Column(
                                children: [
                                  /*SizedBox(
                                    height: 150.0,
                                    child: Ink.image(
                                      image: const AssetImage(
                                          'Assets/Images/logo2.jpeg'),
                                      fit: BoxFit.fill,
                                    ),
                                  ),*/
                                  Container(
                                    //padding: const EdgeInsets.all(8),
                                    height: 100,
                                    decoration: const BoxDecoration(
                                        image: DecorationImage(
                                            image: AssetImage(
                                                'Assets/Images/logo1.png'),
                                            fit: BoxFit.fill),
                                        shape: BoxShape.circle),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${item.nombre}',
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontFamily: 'Barlow',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationWidget(
        user: _user,
      ),
    );
  }
}
