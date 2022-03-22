import 'package:flutter/material.dart';
import 'package:manga_reader/utils/database.dart';
import 'package:manga_reader/widgets/cover.dart';
import 'package:manga_reader/widgets/manga_details.dart';
import 'package:manga_reader/widgets/simple_future_builder.dart';
import 'package:manga_reader/widgets/skeleton.dart';
import 'package:manga_scraper/manga_scraper.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:manga_reader/utils/scraper.dart';

final hostnames = scraper.searchable();

const defaultHostnames = ['mangadex', 'manganelo', 'manganato', 'isekaiscan', 'manhwatop', 'manhuaplus', 'topmanhua'];

class SearchPage extends StatefulWidget {
  static const routeName = "search";

  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

final TextEditingController controller = TextEditingController();
Future<List<SearchManga>> _searchResults = Future.value([]);

class _SearchPageState extends State<SearchPage> {
  List<bool> isSelected = hostnames
      .map((hn) => defaultHostnames.firstWhere((element) => hn.contains(element), orElse: () => '') != '')
      .toList(growable: false);

  @override
  Widget build(BuildContext context) {
    int hostnameIndex = 0;
    return Column(children: [
      TextField(
        controller: controller,
        textAlignVertical: TextAlignVertical.center,
        textAlign: TextAlign.start,
        textInputAction: TextInputAction.search,
        decoration: const InputDecoration(suffixIcon: Icon(Icons.search), contentPadding: EdgeInsets.fromLTRB(8, 0, 8, 0)),
        onSubmitted: (query) {
          if (controller.text.isNotEmpty) {
            setState(() {
              _searchResults = scraper.search(controller.text, hostnames: selectedHostnames());
            });
          }
        },
      ),
      SafeArea(
          child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ToggleButtons(
          renderBorder: false,
          children: [
            ...hostnames.map((hostname) => CustomIcon(
                  text: hostname,
                  isSelected: isSelected[hostnameIndex++],
                )),
          ],
          isSelected: isSelected,
          onPressed: (index) {
            setState(() {
              isSelected[index] = !isSelected[index];
            });
          },
        ),
      )),
      SimpleFutureBuilder<List<SearchManga>>(
        future: _searchResults,
        onErrorBuilder: (context, error) => Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Failed to load',
              textAlign: TextAlign.center,
            ),
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    _searchResults = scraper.search(controller.text, hostnames: selectedHostnames());
                  });
                },
                child: const Text('Retry'))
          ],
        )),
        onLoadedBuilder: (context, results) =>
            results.isNotEmpty ? Expanded(child: _MangaSearchItems(results: results)) : const Text('No search results'),
        onLoadingBuilder: (context) => Expanded(
          child: SkeletonList(
            itemBuilder: (context, index) => const ListTile(
              title: SkeletonRow(),
              subtitle: SkeletonRow(),
              leading: SkeletonRow(
                height: 90,
                width: 40,
              ),
            ),
          ),
        ),
      ),
    ]);
  }

  selectedHostnames() {
    int i = 0;
    return hostnames.where((e) => isSelected[i++]).toList();
  }
}

class CustomIcon extends StatefulWidget {
  final String text;
  final bool isSelected;

  const CustomIcon({
    Key? key,
    required this.text,
    this.isSelected = false,
  }) : super(key: key);

  @override
  _CustomIconState createState() => _CustomIconState();
}

class _CustomIconState extends State<CustomIcon> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
      child: Text(
        widget.text,
      ),
    );
  }
}

class _MangaSearchItems extends StatelessWidget {
  final List<SearchManga> results;

  const _MangaSearchItems({Key? key, required this.results}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) {
          final SearchManga manga = results[index];
          final cover = manga.cover;
          return InkWell(
              onTap: () {
                _showMangaDetails(context, manga);
              },
              child: ListTile(
                leading: cover != null
                    ? Image.network(
                        cover.toString(),
                        headers: {'Referer': manga.url.toString()},
                        fit: BoxFit.fill,
                        height: 90,
                        width: 40,
                        errorBuilder: (context, error, st) => const ColoredBox(
                          color: Colors.red,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(20, 30, 20, 30),
                          ),
                        ),
                      )
                    : const ColoredBox(
                        color: Colors.red,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(20, 30, 20, 30),
                        ),
                      ),
                title: Text(manga.title),
                subtitle: Text(manga.url.host),
              ));
        },
      ),
    );
  }

  _showMangaDetails(BuildContext context, SearchManga manga) {
    return showMaterialModalBottomSheet(
      animationCurve: Curves.easeIn,
      duration: const Duration(milliseconds: 500),
      context: context,
      barrierColor: const Color(0x50696969),
      builder: (context) => SingleChildScrollView(
          controller: ModalScrollController.of(context),
          child: SimpleFutureBuilder<Manga>(
            future: scraper.manga(manga.url),
            onLoadingBuilder: (context) => const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            ),
            onErrorBuilder: (context, error) => Center(
                child: Text(
              "Failed to Scrape Manga\n${error ?? 'Unknown'}",
              style: const TextStyle(color: Colors.red),
            )),
            onLoadedBuilder: (context, manga) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(6),
                  child: Cover(manga.cover, manga.url),
                ),
                Padding(
                  padding: const EdgeInsets.all(6),
                  child: MangaDetails(manga: manga),
                ),
                _MangaButtons(manga: manga),
              ],
            ),
          )),
    );
  }
}

class _MangaButtons extends StatefulWidget {
  final Manga manga;
  const _MangaButtons({Key? key, required this.manga}) : super(key: key);

  @override
  State<_MangaButtons> createState() => __MangaButtonsState();

  _addManga(Manga manga) async {
    final db = DatabaseUtil.instance;
    return db.insertManga(manga);
  }
}

class __MangaButtonsState extends State<_MangaButtons> {
  bool addVisible = true;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: double.infinity,
            child: MaterialButton(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                color: Theme.of(context).colorScheme.secondary,
                textColor: Colors.white,
                disabledColor: Theme.of(context).colorScheme.secondary.withAlpha(100),
                onPressed: addVisible
                    ? () {
                        widget._addManga(widget.manga);
                        setState(() {
                          addVisible = false;
                        });
                      }
                    : null,
                child: const Text('Add')),
          ),
          SizedBox(
            width: double.infinity,
            child: MaterialButton(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                color: Theme.of(context).colorScheme.tertiary,
                textColor: Colors.white,
                onPressed: () {
                  widget._addManga(widget.manga);
                  // TODO: Read
                  setState(() {
                    addVisible = false;
                  });
                },
                child: const Text('Read')),
          ),
        ],
      ),
    );
  }
}
