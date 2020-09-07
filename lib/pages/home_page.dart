import 'package:fl_dictio/constants.dart';
import 'package:fl_dictio/owlbot_api_key.dart';
import 'package:fl_dictio/state.dart';
import 'package:fl_dictio/widgets/favorites.dart';
import 'package:fl_dictio/widgets/history.dart';
import 'package:fl_dictio/widgets/home_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:owlbot_dart/owlbot_dart.dart';

final selectedTabProvider = StateProvider<int>((ref) => 0);

final pageViewController = StateProvider<PageController>(
  (ref) => PageController(
    initialPage: ref.watch(selectedTabProvider).state,
  ),
);

class HomePage extends ConsumerWidget {
  final hBox = Hive.box<OwlBotResponse>(historyBox);
  @override
  Widget build(BuildContext context, watch) {
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
      body: PageView(
        controller: watch(pageViewController).state,
        onPageChanged: (page) {
          context.read(selectedTabProvider).state = page;
        },
        children: [
          HomeTab(),
          HistoryPage(),
          FavoritesPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: watch(selectedTabProvider).state,
        onTap: (index) {
          context.read(pageViewController).state.animateToPage(
                index,
                curve: Curves.easeIn,
                duration: Duration(milliseconds: 500),
              );
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), title: Text("Home")),
          BottomNavigationBarItem(
              icon: Icon(Icons.history), title: Text("History")),
          BottomNavigationBarItem(
              icon: Icon(Icons.star), title: Text("Favorites")),
        ],
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
    context.read(pageViewController).state.jumpToPage(0);
    context.read(loadingProvider).state = false;
  }
}
