import 'package:barber/feature_cruds/widgets/barber_crud.dart';
import 'package:barber/feature_cruds/widgets/service_crud.dart';
import 'package:barber/feature_home/widgets/bottom_navigation.dart';
import 'package:barber/feature_home/widgets/drawer_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class CrudPage extends StatefulWidget {
  final User user;
  const CrudPage({super.key, required this.user});

  @override
  State<CrudPage> createState() => _CrudPageState();
}

class _CrudPageState extends State<CrudPage> {
  // Initialize some code and variables
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
    return Scaffold(
      //appBar: AppBar(backgroundColor: Colors.black87),
      bottomNavigationBar: BottomNavigationWidget(user: _user),
      drawer: DrawerUserWidget(
        user: _user,
      ),
      body: Container(
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
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.black87,
              bottom: const TabBar(
                indicatorColor: Colors.teal,
                labelStyle: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Barlow',
                ),
                tabs: [
                  Tab(text: 'Barberos', icon: Icon(Icons.person_pin_outlined)),
                  Tab(
                    text: 'Productos y Servicios',
                    icon: Icon(Icons.cut_outlined),
                  ),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                //Barber Crud Page
                BarberCrud(user: _user),
                // Service Crud Page
                ProductServiceCrud(user: _user)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
