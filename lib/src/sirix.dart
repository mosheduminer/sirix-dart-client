import './json_database.dart';
import './data_classes.dart';
import './auth.dart';
import './client.dart';

class Sirix {
  Sirix(String sirixUri, Auth auth) {
    this.sirixUri = Uri.parse(sirixUri);
    _client = Client(auth, this.sirixUri);
  }
  Client _client;
  Uri sirixUri;
  List<DatabaseInfo> databasesInfo = [];

  JsonDatabase jsonDatabase(String name) {
    return JsonDatabase(name, databasesInfo, _client);
  }

  Future<bool> getInfo() async {
    var jsonData = await _client.getGlobalInfo();
    try {
      databasesInfo = (jsonData['databases'] as List).map((db) {
        return DatabaseInfo.fromJson(db as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print(e);
      return false;
    }
    return true;
  }

  Future<bool> deleteEverything() async {
    return await _client.deleteAllDatabases();
  }
}
