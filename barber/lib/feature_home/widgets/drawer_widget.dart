import 'dart:io';

import 'package:barber/feature_cruds/screens/cruds.dart';
import 'package:barber/feature_daily_appointment/screens/daily_appointment.dart';
import 'package:barber/feature_login/screens/login_barber_shop.dart';
import 'package:barber/utils/general.dart';
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
            decoration: myBoxDecoration,
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
                    size: 35,
                    color: Colors.brown[600],
                  )
                : Icon(
                    Icons.person_outline,
                    size: 35,
                    color: Colors.brown[600],
                  ),
            title: Text(
              '${_user.displayName}',
              style: myDrawerListStyle,
            ),
            subtitle: Text(
              '${_user.email}',
              style: myDrawerListStyle,
            ),
          ),
          const Divider(),
          ListTile(
            leading: Platform.isIOS
                ? Icon(
                    CupertinoIcons.arrow_clockwise,
                    size: 35,
                    color: Colors.brown[600],
                  )
                : Icon(
                    Icons.history,
                    size: 35,
                    color: Colors.brown[600],
                  ),
            title: Text(
              'Historial',
              style: myDrawerListStyle,
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
                      CupertinoIcons.square_list,
                      size: 35,
                      color: Colors.brown[600],
                    )
                  : Icon(
                      Icons.list_alt_sharp,
                      size: 35,
                      color: Colors.brown[600],
                    ),
              title: Text(
                'Citas del día',
                style: myDrawerListStyle,
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
                      size: 35,
                      color: Colors.brown[600],
                    )
                  : Icon(
                      Icons.settings,
                      size: 35,
                      color: Colors.brown[600],
                    ),
              title: Text(
                'Configuraciones',
                style: myDrawerListStyle,
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
                    size: 35,
                    color: Colors.brown[600],
                  )
                : Icon(
                    Icons.logout_outlined,
                    size: 35,
                    color: Colors.brown[600],
                  ),
            title: Text(
              'Salir',
              style: myDrawerListStyle,
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
