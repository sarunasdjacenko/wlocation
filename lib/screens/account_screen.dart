import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../services/services.dart';

class AccountScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserInfo>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: SafeArea(
        child: (user != null) ? AccountPage() : LoginPage(),
      ),
    );
  }
}

class AccountPage extends StatelessWidget {
  void _signOut() => Auth.signOut();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserInfo>(context);
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
  String _signInError;

  void _signIn() {
    setState(() => _signInError = null);

    // Attempt to sign in.
    Auth.signInWithEmailAndPassword(_email, _password).then((success) {
      if (!success)
        setState(() =>
            _signInError = 'The email or password you entered is incorrect.');
    });
  }

  @override
  Widget build(BuildContext context) {
    final emailFocusNode = FocusNode();
    final passwordFocusNode = FocusNode();
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: <Widget>[
          FlutterLogo(size: 100),
          const Padding(padding: EdgeInsets.only(top: 20)),
          TextField(
            autofocus: true,
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
            onEditingComplete: _signIn,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(top: 5),
              child: Text(
                _signInError ?? '',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: RaisedButton(
              padding: EdgeInsets.symmetric(horizontal: 40),
              color: Theme.of(context).accentColor,
              textColor: Colors.white,
              child: const Text('Sign in'),
              onPressed: _signIn,
            ),
          ),
        ],
      ),
    );
  }
}
