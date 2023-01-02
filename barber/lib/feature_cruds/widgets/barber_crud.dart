import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/validator.dart';

class BarberCrud extends StatefulWidget {
  final User user;
  const BarberCrud({super.key, required this.user});

  @override
  State<BarberCrud> createState() => _BarberCrudState();
}

class _BarberCrudState extends State<BarberCrud> {
  //
  final _nameFieldController = TextEditingController();
  final _descFieldController = TextEditingController();

  final _focusName = FocusNode();
  final _focusDesc = FocusNode();

  final _formKey = GlobalKey<FormState>();
  bool _processing = false;

  //late User _user;

  File? _image;
  final imagePicker = ImagePicker();
  String? downloadURL;

  /// > The initState() function is called when the widget is first created
  @override
  void initState() {
    //_user = widget.user;
    Firebase.initializeApp();
    super.initState();
  }

  // Image picker
  Future imagePickerMethod() async {
    final pick = await imagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      pick != null
          ? _image = File(pick.path)
          : showSnackBar(
              'Seleccione la imagen', const Duration(milliseconds: 1000));
    });
  }

  showSnackBar(String snackText, Duration d) {
    final snackBar = SnackBar(
      content: Text(snackText),
      duration: d,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Upload the image, then getting the download url and then
  // adding that url to my cloud firestore
  Future uploadImage() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    Reference ref = FirebaseStorage.instance
        .ref('Barbero')
        // ignore: unnecessary_string_interpolations
        .child('${_nameFieldController.text}');
    await ref.putFile(_image!);
    downloadURL = await ref.getDownloadURL();

    // upload to firestore

    await firestore.collection('Barbero').add({
      'Nombre': _nameFieldController.text,
      'Disponible': true,
      'ImagenURL': downloadURL,
      'Descripcion': _descFieldController.text
    }).whenComplete(
      () => showSnackBar(
        'Barbero agregado correctamente',
        const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //drawer: DrawerUserWidget(user: _user),
      body: Container(
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
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Column(
                //mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const Padding(padding: EdgeInsets.all(8)),
                        const Text(
                          'Mantenimiento Barbero',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontFamily: 'Barlow',
                          ),
                        ),
                        const Padding(padding: EdgeInsets.all(8)),
                        SizedBox(
                          height: 400,
                          child: StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('Barbero')
                                .where('Disponible', isEqualTo: true)
                                .snapshots(),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              if (snapshot.hasData) {
                                return ListView.builder(
                                  itemCount: snapshot.data!.docs.length,
                                  itemBuilder: (context, index) {
                                    final DocumentSnapshot documentSnapshot =
                                        snapshot.data!.docs[index];

                                    return /*Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          CircleAvatar(
                                            backgroundImage: NetworkImage(
                                              documentSnapshot['ImagenURL'],
                                            ),
                                            radius: 30,
                                          ),
                                          Text(
                                            documentSnapshot['Nombre'],
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'Barlow',
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20),
                                          ),
                                          Text(
                                            documentSnapshot['Descripcion'],
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'Barlow',
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit_outlined,
                                              size: 30,
                                            ),
                                            color: Colors.white,
                                            onPressed: () {
                                              _deleteBarber(documentSnapshot.id,
                                                  documentSnapshot['Nombre']);
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete_outline_outlined,
                                              size: 30,
                                            ),
                                            color: Colors.white,
                                            onPressed: () {
                                              _deleteBarber(documentSnapshot.id,
                                                  documentSnapshot['Nombre']);
                                            },
                                          ),
                                        ],
                                      ),
                                    );*/
                                        ListTile(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      leading: CircleAvatar(
                                        backgroundImage: NetworkImage(
                                          documentSnapshot['ImagenURL'],
                                        ),
                                        radius: 30,
                                      ),
                                      title: Text(
                                        documentSnapshot['Nombre'],
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Barlow',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                      subtitle: Text(
                                        documentSnapshot['Descripcion'],
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Barlow',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            overflow: TextOverflow.ellipsis),
                                      ),
                                      isThreeLine: true,
                                      dense: true,
                                      trailing: IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline_outlined,
                                          size: 35,
                                        ),
                                        color: Colors.white,
                                        onPressed: () {
                                          _deleteBarber2(
                                            documentSnapshot.id,
                                            documentSnapshot['Nombre'],
                                          );
                                        },
                                      ),
                                    );
                                  },
                                );
                              }
                              return const CircularProgressIndicator();
                            },
                          ),
                        ),
                        const Padding(padding: EdgeInsets.all(8)),
                        SizedBox(
                          height: 150,
                          child: Container(
                            width: 200,
                            decoration: BoxDecoration(
                              //borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white38),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: _image == null
                                        ? Container()
                                        : Image.file(_image!,
                                            fit: BoxFit.cover),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        const Padding(padding: EdgeInsets.all(8)),
                        ElevatedButton(
                          onPressed: () {
                            imagePickerMethod();
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 10,
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'Seleccionar imagen',
                            style: TextStyle(
                                color: Color.fromARGB(255, 104, 34, 4),
                                fontFamily: 'Barlow',
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Padding(padding: EdgeInsets.all(8)),
                        TextFormField(
                          style: const TextStyle(color: Colors.white),
                          validator: (value) => Validator.validateName(
                              name: _nameFieldController.text),
                          controller: _nameFieldController,
                          focusNode: _focusName,
                          decoration: const InputDecoration(
                            icon: Icon(
                              Icons.person,
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
                        const Padding(padding: EdgeInsets.all(12)),
                        TextFormField(
                          style: const TextStyle(color: Colors.white),
                          validator: (value) => Validator.validateName(
                              name: _nameFieldController.text),
                          controller: _descFieldController,
                          focusNode: _focusDesc,
                          decoration: const InputDecoration(
                            icon: Icon(
                              Icons.description,
                              size: 25,
                              color: Colors.white,
                            ),
                            hintText: 'Descripcion',
                            errorStyle: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Barlow',
                                fontWeight: FontWeight.bold),
                            hintStyle: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const Padding(padding: EdgeInsets.all(12)),
                        _processing
                            ? const CircularProgressIndicator()
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        elevation: 30,
                                        backgroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      ),
                                      onPressed: () async {
                                        /// Checking if the form is valid.
                                        _focusName.unfocus();
                                        _focusDesc.unfocus();

                                        /// Validating the form.
                                        if (_formKey.currentState!.validate()) {
                                          setState(() {
                                            _processing = true;
                                          });

                                          /// Telling the framework to rebuild the widget.
                                          setState(() {
                                            _processing = false;
                                          });

                                          if (_image != null) {
                                            uploadImage();
                                          } else {
                                            showSnackBar(
                                                'Seleccione una imagen',
                                                const Duration(seconds: 2));
                                          }
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
                        const Divider(),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _deleteBarber(String id, String nombre, BuildContext context) {
  return CupertinoAlertDialog(
    title: const Text(
      '¿Desea eliminar el barbero?',
      style: TextStyle(
          fontFamily: 'Barlow', fontWeight: FontWeight.w900, fontSize: 20),
    ),
    // ignore: prefer_const_constructors
    content: Text(
      'Podria perderse informacion de citas...',
      style: const TextStyle(
          fontFamily: 'Barlow', fontWeight: FontWeight.w900, fontSize: 20),
    ),
    actions: [
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Text(
          'Cancelar',
          style: TextStyle(color: Colors.red),
        ),
      ),
      TextButton(
        onPressed: () {
          // This method will delete the barber
          FirebaseFirestore.instance.collection('Barbero').doc(id).delete();

          FirebaseStorage.instance.ref('Barbero').child(nombre).delete();
          Navigator.of(context).pop();
        },
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Agendar',
          ),
        ),
      ),
    ],
  );
}

void _deleteBarber2(String id, String nombre) {
  // This method will delete the barber
  FirebaseFirestore.instance.collection('Barbero').doc(id).delete();

  FirebaseStorage.instance.ref('Barbero').child(nombre).delete();
}
