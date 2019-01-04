import 'dart:convert';

import '../model/user.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

import 'package:http/http.dart' as http;
import 'dart:async';

class Authenticator {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignInAccount = GoogleSignIn();
  final FacebookLogin _facebookSignIn = new FacebookLogin();

  Authenticator() {
    _firebaseAuth.setLanguageCode('pt-PT');
  }

  Future<User> getCurrentUser() async {
    // Check firebase user
    FirebaseUser firebaseUser = await this._firebaseAuth.currentUser();
    if (firebaseUser != null) {
      return new User(firebaseUser);
    }

    // TODO: Check google user
    bool loggedIn = await this._googleSignInAccount.isSignedIn();
    if (loggedIn) {
      GoogleSignInAccount googleUser = _googleSignInAccount.currentUser;
      //   print(googleUser.displayName);
      //   if (googleUser != null) {
      //     return new User.fromGoogle(googleUser);
      //   }
    }

    // Check facebook user
    FacebookAccessToken token = await this._facebookSignIn.currentAccessToken;
    if (token != null) {
      var graphResponse = await http.get(
          'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=${token.token}');
      if (graphResponse.statusCode == 200) {
        var body = json.decode(graphResponse.body);
        return new User.fromFacebook(body);
      }
    }
    return null;
  }

  signout() async {
    await this._firebaseAuth.signOut();
    await this._googleSignInAccount.signOut();
    await this._facebookSignIn.logOut();
  }

  Future<bool> signInWithEmail(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> signInWithFacebook() async {
    final FacebookLoginResult result =
        await this._facebookSignIn.logInWithReadPermissions(['email']);

    if (result.status == FacebookLoginStatus.loggedIn)
      return true;
    else if (result.status == FacebookLoginStatus.cancelledByUser) {
      print("Login facebook: cancelado");
      return false;
    } else {
      print("Login facebook ERRO: ${result.errorMessage}");
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      await _googleSignInAccount.signIn();
      return true;
    } catch (error) {
      print('Erro login Google: $error');
      return false;
    }
  }

  Future<String> singUp(String email, String password) async {
    FirebaseUser user = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    return user.uid;
  }
}
