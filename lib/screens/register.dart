import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:provider/provider.dart';

import 'package:hugo/auth.dart';
import 'package:hugo/main.dart';

class Register extends StatefulWidget {
  @override
  RegisterState createState() => RegisterState();
}

class RegisterState extends State<Register> {
  Auth _auth = new Auth();

  String currentSelectedValue = '';
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final _cEmail = TextEditingController(), _cPassword = TextEditingController();

  void _submitForm() {
    final FormState? form = _formKey.currentState;
    if (form!.validate()) {
      form.save();
      _auth.userRegister(_cEmail.text, _cPassword.text).then((bool success) {
        if (success) {
          Provider.of<UserInfo>(context, listen: false).setUser(_cEmail.text);
          _auth.storage.setItem('loggedin', _cEmail.text);
          Flushbar(
                  message:
                      tr('regSuccess'),
                  duration: Duration(seconds: 3))
              .show(context);
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => MyHomePage()),
              (Route route) => false);
        } else {
          Flushbar(
                  message: tr('regFailed'),
                  duration: Duration(seconds: 3))
              .show(context);
        }
      }).catchError((e) {
        Flushbar(
                message: tr('regFailed'),
                duration: Duration(seconds: 3))
            .show(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(tr('registerL')),
        ),
        body: Center(
            child: new Form(
                key: _formKey,
                child: new ListView(
                    shrinkWrap: true,
                    padding: EdgeInsets.all(15.0),
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          TextFormField(
                            controller: _cEmail,
                            decoration: InputDecoration(
                              icon: Icon(Icons.email),
                              hintText: tr('email'),
                              labelText: tr('email'),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return tr('noBlank');
                              }
                              if (value.indexOf('@') + 1 < value.indexOf('.') &&
                                  value.indexOf('@') != -1 &&
                                  value[value.length - 1] != '.' &&
                                  value[0] != '@') {
                                return null;
                              }
                              return tr('validEmail');
                            },
                          ),
                          TextFormField(
                            controller: _cPassword,
                            obscureText: true,
                            decoration: InputDecoration(
                              icon: Icon(Icons.lock),
                              hintText: tr('password'),
                              labelText: tr('password'),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return tr('noBlank');
                              }
                              if (value.length < 6) {
                                return tr('pwLength');
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            obscureText: true,
                            decoration: InputDecoration(
                              icon: Icon(Icons.lock),
                              hintText: tr('passwordConfirm'),
                              labelText: tr('passwordConfirm'),
                            ),
                            validator: (value) {
                              if (value != _cPassword.text) {
                                return tr('mustMatch');
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 7.5),
                          ElevatedButton(
                              child: Text(tr('register')), onPressed: _submitForm),
                        ],
                      ),
                    ]))));
  }
}
