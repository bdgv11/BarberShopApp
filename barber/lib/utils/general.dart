import 'package:flutter/material.dart';

BoxDecoration myBoxDecoration = const BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      Colors.black,
      Color.fromARGB(255, 104, 34, 4),
      Color.fromARGB(255, 187, 194, 188),
    ],
  ),
);

// Este es para los que estan dentro del text field
TextStyle myHintStyle = const TextStyle(
  color: Colors.white,
  fontFamily: 'OpenSans',
  fontWeight: FontWeight.bold,
  overflow: TextOverflow.ellipsis,
);

TextStyle myTextFieldStyle = const TextStyle(
  color: Colors.white,
  fontFamily: 'OpenSans',
  fontWeight: FontWeight.bold,
  overflow: TextOverflow.ellipsis,
);

TextStyle myTextH1 = const TextStyle(
  fontFamily: 'OpenSans',
  color: Colors.white,
  fontSize: 20,
  fontWeight: FontWeight.bold,
  overflow: TextOverflow.ellipsis,
);

TextStyle myTextLabel = const TextStyle(
  fontFamily: 'OpenSans',
  color: Colors.white,
  fontSize: 17,
  overflow: TextOverflow.ellipsis,
);

TextStyle myShowDialogStyle = const TextStyle(
  fontFamily: 'OpenSans',
  fontWeight: FontWeight.w900,
  fontSize: 20,
);

TextStyle myShowDialogContentStyle = const TextStyle(
  fontFamily: 'OpenSans',
  fontWeight: FontWeight.w900,
  fontSize: 15,
);

TextStyle myDrawerListStyle = const TextStyle(
  fontFamily: 'OpenSans',
  fontWeight: FontWeight.w900,
  fontSize: 17,
  overflow: TextOverflow.ellipsis,
);

TextStyle mySmallStyle = const TextStyle(
  color: Colors.white,
  fontFamily: 'OpenSans',
  fontWeight: FontWeight.bold,
  fontSize: 15,
  overflow: TextOverflow.ellipsis,
);

TextStyle myProductServiceStyle = const TextStyle(
  fontFamily: 'OpenSans',
  color: Colors.white,
  fontSize: 15,
  fontWeight: FontWeight.bold,
  overflow: TextOverflow.fade,
);

TextStyle myTitle25Style = const TextStyle(
  color: Colors.white,
  fontFamily: 'OpenSans',
  fontSize: 25,
  fontWeight: FontWeight.bold,
);

TextStyle myTitle30Style = const TextStyle(
  color: Colors.white,
  fontSize: 30,
  fontFamily: 'OpenSans',
);

TextStyle myButtonTextStyle = const TextStyle(
  color: Color.fromARGB(255, 104, 34, 4),
  fontFamily: 'OpenSans',
  fontWeight: FontWeight.bold,
);
