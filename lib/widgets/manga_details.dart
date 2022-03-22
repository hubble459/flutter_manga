import 'package:flutter/material.dart';
import 'package:manga_reader/model/db_models.dart';
import 'package:manga_reader/utils/database.dart';
import 'package:manga_scraper/manga_scraper.dart';
import 'package:manga_reader/utils/util.dart' as utils;

// class MangaDetails extends StatelessWidget {
//   final Manga manga;

//   const MangaDetails(this.manga, {Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//         padding: EdgeInsets.zero,
//         child: FutureBuilder<Manga>(
//           future: scraper.manga(manga.url),
//           builder: (context, snapshot) => Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   children: [
//                     Text(
//                       manga.title,
//                       style: const TextStyle(fontSize: 24, color: Colors.black, decoration: TextDecoration.none),
//                       textAlign: TextAlign.center,
//                     ),
//                     Text(
//                       manga.url.host,
//                       style: const TextStyle(fontSize: 11, color: Colors.grey, decoration: TextDecoration.none),
//                       textAlign: TextAlign.center,
//                     ),
//                     manga.cover != null || (snapshot.connectionState == ConnectionState.done && snapshot.hasData)
//                         ? Padding(
//                             padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
//                             child: Image.network(
//                               snapshot.data?.cover?.toString() ?? manga.cover?.toString() ?? 'https://via.placeholder.com/150',
//                               headers: {'Referer': manga.url.toString()},
//                               fit: BoxFit.cover,
//                               filterQuality: FilterQuality.none,
//                               width: 400,
//                               errorBuilder: (context, error, st) => const ColoredBox(
//                                 color: Colors.red,
//                                 child: Text(
//                                   'Image failed to load',
//                                   style: TextStyle(fontSize: 11, color: Colors.red, decoration: TextDecoration.none),
//                                   textAlign: TextAlign.center,
//                                 ),
//                               ),
//                             ))
//                         : const Padding(padding: EdgeInsets.all(2)),
//                     (snapshot.connectionState == ConnectionState.done)
//                         ? snapshot.hasData
//                             ? MangaDetails(
//                                 manga: snapshot.requireData,
//                               )
//                             : const Text(
//                                 'Failed to load',
//                                 textAlign: TextAlign.center,
//                               )
//                         : Column(children: const [
//                             SizedBox(
//                               child: CircularProgressIndicator(),
//                               width: 60,
//                               height: 60,
//                             ),
//                             Padding(padding: EdgeInsets.only(top: 16), child: Text('Loading Manga...'))
//                           ]),
//                   ],
//                 ),
//               ),
//               (snapshot.connectionState == ConnectionState.done && snapshot.hasData)
//                   ? _MangaButtons(
//                       manga: snapshot.requireData,
//                     )
//                   : const Padding(
//                       padding: EdgeInsets.zero,
//                     )
//             ],
//           ),
//         ));
//   }
// }

class MangaDetails extends StatelessWidget {
  final Manga manga;

  const MangaDetails({Key? key, required this.manga}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDbManga = manga is DBManga;

    return Column(children: [
      Table(
        border: TableBorder.symmetric(
          inside: const BorderSide(width: 1),
        ),
        children: [
          TableRow(children: [
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
                child: Text(
                  'Author${manga.authors.length == 1 ? '' : 's'}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )),
            Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 0, 4),
                child: Text(
                  manga.authors.join('; '),
                ))
          ]),
          TableRow(children: [
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
                child: Text(
                  'Genre${manga.genres.length == 1 ? '' : 's'}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )),
            Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 0, 4),
                child: Text(
                  manga.genres.join('; '),
                ))
          ]),
          TableRow(children: [
            const Padding(
                padding: EdgeInsets.fromLTRB(0, 4, 0, 4),
                child: Text(
                  'Chapters',
                  style: TextStyle(fontWeight: FontWeight.bold),
                )),
            Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 0, 4),
                child: Text(
                  (isDbManga ? (manga as DBManga).chapterCount : manga.chapters.length).toString(),
                ))
          ]),
          TableRow(children: [
            const Padding(
                padding: EdgeInsets.fromLTRB(0, 4, 0, 4),
                child: Text(
                  'Read',
                  style: TextStyle(fontWeight: FontWeight.bold),
                )),
            Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 0, 4),
                child: Text(
                  (isDbManga ? (manga as DBManga).progress : 'Unread').toString(),
                ))
          ]),
          TableRow(children: [
            const Padding(
                padding: EdgeInsets.fromLTRB(0, 4, 0, 4),
                child: Text(
                  'Next Chapter',
                  style: TextStyle(fontWeight: FontWeight.bold),
                )),
            Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 0, 4),
                child: Text(
                  (isDbManga
                          ? (manga as DBManga).avgNextChapter
                          : utils.relativeDiff(utils.avgDifference(manga.chapters.map((chapter) => chapter.posted).toList()))) ??
                      'Unknown',
                ))
          ]),
          TableRow(children: [
            const Padding(
                padding: EdgeInsets.fromLTRB(0, 4, 0, 4),
                child: Text(
                  'Updated',
                  style: TextStyle(fontWeight: FontWeight.bold),
                )),
            Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 0, 4),
                child: Text(
                  manga.updated?.fromNow() ?? 'Unknown',
                ))
          ]),
          TableRow(children: [
            const Padding(
                padding: EdgeInsets.fromLTRB(0, 4, 0, 4),
                child: Text(
                  'Refreshed',
                  style: TextStyle(fontWeight: FontWeight.bold),
                )),
            Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 0, 4),
                child: Text(isDbManga ? (manga as DBManga).refreshed.fromNow() : "Just now"))
          ]),
        ],
      ),
    ]);
  }
}
