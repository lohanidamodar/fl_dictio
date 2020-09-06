import 'package:fl_dictio/main.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import 'package:owlbot_dart/owlbot_dart.dart';

class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<OwlBotResponse>(historyBox).listenable(),
        builder: (context, box, child) {
          final favs = box.values;
          if(favs.isEmpty) {
            return Container(
              child: Text("No history"),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: <Widget>[
              ...favs.map((fav) {
                final res = fav;
                return DictionaryListItem(
                  dictionaryItem: res,
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
