import 'dart:convert';

import 'package:bloc_login/sharedPreferencesHelper.dart';

import '../model/user.dart';
import 'database.dart';

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

  // Returns an User instance of current user from SharedPreferences
  Future<User> getCurrentUser() async {
    String uid = await SharedPreferencesHelper.getCurrentUserPrefs();
    if (uid == "") return null;
    return await Database.getUserById(uid);
  }

  // Check if user already exists
  Future<User> userExists(String email) async {
    List<User> users = await Database.getAllUsers();
    for (var i = 0; i < users.length; i++) {
      if (users[i].email == email) {
        return users[i];
      }
    }
    return null;
  }

  // E-mail login
  Future<bool> signInWithEmail(String email, String password) async {
    try {
      FirebaseUser firebaseUser = await this
          ._firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      User loginUser = User.fromEmail(firebaseUser);
      User databaseUser = await userExists(loginUser.email);
      if (databaseUser == null) return null;
      SharedPreferencesHelper.setCurrentUserPrefs(databaseUser.uid);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  // Facebook login
  Future<bool> signInWithFacebook() async {
    final FacebookLoginResult result =
        await this._facebookSignIn.logInWithReadPermissions(['email']);
    User loginUser = await this._getFacebookUser(result.accessToken);

    if (result.status == FacebookLoginStatus.loggedIn) {
      await this._checkDatabase(loginUser, LoginMethod.Facebook);
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
      User loginUser = User.fromGoogle(googleSigniIn);
      await this._checkDatabase(loginUser, LoginMethod.Google);
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
  _getFacebookUser(FacebookAccessToken accessToken) async {
    if (accessToken != null) {
      var graphResponse = await http.get(
          'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email,picture.height(200)&access_token=${accessToken.token}');
      if (graphResponse.statusCode == 200) {
        var body = json.decode(graphResponse.body);
        return new User.fromFacebook(body);
      }
    }
    return null;
  }

  // Check if account is already associated with the login method used
  bool checkAssociate(LoginMethod method, User user) {
    switch (method) {
      case LoginMethod.Email:
        return user.password != "";
        break;
      case LoginMethod.Facebook:
        return user.facebookUid != "";
        break;
      case LoginMethod.Google:
        return user.googleUid != "";
        break;
    }
    return false;
  }

  /// Check if user logged exists in database and create if does not
  /// Set shared prefs to sabe user logged in.
  _checkDatabase(User loginUser, LoginMethod method) async {
    User databaseUser = await userExists(loginUser.email);
    String uid;
    if (databaseUser != null) {
      uid = databaseUser.uid;
      await this._updateInfoOnLogin(method, loginUser, databaseUser);
    } else {
      uid = await Database.createUser(loginUser);
    }
    SharedPreferencesHelper.setCurrentUserPrefs(uid);
  }

  /// @param User databaseUser: user instance from database
  /// @param User loginUser: user instance from login
  /// @param LoginMetho method: method used for logging in
  ///
  /// Update user's info if hasn't already associated account by this method
  /// Compares which information must be filled in database
  Future<void> _updateInfoOnLogin(
      LoginMethod method, User loginUser, User databaseUser) async {
    if (!checkAssociate(method, databaseUser)) {
      Map<String, dynamic> info = {};

      if (databaseUser.displayName == "" && loginUser.displayName != "")
        info['display_name'] = loginUser.displayName;
      if (databaseUser.phoneNumber == "" && loginUser.phoneNumber != "")
        info['phone_number'] = loginUser.phoneNumber;
      if (databaseUser.authUid == "" && loginUser.authUid != "")
        info['auth_id'] = loginUser.authUid;
      if (databaseUser.googleUid == "" && loginUser.googleUid != "")
        info['google_uid'] = loginUser.googleUid;
      if (databaseUser.facebookUid == "" && loginUser.facebookUid != "")
        info['facebook_uid'] = loginUser.facebookUid;
      if (databaseUser.photoUrl == "" && loginUser.photoUrl != "")
        info['photo_url'] = loginUser.photoUrl;

      print(info.toString());

      await Database.updateUserInfo(info, databaseUser.uid);
    }
  }
}
