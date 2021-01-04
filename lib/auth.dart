import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';

import 'package:algolia/algolia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';

import 'package:hugo/main.dart';

// Interfaces with Cloud Firestore and Firebase Storage.
class Auth {
  final FirebaseAuth auth = FirebaseAuth.instance;
  Algolia algolia = Algolia.init(
      applicationId: '', apiKey: '');
  var storage = new LocalStorage('hugoapp.json');

  List<String> categories = [
    'All',
    'Pasta',
    'Meats',
    'Seafood',
    'Fruit',
    'Vegetables'
  ];

  String getIndexRank(int index) {
    if (index <= 50) {
      return 'ECO-FRIENDLY';
    } else if (index <= 100) {
      return 'BEARABLE';
    } else if (index <= 150) {
      return 'ADVERSE';
    } else {
      return 'HIGHLY ADVERSE';
    }
  }

  Color getColorRG(int index, int max, double opacity) {
    return Color.fromRGBO((index / max * 255).floor(),
        (1 - (index / max) * 255).floor(), 0, opacity);
  }

  int getBarSize(int index, int max, int scale) {
    return (index / max * scale).floor();
  }

  List<int> scales = [200, 6650, 1800, 1200, 500, 200];
  List<List<String>> variables = [
    [
      'SECTOR',
      'PRODUCT CLASS',
      'ECOLOGY',
      'HEALTH',
      'SPECIFICATIONS',
      'TRANSP. DIST',
      'TRANSP. TYPE',
      'FACTORY SIZE',
      'FACTORY LOC.',
      'INDUSTRIALIZATION',
      'AUTOMATION',
      'WATER USE',
      'ELECTRICITY USE',
      'ELECTRICITY SOURCE',
      'PLASTIC WASTE',
      'PAPER WASTE',
      'CHEMICAL USE',
      'WASTE OUTPUT',
      'WASTE MGMT.'
    ],
    [
      'ARTIFICIAL INGRD.',
      'SUGAR/SWEETENERS',
      'DYES',
      'FAT',
      'PRESERVATIVES',
      'CHEMICALS/SODIUM'
    ],
    [
      'SUPPLIER LOCAL',
      'SUPPLIER DIST.',
      'DISTRIBUTION CENTERS',
      'DIST. OF CENTERS',
      'LOCALITY OF SALES',
      'VOLUME OF SALES'
    ],
    [
      'COMPANY TYPE',
      'SOCIAL COMMITMENT',
      'HEALTH COMMITMENT',
      'EDUCATION COMMITMENT',
      'ENVIRONMENTAL COMMITMENT'
    ],
    [
      'INTEGRITY',
      'COMPLIANCE',
      'ECOLOGY AWARENESS',
      'ENVIRONMENTAL PARTICIPATION'
    ]
  ];

  Future<Map<String, dynamic>> getProductCached(
      BuildContext context, String name) async {
    if (Provider.of<ItemInfo>(context, listen: false).hasItem(name)) {
      print('cached $name!');
      return Provider.of<ItemInfo>(context, listen: false).getItem(name);
    } else {
      print('lookup $name!');
      Map<String, dynamic> itemData = await getProductInfo(name);
      Provider.of<ItemInfo>(context, listen: false).updateItem(name, itemData);
      return itemData;
    }
  }

  Future<Map<String, dynamic>> getProductInfo(String name) async {
    DocumentSnapshot doc =
        await FirebaseFirestore.instance.collection('products').doc(name).get();
    Map<String, dynamic> data = Map<String, dynamic>.from(doc.data());

    data['id'] = doc.id;
    data['rank'] = getIndexRank(data['i']);
    data['image'] = await fileUrl('products/' + doc.id + '.jpg');

    data['colors'] = [
      getColorRG(data['i'], scales[0], 1),
      getColorRG(data['cat1'][0], scales[1], 1),
      getColorRG(data['cat2'][0], scales[2], 1),
      getColorRG(data['cat3'][0], scales[3], 1),
      getColorRG(data['cat4'][0], scales[4], 1),
      getColorRG(data['cat5'][0], scales[5], 1)
    ];
    data['sizes'] = [
      getBarSize(data['i'], scales[0], 200),
      getBarSize(data['cat1'][0], scales[1], 200),
      getBarSize(data['cat2'][0], scales[2], 200),
      getBarSize(data['cat3'][0], scales[3], 200),
      getBarSize(data['cat4'][0], scales[4], 200),
      getBarSize(data['cat5'][0], scales[5], 200)
    ];

    return data;
  }

