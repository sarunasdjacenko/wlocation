import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../services/services.dart';
import '../components/components.dart';

class AccountScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: SafeArea(
        child: user.isAdmin ? AccountPage() : LoginPage(),
      ),
    );
  }
}

class AccountPage extends StatelessWidget {
  void _signOut() => Auth.signOut();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return Column(
      children: <Widget>[
        ListTile(
          title: const Text('Email'),
          subtitle: Text(user.email),
          contentPadding: EdgeInsets.zero,
          leading: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: const Icon(Icons.mail_outline),
              ),
            ],
          ),
        ),
        ListTile(
          title: const Text('Log out'),
          contentPadding: EdgeInsets.zero,
          leading: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: const Icon(Icons.exit_to_app),
              ),
            ],
          ),
          onTap: _signOut,
        ),
      ],
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _email;
  String _password;
  bool _showLoading = false;

  void _showLoadingScreen(bool loading) =>
      setState(() => _showLoading = loading);

  bool _validateEmailPassword(String email, String password) {
    if (email == null || password == null) {
      showSnackBar(context, 'Enter a valid email and password.');
      return false;
    }
    return true;
  }

  // Attempt to sign up.
  void _signUp(String email, String password) {
    if (_validateEmailPassword(email, password)) {
      _showLoadingScreen(true);
      Auth.signUp(email, password).then((error) {
        if (error != null) {
          _showLoadingScreen(false);
          showSnackBar(context, error);
        } else
          _signIn(email, password);
      });
    }
  }

  // Attempt to sign in.
  void _signIn(String email, String password) {
    if (_validateEmailPassword(email, password)) {
      _showLoadingScreen(true);
      Auth.signIn(email, password).then((error) {
        if (error != null) {
          _showLoadingScreen(false);
          showSnackBar(context, error);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final emailFocusNode = FocusNode();
    final passwordFocusNode = FocusNode();
    return Padding(
      padding: const EdgeInsets.all(20),
      child: (_showLoading)
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: <Widget>[
                const Padding(padding: EdgeInsets.only(top: 20)),
                TextField(
                  controller: TextEditingController(text: _email),
                  focusNode: emailFocusNode,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  cursorWidth: 1,
                  cursorColor: Theme.of(context).textTheme.bodyText2.color,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  onChanged: (email) => _email = email,
                  onEditingComplete: () =>
                      FocusScope.of(context).requestFocus(passwordFocusNode),
                ),
                const Padding(padding: EdgeInsets.only(top: 10)),
                TextField(
                  focusNode: passwordFocusNode,
                  obscureText: true,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  cursorWidth: 1,
                  cursorColor: Theme.of(context).textTheme.bodyText2.color,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.done,
                  onChanged: (password) => _password = password,
                  onEditingComplete: () => _signIn(_email, _password),
                ),
                const Padding(padding: EdgeInsets.only(top: 10)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    FlatButton(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      color: Theme.of(context).canvasColor,
                      textColor: Theme.of(context).accentColor,
                      child: const Text('Create account'),
                      onPressed: () => _signUp(_email, _password),
                    ),
                    FlatButton(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      color: Theme.of(context).accentColor,
                      textColor: Colors.white,
                      child: const Text('Sign in'),
                      onPressed: () => _signIn(_email, _password),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
