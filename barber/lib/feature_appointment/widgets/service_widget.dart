import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:barber/utils/globals.dart' as globals;

import '../../feature_home/models/color_filter.dart';

class ServiceWidget extends StatefulWidget {
  const ServiceWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<ServiceWidget> createState() => _ServiceWidgettState();
}

class _ServiceWidgettState extends State<ServiceWidget> {
  int indexServicio = 100;
  String servicioSeleccionado = '';
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(
          thickness: 1,
          color: Colors.white,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Divider(
              thickness: 1,
              color: Colors.white,
            ),
            Text(
              'Servicio: ${globals.servicioSeleccionado}',
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontFamily: 'OpenSans',
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            const Divider(
              thickness: 1,
              color: Colors.white,
            ),
          ],
        ),
        const Divider(
          thickness: 1,
          color: Colors.white,
        ),
        SizedBox(
          height: 200,
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('ProductoServicio')
                .where('disponible', isEqualTo: true)
                .where('tipo', isEqualTo: 'Servicio')
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final DocumentSnapshot documentSnapshot =
                      snapshot.data!.docs[index];

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              globals.indexServicio = index;
                              servicioSeleccionado = documentSnapshot['nombre'];
                              globals.servicioSeleccionado =
                                  documentSnapshot['nombre'];
                              globals.precioServicio =
                                  documentSnapshot['precio'];
                            });
                          },
                          child: Card(
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                Ink.image(
                                  image: NetworkImage(
                                    documentSnapshot['imageURL'],
                                  ),
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
                      Row(
                        children: <Widget>[
                          Text(
                            '${documentSnapshot['nombre']}',
                            style: const TextStyle(
                              fontFamily: 'OpenSans',
                              color: Colors.white54,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            Icons.check_circle,
                            color: globals.indexServicio == index
                                ? Colors.teal
                                : Colors.grey,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            '₡ ${documentSnapshot['precio']}',
                            style: const TextStyle(
                                fontFamily: 'OpenSans',
                                color: Colors.white54,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
