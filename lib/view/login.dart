import '../constants.dart';
import '../controller/bloc/login-bloc.dart';

import 'package:flutter/material.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/services.dart';

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() {
    return new LoginPageState();
  }
}

class LoginPageState extends State<LoginPage> {
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _emailKey = GlobalKey<FormFieldState>();
  final _passwordKey = GlobalKey<FormFieldState>();

  double _height = 320;

  void initState() {
    super.initState();

    // Validate e-mail
    _emailFocus.addListener(() {
      if (!_emailFocus.hasFocus && !_emailKey.currentState.validate()) {
        FocusScope.of(context).requestFocus(_emailFocus);
      }
    });

    _emailFocus.addListener(() {
      if (!_emailFocus.hasFocus && !_emailKey.currentState.validate()) {
        FocusScope.of(context).requestFocus(_emailFocus);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    this._emailController.dispose();
    this._passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final LoginBloc loginController = BlocProvider.of<LoginBloc>(context);
    loginController.checkUser();
    _emailFocus.addListener(() {
      if (_emailFocus.hasFocus) {
        loginController.checkAndCleanError();
      }
    });
    _passwordFocus.addListener(() {
      if (_passwordFocus.hasFocus) {
        loginController.checkAndCleanError();
      }
    });
    return Scaffold(
      body: Stack(children: [
        Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: Theme.of(context).backgroundColor,
        ),
        Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    buildLogosSection(),
                    SizedBox(height: 40.0),
                    Container(
                      height: this._height,
                      width: 290,
                      child: Stack(
                        children: <Widget>[
                          Positioned(
                              top: (75 / 2),
                              child:
                                  buildFormContainer(context, loginController)),
                          Align(
                              alignment: Alignment.topCenter,
                              child: buildUserImage()),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: buildLoginButtons(loginController),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 20.0),
                    buildRegiserButton(context)
                  ],
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Container buildUserImage() {
    return new Container(
      width: 75.0,
      height: 75.0,
      decoration: new BoxDecoration(
        boxShadow: [
          new BoxShadow(
            color: Color(0xFFB5B5B5),
            blurRadius: 5.0,
          ),
        ],
        color: Colors.black,
        image: new DecorationImage(
          image: AssetImage('assets/img/default-user.png'),
          fit: BoxFit.cover,
        ),
        borderRadius: new BorderRadius.all(new Radius.circular(50.0)),
        border: new Border.all(
          color: Colors.white,
          width: 4.0,
        ),
      ),
    );
  }

  Container buildFormContainer(
      BuildContext context, LoginBloc loginController) {
    return Container(
      width: 280,
      height: (this._height - (75 / 2) - 25),
      margin: EdgeInsets.only(left: 5),
      decoration: BoxDecoration(
          boxShadow: [new BoxShadow(color: Color(0xFFB5B5B5), blurRadius: 5.0)],
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(25.0))),
      padding: EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildEmailFormField(context),
          SizedBox(height: 20.0),
          buildPasswordFormField(loginController),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              FlatButton(
                padding: EdgeInsets.zero,
                child: Text("Esqueceu a senha?"),
                onPressed: () => {},
              )
            ],
          ),
          buildErrorStream(loginController),
        ],
      ),
    );
  }

  FlatButton buildRegiserButton(BuildContext context) {
    return FlatButton(
      onPressed: () => {},
      child: Text(
        "Registre-se",
        style: TextStyle(color: Theme.of(context).primaryColor),
      ),
    );
  }

  /// Responsible method for creating logos' section
  Widget buildLogosSection() {
    return Hero(
      tag: 'logo',
      child:
          Image.asset('assets/img/logo-bird.png', width: 100.0, height: 100.0),
    );
  }

  /// Responsible method for e-mail input
  Widget buildEmailFormField(BuildContext context) {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      controller: _emailController,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: "E-mail",
        contentPadding: EdgeInsets.all(15),
      ),
      textInputAction: TextInputAction.next,
      focusNode: this._emailFocus,
      onFieldSubmitted: (content) {
        if (_emailKey.currentState.validate())
          FocusScope.of(context).requestFocus(this._passwordFocus);
      },
      key: _emailKey,
      validator: (content) {
        if (content.isEmpty || !content.contains('@')) return ERROR_EMAIL;
      },
    );
  }

  /// Responsible method for password input
  Widget buildPasswordFormField(LoginBloc loginController) {
    return StreamBuilder<Object>(
        stream: loginController.outObscurePassword,
        builder: (context, snapshot) {
          return TextFormField(
            controller: _passwordController,
            key: _passwordKey,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Password",
              suffixIcon: IconButton(
                icon: Icon(Icons.lock_outline),
                onPressed: loginController.toggleObscure,
              ),
              contentPadding: EdgeInsets.all(15),
            ),
            obscureText: snapshot.data != null ? snapshot.data : true,
            textInputAction: TextInputAction.go,
            focusNode: this._passwordFocus,
            onFieldSubmitted: (content) {
              if (_passwordKey.currentState.validate())
                validateAndSignIn(loginController);
              else
                FocusScope.of(context).requestFocus(this._passwordFocus);
            },
            validator: (content) {
              if (content.isEmpty)
                return ERROR_EMPTY_PASSWORD;
              else if (content.length < 6) return ERROR_MIN_PASSWORD;
            },
          );
        });
  }

  /// Responsible method for loading widget
  Widget buildLoading() {
    return Container(
      child: CircularProgressIndicator(),
      padding: EdgeInsets.all(5),
    );
  }

  /// Responsible method for creating animation on auth error
  Widget buildErrorStream(loginController) {
    return StreamBuilder(
      stream: loginController.outError,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData)
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(2.0),
                child: Text('${snapshot.data}',
                    textAlign: TextAlign.end,
                    style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          );
        else
          return SizedBox(
            height: 10.0,
          );
      },
    );
  }

  Widget buildLoginButtons(LoginBloc loginController) {
    return StreamBuilder<Object>(
        stream: loginController.outLoading,
        initialData: false,
        builder: (context, snapshot) {
          if (snapshot.data != null)
            return AnimatedCrossFade(
              duration: Duration(milliseconds: 300),
              crossFadeState: snapshot.data
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              secondChild: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  buildLoading(),
                ],
              ),
              firstChild: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      SocialButton(
                        onPressed: loginController.loginGoogle,
                        logo: Icon(FontAwesomeIcons.google),
                        color: Color(0xFFd52d28),
                      ),
                      SizedBox(width: 10),
                      SocialButton(
                        onPressed: loginController.loginFacebook,
                        logo: Icon(FontAwesomeIcons.facebook),
                        color: Color(0xFF4267b2),
                      ),
                    ],
                  ),
                  SocialButton(
                    onPressed: () {
                      validateAndSignIn(loginController);
                    },
                    logo: Icon(Icons.arrow_forward),
                    color: Theme.of(context).primaryColor,
                  )
                ],
              ),
            );
        });
  }

  void validateAndSignIn(LoginBloc loginController) {
    if (_emailFocus.hasFocus) _emailFocus.unfocus();
    if (_passwordFocus.hasFocus) _passwordFocus.unfocus();
    if (_formKey.currentState.validate()) {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      loginController.inEmail.add(_emailController.text.toString().trim());
      loginController.inPassword.add(_passwordController.text);
      loginController.loginEmail();
    }
  }
}

class SocialButton extends StatelessWidget {
  SocialButton(
      {@required this.onPressed, @required this.logo, @required this.color});

  final VoidCallback onPressed;
  final Icon logo;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      child: IconButton(icon: logo, color: Colors.white, onPressed: onPressed),
    );
  }
}
