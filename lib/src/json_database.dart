import './client.dart';

import './data_classes.dart';
import './json_resource.dart';

class JsonDatabase {
  JsonDatabase(this.name, this.databasesInfo, this._client);
  final String name;
  final Client _client;
  List<DatabaseInfo> databasesInfo;
  final DBType dbType = DBType.JSON;

  Future<bool> create() async {
    return await _client.createDatabase(name, dbType);
  }

  Future<bool> getInfo() async {
    var jsonData = await _client.getDatabaseInfo(name);
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

  JsonResource resource(String name) {
    return JsonResource(name, this.name, databasesInfo, _client);
  }

  Future<bool> deleteDatabase() async {
    var statusCode = await _client.deleteDatabase(name);
    if (statusCode != 204) {
      return false;
    } else {
      return true;
    }
  }
}
