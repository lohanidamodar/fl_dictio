import 'package:fl_dictio/constants.dart';
import 'package:fl_dictio/owlbot_api_key.dart';
import 'package:fl_dictio/state.dart';
import 'package:fl_dictio/widgets/dictionary_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:owlbot_dart/owlbot_dart.dart';

class HomePage extends ConsumerWidget {
  final hBox = Hive.box<OwlBotResponse>(historyBox);
  @override
  Widget build(BuildContext context, watch) {
    final searchResult = watch(searchResultProvider).state;
    final error = watch(errorProvider).state;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: watch(searchControllerProvider).state,
          decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              border: UnderlineInputBorder(),
              suffix: IconButton(
                padding: const EdgeInsets.all(4.0),
                icon: Icon(
                  Icons.clear,
                  size: 16.0,
                ),
                onPressed: () {
                  context.read(searchControllerProvider).state.clear();
                },
              ),
              hintText: "enter word to search"),
          textInputAction: TextInputAction.search,
          onEditingComplete: () {
            _search(context);
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          if (error != null && error.isNotEmpty) ...[
            Card(
              child: ListTile(
                title: Text(watch(searchControllerProvider).state.text ?? ''),
                subtitle: Text(error),
                trailing: Icon(
                  Icons.error,
                  color: Theme.of(context).accentColor,
                ),
              ),
            ),
            const SizedBox(height: 20.0),
          ],
          if (searchResult != null)
            DictionaryListItem(dictionaryItem: searchResult),
          if (searchResult == null && hBox.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(
                left: 8.0,
                bottom: 4.0,
              ),
              child: Text(
                "Recent search",
                style: TextStyle(
                  color: Theme.of(context).accentColor,
                ),
              ),
            ),
            DictionaryListItem(
              dictionaryItem: hBox.getAt(0),
            ),
          ],
          if (searchResult == null && hBox.isEmpty) ...[
            Card(
              child: ListTile(
                title: Text(
                    "You haven't used the disctionary, search some words to learn the definitions and more"),
              ),
            )
          ],
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 50,
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.star),
                onPressed: () {
                  Navigator.pushNamed(context, 'favorites');
                },
              ),
              IconButton(
                icon: Icon(Icons.history),
                onPressed: () {
                  Navigator.pushNamed(context, 'history');
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  _search(BuildContext context) async {
    FocusScope.of(context).requestFocus(FocusNode());
    final query = context.read(searchControllerProvider).state.text;
    if (query == null || query.isEmpty || context.read(loadingProvider).state)
      return;
    context.read(errorProvider).state = '';
    context.read(loadingProvider).state = true;
    final box = Hive.box<OwlBotResponse>(historyBox);
    if (box.containsKey(query)) {
      context.read(searchResultProvider).state = box.get(query);
      context.read(loadingProvider).state = false;
      return;
    }

    final res = await OwlBot(token: TOKEN).define(word: query);
    if (res != null) {
      box.put(res.word, res);
    } else {
      context.read(errorProvider).state = '404 Not found';
    }
    context.read(searchResultProvider).state = res;
    context.read(loadingProvider).state = false;
  }
}
