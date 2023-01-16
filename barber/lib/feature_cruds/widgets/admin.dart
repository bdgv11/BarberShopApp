import 'package:barber/feature_cruds/models/admin.dart';
import 'package:barber/utils/general.dart';
import 'package:barber/utils/validator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'admin_list.dart';

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
  final bool _disponible = false;

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
                          style: myTextFieldStyle,
                          validator: (value) => Validator.validateName(
                              name: _nameFieldController.text.trim()),
                          controller: _nameFieldController,
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
                        const Padding(padding: EdgeInsets.all(8)),
                        TextFormField(
                          style: myTextFieldStyle,
                          validator: (value) => Validator.validateEmail(
                              email: _emailFieldController.text.trim()),
                          controller: _emailFieldController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            icon: const Icon(
                              Icons.email_outlined,
                              size: 25,
                              color: Colors.white,
                            ),
                            hintText: 'Correo',
                            errorStyle: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'OpenSans',
                                fontWeight: FontWeight.bold),
                            hintStyle: myHintStyle,
                          ),
                        ),
                        const Padding(padding: EdgeInsets.all(8)),
                        /*Row(
                          children: [
                            Text(
                              _disponible ? 'Disponible' : 'No disponible',
                              style: mySmallStyle,
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
                        ),*/
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
                                            correo: _emailFieldController.text,
                                          );

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
                                          });
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
                ),
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Usuarios Administradores',
                        style: myTitle25Style,
                      ),
                    ],
                  ),
                ),
                const AdminUserList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
