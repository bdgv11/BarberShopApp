import 'package:barber/feature_login/screens/login_barber_shop.dart';
import 'package:barber/utils/general.dart';
import 'package:barber/utils/validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  //
  final formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  //
  bool _processingLogIn = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: myBoxDecoration,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Recibe un email para reestablecer tu contraseña.',
                  textAlign: TextAlign.center,
                  style: myTitle30Style,
                ),
                const Padding(padding: EdgeInsets.all(30)),
                TextFormField(
                  style: myTextFieldStyle,
                  validator: (value) =>
                      Validator.validateEmail(email: _emailController.text),
                  controller: _emailController,
                  cursorColor: Colors.white,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'Correo electrónico',
                    errorStyle: TextStyle(
                      color: Colors.teal,
                      fontWeight: FontWeight.bold,
                    ),
                    hintStyle:
                        TextStyle(color: Colors.white, fontFamily: 'OpenSans'),
                  ),
                ),
                const Padding(padding: EdgeInsets.all(15)),
                _processingLogIn
                    ? const CircularProgressIndicator()
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                setState(() {
                                  _processingLogIn = true;
                                });
                                if (formKey.currentState!.validate()) {
                                  resetPassword();

                                  setState(() {
                                    _processingLogIn = false;
                                  });
                                }
                                setState(() {
                                  _processingLogIn = false;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                elevation: 30,
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text(
                                'Reestablecer contraseña',
                                style: myButtonTextStyle,
                              ),
                            ),
                          )
                        ],
                      ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '¿La recordaste? ',
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
    );
  }

  Future resetPassword() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim());
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const LoginBarberShop(),
      ));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.black,
          duration: const Duration(milliseconds: 500),
          content: Text(
            'Correo enviado.',
            textAlign: TextAlign.center,
            style: myTitle25Style,
          ),
        ),
      );
    } on FirebaseAuthException {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.black,
          duration: const Duration(milliseconds: 500),
          content: Text(
            'No existe ese correo.',
            textAlign: TextAlign.center,
            style: myTitle25Style,
          ),
        ),
      );
    }
  }
}
