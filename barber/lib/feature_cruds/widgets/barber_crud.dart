import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:barber/feature_cruds/models/barber.dart';
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
  final _emailFieldController = TextEditingController();

  final _focusName = FocusNode();
  final _focusDesc = FocusNode();
  final _focusEmail = FocusNode();

  final _formKey = GlobalKey<FormState>();
  bool _processing = false;
  bool _switchValue = false;

  File? _image;
  String imageName = '';
  final imagePicker = ImagePicker();
  String? downloadURL;

  /// > The initState() function is called when the widget is first created
  @override
  void initState() {
    //_user = widget.user;
    Firebase.initializeApp();
    super.initState();
  }

  /// > The dispose() function is called when the widget is removed from the widget tree
  @override
  void dispose() {
    _nameFieldController.dispose();
    _descFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            padding: const EdgeInsets.all(12.0),
            child: Center(
              child: Column(
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const Padding(padding: EdgeInsets.all(8)),
                        TextFormField(
                          style: const TextStyle(color: Colors.white),
                          validator: (value) => Validator.validateName(
                              name: _nameFieldController.text.trim()),
                          controller: _nameFieldController,
                          focusNode: _focusName,
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
                        const Padding(padding: EdgeInsets.all(12)),
                        TextFormField(
                          style: const TextStyle(color: Colors.white),
                          validator: (value) => Validator.validateName(
                              name: _descFieldController.text.trim()),
                          controller: _descFieldController,
                          focusNode: _focusDesc,
                          decoration: const InputDecoration(
                            icon: Icon(
                              Icons.description_outlined,
                              size: 25,
                              color: Colors.white,
                            ),
                            hintText: 'Descripción',
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
                          validator: (value) => Validator.validateEmail(
                              email: _emailFieldController.text.trim()),
                          controller: _emailFieldController,
                          focusNode: _focusEmail,
                          decoration: const InputDecoration(
                            icon: Icon(
                              Icons.alternate_email_outlined,
                              size: 25,
                              color: Colors.white,
                            ),
                            hintText: 'Correo electrónico',
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Icon(
                              Icons.event_available_outlined,
                              size: 25,
                              color: Colors.white,
                            ),
                            Text(
                              _switchValue ? 'Disponible' : 'No disponible',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Barlow',
                                  fontWeight: FontWeight.bold),
                            ),
                            CupertinoSwitch(
                              value: _switchValue,
                              onChanged: (value) {
                                setState(() {
                                  _switchValue = value;
                                });
                              },
                            )
                          ],
                        ),
                        const Padding(padding: EdgeInsets.all(12)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Icon(
                              Icons.image_outlined,
                              size: 25,
                              color: Colors.white,
                            ),
                            const Padding(padding: EdgeInsets.only(right: 20)),
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
                            Expanded(
                              child: Text(
                                imageName,
                                style: const TextStyle(
                                    overflow: TextOverflow.ellipsis,
                                    color: Colors.white),
                              ),
                            ),
                          ],
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
                        const Padding(padding: EdgeInsets.all(8)),
                      ],
                    ),
                  ),
                  const Divider(
                    thickness: 0.5,
                    color: Colors.white,
                  ),
                  SizedBox(
                    height: 320,
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('Barbero')
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
                            physics: const BouncingScrollPhysics(),
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              final DocumentSnapshot documentSnapshot =
                                  snapshot.data!.docs[index];

                              return SizedBox(
                                height: 70,
                                child: Card(
                                  elevation: 20,
                                  color: Colors.black87,
                                  child: FadeInLeft(
                                    delay: Duration(milliseconds: 100 * index),
                                    child: ListTile(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      leading: CircleAvatar(
                                        backgroundImage: NetworkImage(
                                          documentSnapshot['imagenUrl'],
                                        ),
                                      ),
                                      title: Text(
                                        documentSnapshot['nombre'],
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Barlow',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            overflow: TextOverflow.ellipsis),
                                      ),
                                      subtitle: Text(
                                        documentSnapshot['descripcion'],
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Barlow',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            overflow: TextOverflow.ellipsis),
                                      ),
                                      isThreeLine: true,
                                      dense: true,
                                      trailing: SizedBox(
                                        width: 110,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.edit_outlined,
                                              ),
                                              color: Colors.white,
                                              iconSize: 30,
                                              onPressed: () {
                                                _updateBarber(documentSnapshot);
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete_outline_outlined,
                                              ),
                                              color: Colors.white,
                                              iconSize: 30,
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return Platform.isIOS
                                                        ? _deleteBarber(
                                                            documentSnapshot.id,
                                                            documentSnapshot[
                                                                'nombre'],
                                                            context) //cupertinoDialog(context)
                                                        : _deleteBarberAndroid(
                                                            documentSnapshot.id,
                                                            documentSnapshot[
                                                                'nombre'],
                                                            context); //androidDialog(context);
                                                  },
                                                );
                                              },
                                            ),
                                          ],
                                        ),
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
                  const Padding(padding: EdgeInsets.all(8)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --------------------------------------------- CRUD CREATE --------------------------------------------- //
  // ------------------------------------------------------------------------------------------------------- //

  // Image picker
  Future imagePickerMethod() async {
    final pick = await imagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pick != null) {
        _image = File(pick.path);
        imageName = pick.name;
      } else {
        showSnackBar(
            'Seleccione la imagen', const Duration(milliseconds: 1000));
      }
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

    final barber = Barber(
        nombre: _nameFieldController.text,
        descripcion: _descFieldController.text,
        correoElectronico: _emailFieldController.text,
        disponible: _switchValue,
        imagenUrl: downloadURL.toString());

    final jsonData = barber.toJson();

    // upload to firestore
    await firestore.collection('Barbero').add(jsonData).whenComplete(
          () => showSnackBar(
            'Barbero agregado correctamente',
            const Duration(seconds: 3),
          ),
        );

    setState(() {
      _nameFieldController.clear();
      _descFieldController.clear();
      _emailFieldController.clear();
      imageName = '';
    });
  }

  // --------------------------------------------- CRUD UPDATE --------------------------------------------- //
  // ------------------------------------------------------------------------------------------------------- //

  final CollectionReference _barberCollection =
      FirebaseFirestore.instance.collection('Barbero');

  // Controller - Edit view
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _urlImageController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _opcion = false;
  String? urlEdited;

  Future<void> _updateBarber([DocumentSnapshot? documentSnapshot]) async {
    if (documentSnapshot != null) {
      _nameController.text = documentSnapshot['nombre'];
      _descController.text = documentSnapshot['descripcion'];
      _urlImageController.text = documentSnapshot['imagenUrl'];
      _opcion = documentSnapshot['disponible'];
      _emailController.text = documentSnapshot['correoElectronico'];
    }

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: _descController,
                  decoration: const InputDecoration(
                    labelText: 'Descripcion',
                  ),
                ),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Correo',
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Text(_opcion ? 'Disponible' : 'No disponible'),
                    CupertinoSwitch(
                      value: _opcion,
                      activeColor: Colors.green,
                      trackColor: Colors.grey,
                      thumbColor: Colors.white,
                      onChanged: (value) {
                        setState(() {
                          _opcion = value;
                        });
                      },
                    ),
                  ],
                ),
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
                Text(
                  imageName,
                  style: const TextStyle(
                    overflow: TextOverflow.ellipsis,
                    color: Colors.black,
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 10,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Editar',
                    style: TextStyle(
                        color: Color.fromARGB(255, 104, 34, 4),
                        fontFamily: 'Barlow',
                        fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    final String nombre = _nameController.text;
                    final String desc = _descController.text;
                    final String email = _emailController.text;
                    final bool disponible = _opcion;
                    if (desc.isNotEmpty && nombre.isNotEmpty) {
                      if (_image == null) {
                        final barberEdit = Barber.withOutImage(
                            nombre: nombre,
                            descripcion: desc,
                            correoElectronico: email,
                            disponible: disponible);

                        final jsonData = barberEdit.toJsonWithoutImage();

                        await _barberCollection
                            .doc(documentSnapshot!.id)
                            .update(jsonData);

                        if (!mounted) return;
                        Navigator.of(context).pop();
                      } else {
                        FirebaseStorage.instance
                            .ref('Barbero')
                            .child(documentSnapshot?['nombre'])
                            .delete();
                        Reference ref = FirebaseStorage.instance
                            .ref('Barbero')
                            // ignore: unnecessary_string_interpolations
                            .child('${_nameController.text}');
                        await ref.putFile(_image!);
                        downloadURL = await ref.getDownloadURL();

                        _urlImageController.text = downloadURL.toString();

                        imageName = '';

                        if (downloadURL != null) {
                          final barberEdit = Barber(
                              nombre: nombre,
                              descripcion: desc,
                              correoElectronico: email,
                              imagenUrl: _urlImageController.text,
                              disponible: disponible);

                          final jsonData = barberEdit.toJson();

                          await _barberCollection
                              .doc(documentSnapshot!.id)
                              .update(jsonData);

                          if (!mounted) return;

                          Navigator.of(context).pop();
                        }
                      }
                      setState(() {
                        _nameFieldController.clear();
                        _descFieldController.clear();
                        imageName = '';
                      });
                    }
                  },
                ),
              ],
            ),
          );
        });
  }

  // --------------------------------------------- CRUD DELETE --------------------------------------------- //
  // ------------------------------------------------------------------------------------------------------- //

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
              'Eliminar',
            ),
          ),
        ),
      ],
    );
  }

  Widget _deleteBarberAndroid(String id, String nombre, BuildContext context) {
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
              'Eliminar',
            ),
          ),
        ),
      ],
    );
  }
}
