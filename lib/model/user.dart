import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class User {
  String _displayName;
  String _email;
  String _phoneNumber;
  String _uid;
  String _authUid;
  String _googleUid;
  String _facebookUid;

  User.fromEmail(FirebaseUser user) {
    if (user != null) {
      this._email = user.email;
      this._displayName = user.displayName;
      this._phoneNumber = user.phoneNumber;
      this._uid = "";
      this._authUid = user.uid;
      this._facebookUid = "";
      this._googleUid = "";
    }
  }

  User.fromDatabase(String key, Map<dynamic, dynamic> data) {
    this._email = data['email'] ?? "";
    this._displayName = data['display_name'] ?? "";
    this._phoneNumber = data['phone_number'] ?? "";
    this._uid = key;
    this._authUid = data['google_uid'] ?? "";
    this._googleUid = data['google_uid'] ?? "";
    this._facebookUid = data['facebook_uid'] ?? "";
  }

  User.fromFacebook(profile) {
    this._email = profile['email'];
    this._displayName = "${profile['name']}";
    this._phoneNumber = "";
    this._uid = "";
    this._authUid = "";
    this._googleUid = "";
    this._facebookUid = profile['id'];
  }

  User.fromGoogle(GoogleSignInAccount googleUser) {
    this._email = googleUser.email;
    this._displayName = googleUser.displayName;
    this._phoneNumber = "";
    this._uid = "";
    this._authUid = "";
    this._googleUid = googleUser.id;
    this._facebookUid = "";
  }

  get displayName => this._displayName;
  get email => this._email;
  get phoneNumber => this._phoneNumber;
  get uid => this._uid;
  get authUid => this._authUid;
  get googleUid => this._googleUid;
  get facebookUid => this._facebookUid;
}
