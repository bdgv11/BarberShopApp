import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:barber/feature_cruds/models/product_service.dart';
import 'package:barber/utils/validator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProductServiceCrud extends StatefulWidget {
  final User user;
  const ProductServiceCrud({super.key, required this.user});

  @override
  State<ProductServiceCrud> createState() => _ProductServiceCrudState();
}

class _ProductServiceCrudState extends State<ProductServiceCrud> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _focusName = FocusNode();
  final _focusPrice = FocusNode();

  bool _processing = false;
  bool _switchValue = false;

  File? _image;
  String imageName = '';
  final imagePicker = ImagePicker();
  String? downloadURL;

  /// Creating a variable called _opcionRadio of type RadioOpciones and assigning it the value of
  /// RadioOpciones.Producto.
  RadioOpciones _opcionRadio = RadioOpciones.Producto;

  /// > The initState() function is called when the widget is first created
  @override
  void initState() {
    Firebase.initializeApp();
    super.initState();
  }

  /// The dispose() function is called when the widget is removed from the widget tree
  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
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
            padding: const EdgeInsets.all(12),
            child: Center(
              child: Column(
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const Padding(padding: EdgeInsets.all(12)),
                        SizedBox(
                          height: 250,
                          child: Container(
                            width: 200,
                            decoration: BoxDecoration(
                              //borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: _image == null
                                        ? const Center(
                                            child: Text('No hay imagen'))
                                        : Image.file(_image!,
                                            fit: BoxFit.cover),
                                  )
                                ],
                              ),
                            ),
                          ),
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
                        const Padding(padding: EdgeInsets.all(12)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Icon(
                              Icons.image_outlined,
                              size: 25,
                              color: Colors.white,
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
                        TextFormField(
                          style: const TextStyle(color: Colors.white),
                          validator: (value) => Validator.validateName(
                              name: _nameController.text),
                          controller: _nameController,
                          focusNode: _focusName,
                          decoration: const InputDecoration(
                            icon: Icon(
                              Icons.note_add_outlined,
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
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          validator: (value) => Validator.validateName(
                              name: _priceController.text),
                          controller: _priceController,
                          focusNode: _focusPrice,
                          decoration: const InputDecoration(
                            icon: Icon(
                              Icons.price_change_outlined,
                              size: 25,
                              color: Colors.white,
                            ),
                            hintText: 'Precio',
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
                              Icons.camera_rounded,
                              size: 25,
                              color: Colors.white,
                            ),
                            Text(
                              'Producto',
                              style: RadioOpciones.Producto == _opcionRadio
                                  ? const TextStyle(color: Colors.white)
                                  : const TextStyle(),
                            ),
                            Radio(
                              value: RadioOpciones.Producto,
                              groupValue: _opcionRadio,
                              fillColor: MaterialStateColor.resolveWith(
                                  (states) => Colors.green),
                              focusColor: MaterialStateColor.resolveWith(
                                  (states) => Colors.green),
                              onChanged: (value) {
                                setState(() {
                                  _opcionRadio = RadioOpciones.Producto;
                                });
                              },
                            ),
                            Text(
                              'Servicio',
                              style: RadioOpciones.Servicio == _opcionRadio
                                  ? const TextStyle(color: Colors.white)
                                  : const TextStyle(),
                            ),
                            Radio(
                              value: RadioOpciones.Servicio,
                              fillColor: MaterialStateColor.resolveWith(
                                  (states) => Colors.green),
                              focusColor: MaterialStateColor.resolveWith(
                                  (states) => Colors.green),
                              groupValue: _opcionRadio,
                              onChanged: (value) {
                                setState(() {
                                  _opcionRadio = RadioOpciones.Servicio;
                                });
                              },
                            ),
                          ],
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
                                        _focusPrice.unfocus();

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
                                            addProductService();
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
                    height: 250,
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('ProductoServicio')
                          .orderBy('tipo', descending: true)
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
                                          documentSnapshot['imageURL'],
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
                                        '₡ ${documentSnapshot['precio'].toString()} / ${documentSnapshot['tipo']}',
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
                                        width: 99,
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
                                                //_updateBarber(documentSnapshot);
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
                                                        ? _deleteProdService(
                                                            documentSnapshot.id,
                                                            documentSnapshot[
                                                                'nombre'],
                                                            context,
                                                            documentSnapshot[
                                                                'tipo'],
                                                          ) //cupertinoDialog(context)
                                                        : _deleteProdServiceAnd(
                                                            documentSnapshot.id,
                                                            documentSnapshot[
                                                                'nombre'],
                                                            context,
                                                            documentSnapshot[
                                                                'tipo'],
                                                          ); //androidDialog(context);
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
  // Method to pick image
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

  // Snackbar to show a message
  showSnackBar(String snackText, Duration d) {
    final snackBar = SnackBar(
      content: Text(snackText),
      duration: d,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Method to add to firebase
  Future addProductService() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    Reference ref = FirebaseStorage.instance
        .ref('ProductoServicio')
        // ignore: unnecessary_string_interpolations
        .child('${_nameController.text}');
    await ref.putFile(_image!);
    downloadURL = await ref.getDownloadURL();

    // upload to firestore

    final productService = ProductService(
        nombre: _nameController.text,
        precio: int.parse(_priceController.text),
        imageURL: downloadURL.toString(),
        disponible: _switchValue,
        tipo: _opcionRadio.name);

    final json = productService.toJson();

    await firestore.collection('ProductoServicio').add(json);
    setState(() {
      _nameController.clear();
      _priceController.clear();
      imageName = '';
      _switchValue = false;
      _opcionRadio = RadioOpciones.Servicio;
      _image = null;
    });
  }

  // --------------------------------------------- CRUD DELETE --------------------------------------------- //
  // ------------------------------------------------------------------------------------------------------- //
  // Cupertino dialog
  Widget _deleteProdService(
      String id, String nombre, BuildContext context, String tipo) {
    return CupertinoAlertDialog(
      title: Text(
        '¿Desea eliminar el $tipo?',
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
            FirebaseFirestore.instance
                .collection('ProductoServicio')
                .doc(id)
                .delete();

            FirebaseStorage.instance
                .ref('ProductoServicio')
                .child(nombre)
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

  // Android dialog
  Widget _deleteProdServiceAnd(
      String id, String nombre, BuildContext context, String tipo) {
    return CupertinoAlertDialog(
      title: Text(
        '¿Desea eliminar el $tipo?',
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
            FirebaseFirestore.instance
                .collection('ProductoServicio')
                .doc(id)
                .delete();

            FirebaseStorage.instance
                .ref('ProductoServicio')
                .child(nombre)
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
}

// ignore: constant_identifier_names
enum RadioOpciones { Servicio, Producto }
