import 'dart:math';

import 'package:jiffy/jiffy.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:manga_scraper/manga_scraper.dart';

part 'db_models.g.dart';

@JsonSerializable()
@CustomJiffyNullConverter()
@CustomJiffyConverter()
@CustomBooleanConverter()
@CustomStringArray()
class DBManga extends Manga {
  final int id;
  @JsonKey(name: "auto_refresh")
  final bool autoRefresh;
  final Jiffy refreshed;
  final bool deleted;
  String? avgNextChapter;
  int progress = 0;

  @JsonKey(ignore: true)
  double get progressPercentage => 1 / chapterCount * progress;
  @JsonKey(ignore: true)
  int get currentChapter => min(chapterCount - progress, chapterCount - 1);

  @JsonKey(name: 'chapter_count')
  final int chapterCount;

  @JsonKey(ignore: true)
  @Deprecated("No chapters in DBManga")
  @override
  final chapters = const [];

  DBManga({
    required this.id,
    required this.chapterCount,
    required this.refreshed,
    this.progress = 0,
    this.autoRefresh = true,
    this.deleted = false,
    required Uri url,
    required String title,
    required String description,
    Uri? cover,
    this.avgNextChapter,
    required List<String> genres,
    required List<String> authors,
    required List<String> altTitles,
    required bool ongoing,
    Jiffy? updated,
  }) : super(
          url: url,
          title: title,
          description: description,
          cover: cover,
          ongoing: ongoing,
          genres: genres,
          authors: authors,
          altTitles: altTitles,
          chapters: const [],
          updated: updated,
        );

  factory DBManga.fromJson(Map<String, dynamic> json) => _$DBMangaFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$DBMangaToJson(this);

  factory DBManga.fromManga(int mangaId, Manga manga) => DBManga(
      id: mangaId,
      chapterCount: manga.chapters.length,
      cover: manga.cover,
      updated: manga.updated,
      autoRefresh: true,
      deleted: false,
      refreshed: Jiffy(),
      url: manga.url,
      title: manga.title,
      description: manga.description,
      ongoing: manga.ongoing,
      genres: manga.genres,
      authors: manga.authors,
      altTitles: manga.altTitles);

  DBManga copyWith(
      {int? id,
      Uri? url,
      String? title,
      String? description,
      Uri? cover,
      bool? ongoing,
      List<String>? genres,
      List<String>? authors,
      List<String>? altTitles,
      List<Chapter>? chapters,
      Jiffy? updated,
      int? progress,
      bool? deleted,
      Jiffy? refreshed,
      int? chapterCount,
      String? avgNextChapter}) {
    return DBManga(
      id: id ?? this.id,
      url: url ?? this.url,
      title: title ?? this.title,
      description: description ?? this.description,
      cover: cover ?? this.cover,
      ongoing: ongoing ?? this.ongoing,
      genres: genres ?? this.genres,
      authors: authors ?? this.authors,
      altTitles: altTitles ?? this.altTitles,
      updated: updated ?? this.updated,
      progress: progress ?? this.progress,
      deleted: deleted ?? this.deleted,
      refreshed: refreshed ?? this.refreshed,
      chapterCount: chapterCount ?? this.chapterCount,
      avgNextChapter: avgNextChapter ?? this.avgNextChapter,
    );
  }

  @override
  String toString() {
    return '${super.toString()}\nDBManga(id: $id, autoRefresh: $autoRefresh, refreshed: $refreshed, deleted: $deleted, progress: $progress, chapterCount: $chapterCount)';
  }
}

@JsonSerializable()
@CustomJiffyNullConverter()
@CustomJiffyConverter()
class DBChapter extends Chapter {
  final int id;
  @JsonKey(name: 'manga_id')
  final int mangaId;
  double progress;

  DBChapter({
    required this.id,
    required this.mangaId,
    this.progress = 0.0,
    required Uri url,
    required String title,
    required double number,
    Jiffy? posted,
  }) : super(url: url, title: title, number: number, posted: posted);

  factory DBChapter.fromJson(Map<String, dynamic> json) => _$DBChapterFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$DBChapterToJson(this);

  @override
  String toString() => 'DBChapter(id: $id, mangaId: $mangaId, progress: $progress)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DBChapter && other.id == id && other.mangaId == mangaId && other.progress == progress;
  }

  @override
  int get hashCode => id.hashCode ^ mangaId.hashCode ^ progress.hashCode;
}
