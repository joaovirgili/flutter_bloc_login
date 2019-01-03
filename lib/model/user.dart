import 'package:firebase_auth/firebase_auth.dart';

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

  get displayName => this._displayName;
  get email => this._email;
  get phoneNumber => this._phoneNumber;
  get uid => this._uid;
}
