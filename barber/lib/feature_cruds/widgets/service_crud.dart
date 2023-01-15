import 'dart:developer';
import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:barber/feature_cruds/models/product_service.dart';
import 'package:barber/utils/general.dart';
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
    double heightMediaQuery = MediaQuery.of(context).size.height;
    double widthMediaQuery = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        height: heightMediaQuery,
        width: widthMediaQuery,
        decoration: myBoxDecoration,
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
                          child: Text(
                            'Seleccionar imagen',
                            style: myButtonTextStyle,
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
                          style: myTextFieldStyle,
                          maxLength: 23,
                          validator: (value) => Validator.validateName(
                              name: _nameController.text),
                          controller: _nameController,
                          focusNode: _focusName,
                          cursorColor: Colors.white,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.paste_outlined,
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
                          keyboardType: TextInputType.number,
                          style: myTextFieldStyle,
                          validator: (value) => Validator.validateName(
                              name: _priceController.text),
                          controller: _priceController,
                          focusNode: _focusPrice,
                          cursorColor: Colors.white,
                          decoration: InputDecoration(
                            prefixIconColor: Colors.white,
                            icon: const Icon(
                              Icons.price_change_outlined,
                              size: 25,
                              color: Colors.white,
                            ),
                            hintText: 'Precio',
                            errorStyle: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'OpenSans',
                                fontWeight: FontWeight.bold),
                            hintStyle: myHintStyle,
                          ),
                        ),
                        const Padding(padding: EdgeInsets.all(12)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Icon(
                              Icons.design_services_outlined,
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
                                  fontFamily: 'OpenSans',
                                  fontWeight: FontWeight.bold),
                            ),
                            Switch.adaptive(
                              value: _switchValue,
                              activeColor: Colors.green,
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
                                      child: Text(
                                        'Agregar',
                                        style: myButtonTextStyle,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
                                        style: myTextH1,
                                      ),
                                      subtitle: Text(
                                        '₡ ${documentSnapshot['precio'].toString()} / ${documentSnapshot['tipo']}',
                                        style: myTextH1,
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
                                                // METODO PARA EDITAR
                                                _updateProductService(
                                                    documentSnapshot);
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
                                                                    'nombre']
                                                                .replaceAll(
                                                                    " ", "")
                                                                .toLowerCase(),
                                                            context,
                                                            documentSnapshot[
                                                                'tipo'],
                                                          ) //cupertinoDialog(context)
                                                        : _deleteProdServiceAnd(
                                                            documentSnapshot.id,
                                                            documentSnapshot[
                                                                    'nombre']
                                                                .replaceAll(
                                                                    " ", "")
                                                                .toLowerCase(),
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
    //imagen.replaceAll(" ", "").toLowerCase()

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    Reference ref = FirebaseStorage.instance
        .ref('ProductoServicio')
        // ignore: unnecessary_string_interpolations
        .child('${_nameController.text.replaceAll(" ", "").toLowerCase()}');
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

    await firestore
        .collection('ProductoServicio')
        .add(json)
        .whenComplete(() => () {
              showSnackBar(
                "Agregado correctamente",
                const Duration(seconds: 3),
              );
            });
    setState(() {
      _nameController.clear();
      _priceController.clear();
      imageName = '';
      _switchValue = false;
      _opcionRadio = RadioOpciones.Servicio;
      _image = null;
    });
  }

  // --------------------------------------------- CRUD UPDATE --------------------------------------------- //
  // ------------------------------------------------------------------------------------------------------- //

  // Controller - Edit view
  final TextEditingController _nameEditController = TextEditingController();
  final TextEditingController _priceEditController = TextEditingController();
  final TextEditingController _urlImageController = TextEditingController();
  bool _opcion = false;

  Future<void> _updateProductService(
      [DocumentSnapshot? documentSnapshot]) async {
    if (documentSnapshot != null) {
      _nameEditController.text = documentSnapshot['nombre'];
      _priceEditController.text = documentSnapshot['precio'].toString();
      if (documentSnapshot['tipo'] == 'Servicio') {
        _opcionRadio = RadioOpciones.Servicio;
      } else {
        _opcionRadio = RadioOpciones.Producto;
      }
      _urlImageController.text = documentSnapshot['imageURL'];
      _opcion = documentSnapshot['disponible'];
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
                  controller: _nameEditController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  maxLength: 23,
                ),
                TextField(
                  controller: _priceEditController,
                  decoration: const InputDecoration(
                    labelText: 'Precio',
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Producto',
                      style: RadioOpciones.Producto == _opcionRadio
                          ? const TextStyle(
                              color: Colors.black, fontFamily: 'OpenSans')
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
                          ? const TextStyle(
                              color: Colors.black, fontFamily: 'OpenSans')
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
                    //
                    // ACA EMPIEZA EL EDITAR CON O SIN IMAGEN, SON 2 METODOS //
                    //
                    final bool disponible = _opcion;
                    if (_nameEditController.text.isNotEmpty &&
                        _priceEditController.text.isNotEmpty) {
                      if (_image == null) {
                        // Aca actualiza los datos excepto la imagen, esa deja la misma URL.
                        //
                        final prodServ = ProductService.withOutImage(
                          nombre: _nameEditController.text,
                          precio: int.parse(_priceEditController.text),
                          tipo: _opcionRadio.name,
                          disponible: disponible,
                        );

                        final jsonData = prodServ.toJsonWithOutImage();

                        await FirebaseFirestore.instance
                            .collection('ProductoServicio')
                            .doc(documentSnapshot!.id)
                            .update(jsonData);

                        if (!mounted) return;
                        Navigator.of(context).pop();

                        showSnackBar(
                          "Editado correctamente",
                          const Duration(seconds: 3),
                        );
                      } else {
                        // Aca edita todo lo que se cambio y UNA NUEVA imagen, por lo que se debe eliminar la anterior y agregar esta nueva
                        // agarrar el nuevo URL y ponerselo a la tabla de ProductoServicio en la BD
                        String nombreAEliminar = documentSnapshot?['nombre']
                            .replaceAll(" ", "")
                            .toLowerCase();
                        log(nombreAEliminar);
                        FirebaseStorage.instance
                            .ref('ProductoServicio')
                            .child(nombreAEliminar)
                            .delete();

                        // Aca agrega una nueva imagen e el storage para el nuevo prod/servicio
                        Reference ref = FirebaseStorage.instance
                            .ref('ProductoServicio')
                            // ignore: unnecessary_string_interpolations
                            .child(
                                // ignore: unnecessary_string_interpolations
                                '${_nameEditController.text.replaceAll(" ", "").toLowerCase()}');
                        await ref.putFile(_image!);
                        downloadURL = await ref.getDownloadURL();

                        _urlImageController.text = downloadURL.toString();

                        imageName = '';

                        if (downloadURL != null) {
                          final prodServ = ProductService(
                              nombre: _nameEditController.text,
                              precio: int.parse(_priceEditController.text),
                              imageURL: downloadURL.toString(),
                              tipo: _opcionRadio.name,
                              disponible: disponible);

                          final jsonData = prodServ.toJson();

                          await FirebaseFirestore.instance
                              .collection('ProductoServicio')
                              .doc(documentSnapshot!.id)
                              .update(jsonData);

                          if (!mounted) return;
                          Navigator.of(context).pop();
                          showSnackBar(
                            "Editado correctamente",
                            const Duration(seconds: 3),
                          );
                        }
                      }
                      setState(() {
                        _nameEditController.clear();
                        _priceEditController.clear();
                        imageName = '';
                        _image = null;
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
  // Cupertino dialog
  Widget _deleteProdService(
      String id, String nombre, BuildContext context, String tipo) {
    return CupertinoAlertDialog(
      title: Text(
        '¿Desea eliminar el $tipo?',
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
    return AlertDialog(
      title: Text(
        '¿Desea eliminar el $tipo?',
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
