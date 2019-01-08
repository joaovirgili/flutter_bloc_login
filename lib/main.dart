import 'package:bloc_login/controller/bloc/register-bloc.dart';
import 'package:bloc_login/view/register.dart';
import 'package:bloc_login/view/splash.dart';

import './controller/bloc/home-bloc.dart';
import './controller/bloc/login-bloc.dart';
import './view/home.dart';
import './view/login.dart';
import 'constants.dart';

import 'package:flutter/material.dart';
import 'package:bloc_pattern/bloc_pattern.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        primaryColor: Color(0xFF6DA2FF),
        backgroundColor: Color(0xFFEFF3FF),
        hintColor: Color(0xFF6DA2FF),
      ),
      home: Builder(
        builder: (BuildContext context) {
          return new MySplash(
            navigateAfterSeconds:
                BlocProvider(child: LoginPage(), bloc: LoginBloc(context)),
          );
        },
      ),
      routes: <String, WidgetBuilder>{
        PATH_HOME: (context) =>
            BlocProvider(child: Home(), bloc: HomeBloc(context)),
        PATH_LOGIN: (context) =>
            BlocProvider(child: LoginPage(), bloc: LoginBloc(context)),
        PATH_REGISTER: (context) =>
            BlocProvider(child: RegisterPage(), bloc: RegisterBloc(context)),
      },
    );
  }
}
