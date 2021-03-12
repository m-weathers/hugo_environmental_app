import 'package:firebase_auth/firebase_auth.dart';
import 'package:localstorage/localstorage.dart';

class Auth {
  final FirebaseAuth auth = FirebaseAuth.instance;
  LocalStorage storage = new LocalStorage('hugoapp.json');

  Future<bool> init() async {
    await storage.ready;
    return true;
  }

  Future<bool> userLogin(String eEmail, String ePassw) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: eEmail, password: ePassw);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
      return false;
    }
    return true;
  }

  Future<bool> userRegister(String nEmail, String nPassw) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: nEmail, password: nPassw);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
    return true;
  }
}
