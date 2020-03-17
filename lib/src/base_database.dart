import './client.dart';

import './data_classes.dart';


class BaseDatabase {
  BaseDatabase(this.name, this.databasesInfo, this.client);
  final String name;
  final Client client;
  List<DatabaseInfo> databasesInfo;
  DBType dbType;

  Future<bool> create() async {
    return await client.createDatabase(name, dbType);
  }

  Future<bool> getInfo() async {
    var jsonData = await client.getDatabaseInfo(name);
    try {
      var db = databasesInfo.where((db) {
        return db.name == name;
      }).toList();
      if (db.isEmpty) {
        var dbInfo = DatabaseInfo.fromJson({
          'name': name,
          'type': dbType.value,
          'resources': jsonData['resources']
        });
        databasesInfo.add(dbInfo);
      } else {
        db[0].resources = jsonData['resources'];
      }
    } catch (e) {
      print(e);
      return false;
    }
    return true;
  }

  Future<bool> deleteDatabase() async {
    var statusCode = await client.deleteDatabase(name);
    if (statusCode != 204) {
      return false;
    } else {
      return true;
    }
  }
}