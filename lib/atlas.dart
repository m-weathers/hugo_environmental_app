import 'package:flutter/cupertino.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:provider/provider.dart';

import 'main.dart';

Db db;
bool connected = false;

Future<int> init() async {
  if (connected) {
    return 0;
  }
  db = await Db.create(
      'mongodb+srv://');
  await db.open(secure: true);
  connected = true;
  print('Atlas connected');
  return 0;
}

List<String> categories = [
  'All',
  'Pasta',
  'Meats',
  'Seafood',
  'Fruit',
  'Vegetables',
  'Bars'
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

Color getColorRG(double index, int max, double opacity) {
  return Color.fromRGBO((index / max * 255).floor(),
      (1 - (index / max) * 255).floor(), 0, opacity);
}

int getBarSize(double index, int max, int scale) {
  return (index / max * scale).floor();
}

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
    return Provider.of<ItemInfo>(context, listen: false).getItem(name);
  } else {
    Map<String, dynamic> itemData = await getProductInfo(name);
    Provider.of<ItemInfo>(context, listen: false).updateItem(name, itemData);
    return itemData;
  }
}

double categoryScore(List<dynamic> data) {
  double sum = 0;
  for (int i = 0; i < data.length; i++) {
    sum += data[i];
  }
  return sum / data.length;
}

Map<String, dynamic> finishProductInfo(Map<String, dynamic> data) {
  data['INDEX'] = data['INDEX'].ceil();
  data['rank'] = getIndexRank(data['INDEX']);

  data['cat_totals'] = [
    categoryScore(data['CAT1']),
    categoryScore(data['CAT2']),
    categoryScore(data['CAT3']),
    categoryScore(data['CAT4']),
    categoryScore(data['CAT5']),
  ];

  data['colors'] = [
    getColorRG(data['INDEX'].toDouble(), 200, 1),
    getColorRG(data['cat_totals'][0], 10, 1),
    getColorRG(data['cat_totals'][1], 10, 1),
    getColorRG(data['cat_totals'][2], 10, 1),
    getColorRG(data['cat_totals'][3], 10, 1),
    getColorRG(data['cat_totals'][4], 10, 1)
  ];

  data['sizes'] = [
    getBarSize(data['INDEX'].toDouble(), 200, 200),
    getBarSize(data['cat_totals'][0], 10, 200),
    getBarSize(data['cat_totals'][1], 10, 200),
    getBarSize(data['cat_totals'][2], 10, 200),
    getBarSize(data['cat_totals'][3], 10, 200),
    getBarSize(data['cat_totals'][4], 10, 200)
  ];

  return data;
}

Future<Map<String, dynamic>> getProductInfo(String name) async {
  Map<String, dynamic> data =
      await db.collection('products').findOne({'NAME': name});
  return finishProductInfo(data);
}

Future<String> getBarcode(String barcode) async {
  Map<String, dynamic> data =
      await db.collection('products').findOne({'BARCODE': barcode});
  return data['_id'];
}

Future<List<Map<String, dynamic>>> getSearch(
    BuildContext context, String query, String category) async {
  return await db
      .collection('products')
      .find(where
          .match('NAME', query, caseInsensitive: true)
          .and(where.match('CATEGORY', category, caseInsensitive: true)))
      .toList();
}

Future<Map<String, dynamic>> getMonthScores(String user) async {
  return (await db.collection('users').findOne({'_id': user}))['months'];
}

Future<List<dynamic>> getPurchases(
    String user, DateTime start, DateTime end) async {
  return await db.collection('purchases').find(where.eq('user', user).and(where.gt('date', start).and(where.lt('date', end)))).toList();
}

void addPurchase(String user, String item, double qty, int index) {
  DateTime d = DateTime.now().toUtc();
  Map<String, dynamic> purchase = {
    'item': item,
    'date': d,
    'user': user,
    'qty': qty
  };
  db.collection('purchases').save(purchase);
  //db.collection('products').insertOne(purchase);
  String month = '${d.month}';
  if (month.length == 1) {
    month = '0' + month;
  }
  updateMonthScore(user, int.parse('${d.year}$month'), index * qty);
}

void deletePurchase(String user, var purchase, int index) async {
  db.collection('purchases').remove(where.eq('_id', purchase['_id']));
  int ym = int.parse(purchase['date'].toString().substring(0, 4) + purchase['date'].toString().substring(5, 7));
  updateMonthScore(user, ym, -index * purchase['qty']);
}

void updateMonthScore(String user, int ym, double amount) async {
  Map<String, dynamic> userData = await db.collection('users').findOne({'_id': user});
  bool newUser = false;
  if (userData == null) {
    userData = {'_id': user, 'months': {}};
    newUser = true;
  }
  if (!userData['months'].keys.contains(ym.toString())) {
    userData['months'][ym.toString()] = amount;
  } else {
    userData['months'][ym.toString()] += amount;
  }
  if (!newUser) {
    db.collection('users').update(where.eq('_id', user), userData);
  } else {
    db.collection('users').insertOne(userData);
  }
}