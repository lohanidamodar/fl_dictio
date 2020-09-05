import 'package:fl_dictio/owlbot_api_key.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:owlbot_dart/owlbot_dart.dart';
import 'package:hive_flutter/hive_flutter.dart';

const String favoritesBox = "favorites";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox(favoritesBox);
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dictio',
      darkTheme: ThemeData.dark().copyWith(),
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
    );
  }
}

final searchControllerProvider =
    StateProvider<TextEditingController>((ref) => TextEditingController());

final searchResultProvider = StateProvider<OwlBotResponse>((ref) => null);

Map<String, dynamic> toMapRes(OwlBotResponse res) => {
      "word": res.word,
      "pronounciation": res.pronunciation,
      "definitions": res.definitions
          ?.map((def) => {
                "type": def.type,
                "emoji": def.emoji,
                "example": def.example,
                "image_url": def.imageUrl,
                "definition": def.definition,
              })
          ?.toList(),
    };

class HomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, watch) {
    final searchResult = watch(searchResultProvider).state;
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: watch(searchControllerProvider).state,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
            border: OutlineInputBorder(),
          ),
          textInputAction: TextInputAction.search,
          onEditingComplete: () {
            _search(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              _search(context);
            },
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          if (searchResult != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12.0, 8.0, 0.0, 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                searchResult.word,
                                style: Theme.of(context).textTheme.headline5,
                              ),
                              if (searchResult.pronunciation != null) ...[
                                const SizedBox(height: 5.0),
                                Text(searchResult.pronunciation),
                              ],
                            ],
                          ),
                        ),
                        ValueListenableBuilder(
                          valueListenable: Hive.box(favoritesBox).listenable(),
                          builder: (context, box, child) => IconButton(
                            icon: Icon(
                              Icons.star,
                              color: box.containsKey(searchResult.word)
                                  ? Colors.deepOrange
                                  : null,
                            ),
                            onPressed: () {
                              if (box.containsKey(searchResult.word)) {
                                box.delete(searchResult.word);
                              } else {
                                box.put(
                                    searchResult.word, toMapRes(searchResult));
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ...searchResult.definitions.map(
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
                                if (e.imageUrl != null) ...[
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
                ),
              ],
            )
        ],
      ),
    );
  }

  _search(BuildContext context) async {
    final query = context.read(searchControllerProvider).state.text;
    if (query != null && query.isNotEmpty) {
      final res = await OwlBot(token: TOKEN).define(word: query);
      if (res != null) {
        context.read(searchResultProvider).state = res;
      }
    }
  }
}
