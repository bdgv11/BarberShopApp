import 'package:barber/feature_home/screens/home_page.dart';
import 'package:barber/feature_register/screens/register_page.dart';
import 'package:barber/firebase/firebase_authentication.dart';
import 'package:barber/utils/validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../../feature_forgot_password/screens/forgot_password.dart';

class LoginBarberShop extends StatefulWidget {
  const LoginBarberShop({super.key});

  @override
  State<LoginBarberShop> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<LoginBarberShop> {
  /// Creating a controller for the email and password fields.
  final _emailFieldController = TextEditingController();
  final _passwordFieldController = TextEditingController();

  /// Creating a focus node for the email and password fields.
  final _focusEmail = FocusNode();
  final _focusPassword = FocusNode();

  /// A key that is used to identify the form and validate the form.
  final _formKey = GlobalKey<FormState>();

  bool _processingLogIn = false;

  @override
  void dispose() {
    _emailFieldController.dispose();
    _passwordFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _focusEmail.unfocus();
        _focusPassword.unfocus();
      },
      child: Scaffold(
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
          child: FutureBuilder(
            future: _initFirebase(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Padding(
                  padding: const EdgeInsets.only(left: 24, right: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            const Center(
                              child: CircleAvatar(
                                backgroundImage:
                                    AssetImage("Assets/Images/logo2.jpeg"),
                                radius: 60,
                              ),
                            ),
                            //const Padding(padding: EdgeInsets.all(20)),
                            TextFormField(
                              style: const TextStyle(color: Colors.white),
                              validator: (value) => Validator.validateEmail(
                                  email: _emailFieldController.text),
                              controller: _emailFieldController,
                              focusNode: _focusEmail,
                              keyboardType: TextInputType.emailAddress,
                              cursorColor: Colors.white,
                              decoration: const InputDecoration(
                                hintText: 'Correo electrónico',
                                errorStyle: TextStyle(
                                  color: Colors.teal,
                                  fontWeight: FontWeight.bold,
                                ),
                                hintStyle: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Barlow',
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const Padding(padding: EdgeInsets.all(20)),
                            TextFormField(
                              style: const TextStyle(color: Colors.white),
                              validator: (value) => Validator.validatePassword(
                                  password: _passwordFieldController.text),
                              controller: _passwordFieldController,
                              focusNode: _focusPassword,
                              cursorColor: Colors.white,
                              decoration: const InputDecoration(
                                hintText: 'Contraseña',
                                errorStyle: TextStyle(
                                    color: Colors.teal,
                                    fontWeight: FontWeight.bold),
                                hintStyle: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Barlow',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              obscureText: true,
                            ),
                          ],
                        ),
                      ),
                      const Padding(padding: EdgeInsets.all(20)),
                      _processingLogIn
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
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    onPressed: () async {
                                      /// Checking if the form is valid.
                                      _focusEmail.unfocus();
                                      _focusPassword.unfocus();

                                      /// Validating the form.
                                      if (_formKey.currentState!.validate()) {
                                        setState(() {
                                          _processingLogIn = true;
                                        });

                                        /// Trying to log in the user using the email and password that
                                        /// the user has entered.
                                        User? user =
                                            await FirebaseAuthentication
                                                .signInUsingEmailAndPassword(
                                                    email: _emailFieldController
                                                        .text
                                                        .trim(),
                                                    password:
                                                        _passwordFieldController
                                                            .text);

                                        /// Telling the framework to rebuild the widget.
                                        setState(() {
                                          _processingLogIn = false;
                                        });

                                        /// Checking if the user is not null. If the user is not null, it
                                        /// is navigating to the HomePageScreen.
                                        if (user != null) {
                                          if (!mounted) return;
                                          Navigator.of(context).pushReplacement(
                                              MaterialPageRoute(
                                            builder: (context) =>
                                                HomePageScreen(user: user),
                                          ));
                                        } else {
                                          if (!mounted) return;
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              backgroundColor: Colors.black,
                                              duration:
                                                  Duration(milliseconds: 750),
                                              content: Text(
                                                'Correo no existe o contrasena incorrecta',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 25,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'Barlow'),
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    child: const Text(
                                      'Iniciar Sesión',
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 24),
                          GestureDetector(
                            onTap: () => Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: ((context) =>
                                    const ForgotPasswordPage()),
                              ),
                            ),
                            child: const Text(
                              'Olvidé contraseña',
                              style: TextStyle(
                                  //decoration: TextDecoration.underline,
                                  color: Colors.white,
                                  fontFamily: 'Barlow'),
                            ),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '¿No tienes cuenta? ',
                            style: TextStyle(
                                color: Colors.white, fontFamily: 'Barlow'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const RegisterScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Registrate',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Barlow'),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                );
              }
              return const CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }

  /// It initializes the firebase app.
  /// Returns:
  ///   A Future object that will eventually contain a FirebaseApp object.
  Future<FirebaseApp> _initFirebase() async {
    FirebaseApp firebaseapp = await Firebase.initializeApp();
    return firebaseapp;
  }
}
