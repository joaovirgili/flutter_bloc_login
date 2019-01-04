import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class User {
  String _displayName;
  String _email;
  String _phoneNumber;
  String _uid;

  User(FirebaseUser user) {
    if (user != null) {
      this._email = user.email;
      this._displayName = user.displayName;
      this._phoneNumber = user.phoneNumber;
      this._uid = user.uid;
    }
  }

  User.fromFacebook(profile) {
    this._email = profile['email'];
    this._displayName = "${profile['name']}";
    this._phoneNumber = "";
    this._uid = profile['id'];
  }

  User.fromGoogle(GoogleSignInAccount googleUser) {
    this._email = googleUser.email;
    this._displayName = googleUser.displayName;
    this._phoneNumber = "";
    this._uid = googleUser.id;
  }

  get displayName => this._displayName;
  get email => this._email;
  get phoneNumber => this._phoneNumber;
  get uid => this._uid;
}
