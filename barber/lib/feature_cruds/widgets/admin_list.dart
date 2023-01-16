import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../utils/general.dart';

class AdminUserList extends StatefulWidget {
  const AdminUserList({
    Key? key,
  }) : super(key: key);

  @override
  State<AdminUserList> createState() => _AdminUserListState();
}

class _AdminUserListState extends State<AdminUserList> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Administrador')
            .orderBy('nombre')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasData) {
            return ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                    snapshot.data!.docs[index];

                return FadeIn(
                  delay: Duration(milliseconds: 200 * index),
                  child: Dismissible(
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.center,
                      color: Colors.red,
                      child: Text(
                        'Eliminar',
                        style: myTitle25Style,
                      ),
                    ),
                    key: Key(documentSnapshot.id),
                    child: SizedBox(
                      height: 75,
                      child: Card(
                        elevation: 20,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        color: Colors.black87,
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          leading: const Icon(Icons.verified_user_outlined,
                              color: Colors.white, size: 35),
                          title: Text(
                            '${documentSnapshot['nombre']}',
                            style: myTextH1,
                          ),
                          subtitle: Text(
                            '${documentSnapshot['correo']}',
                            style: mySmallStyle,
                          ),
                          isThreeLine: true,
                          trailing: SizedBox(
                            width: 50,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline_outlined,
                                  ),
                                  color: Colors.white,
                                  iconSize: 30,
                                  onPressed: () async {
                                    FirebaseFirestore.instance
                                        .collection('Administrador')
                                        .doc(documentSnapshot.id)
                                        .delete();
                                  },
                                ),
                              ],
                            ),
                          ),
                          onTap: () {},
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return const CircularProgressIndicator();
        },
      ),
    );
  }
}
