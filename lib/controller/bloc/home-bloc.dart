import '../../controller/auth.dart';
import '../../model/user.dart';
import '../../constants.dart';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import 'dart:async';

class HomeBloc implements BlocBase {
  final BuildContext context;

  HomeBloc(this.context);

  // Authentication
  final Authenticator auth = Authenticator();

  // Controllers
  var _nameController = BehaviorSubject<String>();

  // Outputs
  Stream<String> get outName => _nameController.stream;

  // Inputs
  Sink<String> get inName => _nameController.sink;

  signout() async {
    await this.auth.signout();
    navigateToLogin();
  }

  navigateToLogin() {
    Navigator.of(this.context)
        .pushNamedAndRemoveUntil(PATH_LOGIN, (Route<dynamic> route) => true);
  }

  getCurrentUser() async {
    User user = await auth.getCurrentUser();
    if (user != null) {
      String display = user.displayName != null ? user.displayName : user.email;
      this.inName.add(display);
    } else {
      this.navigateToLogin();
    }
  }

  @override
  void dispose() {
    _nameController.close();
  }
}
