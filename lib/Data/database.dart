import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class Contact {
  Contact({this.id, this.name, this.phone, this.email});
  int? id;
  String? name;
  int? phone;
  String? email;

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'phone': phone, 'email': email};
  }
}

class SqlStorage {
  Future<Database> database() async {
    Future<Database> database =
        openDatabase(path.join(await getDatabasesPath(), 'contact.db'),
            onCreate: (db, version) {
      db.execute(
          'CREATE TABLE contacts(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, phone INTEGER, email TEXT)');
    }, version: 1);
    return database;
  }

  Future<void> insert(Contact contact) async {
    Database db = await database();
    await db.insert('contacts', contact.toMap());
  }

  Future<List<Contact>> getdata() async {
    final Database db = await database();
    final List<Map<String, dynamic>> cont =
        await db.query('contacts', orderBy: 'name');
    return List.generate(cont.length, (i) {
      return Contact(
          id: cont[i]['id'],
          name: cont[i]['name'],
          phone: cont[i]['phone'],
          email: cont[i]['email']);
    });
  }

  Future<void> update(Contact contact) async {
    Database db = await database();
    await db.update(
      'contacts',
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  Future<void> delete(int id) async {
    final Database db = await database();
    await db.delete(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
