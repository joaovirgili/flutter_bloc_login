import '../controller/bloc/home-bloc.dart';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final HomeBloc homeController = BlocProvider.of<HomeBloc>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        backgroundColor: Theme.of(context).accentColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new UsernameText(homeController: homeController),
            SizedBox(
              height: 20.0,
            ),
            RaisedButton(
              child: Text("Logout"),
              onPressed: () async {
                await homeController.signout();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class UsernameText extends StatefulWidget {
  const UsernameText({
    Key key,
    @required this.homeController,
  }) : super(key: key);

  final HomeBloc homeController;

  @override
  UsernameTextState createState() {
    homeController.getCurrentUser();
    return new UsernameTextState();
  }
}

class UsernameTextState extends State<UsernameText> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.homeController.outName,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        return Text('Usuário logado: ${snapshot.data}');
      },
      initialData: "",
    );
  }
}
