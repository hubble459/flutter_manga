// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DBManga _$DBMangaFromJson(Map<String, dynamic> json) => DBManga(
      id: json['id'] as int,
      chapterCount: json['chapter_count'] as int,
      refreshed: const CustomJiffyConverter().fromJson(json['refreshed'] as String),
      progress: json['progress'] as int? ?? 0,
      autoRefresh: json['auto_refresh'] == null ? true : const CustomBooleanConverter().fromJson(json['auto_refresh'] as int),
      deleted: json['deleted'] == null ? false : const CustomBooleanConverter().fromJson(json['deleted'] as int),
      url: Uri.parse(json['url'] as String),
      title: json['title'] as String,
      description: json['description'] as String,
      cover: json['cover'] == null ? null : Uri.parse(json['cover'] as String),
      genres: const CustomStringArray().fromJson(json['genres'] as String),
      authors: const CustomStringArray().fromJson(json['authors'] as String),
      altTitles: const CustomStringArray().fromJson(json['alt_titles'] as String),
      ongoing: const CustomBooleanConverter().fromJson(json['ongoing'] as int),
      updated: const CustomJiffyNullConverter().fromJson(json['updated'] as String?),
    );

Map<String, dynamic> _$DBMangaToJson(DBManga instance) => <String, dynamic>{
      'url': instance.url.toString(),
      'title': instance.title,
      'description': instance.description,
      'cover': instance.cover?.toString(),
      'ongoing': const CustomBooleanConverter().toJson(instance.ongoing),
      'genres': const CustomStringArray().toJson(instance.genres),
      'authors': const CustomStringArray().toJson(instance.authors),
      'alt_titles': const CustomStringArray().toJson(instance.altTitles),
      'updated': const CustomJiffyNullConverter().toJson(instance.updated),
      'id': instance.id,
      'auto_refresh': const CustomBooleanConverter().toJson(instance.autoRefresh),
      'refreshed': const CustomJiffyConverter().toJson(instance.refreshed),
      'deleted': const CustomBooleanConverter().toJson(instance.deleted),
      'progress': instance.progress,
      'chapter_count': instance.chapterCount,
    };

DBChapter _$DBChapterFromJson(Map<String, dynamic> json) => DBChapter(
      id: json['id'] as int,
      mangaId: json['manga_id'] as int,
      progress: json['progress'] as double,
      url: Uri.parse(json['url'] as String),
      title: json['title'] as String,
      number: (json['number'] as num).toDouble(),
      posted: const CustomJiffyNullConverter().fromJson(json['posted'] as String?),
    );

Map<String, dynamic> _$DBChapterToJson(DBChapter instance) => <String, dynamic>{
      'url': instance.url.toString(),
      'title': instance.title,
      'number': instance.number,
      'posted': const CustomJiffyNullConverter().toJson(instance.posted),
      'id': instance.id,
      'manga_id': instance.mangaId,
      'progress': instance.progress,
    };
