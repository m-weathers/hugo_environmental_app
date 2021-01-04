import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

import 'package:hugo/auth.dart';
import 'package:hugo/main.dart';
import 'package:hugo/screens/history.dart';
import 'package:hugo/screens/login.dart';
import 'package:hugo/screens/search.dart';
import 'package:hugo/screens/view.dart';

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
  Auth _auth = new Auth();
  var _history = [];
  double _total = 0.0;
  bool canDelete;

  Future<int> _get() async {
    _total = 0.0;
    _history = await _auth.getPurchases2(
        Provider.of<UserInfo>(context, listen: false).getUser(), start, end);
    print(_total);
    for (var purchase in _history) {
      purchase['image'] =
          await _auth.fileUrl('products/' + purchase['item'] + '.jpg');
      purchase['weight'] = purchase['index'] * purchase['amount'];
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
                        return new ListTile(
                            title: Text(
                              _history[index]['item'],
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                                '''${_history[index]["index"]} x ${_history[index]["amount"]} = ${_history[index]["weight"]}
${_history[index]["date"].toDate().toUtc().toString().split(".")[0]}'''),
                            trailing: canDelete
                                ? IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () async {
                                      await _auth.deletePurchase2(
                                          Provider.of<UserInfo>(context,
                                                  listen: false)
                                              .getUser(),
                                          _history[index]);
                                      setState(() {
                                        _total = 0.0;
                                      });
                                    })
                                : null,
                            tileColor: _auth.getColorRG(
                                _history[index]['index'], 200, 0.5),
                            leading: Container(
                              child: CachedNetworkImage(
                                  imageUrl: _history[index]['image'],
                                  fit: BoxFit.fill,
                                  progressIndicatorBuilder: (context, url,
                                          downloadProgress) =>
                                      CircularProgressIndicator(
                                          value: downloadProgress.progress)),
                            ),
                            onTap: () async {
                              Map<String, dynamic> itemData =
                                  await _auth.getProductCached(
                                      context, _history[index]['item']);
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
