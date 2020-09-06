import 'package:fl_dictio/favorites.dart';
import 'package:fl_dictio/history.dart';
import 'package:fl_dictio/owlbot_api_key.dart';
import 'package:fl_dictio/owlbot_res_adapter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:owlbot_dart/owlbot_dart.dart';
import 'package:hive_flutter/hive_flutter.dart';

const String favoritesBox = "favorites";
const String historyBox = "history";

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
      routes: {
        "favorites": (_) => FavoritesPage(),
        "history": (_) => HistoryPage(),
      },
    );
  }
}

final searchControllerProvider =
    StateProvider<TextEditingController>((ref) => TextEditingController());

final searchResultProvider = StateProvider<OwlBotResponse>((ref) => null);
final loadingProvider = StateProvider<bool>((ref) => false);

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
            icon: watch(loadingProvider).state ? CircularProgressIndicator() :  Icon(Icons.search),
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
            DictionaryListItem(dictionaryItem: searchResult)
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
    final query = context.read(searchControllerProvider).state.text;
    if(query == null || query.isEmpty || context.read(loadingProvider).state) return;
    context.read(loadingProvider).state = true;
    FocusScope.of(context).requestFocus(FocusNode());
    final box = Hive.box<OwlBotResponse>(historyBox);
    if (box.containsKey(query)) {
      context.read(searchResultProvider).state = box.get(query);
      return;
    }
    if (query != null && query.isNotEmpty) {
      final res = await OwlBot(token: TOKEN).define(word: query);
      if (res != null) {
        box.put(res.word, res);
      }
      context.read(searchResultProvider).state = res;
    }
    context.read(loadingProvider).state = false;
  }
}

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
          child: Padding(
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
        ),
        Card(
          child: Padding(
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
    );
  }
}
