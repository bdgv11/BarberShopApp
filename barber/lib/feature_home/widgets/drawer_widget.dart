import 'package:barber/feature_login/screens/login_barber_shop.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DrawerUserWidget extends StatefulWidget {
  final User user;
  const DrawerUserWidget({super.key, required this.user});

  @override
  State<DrawerUserWidget> createState() => _DrawerUserWidgetState();
}

class _DrawerUserWidgetState extends State<DrawerUserWidget> {
  //
  late User _user;
  //
  @override
  void initState() {
    _user = widget.user;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
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
              color: Colors.white,
            ),
            child: Center(
              child: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircleAvatar(
                      backgroundImage: AssetImage("Assets/Images/avatar1.jpeg"),
                      radius: 40,
                    ),
                  ],
                ),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: const [
                        IconButton(
                          onPressed: null,
                          icon: Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ]),
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.person_outline,
              size: 40,
              color: Colors.teal,
            ),
            title: Text(
              '${_user.displayName}',
              style: const TextStyle(
                fontSize: 20,
                fontFamily: 'Barlow',
                overflow: TextOverflow.ellipsis,
              ),
            ),
            subtitle: Text(
              '${_user.email}',
              style: const TextStyle(
                fontFamily: 'Barlow',
                color: Colors.black,
                fontSize: 16,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(
              Icons.history,
              size: 40,
              color: Colors.teal,
            ),
            title: Text(
              'Historial',
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Barlow',
              ),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(
              Icons.logout_outlined,
              size: 40,
              color: Colors.teal,
            ),
            title: const Text(
              'Salir',
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Barlow',
              ),
            ),
            onTap: () {
              FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const LoginBarberShop(),
                ),
              );
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}
