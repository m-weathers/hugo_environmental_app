import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flushbar/flushbar.dart';
import 'package:provider/provider.dart';

import 'package:hugo/auth.dart';
import 'package:hugo/main.dart';
import 'package:hugo/screens/register.dart';

class Login extends StatefulWidget {
  Login();

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  String _email, _password;

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  Auth _auth = new Auth();

  void _submitForm() {
    final FormState form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      _auth.userLogin(_email, _password).then((bool success) {
        if (success) {
          Provider.of<UserInfo>(context, listen: false).setUser(_email);
          _auth.storage.setItem('loggedin', _email);
          Navigator.pushAndRemoveUntil(
              context,
              new MaterialPageRoute(builder: (context) => new MyHomePage()),
              (Route route) => false);
        } else {
          Flushbar(
                  message: tr('credError'),
                  duration: Duration(seconds: 3))
              .show(context);
        }
      }).catchError((e) {
        Flushbar(
                message: tr('credError'),
                duration: Duration(seconds: 3))
            .show(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(tr('loginL')),
        ),
        body: Center(
            child: new Form(
                key: _formKey,
                child: ListView(
                    shrinkWrap: true,
                    padding: EdgeInsets.all(15.0),
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(height: 15),
                          TextFormField(
                            decoration: InputDecoration(
                              icon: Icon(Icons.email),
                              hintText: tr('email'),
                              labelText: tr('email'),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value.isEmpty) {
                                return tr('noBlank');
                              }
                              if (value.indexOf('@') + 1 < value.indexOf('.') &&
                                  value.indexOf('@') != -1 &&
                                  value[value.length - 1] != '.' &&
                                  value[0] != '@') {
                                _email = value;
                                return null;
                              }
                              return tr('validEmail');
                            },
                          ),
                          TextFormField(
                            obscureText: true,
                            decoration: InputDecoration(
                              icon: Icon(Icons.lock),
                              hintText: tr('password'),
                              labelText: tr('password'),
                            ),
                            validator: (value) {
                              if (value.isEmpty) {
                                return tr('noBlank');
                              }
                              _password = value;
                              return null;
                            },
                          ),
                          SizedBox(height: 7.5),
                          RaisedButton(
                              onPressed: _submitForm,
                              child: Text(tr('login'))),
                          SizedBox(height: 15),
                          FlatButton(
                            child: Text(tr('register')),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  new MaterialPageRoute(
                                      builder: (context) => new Register()));
                            },
                          )
                        ],
                      )
                    ]))));
  }
}
