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
  final FocusNode _emaiFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  buildLogosSection(),
                  SizedBox(height: 30.0),
                  buildEmailFormField(context),
                  SizedBox(height: 20.0),
                  buildPasswordFormField(loginController),
                  SizedBox(height: 15.0),
                  buildButtonsSection(loginController),
                  SizedBox(height: 20.0),
                  buildRegisterSection(loginController)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Responsible method for creating logos' section
  Widget buildLogosSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Image.asset('assets/img/flutter-logo.png', width: 100.0, height: 100.0),
        Image.asset('assets/img/bloc-pattern.png', width: 100.0, height: 100.0),
      ],
    );
  }

  /// Responsible method for e-mail input
  Widget buildEmailFormField(BuildContext context) {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      controller: _emailController,
      decoration:
          InputDecoration(border: UnderlineInputBorder(), labelText: "E-mail"),
      textInputAction: TextInputAction.next,
      focusNode: this._emaiFocus,
      onFieldSubmitted: (content) {
        FocusScope.of(context).requestFocus(this._passwordFocus);
      },
      validator: (content) {
        if (content.isEmpty || !content.contains('@')) return ERROR_EMAIL;
      },
    );
  }

  /// Responsible method for password input
  Widget buildPasswordFormField(LoginBloc loginController) {
    return TextFormField(
      controller: _passwordController,
      decoration: InputDecoration(
          border: UnderlineInputBorder(), labelText: "Password"),
      obscureText: true,
      textInputAction: TextInputAction.go,
      focusNode: this._passwordFocus,
      onFieldSubmitted: (content) {
        validateAndSignIn(loginController);
      },
      validator: (content) {
        if (content.isEmpty)
          return ERROR_EMPTY_PASSWORD;
        else if (content.length < 6) return ERROR_MIN_PASSWORD;
      },
    );
  }

  /// Responsible method for creating animation when pressing the buttons
  Widget buildButtonsSection(LoginBloc loginController) {
    return StreamBuilder(
      stream: loginController.outLoading,
      initialData: false,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        return AnimatedCrossFade(
          crossFadeState: snapshot.data
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: buildButtons(context, loginController),
          secondChild: buildLoading(),
          duration: Duration(milliseconds: 300),
        );
      },
    );
  }

  /// Responsible method for register section
  Widget buildRegisterSection(LoginBloc loginController) {
    return Center(
      child: FlatButton(
        child: Text(
          "Não possui conta? Registre-se.",
          style: TextStyle(color: Colors.grey[500]),
        ),
        onPressed: () {
          loginController.navigateToRegister();
        },
      ),
    );
  }

  /// Responsible method for loading widget
  Widget buildLoading() {
    return Center(
        child: Container(
            child: CircularProgressIndicator(), padding: EdgeInsets.all(50.0)));
  }

  /// Responsible method for creating button tree
  Column buildButtons(context, loginController) {
    return Column(
      children: <Widget>[
        buildLoginButton(context, loginController),
        buildErrorStream(loginController),
        Separator(),
        SizedBox(height: 15.0),
        buildSocialButtons(loginController)
      ],
    );
  }

  /// Responsible method for creating
  Container buildLoginButton(context, loginController) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: RaisedButton(
        color: Theme.of(context).accentColor,
        child: Text(
          "Login",
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () {
          validateAndSignIn(loginController);
        },
      ),
    );
  }

  /// Responsible method for creating animation on auth error
  Widget buildErrorStream(loginController) {
    return StreamBuilder(
      stream: loginController.outError,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData)
          return Row(
            mainAxisAlignment: MainAxisAlignment.end,
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
            height: 15.0,
          );
      },
    );
  }

  // Build row of Social buttons
  Widget buildSocialButtons(loginController) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        SocialButton(
          onPressed: loginController.loginFacebook,
          logo: Icon(FontAwesomeIcons.facebook),
          color: Color(0xFF4267b2),
        ),
        SocialButton(
          onPressed: loginController.loginGoogle,
          logo: Icon(FontAwesomeIcons.google),
          color: Color(0xFFd52d28),
        ),
      ],
    );
  }

  void validateAndSignIn(LoginBloc loginController) {
    if (_formKey.currentState.validate()) {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      loginController.inEmail.add(_emailController.text.toString().trim());
      loginController.inPassword.add(_passwordController.text);
      loginController.loginEmail();
    }
  }
}

class Separator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(width: 2.0, color: Colors.grey[300])),
            ),
          ),
        ),
      ],
    );
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
