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
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Builder(
        builder: (BuildContext context) {
          return BlocProvider(
            child: LoginPage(),
            bloc: LoginBloc(context),
          );
        },
      ),
      routes: <String, WidgetBuilder>{
        PATH_HOME: (context) =>
            BlocProvider(child: Home(), bloc: HomeBloc(context)),
        PATH_LOGIN: (context) =>
            BlocProvider(child: LoginPage(), bloc: LoginBloc(context)),
      },
    );
  }
}