  // Returns the product information based on barcode.
  Future<String> getBarcode(String barcode) async {
    QuerySnapshot snap = await FirebaseFirestore.instance
        .collection('products')
        .where('barcode', isEqualTo: barcode)
        .get();
    if (snap.docs.length == 0) {
      print('no results!');
      return '';
    }
    return snap.docs[0].id;
  }

  // Performs a product search based on a query and/or category. If category
  // is the only field, returns up to 15 products of that category. Query
  // may be the start of the item's name ("publix spa") or may be a word that
  // is part of the item's name ("spaghetti"). Results must be part of the
  // category if one is given.
  Future<List<Map<String, dynamic>>> getSearch(
      BuildContext context, String query, String category) async {
    List<Map<String, dynamic>> results = [];
    query = query.toLowerCase();
    category = category.toLowerCase();

    AlgoliaQuery algoliaQuery = algolia.instance
        .index('products')
        .setOffset(0)
        .setLength(20)
        .search(query);
    List<AlgoliaObjectSnapshot> aR = (await algoliaQuery.getObjects()).hits;
    await Future.forEach(aR, (AlgoliaObjectSnapshot x) async {
      if (category == 'all' || x.data['category'] == category) {
        Map<String, dynamic> y = await getProductCached(context, x.objectID);
        results.add(y);
      }
    });

    return results;
  }

  // Gets the URL for a resource in Firebase Storage. "file" must be the
  // complete reference, e.g. products/Publix Spaghetti.jpg. Used with
  // Image.network().
  Future<String> fileUrl(String file) async {
    return await FirebaseStorage.instance.ref().child(file).getDownloadURL();
  }

  void addPurchase2(String user, String item, double amount, int index) {
    DateTime d = DateTime.now().toUtc();
    Map<String, dynamic> purchase = {
      'item': item,
      'amount': amount,
      'date': d,
      'index': index
    };
    FirebaseFirestore.instance
        .collection('users')
        .doc(user)
        .collection('history')
        .add(purchase);
    String ym = '${d.year}-${d.month}';
    updateMonthScore(user, ym, index*amount);
  }

  Future<List<dynamic>> getPurchases2(
      String user, DateTime start, DateTime end) async {
    QuerySnapshot snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(user)
        .collection('history')
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThanOrEqualTo: end)
        .get();
    List<dynamic> results = [];
    snap.docs.forEach((DocumentSnapshot doc) {
      results.add(doc.data());
    });
    print(results);
    return results;
  }

  Future<int> deletePurchase2(String user, var purchase) async {
    QuerySnapshot snap = await FirebaseFirestore.instance.collection('users').doc(user).collection('history').
      where('date', isEqualTo: purchase['date']).get();
    if (snap.docs.length != 0) {
      await snap.docs[0].reference.delete();
    }
    DateTime dt = purchase["date"].toDate().toUtc();
    String ym = '${dt.year}-${dt.month}';
    updateMonthScore(user, ym, -purchase['amount']*purchase['index']);
    return 0;
  }

  Future<Map<String, dynamic>> getMonthScores(String user) async {
    DocumentSnapshot snap = await FirebaseFirestore.instance.collection('users').doc(user).get();
    return snap.data()['monthScores'];
  }

  void updateMonthScore(String user, String month, double amount) async {
    DocumentReference ref = FirebaseFirestore.instance.collection('users').doc(user);
    Map<String, dynamic> uData = (await ref.get()).data();
    Map<String, dynamic> tmp = uData['monthScores'];
    if (!tmp.keys.contains(month)) {
      tmp[month] = amount;
    } else {
      tmp[month] += amount;
    }
    uData['monthScores'] = tmp;
    ref.update(uData);
  }

  Future<int> initUser(String user) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user)
        .set({'history': []}, SetOptions(merge: true));
    return 1;
  }

  Future<bool> userLogin(String eEmail, String ePassw) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: eEmail, password: ePassw);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
      return false;
    }
    return true;
  }

  Future<bool> userRegister(String nEmail, String nPassw) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: nEmail, password: nPassw);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
    return true;
  }
}
