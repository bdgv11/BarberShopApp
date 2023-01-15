import 'package:barber/feature_home/screens/home_page.dart';
import 'package:barber/feature_login/screens/login_barber_shop.dart';
import 'package:barber/firebase/firebase_authentication.dart';
import 'package:barber/utils/general.dart';
import 'package:barber/utils/validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
            decoration: myBoxDecoration,
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
                          Text(
                            'Registro',
                            style: myTitle30Style,
                          ),
                          const Padding(padding: EdgeInsets.all(8)),
                          TextFormField(
                            style: myTextFieldStyle,
                            validator: (value) => Validator.validateName(
                                name: _nameFieldController.text),
                            controller: _nameFieldController,
                            focusNode: _focusName,
                            decoration: InputDecoration(
                              icon: const Icon(
                                Icons.person_outline_outlined,
                                size: 25,
                                color: Colors.white,
                              ),
                              hintText: 'Nombre completo',
                              errorStyle: const TextStyle(
                                color: Colors.teal,
                                fontWeight: FontWeight.bold,
                              ),
                              hintStyle: myHintStyle,
                            ),
                          ),
                          const Padding(padding: EdgeInsets.all(8)),
                          const SizedBox(height: 8),
                          TextFormField(
                            style: myTextFieldStyle,
                            validator: (value) => Validator.validateEmail(
                                email: _emailFieldController.text),
                            controller: _emailFieldController,
                            focusNode: _focusEmail,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              icon: const Icon(
                                Icons.email_outlined,
                                size: 25,
                                color: Colors.white,
                              ),
                              hintText: 'Correo Electrónico',
                              errorStyle: const TextStyle(
                                color: Colors.teal,
                                fontWeight: FontWeight.bold,
                              ),
                              hintStyle: myHintStyle,
                            ),
                          ),
                          const Padding(padding: EdgeInsets.all(8)),
                          const SizedBox(height: 8),
                          TextFormField(
                            style: myTextFieldStyle,
                            validator: (value) => Validator.validatePassword(
                                password: _passwordFieldController.text),
                            controller: _passwordFieldController,
                            focusNode: _focusPassword,
                            decoration: InputDecoration(
                              icon: const Icon(
                                Icons.key_outlined,
                                size: 25,
                                color: Colors.white,
                              ),
                              hintText: 'Contraseña',
                              errorStyle: const TextStyle(
                                color: Colors.teal,
                                fontWeight: FontWeight.bold,
                              ),
                              hintStyle: myHintStyle,
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
                                        SharedPreferences pref =
                                            await SharedPreferences
                                                .getInstance();
                                        pref.setString(
                                            "email", user.email.toString());
                                        pref.setString("userId", user.uid);
                                        pref.setString("name",
                                            user.displayName.toString());
                                        if (!mounted) return;
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const HomePageScreen(),
                                          ),
                                        );
                                      } else {
                                        if (!mounted) return;
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            backgroundColor: Colors.black,
                                            content: Text(
                                              'Correo en uso',
                                              textAlign: TextAlign.center,
                                              style: myTitle25Style,
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  child: Text(
                                    'Registrarse',
                                    style: myButtonTextStyle,
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
