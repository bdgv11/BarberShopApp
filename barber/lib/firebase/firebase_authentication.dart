import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthentication {
  static Future<User?> signInUsingEmailAndPassword({
    required String email,
    required String password,
  }) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: email, password: password);

      user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        //print('Email no existe');
      } else if (e.code == 'wrong-password') {
        //print('Contraseña incorrecta');
      }
    }
    return user;
  }

  static Future<User?> singUpUsingEmailAndPass({
    required String name,
    required String email,
    required String password,
  }) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: email, password: password);

      user = userCredential.user;

      await user!.updateDisplayName(name);
      await user.reload();
      user = auth.currentUser;
      //
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        //print('Advertencia: contraseña muy débil');
      } else if (e.code == 'email-already-in-use') {
        //print('Error: Correo ya está en uso');
      }
    } catch (e) {
      //print(e);
    }
    return user;
  }
}
