import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flushbar/flushbar.dart';
import 'package:provider/provider.dart';

import 'package:hugo/main.dart';
import 'package:hugo/screens/history.dart';
import 'package:hugo/screens/login.dart';
import 'package:hugo/screens/report.dart';
import 'package:hugo/screens/search.dart';

import '../atlas.dart' as atlas;

class View extends StatefulWidget {
  final Map<String, dynamic> _data;

  View(this._data);

  @override
  ViewState createState() => ViewState(this._data);
}

class ViewState extends State<View> {
  double _amount = 1;
  Map<String, dynamic> _data;
  TextEditingController myController = TextEditingController()..text = '1';

  List<Widget> _c1Text,
      _c1Stars,
      _c2Text,
      _c2Stars,
      _c3Text,
      _c3Stars,
      _c4Text,
      _c4Stars,
      _c5Text,
      _c5Stars;

  ViewState(this._data);

  @override
  Widget build(BuildContext context) {
    String rank = _data['rank'];
    if (rank == 'ECO-FRIENDLY') {
      _data['rank_local'] = tr('r0');
    } else if (rank == 'BEARABLE') {
      _data['rank_local'] = tr('r1');
    } else if (rank == 'ADVERSE') {
      _data['rank_local'] = tr('r2');
    } else {
      _data['rank_local'] = tr('r3');
    }

    // Generate the Text() elements for each of the variables and the 5-star displays for their
    // ranking for a variable. (Icon is currently boxes not stars.)
    _c1Text = [];
    _c1Stars = [];
    for (int i = 0; i < atlas.variables[0].length; i++) {
      _c1Text.add(new Text(atlas.variables[0][i]));
      _c1Stars.add(new StarDisplay(value: (_data['CAT1'][i] / 2.5).floor()));
    }

    _c2Text = [];
    _c2Stars = [];
    for (int i = 0; i < atlas.variables[1].length; i++) {
      _c2Text.add(new Text(atlas.variables[1][i]));
      _c2Stars.add(new StarDisplay(value: (_data['CAT2'][i] / 2.5).floor()));
    }

    _c3Text = [];
    _c3Stars = [];
    for (int i = 0; i < atlas.variables[2].length; i++) {
      _c3Text.add(new Text(atlas.variables[2][i]));
      _c3Stars.add(new StarDisplay(value: (_data['CAT3'][i] / 2.5).floor()));
    }

    _c4Text = [];
    _c4Stars = [];
    for (int i = 0; i < atlas.variables[3].length; i++) {
      _c4Text.add(new Text(atlas.variables[3][i]));
      _c4Stars.add(new StarDisplay(value: (_data['CAT4'][i] / 2.5).floor()));
    }

    _c5Text = [];
    _c5Stars = [];
    for (int i = 0; i < atlas.variables[4].length; i++) {
      _c5Text.add(new Text(atlas.variables[4][i]));
      _c5Stars.add(new StarDisplay(value: (_data['CAT5'][i] / 2.5).floor()));
    }

    return Scaffold(
      appBar: AppBar(title: Text(tr('productscore'))),
      bottomNavigationBar: BottomNavigationBar(
          selectedFontSize: 14.0,
          selectedItemColor: Colors.black45,
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
            if (button == 0) {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => MyHomePage()),
                  (Route route) => false);
            } else if (button == 1) {
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
      body: ListView(
        shrinkWrap: true,
        padding:
            EdgeInsets.only(left: 10.0, right: 10.0, top: 0.0, bottom: 0.0),
        children: <Widget>[
          SizedBox(height: 18),
          Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(width: 16),
                Text('${_data["_id"]}', style: TextStyle(fontSize: 18.0)),
              ]),
          SizedBox(height: 8),
          Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(width: 16),
                Text(
                    '${tr("in0")}: ${tr(_data["CATEGORY"][0].toUpperCase() + _data["CATEGORY"].substring(1))}'),
              ]),
          SizedBox(height: 14),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Hero(
                    child: Image.memory(_data['IMAGE'].byteList,
                        fit: BoxFit.fitHeight, height: 120, width: 120),
                    tag: _data['_id']),
                SizedBox(width: 30),
                Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text('${_data["INDEX"]}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 50.0,
                              fontWeight: FontWeight.bold,
                              color: _data['colors'][0])),
                      SizedBox(height: 5),
                      Text('${_data["rank_local"]}',
                          style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: _data['colors'][0]))
                    ]),
              ]),
          SizedBox(height: 16),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: 40,
                  width: 90,
                  child: TextField(
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: tr('amount0'),
                      ),
                      controller: myController,
                      onChanged: (String text) {
                        if (isNumeric(text) && double.parse(text) > 0) {
                          _amount = double.parse(text);
                        } else {
                          _amount = 0;
                        }
                      }),
                ),
                SizedBox(width: 20),
                FlatButton(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Icon(CupertinoIcons.money_dollar),
                          Text(tr('addto')),
                        ]),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      if (Provider.of<UserInfo>(context, listen: false)
                              .getUser() ==
                          '') {
                        Flushbar(
                                message: tr('purchaseHistory'),
                                duration: Duration(seconds: 3))
                            .show(context);
                        return;
                      }
                      if (_amount > 0) {
                        atlas.addPurchase(
                            Provider.of<UserInfo>(context, listen: false)
                                .getUser(),
                            _data['_id'],
                            _amount,
                            _data['INDEX']);
                        Flushbar(
                                message: '$_amount ' +
                                    tr('of0') +
                                    ' ${_data["_id"]} ' +
                                    tr('haveBeen'),
                                duration: Duration(seconds: 3))
                            .show(context);
                      } else {
                        Flushbar(
                                message: tr('amountZero'),
                                duration: Duration(seconds: 3))
                            .show(context);
                      }
                    })
              ]),
          SizedBox(height: 8),
          FlatButton(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Icon(CupertinoIcons.cart_fill),
                    SizedBox(width: 8),
                    Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: Text(tr('viewimpact'),
                            overflow: TextOverflow.ellipsis, maxLines: 2))
                  ]),
              onPressed: () async {
                if (Provider.of<UserInfo>(context, listen: false).getUser() ==
                    '') {
                  Flushbar(
                          message: tr('purchaseHistory'),
                          duration: Duration(seconds: 3))
                      .show(context);
                  return;
                }
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (context) => new Report(
                            tr('trip'),
                            DateTime.now().subtract(Duration(hours: 3)),
                            DateTime.now(),
                            true)));
              }),
          SizedBox(height: 30),
          Dropdown(Icons.memory, _data['sizes'][1], _data['colors'][1],
              tr('cat1'), _c1Text, _c1Stars),
          SizedBox(height: 10),
          Dropdown(Icons.fastfood, _data['sizes'][2], _data['colors'][2],
              tr('cat2'), _c2Text, _c2Stars),
          SizedBox(height: 10),
          Dropdown(Icons.local_shipping, _data['sizes'][3], _data['colors'][3],
              tr('cat3'), _c3Text, _c3Stars),
          SizedBox(height: 10),
          Dropdown(CupertinoIcons.doc_text_fill, _data['sizes'][4],
              _data['colors'][4], tr('cat4'), _c4Text, _c4Stars),
          SizedBox(height: 10),
          Dropdown(Icons.local_police, _data['sizes'][5], _data['colors'][5],
              tr('cat5'), _c5Text, _c5Stars),
          SizedBox(height: 40),
        ],
      ),
    );
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.parse(s, (e) => null) != null;
  }
}

