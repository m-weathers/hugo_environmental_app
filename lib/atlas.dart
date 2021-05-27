import 'package:flutter/cupertino.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;

import 'main.dart';

// MongoDB Atlas connection accessed by numerous pages. This is actually set in
// main.dart before the app runs.
Db? db;

// List of categories in the HUGO index. These are translated on the pages they
// are displayed on, so a label would say: tr('Category').
List<String> categories = [
  'All',
  'Beer (Domestic)',
  'Beer (Imported)',
  'Bread',
  'Broth',
  'Butter',
  'Candy',
  'Canned Fruit',
  'Canned Pickles',
  'Canned Vegetables',
  'Cereal (Granola)',
  'Cereal Bars',
  'Cheese',
  'Chocolate (Dry)',
  'Chocolate',
  'Coffee',
  'Cookies & Biscuits',
  'Crackers',
  'Cream',
  'Eggs',
  'Flour',
  'Gum & Mints',
  'Jelly & Peanut Butter',
  'Juice',
  'Meat (Bacon)',
  'Meat (Chicken)',
  'Meat (Deli)',
  'Tortillas'
];

// Return 1 of 4 ranks based on an item's index score, from ECO-FRIENDLY to
// HIGHLY ADVERSE.
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

// Get a color on a scale from green (low) to red (high) based on an index value
// and the maximum possible value. Used for a product's index value on a scale
// of 200, but also for individual categories.
Color getColorRG(double index, int max, double opacity) {
  return Color.fromRGBO((index / max * 255).floor(),
      (1 - (index / max) * 255).floor(), 0, opacity);
}

// Basically just multiplies a scale by a ratio. Used to get the size of the
// bars displayed for each of the categories on view.dart (so a higher and
// therefore worse score would have a larger bar).
int getBarSize(double index, int max, int scale) {
  return (index / max * scale).floor();
}

// List of the 40 variables that are used to calculate a product's scores.
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

// Used by history.dart/report.dart. If a product's info is already cached,
// no need to look it up again.
Future<Map<String, dynamic>> getProductCached(
    BuildContext context, String name) async {
  if (Provider.of<ItemInfo>(context, listen: false).hasItem(name)) {
    print('$name is cached');
    return Provider.of<ItemInfo>(context, listen: false).getItem(name);
  } else {
    print('getting info for $name');
    Map<String, dynamic> itemData = await getProductInfo(name);
    Provider.of<ItemInfo>(context, listen: false).updateItem(name, itemData);
    return itemData;
  }
}

// Each of the 40 variables a product is ranked on are on a scale of 0-10. To
// get the average for a category, sum and divide by the number of variables.
double categoryScore(List<dynamic> data) {
  double sum = 0;
  for (int i = 0; i < data.length; i++) {
    sum += data[i];
  }
  return sum / data.length;
}

