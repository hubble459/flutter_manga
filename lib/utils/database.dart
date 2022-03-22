import 'package:jiffy/jiffy.dart';
import 'package:manga_reader/model/db_models.dart';
import 'package:manga_reader/utils/util.dart';
import 'package:manga_scraper/manga_scraper.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:collection/collection.dart';
import 'package:manga_reader/utils/scraper.dart';

onCreate(Database db, int version) async => db.transaction((txn) async {
      // ### MANGA ###
      await txn.execute("""CREATE TABLE manga (
                  id INTEGER PRIMARY KEY,
                  title TEXT NOT NULL,
                  url VARCHAR(255) NOT NULL UNIQUE,
                  description TEXT NOT NULL DEFAULT '',  
                  authors TEXT NOT NULL DEFAULT '',  
                  genres TEXT NOT NULL DEFAULT '', 
                  alt_titles TEXT NOT NULL DEFAULT '', 
                  cover VARCHAR(255) DEFAULT NULL, 
                  ongoing BOOLEAN NOT NULL DEFAULT 0,
                  auto_refresh BOOLEAN DEFAULT 1, 
                  deleted BOOLEAN DEFAULT 0, 
                  refreshed DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                  updated DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, 
                  progress INTEGER NOT NULL DEFAULT 0);""");

      await txn.execute("""
                  CREATE TRIGGER UPDATE_manga AFTER UPDATE ON manga
                    BEGIN
                      UPDATE manga SET refreshed = datetime('now', 'localtime')
                      WHERE rowid = new.rowid;
                    END
              """);
      await txn.execute("""
                  CREATE TRIGGER INSERT_manga AFTER INSERT ON manga
                    BEGIN
                      UPDATE manga SET refreshed = datetime('now', 'locative')
                      WHERE rowid = new.rowid;
                    END
              """);

      // ### CHAPTER ###
      await txn.execute("""
                  CREATE TABLE chapter (
                    id INTEGER PRIMARY KEY,
                    manga_id INTEGER NOT NULL,
                    title TEXT NOT NULL,
                    url VARCHAR(255) UNIQUE NOT NULL,
                    progress DOUBLE NOT NULL DEFAULT 0,
                    number DOUBLE NOT NULL,
                    posted DATETIME,
                    FOREIGN KEY (manga_id)
                      REFERENCES manga (id)
                        ON UPDATE CASCADE
                        ON DELETE CASCADE);
              """);
    });

class DatabaseUtil {
  static DatabaseUtil? _instance;
  static String dbPath = '';
  static DatabaseUtil get instance {
    if (_instance == null) {
      return _instance = DatabaseUtil(dbPath);
    } else {
      return _instance!;
    }
  }

  final Future<Database> database;

  DatabaseUtil(databasePath)
      : database = openDatabase(
            // Set the path to the database. Note: Using the `join` function from the
            // `path` package is best practice to ensure the path is correctly
            // constructed for each platform.
            join(databasePath, 'manga.db'),
            // Enable foreign key constraints
            onConfigure: (db) => db.execute("PRAGMA foreign_keys = ON"),
            // Set the version. This executes the onCreate function and provides a
            // path to perform database upgrades and downgrades.
            version: 1,
            onUpgrade: (db, oldVersion, newVersion) => db.transaction((txn) async {
                  await txn.execute("DROP TABLE manga");
                  await txn.execute("DROP TABLE chapter");
                  await onCreate(db, newVersion);
                }),
            onCreate: onCreate);

