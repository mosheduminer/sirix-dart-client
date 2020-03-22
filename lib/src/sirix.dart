import './xml_database.dart';
import './json_database.dart';
import './data_classes.dart';
import './auth.dart';
import './client.dart';

import 'dart:convert';

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

  XmlDatabase xmlDatabase(String name) {
    return XmlDatabase(name, databasesInfo, _client);
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

  Future<String> query(String query,
      {int startResultSeqIndex, int endResultSeqIndex}) async {
    var queryObj = {
      'query': query,
      'startResultSeqIndex': startResultSeqIndex,
      'endResultSeqIndex': endResultSeqIndex
    };
    queryObj.removeWhere((key, value) => value == null);
    var stream = await _client.postQuery(jsonEncode(queryObj));
    var data = await stream?.toList();
    return data?.join();
  }

  Future<Stream<String>> queryAsStream(String query,
      {int startResultSeqIndex, int endResultSeqIndex}) {
    var queryObj = {
      'query': query,
      'startResultSeqIndex': startResultSeqIndex,
      'endResultSeqIndex': endResultSeqIndex
    };
    queryObj.removeWhere((key, value) => value == null);
    return _client.postQuery(jsonEncode(queryObj));
  }

  Future<bool> deleteEverything() async {
    return await _client.deleteAllDatabases();
  }
}
