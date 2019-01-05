import 'dart:convert';

import 'package:bloc_login/sharedPreferencesHelper.dart';

import '../model/user.dart';
import 'database.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

import 'package:http/http.dart' as http;
import 'dart:async';

enum loginMethod { Google, Facebook, Email }

class Authenticator {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignInAccount = GoogleSignIn();
  final FacebookLogin _facebookSignIn = new FacebookLogin();

  Authenticator() {
    _firebaseAuth.setLanguageCode('pt-PT');
  }

  // Returns an User instance of current user from SharedPreferences
  Future<User> getCurrentUser() async {
    String uid = await SharedPreferencesHelper.getCurrentUserPrefs();
    if (uid == "") return null;
    return await Database.getUserById(uid);
  }

  // Check if user already exists
  Future<dynamic> userExists(String email) async {
    List<User> users = await Database.getAllUsers();
    for (var i = 0; i < users.length; i++) {
      if (users[i].email == email) {
        return users[i].uid;
      }
    }
    return false;
  }

  // E-mail login
  Future<bool> signInWithEmail(String email, String password) async {
    try {
      FirebaseUser firebaseUser = await this
          ._firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      User user = User.fromEmail(firebaseUser);
      var uid = await userExists(user.email);
      SharedPreferencesHelper.setCurrentUserPrefs(uid);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Facebook login
  Future<bool> signInWithFacebook() async {
    final FacebookLoginResult result =
        await this._facebookSignIn.logInWithReadPermissions(['email']);
    User user = await this._getFacebookUser(result.accessToken);

    if (result.status == FacebookLoginStatus.loggedIn) {
      var uid = await userExists(user.email);
      if (uid == false) {
        uid = await Database.createUser(user);
      }
      SharedPreferencesHelper.setCurrentUserPrefs(uid);
      return true;
    } else if (result.status == FacebookLoginStatus.cancelledByUser) {
      print("Login facebook: cancelado");
      return false;
    } else {
      print("Login facebook ERRO: ${result.errorMessage}");
      return false;
    }
  }

  // Google login
  Future<bool> signInWithGoogle() async {
    try {
      GoogleSignInAccount googleSigniIn = await _googleSignInAccount.signIn();
      User user = User.fromGoogle(googleSigniIn);

      var uid = await userExists(user.email);
      if (uid == false) {
        uid = await Database.createUser(user);
      }
      SharedPreferencesHelper.setCurrentUserPrefs(uid);
      return true;
    } catch (error) {
      print('Erro login Google: $error');
      return false;
    }
  }

  // E-mail register account
  Future<String> singUp(String email, String password) async {
    FirebaseUser user = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    return user.uid;
  }

  // Logout
  signout() async {
    await this._firebaseAuth.signOut();
    await this._googleSignInAccount.signOut();
    await this._facebookSignIn.logOut();
    SharedPreferencesHelper.setCurrentUserPrefs(null);
  }

  // Get facebook user info
  _getFacebookUser(FacebookAccessToken token) async {
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
}
