import 'package:fl_dictio/constants.dart';
import 'package:fl_dictio/pages/home_page.dart';
import 'package:fl_dictio/widgets/favorites.dart';
import 'package:fl_dictio/widgets/history.dart';
import 'package:fl_dictio/owlbot_res_adapter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:owlbot_dart/owlbot_dart.dart';
import 'package:hive_flutter/hive_flutter.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(OwlBotResAdapter());
  Hive.registerAdapter(OwlBotDefinitionAdapter());
  await Hive.openBox<OwlBotResponse>(favoritesBox);
  await Hive.openBox<OwlBotResponse>(historyBox);
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dictio',
      darkTheme: ThemeData.dark().copyWith(
        accentColor: Colors.red,
      ),
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
          color: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(
            color: Colors.red,
          ),
          actionsIconTheme: IconThemeData(
            color: Colors.red,
          ),
        ),
      ),
      home: HomePage(),
      routes: {
        "favorites": (_) => FavoritesPage(),
        "history": (_) => HistoryPage(),
      },
    );
  }
}
