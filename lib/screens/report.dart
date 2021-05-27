import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

import 'package:hugo/auth.dart';
import 'package:hugo/main.dart';
import 'package:hugo/screens/history.dart';
import 'package:hugo/screens/login.dart';
import 'package:hugo/screens/search.dart';
import 'package:hugo/screens/view.dart';

import '../atlas.dart' as atlas;

class Report extends StatefulWidget {
  final String dText;
  final DateTime start, end;
  final bool canDelete;

  Report(this.dText, this.start, this.end, this.canDelete);

  @override
  ReportState createState() =>
      ReportState(this.dText, this.start, this.end, this.canDelete);
}

class ReportState extends State<Report> {
  String dText;
  DateTime start, end;
  var _history = [];
  Map<String, dynamic> _data = {};
  double _total = 0.0;
  bool canDelete;

  Future<int> _get() async {
    _total = 0.0;
    _history = await atlas.getPurchases(
        Provider.of<UserInfo>(context, listen: false).getUser(), start, end);

    for (Map<String, dynamic> purchase in _history) {
      Map<String, dynamic> pData = await atlas.getProductCached(context, purchase['item']);
      _data[purchase['item']] = pData;
      purchase['weight'] = pData['INDEX'] * purchase['qty'];
      _total += purchase['weight'];
    }
    return 0;
  }

  ReportState(this.dText, this.start, this.end, this.canDelete);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
        future: _get(),
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
                appBar: AppBar(title: Text(tr('report'))),
                bottomNavigationBar: BottomNavigationBar(
                    selectedFontSize: 14.0,
                    selectedItemColor: Colors.black45,
                    items: <BottomNavigationBarItem>[
                      BottomNavigationBarItem(
                          icon: Icon(Icons.home), label: tr('home')),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.search),
                        label: tr('search'),
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
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => Search()),
                            (Route route) => false);
                      } else if (button == 2) {
                        if (Provider.of<UserInfo>(context, listen: false)
                                .getUser() !=
                            '') {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => History()));
                        } else {
                          Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => Login()));
                        }
                      }
                    }),
                body: ListView(children: <Widget>[
                  SizedBox(height: 10),
                  Text(
                    '${tr("impactFor")} $dText: $_total',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 14),
                  ListView.builder(
                      shrinkWrap: true,
                      primary: false,
                      itemCount: _history.length,
                      itemBuilder: (BuildContext ctxt, int index) {
                        String item = _history[index]['item'];
                        Map<String, dynamic> pData = _data[item];
                        return new ListTile(
                            title: Text(
                              item,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                                '''${pData["INDEX"]} x ${_history[index]["qty"]} = ${_history[index]["weight"]}
${_history[index]["date"].toUtc().toString().split(".")[0]}'''),
                            trailing: canDelete
                                ? IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () async {
                                      atlas.deletePurchase(
                                          Provider.of<UserInfo>(context,
                                                  listen: false)
                                              .getUser(),
                                          _history[index], pData['INDEX']);
                                      setState(() {
                                        _total = 0.0;
                                      });
                                    })
                                : null,
                            tileColor: atlas.getColorRG(
                                pData['INDEX'].toDouble(), 200, 0.5),
                            leading: Container(
                              child: Image.memory(
                                  pData['IMAGE'],
                                  fit: BoxFit.fill),
                            ),
                            onTap: () async {
                              Map<String, dynamic> itemData =
                                  await atlas.getProductCached(
                                      context, item);
                              if (!canDelete) {
                                Navigator.push(
                                    context,
                                    new MaterialPageRoute(
                                        builder: (context) =>
                                            new View(itemData)));
                              } else {
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                                Navigator.push(
                                    context,
                                    new MaterialPageRoute(
                                        builder: (context) =>
                                            new View(itemData)));
                              }
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
