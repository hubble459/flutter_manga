import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:manga_reader/model/db_models.dart';
import 'package:manga_reader/pages/manga/manga_chapter_page.dart';
import 'package:manga_reader/utils/database.dart';

class MangaChaptersPage extends StatefulWidget {
  final DBManga manga;
  final database = DatabaseUtil.instance;

  MangaChaptersPage({Key? key, required this.manga}) : super(key: key);

  @override
  State<MangaChaptersPage> createState() => _MangaChaptersPageState();
}

class _MangaChaptersPageState extends State<MangaChaptersPage> {
  final _pageSize = 20;
  final PagingController<int, DBChapter> _pagingController = PagingController(firstPageKey: 0);

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  Future<void> _fetchPage(int offset) async {
    try {
      final newItems = await widget.database.getChapters(widget.manga.id, offset: offset, limit: _pageSize);
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = offset + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.manga.title,
                style: Theme.of(context).textTheme.headline5,
              ),
              Text(
                widget.manga.url.host,
                style: Theme.of(context).textTheme.subtitle2,
              )
            ],
          ),
        ),
        PagedSliverList<int, DBChapter>(
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate<DBChapter>(
                itemBuilder: (context, chapter, index) => ListTile(
                      contentPadding: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
                      title: Text(chapter.title),
                      subtitle: Text(chapter.posted?.fromNow() ?? 'Unknown'),
                      trailing: Text(chapter.number.toString()),
                      minLeadingWidth: 5,
                      leading: ColoredBox(
                        color: widget.manga.chapterCount - widget.manga.progress <= index
                            ? Theme.of(context).colorScheme.tertiary
                            : Colors.transparent,
                        child: const SizedBox(
                          width: 3,
                          height: double.infinity,
                        ),
                      ),
                      onTap: () async {
                        await widget.database.setProgress(widget.manga, widget.manga.chapterCount - index);

                        setState(() {});

                        Navigator.of(context)
                            .push(MaterialPageRoute(
                                builder: (context) => MangaChapterPage(
                                      manga: widget.manga,
                                      chapter: chapter,
                                    )))
                            .then((value) => setState(() {}));
                      },
                    )))
      ],
    ));
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}