  // Define a function that inserts manga into the database
  Future<DBManga> insertManga(Manga manga) async {
    final db = await database;
    final mangaMap = manga.toJson();
    mangaMap.remove('chapters');

    final oldManga = manga is DBManga ? manga : await getManga(manga.url);

    if (oldManga != null) {
      mangaMap['id'] = oldManga.id;
      mangaMap['progress'] = oldManga.progress;
      mangaMap['deleted'] = oldManga.deleted ? 1 : 0;
      mangaMap['auto_refresh'] = oldManga.autoRefresh ? 1 : 0;
    }

    final int mangaId = await db.insert(
      'manga',
      mangaMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    print('owo $mangaId');
    print('owo ${mangaId.runtimeType}');

    final batch = db.batch();
    for (final chapter in manga.chapters) {
      batch.insert('chapter', {...chapter.toJson(), 'manga_id': mangaId}, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit();

    return (await getManga(mangaId))!;
  }

  Future<DBManga?> getManga(dynamic urlOrId) async {
    if (urlOrId == null) return null;

    final db = await database;

    final where = (urlOrId is String || urlOrId is Uri)
        ? "manga.url = ?"
        : urlOrId is int
            ? "manga.id = ?"
            : throw 'Bad type "${urlOrId.runtimeType}"';

    final mangaRow = (await db.rawQuery(
            'SELECT manga.*, COUNT(chapter.manga_id) AS chapter_count FROM manga INNER JOIN chapter ON chapter.manga_id = manga.id WHERE $where GROUP BY manga.id LIMIT ?',
            [urlOrId.toString(), 1]))
        .firstOrNull;

    if (mangaRow != null) {
      final manga = DBManga.fromJson(mangaRow);
      manga.avgNextChapter = await getAverageTimeForNextChapter(manga.id);

      return manga;
    } else if (urlOrId is String || urlOrId is Uri) {
      // TODO: Add Manga?
      return null;
    } else {
      return null;
    }
  }

  Future<List<DBManga>> getAllManga({int limit = 20, int offset = 0, String orderBy = "title ASC"}) async {
    final db = await database;

    final mangaList = await db.rawQuery(
        'SELECT manga.*, COUNT(chapter.manga_id) AS chapter_count FROM manga INNER JOIN chapter ON chapter.manga_id = manga.id WHERE manga.deleted = 0 GROUP BY manga.id ORDER BY $orderBy LIMIT ?, ?',
        [offset, limit]);
    return Future.wait(mangaList.map((manga) async {
      final dbManga = DBManga.fromJson(manga);
      dbManga.avgNextChapter = await getAverageTimeForNextChapter(dbManga.id);
      return dbManga;
    }).toList());
  }

  Future<List<DBChapter>> getChapters(int mangaId, {int limit = 20, int offset = 0}) async {
    final db = await database;

    final chapterList = await db.query('chapter', where: 'manga_id = ?', whereArgs: [mangaId], limit: limit, offset: offset);
    return chapterList.map((chapter) => DBChapter.fromJson(chapter)).toList();
  }

  Future<DBChapter> getChapter(int mangaId, int progress) async {
    final db = await database;

    final chapterList = await db.query('chapter', where: 'manga_id = ?', whereArgs: [mangaId], limit: 1, offset: progress);
    return chapterList.map((chapter) => DBChapter.fromJson(chapter)).first;
  }

  Future<int> getTotalChapters() async {
    final db = await database;
    return (await db.query('chapter', columns: const ['COUNT(*) AS total_chapters'])).firstOrNull?['total_chapters'] as int? ?? 0;
  }

  Future<int> getTotalChaptersRead() async {
    final db = await database;
    return (await db.query('manga', columns: const ['SUM(progress) AS total_read'])).firstOrNull?['total_read'] as int? ?? 0;
  }

  Future<int> getTotalManga() async {
    final db = await database;
    // not sure if deleted should be included [where: 'manga.deleted = 0']
    return (await db.query('manga', columns: const ['COUNT(*) AS total_manga'])).firstOrNull?['total_manga'] as int? ?? 0;
  }

  Future<int> getTotalMangaNoProgress() async {
    final db = await database;
    // not sure if deleted should be included [where: 'manga.deleted = 0']
    return (await db.query('manga', columns: const ['COUNT(*) AS total_manga'], where: "manga.progress = 0"))
            .firstOrNull?['total_manga'] as int? ??
        0;
  }

  Future<int> getTotalMangaCompleted() async {
    final db = await database;
    // not sure if deleted should be included [where: 'manga.deleted = 0']
    final row = (await db.query('manga',
        columns: const ['progress', 'id', 'COUNT(id) AS total_completed'],
        where: "manga.progress = (SELECT COUNT(*) AS chapters FROM chapter WHERE chapter.manga_id = manga.id)"))[0];
    return row['total_completed'] as int? ?? 0;
  }

  Future<String?> getAverageTimeForNextChapter(int mangaId) async {
    final db = await database;

    final postedList = await db.query('chapter', columns: ['posted'], where: 'manga_id = ?', whereArgs: [mangaId]);
    const converter = CustomJiffyNullConverter();
    final postedJiffyList = postedList.map((postedString) => converter.fromJson(postedString['posted'] as String)).toList();
    final avgDiff = avgDifference(postedJiffyList);
    return relativeDiff(avgDiff);
  }

  Future<bool> setProgress(DBManga manga, int progress) async {
    final db = await database;
    manga.progress = progress;

    // 1 row changed
    final changes = await db.update("manga", {"progress": progress}, where: "id == ?", whereArgs: [manga.id]);
    return changes == 1;
  }

  bool shouldUpdate(DBManga manga) {
    return manga.autoRefresh && Jiffy().diff(manga.refreshed) >= const Duration(hours: 1).inMilliseconds;
  }

  Future<DBManga> update(DBManga manga) async {
    return insertManga(await scraper.manga(manga.url));
  }

  Future<bool> updateChapter(DBChapter chapter) async {
    final db = await database;

    // 1 row changed
    final changes = await db.update('chapter', chapter.toJson(),
        where: "id = ?", whereArgs: [chapter.id], conflictAlgorithm: ConflictAlgorithm.replace);
    return changes == 1;
  }

  Future<bool> deleteManga(int id) async {
    // TODO remove all chapters to save space
    // TODO set the deleted flag to true

    final db = await database;

    // final deleted =
    //     await db.update('manga', {'deleted': 1}, where: "id = ?", whereArgs: [id], conflictAlgorithm: ConflictAlgorithm.replace);

    //     if (deleted == 1) {
    //       // remove all chapters

    //     }
    final deleted = await db.delete('manga', where: 'id = ?', whereArgs: [id]);
    return deleted == 1;
  }
}
