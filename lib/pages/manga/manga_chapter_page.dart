import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:manga_reader/model/db_models.dart';
import 'package:manga_reader/utils/database.dart';
import 'package:manga_reader/utils/scraper.dart';
import 'package:manga_reader/widgets/simple_future_builder.dart';

class MangaChapterPage extends StatefulWidget {
  final DatabaseUtil database = DatabaseUtil.instance;
  final DBManga manga;
  final DBChapter chapter;

  MangaChapterPage({Key? key, required this.manga, required this.chapter}) : super(key: key);

  @override
  _MangaChapterPageState createState() => _MangaChapterPageState();
}

class _MangaChapterPageState extends State<MangaChapterPage> with WidgetsBindingObserver {
  late final ScrollController _scrollController;
  late DBChapter _chapter;
  late double _progress;

  @override
  void initState() {
    super.initState();
    _chapter = widget.chapter;
    _progress = _chapter.progress;
    _scrollController = ScrollController();
    WidgetsBinding.instance!.addObserver(this);
    _scrollController.addListener(() {
      _progress = _scrollController.offset;
    });
  }

  @override
  void dispose() {
    _saveProgress();

    WidgetsBinding.instance!.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // user returned to our app
    } else if (state == AppLifecycleState.inactive) {
      // app is inactive
      _saveProgress();
    } else if (state == AppLifecycleState.paused) {
      // user is about quit our app temporally
    } else if (state == AppLifecycleState.detached) {
      // app detached
    }
  }

  Future<bool> _saveProgress() async {
    _chapter.progress = _progress;
    return widget.database.updateChapter(_chapter);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
        body: NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (context, isScrolled) => [
            SliverAppBar(
              floating: true,
              title: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_chapter.title),
                  Text(
                    _chapter.posted != null ? _chapter.posted!.fromNow() : "Unknown",
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.open_in_browser),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: const Text("Open in Browser?"),
                              content: Text(_chapter.url.toString()),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Cancel")),
                                TextButton(
                                    onPressed: () async {
                                      await url_launcher.launch(_chapter.url.toString());
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Open")),
                              ],
                            ));
                  },
                ),
              ],
            )
          ],
          body: SimpleFutureBuilder<List<Uri>>(
            future: scraper.images(_chapter.url).then((value) {
              Future.delayed(const Duration(milliseconds: 500)).then(
                  (value) => _scrollController.animateTo(_progress, duration: const Duration(seconds: 1), curve: Curves.ease));
              return value;
            }),
            onErrorBuilder: (context, error) {
              return Center(
                child: Text(error.toString()),
              );
            },
            onLoadingBuilder: (context) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
            onLoadedBuilder: (context, images) {
              return RawScrollbar(
                  controller: _scrollController,
                  thumbColor: Theme.of(context).colorScheme.secondary,
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      final image = images[index];
                      return CachedNetworkImage(
                        alignment: Alignment.topCenter,
                        imageUrl: image.toString(),
                        width: size.width,
                        progressIndicatorBuilder: (context, url, downloadProgress) => SizedBox(
                          height: size.height,
                          width: size.width,
                          child: Center(
                            child: CircularProgressIndicator(value: downloadProgress.progress),
                          ),
                        ),
                        errorWidget: (context, url, error) => SizedBox(
                          height: size.height,
                          width: size.width,
                          child: Center(
                            child: Column(
                              children: [
                                const Icon(Icons.error),
                                Text(
                                  error.toString(),
                                  style: const TextStyle(color: Colors.red, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ),
                        httpHeaders: {'referer': widget.manga.url.toString()},
                      );
                    },
                  ));
            },
          ),
        ),
        bottomNavigationBar: IntrinsicHeight(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: widget.manga.progressPercentage,
              minHeight: 5,
              color: Theme.of(context).colorScheme.tertiary,
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: MaterialButton(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: EdgeInsets.zero,
                    onPressed: widget.manga.progress > 1
                        ? () async {
                            await _saveProgress();
                            final chapter = await _getChapter(widget.manga, --widget.manga.progress);
                            setState(() {
                              _chapter = chapter;
                              _progress = chapter.progress;
                            });
                          }
                        : null,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Visibility(visible: widget.manga.progress > 1, child: Text((widget.manga.progress - 1).toString())),
                        const Icon(Icons.navigate_before)
                      ],
                    ),
                  ),
                ),
                Expanded(
                    child: _ChapterSelector(
                        manga: widget.manga, chapter: _chapter, getChapter: _getChapter, saveProgress: _saveProgress)),
                Expanded(
                  child: MaterialButton(
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onPressed: widget.manga.progress < widget.manga.chapterCount
                        ? () async {
                            await _saveProgress();
                            final chapter = await _getChapter(widget.manga, ++widget.manga.progress);
                            setState(() {
                              _chapter = chapter;
                              _progress = chapter.progress;
                            });
                          }
                        : null,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.navigate_next),
                        Visibility(
                            visible: widget.manga.progress < widget.manga.chapterCount,
                            child: Text((widget.manga.progress + 1).toString()))
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        )));
  }

  Future<DBChapter> _getChapter(final DBManga manga, final int progress) async {
    await widget.database.setProgress(manga, progress);

    return await widget.database.getChapter(manga.id, manga.currentChapter);
  }
}

class _ChapterSelector extends StatelessWidget {
  final DBManga manga;
  final DBChapter chapter;
  final Future<DBChapter> Function(DBManga manga, int progress) getChapter;
  final Future<bool> Function() saveProgress;

  const _ChapterSelector(
      {Key? key, required this.manga, required this.chapter, required this.getChapter, required this.saveProgress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      onPressed: () async {
        final result = await showDialog(
            context: context,
            builder: (context) {
              return const Center(
                child: Text("Select Chapter"),
              );
            });

        // final chapter = await widget.getChapter(widget.manga, 0);
        // setState(() {
        //   _chapter = chapter;
        // });
      },
      child: Text("Chapter ${manga.progress}"),
    );
  }
}
