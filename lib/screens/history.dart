import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

import 'package:hugo/auth.dart';
import 'package:hugo/main.dart';
import 'package:hugo/screens/search.dart';
import 'package:hugo/screens/report.dart';

class History extends StatefulWidget {
  History();

  @override
  HistoryState createState() => HistoryState();
}

class HistoryState extends State<History> {
  Auth _auth = new Auth();

  var _monthScores = {};
  var _months = [];
  Map<String, String> _monthsExp = {
    '1': tr('january'),
    '2': tr('february'),
    '3': tr('march'),
    '4': tr('april'),
    '5': tr('may'),
    '6': tr('june'),
    '7': tr('july'),
    '8': tr('august'),
    '9': tr('september'),
    '10': tr('october'),
    '11': tr('november'),
    '12': tr('december')
  };

  Future<int> _get() async {
    _monthScores = await _auth.getMonthScores(Provider.of<UserInfo>(context, listen: false).getUser());
    _months = _monthScores.keys.toList();
    return 0;
  }

  HistoryState();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
        future: _get(),
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
                appBar: AppBar(title: Text('Report')),
                bottomNavigationBar: BottomNavigationBar(
                    currentIndex: 2,
                    items: <BottomNavigationBarItem>[
                      BottomNavigationBarItem(
                          icon: Icon(Icons.home), label: tr('home')),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.search),
                        label: 'Search',
                      ),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.person), label: tr('profile'))
                    ],
                    onTap: (int button) {
                      if (button == 0) {
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => MyHomePage()),
                            (Route route) => false);
                      } else if (button == 1) {
                        Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => Search()));
                      }
                    }),
                body: Column(children: <Widget>[
                  SizedBox(height: 10),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        FlatButton(
                            child: Text(tr('logout')),
                            onPressed: () {
                              Provider.of<UserInfo>(context, listen: false)
                                  .setUser('');
                              _auth.storage.deleteItem('loggedin');
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  new MaterialPageRoute(
                                      builder: (context) => MyHomePage()),
                                  (Route route) => false);
                            })
                      ]),
                  Text(
                      '${tr("impactFor")} ${Provider.of<UserInfo>(context, listen: false).getUser()}',
                      style: TextStyle(fontSize: 18)),
                  SizedBox(height: 6),
                  Text(tr('tapMonth')),
                  SizedBox(height: 10),
                  ListView.builder(
                      shrinkWrap: true,
                      itemCount: _monthScores.length,
                      padding: EdgeInsets.only(
                          left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
                      itemBuilder: (BuildContext ctxt, int index) {
                        int i2 = _monthScores.length - index - 1;
                        String ym = _months[i2];
                        String ymp = i2 == 0 ? '' : _months[i2 - 1];
                        double s1 = _monthScores[ym].toDouble();
                        double s2 = i2 == 0 ? 0.0 : _monthScores[ymp].toDouble();
                        return new ListTile(
                            title: Text(
                                _monthsExp[ym.split('-')[1]]+' '+ym.split('-')[0]
                            ),
                            subtitle: Text('$s1'),
                             trailing: i2 == 0 ? null : Container(
                               width: 100,
                               child: Row(children: <Widget>[
                                 Expanded(
                                   flex: 2,
                                   child: Text(s1 > s2 ? (100*(s1-s2)/s2).toStringAsFixed(1) + '%' :
                                   (100*(s2-s1)/s2).toStringAsFixed(1) + '%',
                                   textAlign: TextAlign.end,
                                   style: TextStyle(
                                     color: s1 > s2 ? Colors.red : Colors.green
                                   ))
                                ),
                                Expanded(
                                  flex: 1,
                                  child: s1 > s2 ? Icon(Icons.arrow_upward, color: Colors.red) : Icon(Icons.arrow_downward, color: Colors.green)
                                )
                              ])
                            ),
                            onTap: () {
                              int year = int.parse(ym.split('-')[0]);
                              int month = int.parse(ym.split('-')[1]);
                              Navigator.push(
                                  context,
                                  new MaterialPageRoute(
                                      builder: (context) => new Report(
                                          _monthsExp[ym.split('-')[1]]+' '+ym.split('-')[0],
                                          DateTime.utc(year, month),
                                          DateTime.utc(year, month + 1)
                                              .subtract(Duration(seconds: 1)),
                                          false)));
                            });
                      })
                ]));
          } else {
            return Scaffold(
                appBar: AppBar(title: Text('Loading...')),
                body: Container(
                    alignment: Alignment.center,
                    child: SizedBox(
                        height: 60,
                        width: 60,
                        child: CircularProgressIndicator())));
          }
        });
  }
}
