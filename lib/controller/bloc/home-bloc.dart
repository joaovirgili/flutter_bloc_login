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
  var _userController = BehaviorSubject<User>();

  // Outputs
  Stream<User> get outUser => _userController.stream;

  // Inputs
  Sink<User> get inUser => _userController.sink;

  signout() async {
    await this.auth.signout();
    navigateToLogin();
  }

  navigateToLogin() {
    Navigator.of(this.context)
        .pushNamedAndRemoveUntil(PATH_LOGIN, (Route<dynamic> route) => false);
  }

  getCurrentUser() async {
    User user = await auth.getCurrentUser();
    if (user != null) {
      this.inUser.add(user);
    } else {
      this.navigateToLogin();
    }
  }

  @override
  void dispose() {
    _userController.close();
  }
}
