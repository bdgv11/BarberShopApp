import 'package:barber/feature_home/widgets/drawer_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class ServiceCrud extends StatefulWidget {
  final User user;
  const ServiceCrud({super.key, required this.user});

  @override
  State<ServiceCrud> createState() => _ServiceCrudState();
}

class _ServiceCrudState extends State<ServiceCrud> {
  //
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
      drawer: DrawerUserWidget(user: _user),
      body: Container(),
    );
  }
}
