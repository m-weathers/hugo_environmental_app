/*
 * HUGO App v2021.05.12
 *
 * What each file does:
 * atlas.dart: General functions and global variables used by multiple pages,
 *    as well as functions that interact w/ MongoDB Atlas. Only needs to be
 *    imported to be used.
 * auth.dart: Does user registration & login. Used to contain many of the
 *    functions that atlas.dart does now. Requires an instance of it to be
 *    instantiated.
 * main.dart: The home page. Navigates to about.dart, search.dart, history.dart,
 *    and login.dart (the Profile button will navigate to history.dart if a user
 *    is logged in already and login.dart if not).
 *
 * screens/about.dart: Displays info about the app.
 * screens/history.dart: Shows a list of months, the score for each (i.e.
 *    the total of items_purchased*hugo_index, and the percentage change from
 *    the previous month (e.g. up 50%, down 30%).
 * screens/login.dart: Login page. Option to register if user doesn't have
 *    account. Authentication is done through Firebase.
 * screens/register.dart: Register a new account.
 * screens/report.dart: Displays a list of items purchased by a user for a
 *    given timeframe. The timeframe is determined by the two DateTimes passed
 *    to it.
 * screens/search.dart: Searches items based on a query and a category. Number
 *    of results is limited to 25. Searching with a category and no query will
 *    return 25 items from that category.
 * screens/view.dart: View an item's info, has the option to add the item to
 *    a user's purchase history.
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:localstorage/localstorage.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:provider/provider.dart';

import 'package:hugo/screens/about.dart';
import 'package:hugo/screens/history.dart';
import 'package:hugo/screens/login.dart';
import 'package:hugo/screens/search.dart';

import 'atlas.dart' as atlas;

// LocalStorage is used to track whether the user is logged-in between sessions.
LocalStorage storage = new LocalStorage('hugoapp.json');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Wait to ensure Atlas, Firebase, LocalStorage, and EasyLocalization are ready.
  mongo.Db db = await mongo.Db.create('mongodb+srv://');
  await EasyLocalization.ensureInitialized();
  await storage.ready;
  await Firebase.initializeApp();
  await db.open(secure: true);
  // Other pages access Atlas through atlas.dart, so set atlas.db to the DB
  // just created.
  atlas.db = db;

  runApp(
    EasyLocalization(
        supportedLocales: [Locale('en', ''), Locale('es', '')],
        path: 'assets/translation',
        fallbackLocale: Locale('en', ''),
        child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // The two providers used are UserInfo and ItemInfo. UserInfo allows any page
      // to check the currently logged-in user and ItemInfo acts as a sort of cache
      // to avoid repeatedly retrieving item information when necessary. ItemInfo
      // is NOT currently used with user searches in search.dart, only with history.dart
      // and report.dart.
        providers: [
          ChangeNotifierProvider(create: (_) => UserInfo()),
          ChangeNotifierProvider(create: (_) => ItemInfo())
        ],
        child: MaterialApp(
          title: 'HUGO',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          home: MyHomePage(),
        )
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage();

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  _MyHomePageState();

  String _language = '';
  List<String> _languages = ['en', 'es'];
  Map<String, String> _ccIcons = {'en': 'us', 'es': 'mx'};
  Map<String, String> _langMap = {'en': 'English', 'es': 'Español'};

  String u = storage.getItem('loggedin');

  @override
  Widget build(BuildContext context) {
    _language = context.locale.languageCode;
    // If LocalStorage returns a current user, set the UserInfo provider to say as much.
    if (Provider.of<UserInfo>(context, listen: false).getUser() == '') {
      Provider.of<UserInfo>(context, listen: false).setUser(u);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('HUGO'),
      ),
      // Navigation options are main.dart, search.dart, and history.dart (or
      // login.dart if no user currently logged in).
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
              // Menu to let the user switch between languages.
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(width: 20),
                  DropdownButton<String>(
                    value: _language,
                    icon: Icon(CupertinoIcons.arrow_down),
                    iconSize: 24,
                    onChanged: (String? newvalue) {
                      setState(() {
                        _language = newvalue!;
                        context.setLocale(Locale(_language, ''));
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
                              Text(_langMap[value] ?? '')
                            ]),
                      );
                    }).toList(),
                  ),
                ],
              ),
              SizedBox(height: 50),
              // Show the app logo.
              Container(
                  width: 140.0,
                  height: 140.0,
                  decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      image: new DecorationImage(
                          fit: BoxFit.contain,
                          image: new AssetImage('assets/hicon.png')))),
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
              // Button to show about.dart, which explains the app.
              ElevatedButton(
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

// Stores the currently logged in user.
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

// Stores a list of item info.
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
