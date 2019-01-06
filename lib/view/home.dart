import 'package:bloc_login/model/user.dart';

import '../controller/bloc/home-bloc.dart';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final HomeBloc homeController = BlocProvider.of<HomeBloc>(context);
    homeController.getCurrentUser();
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Bloc'),
        backgroundColor: Theme.of(context).accentColor,
      ),
      body: Center(child: Text('Bem-vindo.')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            StreamBuilder<User>(
                stream: homeController.outUser,
                builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
                  return snapshot.data != null
                      ? UserAccountsDrawerHeader(
                          otherAccountsPictures: <Widget>[
                            CircleAvatar(
                              backgroundImage: snapshot.data.photoUrl != ""
                                  ? NetworkImage(snapshot.data.photoUrl)
                                  : AssetImage('assets/img/default-user.png'),
                            )
                          ],
                          accountName: Text(snapshot.data.displayName),
                          accountEmail: Text(snapshot.data.email),
                        )
                      : Container();
                }),
            ListTile(
              leading: Icon(Icons.arrow_back),
              title: Text("Logout"),
              onTap: () async {
                await homeController.signout();
              },
            ),
          ],
        ),
      ),
    );
  }
}
