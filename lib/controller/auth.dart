import 'dart:async';

import 'package:bloc_login/model/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  Future<User> signInWithGoogle() async {
    GoogleSignInAccount googleAuthentication =
        await _googleSignInAccount.signIn();
    final authenticated = await googleAuthentication.authentication;
    FirebaseUser user = await _firebaseAuth.signInWithGoogle(
        idToken: authenticated.idToken, accessToken: authenticated.accessToken);
    return new User(user);
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
