import 'dart:async';

import 'package:bloc_login/constants.dart';
import 'package:bloc_login/controller/bloc/login-bloc.dart';
import 'package:bloc_login/view/login.dart';
import 'package:bloc_login/widgets/CustomRout.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:progress_indicators/progress_indicators.dart';

class MySplash extends StatefulWidget {
  final navigateAfterSeconds;

  const MySplash({
    Key key,
    @required this.navigateAfterSeconds,
  }) : super(key: key);

  @override
  MySplashState createState() {
    return new MySplashState();
  }
}

class MySplashState extends State<MySplash> {
  void initState() {
    super.initState();
    goToLoginPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: Theme.of(context).backgroundColor,
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                HeartbeatProgressIndicator(
                  child: Hero(
                    tag: 'logo',
                    child: Image.asset(
                      'assets/img/logo-bird.png',
                      width: 100.0,
                      height: 100.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future goToLoginPage() async {
    await new Future.delayed(const Duration(milliseconds: 4000));
    Navigator.of(context).push(
      AppPageRoute(
          builder: (BuildContext context) => BlocProvider(
                child: LoginPage(),
                bloc: LoginBloc(context),
              )),
    );
  }
}
