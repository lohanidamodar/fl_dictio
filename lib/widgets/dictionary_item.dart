import 'package:fl_dictio/constants.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:owlbot_dart/owlbot_dart.dart';

class DictionaryListItem extends StatelessWidget {
  const DictionaryListItem({
    Key key,
    @required this.dictionaryItem,
  }) : super(key: key);

  final OwlBotResponse dictionaryItem;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12.0, 8.0, 0.0, 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            dictionaryItem.word,
                            style: Theme.of(context).textTheme.headline5,
                          ),
                          if (dictionaryItem.pronunciation != null) ...[
                            const SizedBox(height: 5.0),
                            Text(dictionaryItem.pronunciation),
                          ],
                        ],
                      ),
                    ),
                    ValueListenableBuilder(
                      valueListenable:
                          Hive.box<OwlBotResponse>(favoritesBox).listenable(),
                      builder: (context, box, child) => IconButton(
                        icon: Icon(
                          Icons.star,
                          color: box.containsKey(dictionaryItem.word)
                              ? Colors.deepOrange
                              : null,
                        ),
                        onPressed: () {
                          if (box.containsKey(dictionaryItem.word)) {
                            box.delete(dictionaryItem.word);
                          } else {
                            box.put(dictionaryItem.word, dictionaryItem);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...dictionaryItem.definitions.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.type,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5.0),
                            Text(e.definition),
                            if (e.example != null) ...[
                              const SizedBox(height: 5.0),
                              Text("Example: ${e.example}"),
                            ],
                            if (e.imageUrl != null &&
                                e.imageUrl.isNotEmpty) ...[
                              const SizedBox(height: 10.0),
                              Image.network(e.imageUrl),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