// Product info stored in Atlas doesn't contain information that can easily
// be calculated at runtime (saves on space and data usage).
Future<Map<String, dynamic>> finishProductInfo(
    Map<String, dynamic> data) async {
  // Round INDEX up and get the rank (ECO-FRIENDLY, etc).
  data['INDEX'] = data['INDEX'].ceil();
  data['rank'] = getIndexRank(data['INDEX']);
  // Set the image to a Uint8List if it exists, or placeholder if not.
  if (!data.containsKey('IMAGE')) {
    ByteData x = await rootBundle.load('assets/placeholder.png');
    data['IMAGE'] = x.buffer.asUint8List(0);
  } else {
    data['IMAGE'] = data['IMAGE'].byteArray.buffer.asUint8List(0);
  }

  // Get the averages for each category (0-10).
  data['cat_totals'] = [
    categoryScore(data['CAT1']),
    categoryScore(data['CAT2']),
    categoryScore(data['CAT3']),
    categoryScore(data['CAT4']),
    categoryScore(data['CAT5']),
  ];

  // Get the corresponding color (lower=green, higher=red).
  data['colors'] = [
    getColorRG(data['INDEX'].toDouble(), 200, 1),
    getColorRG(data['cat_totals'][0], 10, 1),
    getColorRG(data['cat_totals'][1], 10, 1),
    getColorRG(data['cat_totals'][2], 10, 1),
    getColorRG(data['cat_totals'][3], 10, 1),
    getColorRG(data['cat_totals'][4], 10, 1)
  ];

  // Get the sizes of the bars shown on view.dart.
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

// Gets product info from Atlas, calls finishProductInfo(), and returns.
Future<Map<String, dynamic>> getProductInfo(String name) async {
  Map<String, dynamic>? data =
      await db!.collection('products').findOne({'_id': name});
  return finishProductInfo(data!);
}

// Get the product associated with a barcode.
Future<String> getBarcode(String barcode) async {
  Map<String, dynamic>? data =
      await db!.collection('products').findOne({'BARCODE': barcode});
  return data!['_id'];
}

// Search Atlas based on category and user query. Query+Category All means search
// all products. Query+Category means search in that Category, Category+No Query
// means return first 25 producs from that category.
Future<List<Map<String, dynamic>>> getSearch(
    BuildContext context, String query, String category) async {
  if (category != 'All' && query != '') {
    return await db!
        .collection('products')
        .find(where
            .match('_id', query, caseInsensitive: true)
            .and(where.eq('CATEGORY', category))
            .limit(25))
        .toList();
  } else if (category != 'All' && query == '') {
    return await db!
        .collection('products')
        .find(
            where.eq('CATEGORY', category).limit(25))
        .toList();
  } else {
    return await db!
        .collection('products')
        .find(where.match('_id', query, caseInsensitive: true).limit(25))
        .toList();
  }
}

// Get the monthly scores for a user, that is the total of every product purchased
// * number purchased * index value. These are already stored in a collection
// called users.
Future<Map<String, dynamic>> getMonthScores(String user) async {
  return (await db!.collection('users').findOne({'_id': user}))!['months'];
}

// Get a list of purchases for a user between start and end.
Future<List<dynamic>> getPurchases(
    String user, DateTime start, DateTime end) async {
  return await db!
      .collection('purchases')
      .find(where
          .eq('user', user)
          .and(where.gt('date', start).and(where.lt('date', end))))
      .toList();
}

// Add a purchase to the Atlas database. Stores the username, the item name,
// the amount and the item's index (redundant but easier than looking it up
// when doing calculations).
void addPurchase(String user, String item, double qty, int index) {
  DateTime d = DateTime.now().toUtc();
  Map<String, dynamic> purchase = {
    'item': item,
    'date': d,
    'user': user,
    'qty': qty
  };
  db!.collection('purchases').insertOne(purchase);
  // Update the user's total monthly score as well.
  String month = '${d.month}';
  if (month.length == 1) {
    month = '0' + month;
  }
  updateMonthScore(user, int.parse('${d.year}$month'), index * qty);
}

// Remove a purchase from the DB and update the user's monthly score.
void deletePurchase(
    String user, Map<String, dynamic> purchase, int index) async {
  double indx = index.toDouble();
  db!.collection('purchases').remove(where.eq('_id', purchase['_id']));
  int ym = int.parse(purchase['date'].toString().substring(0, 4) +
      purchase['date'].toString().substring(5, 7));
  updateMonthScore(user, ym, -indx * purchase['qty']);
}

// Update a user's monthly score based on an amount.
void updateMonthScore(String user, int ym, double amount) async {
  Map<String, dynamic>? userData =
      await db!.collection('users').findOne({'_id': user});

  // If the user doesn't have any monthly score data stored previously, create
  // a new set of data.
  bool newUser = false;
  if (userData == null) {
    userData = {'_id': user, 'months': {}};
    newUser = true;
  }

  // If the month is not listed in the user's monthly scores, add it. Otherwise,
  // update the current score.
  if (!userData['months'].keys.contains(ym.toString())) {
    userData['months'][ym.toString()] = amount;
  } else {
    userData['months'][ym.toString()] += amount;
  }
  if (!newUser) {
    db!.collection('users').update(where.eq('_id', user), userData);
  } else {
    db!.collection('users').insertOne(userData);
  }
}
