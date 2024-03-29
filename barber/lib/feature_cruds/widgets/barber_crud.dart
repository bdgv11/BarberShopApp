import 'dart:developer';
import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:barber/feature_cruds/models/barber.dart';
import 'package:barber/utils/general.dart';
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
  final CollectionReference _barberCollection =
      FirebaseFirestore.instance.collection('Barbero');

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

    _nameController.dispose();
    _descController.dispose();
    _urlImageController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double heightMediaQuery = MediaQuery.of(context).size.height;
    double widthMediaQuery = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        height: heightMediaQuery,
        width: widthMediaQuery,
        decoration: myBoxDecoration,
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
                          style: myTextFieldStyle,
                          validator: (value) => Validator.validateName(
                              name: _nameFieldController.text.trim()),
                          controller: _nameFieldController,
                          focusNode: _focusName,
                          decoration: InputDecoration(
                            icon: const Icon(
                              Icons.person_add_alt_1_outlined,
                              size: 25,
                              color: Colors.white,
                            ),
                            hintText: 'Nombre',
                            errorStyle: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'OpenSans',
                                fontWeight: FontWeight.bold),
                            hintStyle: myHintStyle,
                          ),
                        ),
                        const Padding(padding: EdgeInsets.all(12)),
                        TextFormField(
                          style: myTextFieldStyle,
                          validator: (value) => Validator.validateName(
                              name: _descFieldController.text.trim()),
                          controller: _descFieldController,
                          focusNode: _focusDesc,
                          decoration: InputDecoration(
                            icon: const Icon(
                              Icons.description_outlined,
                              size: 25,
                              color: Colors.white,
                            ),
                            hintText: 'Descripción',
                            errorStyle: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'OpenSans',
                                fontWeight: FontWeight.bold),
                            hintStyle: myHintStyle,
                          ),
                        ),
                        const Padding(padding: EdgeInsets.all(12)),
                        TextFormField(
                          style: myTextFieldStyle,
                          validator: (value) => Validator.validateEmail(
                              email: _emailFieldController.text.trim()),
                          controller: _emailFieldController,
                          focusNode: _focusEmail,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            icon: const Icon(
                              Icons.alternate_email_outlined,
                              size: 25,
                              color: Colors.white,
                            ),
                            hintText: 'Correo electrónico',
                            errorStyle: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'OpenSans',
                                fontWeight: FontWeight.bold),
                            hintStyle: myHintStyle,
                          ),
                        ),
                        const Padding(padding: EdgeInsets.all(8)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              _switchValue ? 'Disponible' : 'No disponible',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'OpenSans',
                                  fontWeight: FontWeight.bold),
                            ),
                            const Padding(padding: EdgeInsets.only(right: 20)),
                            Switch.adaptive(
                              value: _switchValue,
                              activeColor: Colors.green,
                              onChanged: (value) {
                                setState(() {
                                  _switchValue = value;
                                });
                              },
                            ),
                          ],
                        ),
                        const Padding(padding: EdgeInsets.all(8)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            //const Padding(padding: EdgeInsets.only(right: 20)),
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
                              child: Text(
                                'Seleccionar imagen',
                                style: myButtonTextStyle,
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
                                      child: Text(
                                        'Agregar',
                                        style: myButtonTextStyle,
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
                  barberList(),
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
    log('---------');
    log('Inicia el proceso de crear/actualizar un barbero, seleccionando una imagen...');
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

    log('Imagen seleccionada: $imageName');
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
    log('Inicia proceso para subir la imagen del barbero al STORAGE');
    Reference ref = FirebaseStorage.instance
        .ref('Barbero')
        // ignore: unnecessary_string_interpolations
        .child(
            // ignore: unnecessary_string_interpolations
            '${_nameFieldController.text.replaceAll(" ", "").toLowerCase()}');
    log('Nombre de la imagen a subir (barbero): ${_nameFieldController.text.replaceAll(" ", "").toLowerCase()}');
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
    log('Inicia el proceso de subir la informacion a la coleccion Barbero en la base de datos..');
    await _barberCollection.add(jsonData).whenComplete(
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

  // Controller - Edit view
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _urlImageController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _opcion = false;

  Future<void> _updateBarber([DocumentSnapshot? documentSnapshot]) async {
    log('---------');
    log('Inicia el proceso de actualizar al barbero, primero se levanta el modal con la info.');
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
                  keyboardType: TextInputType.emailAddress,
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
                    Switch.adaptive(
                      value: _opcion,
                      activeColor: Colors.green,
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
                  child: Text(
                    'Seleccionar imagen',
                    style: myButtonTextStyle,
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
                  child: Text(
                    'Editar',
                    style: myButtonTextStyle,
                  ),
                  onPressed: () async {
                    final bool disponible = _opcion;
                    if (_descController.text.isNotEmpty &&
                        _nameController.text.isNotEmpty &&
                        _emailController.text.isNotEmpty) {
                      if (_image == null) {
                        final barberEdit = Barber.withOutImage(
                            nombre: _nameController.text,
                            descripcion: _descController.text,
                            correoElectronico: _emailController.text,
                            disponible: _opcion);

                        final jsonData = barberEdit.toJsonWithoutImage();
                        log('Eliminando el actual y modificandolo por el nuevo nombre ya sea que se cambio o no, esto en el storage.');
                        FirebaseStorage.instance
                            .ref('Barbero')
                            .child(documentSnapshot?['nombre'])
                            .delete();
                        log('Actualizando con el nombre: ${_nameController.text} en la coleccion Barbero - sin editar imagen');

                        await _barberCollection
                            .doc(documentSnapshot!.id)
                            .update(jsonData);

                        if (!mounted) return;
                        Navigator.of(context).pop();

                        showSnackBar("Editado correctamente",
                            const Duration(seconds: 3));
                      } else {
                        log('Actualizando con el nombre: ${_nameController.text} en el STORAGE');
                        FirebaseStorage.instance
                            .ref('Barbero')
                            .child(documentSnapshot?['nombre'])
                            .delete();
                        Reference ref = FirebaseStorage.instance
                            .ref('Barbero')
                            // ignore: unnecessary_string_interpolations
                            .child(
                                // ignore: unnecessary_string_interpolations
                                '${_nameController.text.replaceAll(" ", "").toLowerCase()}');
                        await ref.putFile(_image!);
                        downloadURL = await ref.getDownloadURL();

                        _urlImageController.text = downloadURL.toString();
                        log('Se obtiene el URL de vuelta para modificar el campo en la base de datos: ${_urlImageController.text}');

                        imageName = '';

                        if (downloadURL != null) {
                          final barberEdit = Barber(
                              nombre: _nameController.text,
                              descripcion: _descController.text,
                              correoElectronico: _emailController.text,
                              imagenUrl: _urlImageController.text,
                              disponible: disponible);

                          final jsonData = barberEdit.toJson();

                          log('Se actualiza la colecion Barbero en la base de datos.');
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
    log('---------');
    log('Inicia proceso de eliminar - IOS DEVICE');
    return CupertinoAlertDialog(
      title: Text(
        '¿Desea eliminar el barbero?',
        style: myShowDialogStyle,
      ),
      // ignore: prefer_const_constructors
      content: Text(
        'Podria perderse información de citas...',
        style: myShowDialogStyle,
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
            log('Eliminando a $id de la coleccion Barbero');
            _barberCollection.doc(id).delete();

            log('Eliminando a ${nombre.replaceAll(" ", "").toLowerCase()} de la coleccion Barbero');
            FirebaseStorage.instance
                .ref('Barbero')
                .child(nombre.replaceAll(" ", "").toLowerCase())
                .delete();
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
    log('---------');
    log('Inicia proceso de eliminar - Android DEVICE');
    return AlertDialog(
      title: Text(
        '¿Desea eliminar el barbero?',
        style: myShowDialogStyle,
      ),
      // ignore: prefer_const_constructors
      content: Text(
        'Podria perderse información de citas...',
        style: myShowDialogStyle,
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
            log('Eliminando a $id de la coleccion Barbero');
            _barberCollection.doc(id).delete();

            log('Eliminando a ${nombre.replaceAll(" ", "").toLowerCase()} de la coleccion Barbero');
            FirebaseStorage.instance
                .ref('Barbero')
                .child(nombre.replaceAll(" ", "").toLowerCase())
                .delete();
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

  Widget barberList() {
    return Center(
      child: Column(
        children: [
          SizedBox(
            height: 300,
            child: StreamBuilder(
              stream: _barberCollection.snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasData) {
                  return ListView.builder(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
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
                                style: myTextH1,
                              ),
                              subtitle: Text(
                                documentSnapshot['descripcion'],
                                style: myTextH1,
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
                                          builder: (BuildContext context) {
                                            return Platform.isIOS
                                                ? _deleteBarber(
                                                    documentSnapshot.id,
                                                    documentSnapshot['nombre'],
                                                    context) //cupertinoDialog(context)
                                                : _deleteBarberAndroid(
                                                    documentSnapshot.id,
                                                    documentSnapshot['nombre'],
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
    );
  }
}
