import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:manga_reader/model/db_models.dart';
import 'package:manga_reader/pages/manga/manga_page.dart';
import 'package:manga_reader/utils/database.dart';
import 'package:manga_reader/widgets/simple_future_builder.dart';

class ReadingPage extends StatefulWidget {
  const ReadingPage({Key? key}) : super(key: key);

  @override
  _ReadingPageState createState() => _ReadingPageState();
}

class _ReadingPageState extends State<ReadingPage> {
  final database = DatabaseUtil.instance;
  late Future<List<DBManga>> _reading;

  @override
  void initState() {
    _reading = database.getAllManga();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleFutureBuilder<List<DBManga>>(
        future: _reading,
        onErrorBuilder: (context, error) => Column(
              children: [
                const Text(
                  'Failed to load',
                  textAlign: TextAlign.center,
                ),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                ),
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _reading = database.getAllManga();
                      });
                    },
                    child: const Text('Retry'))
              ],
            ),
        onLoadedBuilder: (context, items) {
          return items.isEmpty
              ? const Text('No manga')
              : ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) => _MangaListItem(
                      manga: items[index],
                      update: () => setState(() {
                            _reading = database.getAllManga();
                          })));
        },
        onLoadingBuilder: (context) =>
            ListView.builder(itemCount: 10, itemBuilder: (context, index) => const _MangaListItemSkeleton()));
  }
}

class _MangaListItemSkeleton extends StatelessWidget {
  const _MangaListItemSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ListTile(
      title: VerticalDivider(
        width: 20,
        thickness: 10,
      ),
    );
  }
}

class _MangaListItem extends StatefulWidget {
  final database = DatabaseUtil.instance;
  final DBManga manga;
  final void Function() update;

  _MangaListItem({Key? key, required this.manga, required this.update}) : super(key: key);

  @override
  State<_MangaListItem> createState() => __MangaListItemState();
}

class __MangaListItemState extends State<_MangaListItem> {
  late DBManga _manga;

  @override
  void initState() {
    _manga = widget.manga;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
        onTap: () async {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => MangaPage(manga: _manga))).then((value) async {
            _manga = (await widget.database.getManga(_manga.id))!;
            setState(() {});
          });
        },
        onLongPress: () async {
          showDialog(
            context: context,
            builder: (context) => Center(
              child: ColoredBox(
                color: Theme.of(context).dialogBackgroundColor,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0, bottom: 2.0),
                  child: SizedBox(
                    width: 200,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Delete",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Divider(
                          thickness: 1,
                        ),
                        Text(
                          "Are you sure you want to delete [${_manga.title}]?",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                                onPressed: () async {
                                  final deleted = await widget.database.deleteManga(_manga.id);
                                  if (deleted) {
                                    Fluttertoast.showToast(msg: "Deleted!");
                                  } else {
                                    Fluttertoast.showToast(msg: "Something went wrong...");
                                  }
                                  widget.update();
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Confirm")),
                            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Cancel"))
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        title: Text(_manga.title),
        subtitle: Text(_manga.url.host),
        minLeadingWidth: 50,
        leading: Hero(
          tag: 'cover_${_manga.id}',
          child: Image.network(
            _manga.cover?.toString() ?? 'https://via.placeholder.com/150',
            width: 50,
            height: double.infinity,
            headers: {'Referer': _manga.url.toString()},
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const _ErrorImage(),
          ),
        ),
        trailing: SizedBox(
          width: 50,
          child: Stack(
            children: [
              Center(
                child: CircularProgressIndicator(
                  color: _manga.progressPercentage == 1
                      ? Colors.green
                      : _manga.ongoing
                          ? Theme.of(context).colorScheme.tertiary
                          : Colors.red,
                  value: _manga.progressPercentage,
                ),
              ),
              Visibility(
                visible: _manga.progress < _manga.chapterCount,
                child: Center(
                  child: Text((_manga.currentChapter).toString()),
                ),
              )
            ],
          ),
        ));
  }
}

class _ErrorImage extends StatelessWidget {
  const _ErrorImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Colors.red,
      child: SizedBox(
        height: double.infinity,
        width: 30,
      ),
    );
  }
}
