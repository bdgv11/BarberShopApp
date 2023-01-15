import 'dart:io';

import 'package:barber/feature_cruds/screens/cruds.dart';
import 'package:barber/feature_daily_appointment/screens/daily_appointment.dart';
import 'package:barber/feature_login/screens/login_barber_shop.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:barber/utils/globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';

import '../../feature_history/screens/history.dart';

class DrawerUserWidget extends StatefulWidget {
  final User user;
  const DrawerUserWidget({super.key, required this.user});

  @override
  State<DrawerUserWidget> createState() => _DrawerUserWidgetState();
}

class _DrawerUserWidgetState extends State<DrawerUserWidget> {
  //

  bool isAdmin = false;

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
        padding: EdgeInsets.zero,
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
              child: Column(
                children: [
                  if (_user.photoURL != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(
                            _user.photoURL.toString(),
                          ),
                          radius: 65,
                        ),
                      ],
                    ),
                  if (_user.photoURL == null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        CircleAvatar(
                          backgroundImage:
                              AssetImage("Assets/Images/logo2.jpeg"),
                          radius: 60,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: Platform.isIOS
                ? Icon(
                    CupertinoIcons.person_alt_circle,
                    size: 40,
                    color: Colors.brown[600],
                  )
                : Icon(
                    Icons.person_outline,
                    size: 40,
                    color: Colors.brown[600],
                  ),
            title: Text(
              '${_user.displayName}',
              style: const TextStyle(
                fontSize: 20,
                fontFamily: 'OpenSans',
                overflow: TextOverflow.ellipsis,
              ),
            ),
            subtitle: Text(
              '${_user.email}',
              style: const TextStyle(
                fontFamily: 'OpenSans',
                color: Colors.black,
                fontSize: 16,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const Divider(),
          ListTile(
            leading: Platform.isIOS
                ? Icon(
                    CupertinoIcons.clock,
                    size: 40,
                    color: Colors.brown[600],
                  )
                : Icon(
                    Icons.history,
                    size: 40,
                    color: Colors.brown[600],
                  ),
            title: const Text(
              'Historial',
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'OpenSans',
              ),
            ),
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => UserHistory(
                    user: _user,
                  ),
                ),
              );
            },
          ),
          if (globals.isAdmin)
            ListTile(
              leading: Platform.isIOS
                  ? Icon(
                      CupertinoIcons.chart_bar_circle,
                      size: 40,
                      color: Colors.brown[600],
                    )
                  : Icon(
                      Icons.add_chart_outlined,
                      size: 40,
                      color: Colors.brown[600],
                    ),
              title: const Text(
                'Citas del día',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'OpenSans',
                ),
              ),
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => DailyReport(
                      user: _user,
                    ),
                  ),
                );
              },
            ),
          if (globals.isAdmin)
            ListTile(
              leading: Platform.isIOS
                  ? Icon(
                      CupertinoIcons.settings,
                      size: 40,
                      color: Colors.brown[600],
                    )
                  : Icon(
                      Icons.settings,
                      size: 40,
                      color: Colors.brown[600],
                    ),
              title: const Text(
                'Configuraciones',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'OpenSans',
                ),
              ),
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => CrudPage(
                      user: _user,
                    ),
                  ),
                );
              },
            ),
          const Divider(),
          ListTile(
            leading: Platform.isIOS
                ? Icon(
                    Icons.logout_outlined,
                    size: 40,
                    color: Colors.brown[600],
                  )
                : Icon(
                    Icons.logout_outlined,
                    size: 40,
                    color: Colors.brown[600],
                  ),
            title: const Text(
              'Salir',
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'OpenSans',
              ),
            ),
            onTap: () async {
              globals.isAdmin = false;
              FirebaseAuth.instance.signOut();
              SharedPreferences pref = await SharedPreferences.getInstance();
              pref.remove("email");
              pref.remove("userId");
              pref.remove("name");
              if (!mounted) return;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const LoginBarberShop(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
