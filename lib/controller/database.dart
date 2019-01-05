import 'dart:async';

import 'package:bloc_login/model/user.dart';
import 'package:firebase_database/firebase_database.dart';

import './../constants.dart';

class Database {
  static Future<String> createUser(User user) async {
    Map<String, dynamic> object = {
      "email": user.email,
      "display_name": user.displayName,
      "phone_number": user.phoneNumber,
      "google_uid": user.googleUid,
      "facebook_uid": user.facebookUid,
    };

    DatabaseReference _databaseReference =
        FirebaseDatabase.instance.reference();

    String uid = _databaseReference.child(DATABASE_USERS).push().key;
    await _databaseReference.child(DATABASE_USERS + uid).set(object);

    return uid;
  }

  static Future<User> getUserById(String uid) async {
    DatabaseReference _databaseReference =
        FirebaseDatabase.instance.reference();
    User user;
    await _databaseReference
        .child(DATABASE_USERS + uid)
        .once()
        .then((DataSnapshot data) {
      user = User.fromDatabase(uid, data.value);
    });
    return user;
  }

  static Future<List<User>> getAllUsers() async {
    DatabaseReference _databaseReference =
        FirebaseDatabase.instance.reference();

    List<User> users = [];
    await _databaseReference
        .child(DATABASE_USERS)
        .once()
        .then((DataSnapshot data) {
      data.value.forEach((key, value) {
        users.add(User.fromDatabase(key, value));
      });
    });
    return users;
  }
}
