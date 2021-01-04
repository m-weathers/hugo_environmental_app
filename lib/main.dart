import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';

import 'package:hugo/auth.dart';
import 'package:hugo/screens/about.dart';
import 'package:hugo/screens/history.dart';
import 'package:hugo/screens/login.dart';
import 'package:hugo/screens/search.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  var storage = new LocalStorage('hugoapp.json');

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserInfo()),
          ChangeNotifierProvider(create: (_) => ItemInfo())
        ],
        child: EasyLocalization(
            supportedLocales: [Locale('en', ''), Locale('es', '')],
            path: 'assets/translation',
            fallbackLocale: Locale('en', ''),
            saveLocale: true,
            child: FutureBuilder(
                future: Firebase.initializeApp(),
                builder: (context, snapshot) {
                  return FutureBuilder(
                      future: storage.ready,
                      builder: (context, snapshot) {
                        var _storage = new LocalStorage('hugoapp.json');
                        String u = _storage.getItem('loggedin');
                        if (u != null && Provider.of<UserInfo>(context, listen: false).getUser() == '') {
                          Provider.of<UserInfo>(context, listen: false).setUser(u);
                        }
                        return MaterialApp(
                          title: 'HUGO',
                          debugShowCheckedModeBanner: false,
                          theme: ThemeData(
                            primarySwatch: Colors.blue,
                            visualDensity:
                                VisualDensity.adaptivePlatformDensity,
                          ),
                          home: MyHomePage(),
                          localizationsDelegates: context.localizationDelegates,
                          supportedLocales: context.supportedLocales,
                          locale: context.locale,
                        );
                      });
                })));
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage();

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  _MyHomePageState();

  String _language;
  List<String> _languages = ['en', 'es'];
  Map<String, String> _ccIcons = {'en': 'us', 'es': 'mx'};
  Map<String, String> _langMap = {'en': 'English', 'es': 'Español'};

  @override
  Widget build(BuildContext context) {
    _language = context.locale.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text('HUGO'),
      ),
      bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: tr('home')),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: tr('search'),
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.person), label: tr('profile'))
          ],
          onTap: (int button) {
            if (button == 1) {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => Search()));
            } else if (button == 2) {
              if (Provider.of<UserInfo>(context, listen: false).getUser() !=
                  '') {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => History()));
              } else {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => Login()));
              }
            }
          }),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
                child: ListView(children: <Widget>[
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(width: 20),
                  DropdownButton<String>(
                    value: _language,
                    icon: Icon(CupertinoIcons.arrow_down),
                    iconSize: 24,
                    onChanged: (String newvalue) {
                      setState(() {
                        _language = newvalue;
                        context.locale = Locale(_language, '');
                      });
                    },
                    items: _languages
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Image.asset(
                                  'assets/flags/png/${_ccIcons[value]}.png',
                                  height: 16,
                                  width: 24,
                                  fit: BoxFit.fill),
                              SizedBox(width: 6),
                              Text(_langMap[value])
                            ]),
                      );
                    }).toList(),
                  ),
                ],
              ),
              SizedBox(height: 50),
              Container(
                  width: 140.0,
                  height: 140.0,
                  decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      image: new DecorationImage(
                          fit: BoxFit.contain,
                          image: new AssetImage(
                              'assets/hicon.png')
                      )
                  )),
              // Image.asset(
              //   'assets/hicon.png',
              //   height: 150,
              //   width: 150,
              // ),
              SizedBox(height: 26),
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      tr('appDesc'),
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ]),
              SizedBox(height: 60),
              RaisedButton(
                  child: Text(tr('howAre'), textAlign: TextAlign.center),
                  onPressed: () {
                    Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (context) => new About()));
                  }),
                  SizedBox(height: 20)
            ])),
          ],
        ),
      ),
    );
  }
}

class UserInfo with ChangeNotifier {
  String _user = '';

  void setUser(newValue) {
    _user = newValue;
    notifyListeners();
  }

  String getUser() {
    return _user;
  }
}

class ItemInfo with ChangeNotifier {
  Map<String, dynamic> _items = {};

  void updateItem(String itemName, Map<String, dynamic> itemData) {
    _items[itemName] = itemData;
  }

  Map<String, dynamic> getItem(String itemName) {
    return _items[itemName];
  }

  Map<String, dynamic> getAll() {
    return _items;
  }

  bool hasItem(String itemName) {
    return _items.containsKey(itemName);
  }
}
