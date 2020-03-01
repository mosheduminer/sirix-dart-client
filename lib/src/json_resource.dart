import 'dart:convert';

import './data_classes.dart';
import './client.dart';

class JsonResource {
  JsonResource(this.name, this.dbName, this.databasesInfo, this._client);
  List<DatabaseInfo> databasesInfo;
  final Client _client;
  final String name;
  final String dbName;
  final DBType dbType = DBType.JSON;

  Future<bool> exists() async {
    return await _client.resourceExists(dbName, name);
  }

  Future<dynamic> create(String data) async {
    var response = await _client.createResource(dbName, dbType, name, data);
    if (response == null) {
      return response;
    }
    try {
      return jsonDecode(response);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<dynamic> update(int nodeId, String data, Insert insert) {
    ///TODO
    return null;
  }

  Future<dynamic> read() async {
    //TODO implement params
    var content = await _client.readResource(dbName, dbType, name);
    var data = await content.toList();
    return jsonDecode(await data.join());
  }

  Future<Stream<String>> readAsStream() {
    //TODO implement params
    return _client.readResource(dbName, dbType, name);
  }
}
