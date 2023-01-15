import 'package:flutter/material.dart';

import '../utils/general.dart';

class ConnectionError extends StatelessWidget {
  const ConnectionError({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 50,
          ),
          Text(
            'Error de conexion',
            style: myTextH1,
          ),
        ],
      ),
    );
  }
}
