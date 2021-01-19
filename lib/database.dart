import 'package:sqflite/sqflite.dart';
import 'package:sqflite/utils/utils.dart' as utils;


Future<bool> tableExists(DatabaseExecutor db, String table) async {
  var count = utils.firstIntValue(await db.query('sqlite_master',
      columns: ['COUNT(*)'],
      where: 'type = ? AND name = ?',
      whereArgs: ['table', table]));
  if (count > 0) {
    return true;
  }
  return false;
}

Future<Null> createPostTable(DatabaseExecutor db) async {
  await db.execute('DROP TABLE IF EXISTS Post;');
  await db.execute('''CREATE TABLE Post (
    id UUID PRIMARY KEY,
    upvote_count INTEGER,
    downvote_count INTEGER,
    favourite_count INTEGER,
    file TEXT,
    owner INTEGER,
    shared_at TEXT,
    last_modified TEXT
);''');
}

Future<Null> createFavPostTable(DatabaseExecutor db) async {
  await db.execute('DROP TABLE IF EXISTS FavPost;');
  await db.execute('''CREATE TABLE FavPost (
    id UUID PRIMARY KEY,
    upvote_count INTEGER,
    downvote_count INTEGER,
    favourite_count INTEGER,
    file TEXT,
    owner INTEGER,
    shared_at TEXT,
    last_modified TEXT
);''');
}

Future<dynamic> getTable(DatabaseExecutor db, String table) async {
  var list = await db.query(table, columns: ['id', 'name']);
  return list;
}


class LocalDatabase {
  final String path;
  LocalDatabase(this.path);
  Future<Database> _db;

  Future<Database> getDb() {
    _db ??= _initDb();
    return _db;
  }

  // Guaranteed to be called only once.
  Future<Database> _initDb() async {
    final db = await openDatabase(this.path);
    if (await tableExists(db, "Post") == false){
      await createPostTable(db);
    }
    if (await tableExists(db, "FavPost") == false){
      await createFavPostTable(db);
    }
    // do "tons of stuff in async mode"
    return db;
  }
}