// https://medium.com/icnh/a-star-rating-widget-for-flutter-41560f82c8cb
class StarDisplay extends StatelessWidget {
  final int value;
  const StarDisplay({Key key, this.value = 0})
      : assert(value != null),
        super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
            index < value
                ? CupertinoIcons.cube_box_fill
                : CupertinoIcons.cube_box,
            size: 16);
      }),
    );
  }
}

class Dropdown extends StatelessWidget {
  final IconData _barIcon;
  final int _barWidth;
  final Color _barColor;
  final String _barDescr;

  final List<Widget> _vars;
  final List<Widget> _vals;

  Dropdown(this._barIcon, this._barWidth, this._barColor, this._barDescr,
      this._vars, this._vals);

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
        title: Column(children: <Widget>[
          Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(width: 20),
                Icon(_barIcon, size: 30),
                SizedBox(width: 15),
                Container(
                  height: 18,
                  width: _barWidth.toDouble(),
                  decoration: BoxDecoration(
                      color: _barColor,
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                )
              ]),
          Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(width: 15),
                Container(
                    width: MediaQuery.of(context).size.width * 0.70,
                    child: Text(_barDescr,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                        style: TextStyle(
                            fontSize: 14.0, fontWeight: FontWeight.bold))),
              ])
        ]),
        children: <Widget>[
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 6,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: _vars),
                ),
                SizedBox(width: 5),
                Expanded(
                    flex: 3,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _vals))
              ])
        ]);
  }
}
