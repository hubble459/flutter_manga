import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:manga_reader/model/db_models.dart';
import 'package:manga_reader/pages/manga/download_chapters_page.dart';
import 'package:manga_reader/pages/manga/manga_chapter_page.dart';
import 'package:manga_reader/pages/manga/manga_chapters_page.dart';
import 'package:manga_reader/utils/database.dart';
import 'package:manga_reader/widgets/cover.dart';
import 'package:manga_reader/widgets/manga_details.dart';
import 'package:url_launcher/url_launcher.dart';

class MangaPage extends StatefulWidget {
  final DBManga manga;
  final database = DatabaseUtil.instance;

  MangaPage({Key? key, required this.manga}) : super(key: key);

  @override
  State<MangaPage> createState() => _MangaPageState();
}

class _MangaPageState extends State<MangaPage> {
  late DBManga _manga;
  bool _updating = true;

  @override
  void initState() {
    _manga = widget.manga;

    // Update
    if (_updating = widget.database.shouldUpdate(_manga)) {
      Fluttertoast.showToast(msg: "Updating");

      widget.database.update(_manga).then((manga) => setState(() {
            _manga = manga;
            _updating = false;
          }));
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _manga.title,
              style: Theme.of(context).textTheme.headline5,
            ),
            Text(
              _manga.url.host,
              style: Theme.of(context).textTheme.subtitle2,
            )
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => DownloadChaptersPage(manga: _manga)));
            },
            icon: const Icon(Icons.download_outlined),
          ),
          IconButton(
            onPressed: () async {
              await launch(_manga.url.toString());
            },
            icon: const Icon(Icons.web_outlined),
          ),
          IconButton(
            onPressed: () async {
              setState(() {
                _updating = true;
              });
              final manga = await widget.database.update(_manga);

              setState(() {
                _manga = manga;
                _updating = false;
              });
            },
            icon: const Icon(Icons.refresh_outlined),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Hero(tag: 'cover_${_manga.id}', child: Cover(_manga.cover, _manga.url)),
            MangaDetails(manga: _manga),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Text(
                _manga.description,
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _updating ? const CircularProgressIndicator() : null,
      bottomNavigationBar: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MaterialButton(
              child: const Text('See Chapters'),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              minWidth: double.infinity,
              color: Theme.of(context).colorScheme.primary,
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => MangaChaptersPage(manga: _manga)))
                    .then((value) => setState(() {}));
              },
            ),
            LinearProgressIndicator(
              color: Theme.of(context).colorScheme.tertiary,
              value: _manga.progressPercentage,
            ),
            Row(
              children: [
                Flexible(
                  flex: 1,
                  child: MaterialButton(
                    child: const Text('First'),
                    minWidth: double.infinity,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    color: Theme.of(context).colorScheme.primary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onPressed: () async {
                      await widget.database.setProgress(_manga, 0);
                      final chapter = await widget.database.getChapter(_manga.id, _manga.currentChapter);
                      Navigator.of(context)
                          .push(MaterialPageRoute(
                              builder: (context) => MangaChapterPage(
                                    manga: _manga,
                                    chapter: chapter,
                                  )))
                          .then((value) => setState(() {}));
                    },
                  ),
                ),
                Flexible(
                  flex: 2,
                  child: MaterialButton(
                    child: const Text('Continue'),
                    minWidth: double.infinity,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    color: Theme.of(context).colorScheme.secondary,
                    splashColor: Theme.of(context).primaryColorLight,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onPressed: () async {
                      final chapter = await widget.database.getChapter(_manga.id, _manga.currentChapter);
                      Navigator.of(context)
                          .push(MaterialPageRoute(
                              builder: (context) => MangaChapterPage(
                                    manga: _manga,
                                    chapter: chapter,
                                  )))
                          .then((value) => setState(() {}));
                    },
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: MaterialButton(
                    child: const Text('Last'),
                    minWidth: double.infinity,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    color: Theme.of(context).colorScheme.primary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onPressed: () async {
                      await widget.database.setProgress(_manga, _manga.chapterCount);
                      final chapter = await widget.database.getChapter(_manga.id, _manga.currentChapter);
                      Navigator.of(context)
                          .push(MaterialPageRoute(
                              builder: (context) => MangaChapterPage(
                                    manga: _manga,
                                    chapter: chapter,
                                  )))
                          .then((value) => setState(() {}));
                    },
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
