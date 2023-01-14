import 'package:barber/feature_appointment/screens/appointment.dart';
import 'package:barber/feature_home/screens/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BottomNavigationWidget extends StatefulWidget {
  final User user;

  const BottomNavigationWidget({super.key, required this.user});

  @override
  State<BottomNavigationWidget> createState() => _BottomNavigationWidgetState();
}

class _BottomNavigationWidgetState extends State<BottomNavigationWidget> {
  late User _user;
  int _currentIndex = 0;

  @override
  void initState() {
    _user = widget.user;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      unselectedItemColor: Colors.white,
      selectedItemColor: Colors.white,
      backgroundColor: Colors.black,
      selectedFontSize: 10,
      currentIndex: _currentIndex,
      iconSize: 30,
      unselectedLabelStyle: const TextStyle(
          fontFamily: 'OpenSans',
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 15),
      selectedLabelStyle: const TextStyle(
          fontFamily: 'OpenSans',
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 15),
      onTap: (value) {
        setState(() {
          _currentIndex = value;
        });

        if (_currentIndex == 0) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => const HomePageScreen(),
          ));
        }
        if (_currentIndex == 1) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => AppointmentScreen(user: _user),
          ));
        }
        if (_currentIndex == 2) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => const HomePageScreen(),
          ));
        }
      },
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, color: Colors.white),
            label: 'Inicio'),
        BottomNavigationBarItem(
            icon: Icon(
              Icons.add_box_outlined,
              color: Colors.white,
            ),
            label: 'Agendar'),
        BottomNavigationBarItem(
            icon:
                Icon(Icons.notifications_active_outlined, color: Colors.white),
            label: 'Notificaciones'),
      ],
    );
  }
}
