import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';

class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(tr('aboutt'))),
        body: ListView(children: <Widget>[
          Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(width: 20, height: 20),
                Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 20),
                      Text(tr('about0'),
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20.0)),
                      SizedBox(height: 8),
                      Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: Text(
                            tr('about1'),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 20,
                          )),
                      SizedBox(height: 15),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: Text(tr('about2'),
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 4,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20.0)),
                      ),
                      SizedBox(height: 8),
                      Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: Text(
                            tr('about3'),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 20,
                          )),
                      SizedBox(height: 20),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.memory, size: 44),
                            SizedBox(width: 10),
                            Text('35%',
                                style: TextStyle(
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.bold)),
                            SizedBox(width: 10),
                            Container(
                                width: MediaQuery.of(context).size.width * 0.6,
                                child: Text(
                                  tr('about4'),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 6,
                                )),
                          ]),
                      SizedBox(height: 10),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.fastfood, size: 44),
                            SizedBox(width: 10),
                            Text('30%',
                                style: TextStyle(
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.bold)),
                            SizedBox(width: 10),
                            Container(
                                width: MediaQuery.of(context).size.width * 0.6,
                                child: Text(
                                  tr('about5'),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 6,
                                )),
                          ]),
                      SizedBox(height: 10),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.local_shipping, size: 44),
                            SizedBox(width: 10),
                            Text('20%',
                                style: TextStyle(
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.bold)),
                            SizedBox(width: 10),
                            Container(
                                width: MediaQuery.of(context).size.width * 0.6,
                                child: Text(
                                  tr('about6'),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 6,
                                )),
                          ]),
                      SizedBox(height: 10),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Icon(CupertinoIcons.doc_text_fill, size: 44),
                            SizedBox(width: 10),
                            Text('10%',
                                style: TextStyle(
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.bold)),
                            SizedBox(width: 10),
                            Container(
                                width: MediaQuery.of(context).size.width * 0.6,
                                child: Text(
                                  tr('about7'),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 6,
                                )),
                          ]),
                      SizedBox(height: 10),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.local_police, size: 44),
                            SizedBox(width: 10),
                            Text('  5%',
                                style: TextStyle(
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.bold)),
                            SizedBox(width: 10),
                            Container(
                                width: MediaQuery.of(context).size.width * 0.6,
                                child: Text(
                                  tr('about8'),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 6,
                                )),
                          ]),
                      SizedBox(height: 28),
                      Text('0-50: ${tr("r0")}',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24.0,
                              color: Colors.green)),
                      SizedBox(height: 8),
                      Text('50-100: ${tr("r1")}',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24.0,
                              color: Color.fromRGBO(105, 155, 0, 1))),
                      SizedBox(height: 8),
                      Text('100-150: ${tr("r2")}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24.0,
                              color: Color.fromRGBO(155, 50, 0, 1))),
                      SizedBox(height: 8),
                      Text('150-200: ${tr("r3")}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24.0,
                              color: Colors.red)),
                      SizedBox(height: 8),
                    ])
              ])
        ]));
  }
}
