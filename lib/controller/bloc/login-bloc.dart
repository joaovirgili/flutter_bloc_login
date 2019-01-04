import '../../controller/auth.dart';
import '../../model/user.dart';
import '../../constants.dart';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import 'dart:async';

class LoginBloc implements BlocBase {
  final BuildContext context;

  LoginBloc(this.context);

  // Authentication
  final Authenticator auth = Authenticator();

  // Controllers
  var _emailController = BehaviorSubject<String>();
  var _passwordController = BehaviorSubject<String>();
  var _loadingController = BehaviorSubject<bool>(seedValue: false);
  var _errorController = BehaviorSubject<String>();

  // Outputs
  Stream<String> get outEmail => _emailController.stream;
  Stream<String> get outPassword => _passwordController.stream;
  Stream<bool> get outLoading => _loadingController.stream;
  Stream<String> get outError => _errorController.stream;

  // Inputs
  Sink<String> get inEmail => _emailController.sink;
  Sink<String> get inPassword => _passwordController.sink;
  Sink<bool> get inLoading => _loadingController.sink;
  Sink<String> get inError => _errorController.sink;

  checkUser() async {
    inLoading.add(true);
    var user = await this.auth.getCurrentUser();
    inLoading.add(false);
    if (user != null) {
      navigateToHome();
    }
  }

  loginEmail() async {
    // Inicia o loading
    _loadingController.add(true);

    final email = _emailController.value;
    final password = _passwordController.value;
    User user = await auth.signIn(email, password);
    _loadingController.add(false);
    if (user == null) {
      inError.add(ERROR_VALIDATION);
    } else {
      navigateToHome();
    }
  }

  loginGoogle() async {
    _loadingController.add(true);
    bool ok = await auth.signInWithGoogle();
    _loadingController.add(false);
    if (ok) navigateToHome();
  }

  loginFacebook() async {
    // await this.auth.signInWithFacebook();
  }

  signout() async {
    await this.auth.signout();
  }

  navigateToHome() {
    Navigator.of(this.context)
        .pushNamedAndRemoveUntil(PATH_HOME, (Route<dynamic> route) => false);
  }

  @override
  void dispose() {
    _emailController.close();
    _passwordController.close();
    _loadingController.close();
    _errorController.close();
  }
}
