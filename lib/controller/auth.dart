import '../model/user.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'dart:async';

class Authenticator {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignInAccount = GoogleSignIn();

  Authenticator() {
    _firebaseAuth.setLanguageCode('pt-PT');
  }

  Future<User> getCurrentUser() async {
    FirebaseUser user = await this._firebaseAuth.currentUser();
    return user != null ? new User(user) : null;
  }

  signout() async {
    await _firebaseAuth.signOut();
    await _googleSignInAccount.signOut();
  }

  Future<bool> signInWithGoogle() async {
    try {
      GoogleSignInAccount googleAuthentication =
          await _googleSignInAccount.signIn();
      await googleAuthentication.authentication;
      return true;
    } catch (error) {
      print('Erro login Google: $error');
      return false;
    }
  }

  // User sign in returning uid
  Future<User> signIn(String email, String password) async {
    FirebaseUser user;
    try {
      user = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return new User(user);
    } catch (e) {
      return null;
    }
  }

  Future<String> singUp(String email, String password) async {
    FirebaseUser user = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    return user.uid;
  }
}
