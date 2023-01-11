import 'package:barber/feature_home/screens/home_page.dart';
import 'package:barber/feature_login/screens/login_barber_shop.dart';
import 'package:barber/firebase/firebase_authentication.dart';
import 'package:barber/utils/validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameFieldController = TextEditingController();
  final _emailFieldController = TextEditingController();
  final _passwordFieldController = TextEditingController();

  final _focusName = FocusNode();
  final _focusEmail = FocusNode();
  final _focusPassword = FocusNode();

  final _formKey = GlobalKey<FormState>();

  bool _processing = false;
  @override
  Widget build(BuildContext context) {
    double heightMediaQuery = MediaQuery.of(context).size.height;
    double widthMediaQuery = MediaQuery.of(context).size.width;
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          _focusName.unfocus();
          _focusEmail.unfocus();
          _focusPassword.unfocus();
        },
        child: SingleChildScrollView(
          child: Container(
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
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const Text(
                            'Registro',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontFamily: 'OpenSans',
                              fontWeight: FontWeight.bold,
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
                                Icons.person_outline_outlined,
                                size: 25,
                                color: Colors.white,
                              ),
                              hintText: 'Nombre completo',
                              errorStyle: TextStyle(
                                color: Colors.teal,
                                fontWeight: FontWeight.bold,
                              ),
                              hintStyle: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const Padding(padding: EdgeInsets.all(8)),
                          const SizedBox(height: 8),
                          TextFormField(
                            style: const TextStyle(color: Colors.white),
                            validator: (value) => Validator.validateEmail(
                                email: _emailFieldController.text),
                            controller: _emailFieldController,
                            focusNode: _focusEmail,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              icon: Icon(
                                Icons.email_outlined,
                                size: 25,
                                color: Colors.white,
                              ),
                              hintText: 'Correo Electrónico',
                              errorStyle: TextStyle(
                                color: Colors.teal,
                                fontWeight: FontWeight.bold,
                              ),
                              hintStyle: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const Padding(padding: EdgeInsets.all(8)),
                          const SizedBox(height: 8),
                          TextFormField(
                            style: const TextStyle(color: Colors.white),
                            validator: (value) => Validator.validatePassword(
                                password: _passwordFieldController.text),
                            controller: _passwordFieldController,
                            focusNode: _focusPassword,
                            decoration: const InputDecoration(
                              icon: Icon(
                                Icons.key_outlined,
                                size: 25,
                                color: Colors.white,
                              ),
                              hintText: 'Contraseña',
                              errorStyle: TextStyle(
                                color: Colors.teal,
                                fontWeight: FontWeight.bold,
                              ),
                              hintStyle: TextStyle(
                                color: Colors.white,
                                fontFamily: 'OpenSans',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            obscureText: true,
                          ),
                        ],
                      ),
                    ),
                    const Padding(padding: EdgeInsets.all(20)),
                    const SizedBox(height: 8),
                    _processing
                        ? const CircularProgressIndicator()
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    elevation: 100,
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  onPressed: () async {
                                    _focusName.unfocus;
                                    _focusEmail.unfocus;
                                    _focusPassword.unfocus;

                                    if (_formKey.currentState!.validate()) {
                                      setState(() {
                                        _processing = true;
                                      });

                                      User? user = await FirebaseAuthentication
                                          .singUpUsingEmailAndPass(
                                              name: _nameFieldController.text,
                                              email: _emailFieldController.text,
                                              password: _passwordFieldController
                                                  .text);

                                      setState(() {
                                        _processing = false;
                                      });

                                      if (user != null) {
                                        if (!mounted) return;
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                HomePageScreen(user: user),
                                          ),
                                        );
                                      } else {
                                        if (!mounted) return;
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            backgroundColor: Colors.black,
                                            content: Text(
                                              'Correo en uso',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 25,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'OpenSans'),
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  child: const Text(
                                    'Registrarse',
                                    style: TextStyle(
                                        color: Color.fromARGB(255, 104, 34, 4),
                                        fontFamily: 'OpenSans',
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '¿Ya tienes cuenta? ',
                          style: TextStyle(
                              color: Colors.white, fontFamily: 'OpenSans'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const LoginBarberShop(),
                              ),
                            );
                          },
                          child: Text(
                            'Inicia Sesion',
                            style: GoogleFonts.barlow(
                              textStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'OpenSans',
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
