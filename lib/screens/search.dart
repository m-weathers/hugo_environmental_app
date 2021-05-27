import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:provider/provider.dart';

import 'package:hugo/main.dart';
import 'package:hugo/screens/history.dart';
import 'package:hugo/screens/login.dart';
import 'package:hugo/screens/view.dart';

import '../atlas.dart' as atlas;

class Search extends StatefulWidget {
  Search();

  @override
  SearchState createState() => SearchState();
}

class SearchState extends State<Search> {
  List<Map<String, dynamic>> _results = [];
  String _userSearchTerm = '', _category = 'All';
  bool _isDoingSearch = false;

  SearchState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(tr('search'))),
        bottomNavigationBar: BottomNavigationBar(
            currentIndex: 1,
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
                    MaterialPageRoute(builder: (context) => MyHomePage()),
                    (Route route) => false);
              } else if (button == 2) {
                if (Provider.of<UserInfo>(context, listen: false).getUser() !=
                    '') {
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => History()));
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
                SizedBox(height: 8),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(width: 15),
                      Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(height: 8),
                            DropdownButton<String>(
                              value: _category,
                              icon: Icon(CupertinoIcons.arrow_down),
                              iconSize: 24,
                              onChanged: (String? newvalue) {
                                setState(() {
                                  _category = newvalue!;
                                });
                              },
                              items: atlas.categories
                                  .map<DropdownMenuItem<String>>(
                                      (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(tr(value)),
                                );
                              }).toList(),
                            ),
                          ]),
                      SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          onChanged: (text) {
                            _userSearchTerm = text;
                          },
                        ),
                      ),
                      SizedBox(width: 15)
                    ]),
                SizedBox(height: 5),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      TextButton(
                          child: Row(children: <Widget>[
                            Icon(Icons.search),
                            SizedBox(width: 6),
                            Text(tr('search'))
                          ]),
                          onPressed: () async {
                            if (!_isDoingSearch) {
                              _isDoingSearch = true;
                              FocusScope.of(context).unfocus();
                              checkNoInput();
                            }
                          }),
                      SizedBox(width: 15),
                      TextButton(
                        child: Row(children: <Widget>[
                          Icon(CupertinoIcons.barcode),
                          SizedBox(width: 6),
                          Text(tr('scanbarcode')),
                        ]),
                        onPressed: () async {
                          String barcodeScanRes =
                              await FlutterBarcodeScanner.scanBarcode(
                                  "#ff0000", "Cancel", false, ScanMode.BARCODE);
                          print(barcodeScanRes);
                          String _id = await atlas.getBarcode(barcodeScanRes);
                          if (_id != '') {
                            Map<String, dynamic> itemData =
                                await atlas.getProductCached(context, _id);
                            Navigator.push(
                                context,
                                new MaterialPageRoute(
                                    builder: (context) => new View(itemData)));
                          } else {
                            Flushbar(
                                    message:
                                        'No results found for your search.',
                                    duration: Duration(seconds: 3))
                                .show(context);
                          }
                        },
                      ),
                    ]),
                SizedBox(height: 10),
                 _isDoingSearch ? Container(
                     alignment: Alignment.center,
                     child: SizedBox(
                         height: 60,
                         width: 60,
                         child: CircularProgressIndicator())) : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _results.length,
                    primary: false,
                    padding: EdgeInsets.only(
                        left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
                    itemBuilder: (BuildContext ctxt, int index) {
                      return new ListTile(
                          title: Text(
                            _results[index]['_id'],
                          ),
                          subtitle: Text('${_results[index]["INDEX"]}'),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                          ),
                          tileColor: Color.fromRGBO(
                              ((_results[index]['INDEX'] / 200) * 255).floor(),
                              ((1 - _results[index]['INDEX'] / 200) * 255).floor(),
                              0,
                              0.5),
                          onTap: () {
                            Navigator.push(
                                context,
                                new MaterialPageRoute(
                                    builder: (context) =>
                                        new View(_results[index])));
                          },
                          leading: Hero(
                            child: Container(
                              child: Image.memory(
                                _results[index]['IMAGE'],
                                fit: BoxFit.fill,
                                width: 55,
                                height: 55
                              )
                            ),
                            tag: _results[index]['_id'],
                          ));
                    })
              ])),
            ])));
  }

  void checkNoInput() async {
    _results = [];
    setState(() {});
    if (_userSearchTerm == "" && _category == "All") {
      _isDoingSearch = false;
      return;
    }

    List<Map<String, dynamic>> _names =
        await atlas.getSearch(context, _userSearchTerm, _category);
    if (_names.length == 0 && (_category != "All" || _userSearchTerm != "")) {
      _isDoingSearch = false;
      setState(() {});
      Flushbar(
              message: 'No results found for your search.',
              duration: Duration(seconds: 3))
          .show(context);

    }
    // getSearch returns item data straight from Atlas so to get the complete
    // data, call finishProductInfo (does calculations to avoid storing
    // unnecessary data in Atlas).
    await Future.forEach(_names, (Map<String, dynamic> itemData) async {
      _results.add(await atlas.finishProductInfo(itemData));
      setState(() {});
    });

    _isDoingSearch = false;
  }
}
