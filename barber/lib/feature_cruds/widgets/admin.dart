import 'package:animate_do/animate_do.dart';
import 'package:barber/feature_cruds/models/admin.dart';
import 'package:barber/utils/validator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminUsers extends StatefulWidget {
  const AdminUsers({super.key});

  @override
  State<AdminUsers> createState() => _AdminUsersState();
}

class _AdminUsersState extends State<AdminUsers> {
  final _formKey = GlobalKey<FormState>();
  final _nameFieldController = TextEditingController();
  final _emailFieldController = TextEditingController();
  bool _processing = false;
  bool _disponible = false;

  @override
  Widget build(BuildContext context) {
    double heightMediaQuery = MediaQuery.of(context).size.height;
    double widthMediaQuery = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        height: heightMediaQuery,
        width: widthMediaQuery,
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
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          style: const TextStyle(color: Colors.white),
                          validator: (value) => Validator.validateName(
                              name: _nameFieldController.text.trim()),
                          controller: _nameFieldController,
                          decoration: const InputDecoration(
                            icon: Icon(
                              Icons.person_add_alt_1_outlined,
                              size: 25,
                              color: Colors.white,
                            ),
                            hintText: 'Nombre',
                            errorStyle: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Barlow',
                                fontWeight: FontWeight.bold),
                            hintStyle: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const Padding(padding: EdgeInsets.all(8)),
                        TextFormField(
                          style: const TextStyle(color: Colors.white),
                          validator: (value) => Validator.validateEmail(
                              email: _emailFieldController.text.trim()),
                          controller: _emailFieldController,
                          decoration: const InputDecoration(
                            icon: Icon(
                              Icons.email_outlined,
                              size: 25,
                              color: Colors.white,
                            ),
                            hintText: 'Correo',
                            errorStyle: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Barlow',
                                fontWeight: FontWeight.bold),
                            hintStyle: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const Padding(padding: EdgeInsets.all(8)),
                        Row(
                          children: [
                            Text(
                              _disponible ? 'Disponible' : 'No disponible',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 15),
                            ),
                            const Padding(padding: EdgeInsets.only(right: 20)),
                            Switch.adaptive(
                              value: _disponible,
                              activeColor: Colors.green,
                              onChanged: (value) {
                                setState(() {
                                  _disponible = value;
                                });
                              },
                            ),
                          ],
                        ),
                        const Padding(padding: EdgeInsets.all(8)),
                        _processing
                            ? const CircularProgressIndicator()
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        elevation: 10,
                                        backgroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      ),
                                      onPressed: () async {
                                        /// Validating the form.
                                        if (_formKey.currentState!.validate()) {
                                          setState(() {
                                            _processing = true;
                                          });

                                          final admin = Administrador(
                                              nombre: _nameFieldController.text,
                                              correo:
                                                  _emailFieldController.text,
                                              habilitado: _disponible);

                                          final jsonData = admin.toJson();

                                          // upload to firestore
                                          await FirebaseFirestore.instance
                                              .collection('Administrador')
                                              .add(jsonData);

                                          /// Telling the framework to rebuild the widget.
                                          setState(() {
                                            _processing = false;
                                            _nameFieldController.clear();
                                            _emailFieldController.clear();
                                            _disponible = false;
                                          });
                                        }
                                      },
                                      child: const Text(
                                        'Agregar',
                                        style: TextStyle(
                                            color:
                                                Color.fromARGB(255, 104, 34, 4),
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Barlow'),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Usuarios Administradores',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Barlow',
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('Administrador')
                        .where('habilitado', isEqualTo: true)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
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
                                  child: const Text(
                                    'Eliminar',
                                    style: TextStyle(
                                        fontFamily: 'Barlow',
                                        fontSize: 25,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
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
                                      leading: const Icon(
                                          Icons.verified_user_outlined,
                                          color: Colors.white,
                                          size: 35),
                                      title: Text(
                                        '${documentSnapshot['nombre']}',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Barlow',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                      subtitle: Text(
                                        '${documentSnapshot['correo']}',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Barlow',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 19,
                                            overflow: TextOverflow.ellipsis),
                                      ),
                                      isThreeLine: true,
                                      trailing: SizedBox(
                                        width: 50,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
