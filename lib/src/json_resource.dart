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
    return await _client.resourceExists(dbName, dbType, name);
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

  Future<dynamic> read(
      {bool withMetadata,
      int maxLevel,
      int nodeId,
      int revision,
      int startRevision,
      int endRevision,
      DateTime revisionTimestamp,
      DateTime startRevisionTimestamp,
      DateTime endRevisionTimestamp}) async {
    var params = {
      'withMetadata': withMetadata?.toString(),
      'maxLevel': maxLevel?.toString(),
      'nodeId': nodeId?.toString(),
      'revision': revision?.toString(),
      'startRevision': startRevision?.toString(),
      'endRevision': endRevision?.toString(),
      'revisionTimestamp': revisionTimestamp?.toIso8601String(),
      'startRevisionTimestamp': startRevisionTimestamp?.toIso8601String(),
      'endRevisionTimestamp': endRevisionTimestamp?.toIso8601String()
    };
    params.removeWhere((key, value) => value == null);
    print(jsonEncode(params));
    var content =
        await _client.readResource(dbName, dbType, name, params: params);
    var data = await content?.toList();
    return await data?.join();
  }

  Future<Stream<String>> readAsStream(
      {bool withMetadata,
      int maxLevel,
      int nodeId,
      int revision,
      int startRevision,
      int endRevision,
      DateTime revisionTimestamp,
      DateTime startRevisionTimestamp,
      DateTime endRevisionTimestamp}) {
    var params = {
      'withMetadata': withMetadata?.toString(),
      'maxLevel': maxLevel?.toString(),
      'nodeId': nodeId?.toString(),
      'revision': revision?.toString(),
      'start-revision': startRevision?.toString(),
      'end-revision': endRevision?.toString(),
      'revision-timestamp': revisionTimestamp?.toIso8601String(),
      'start-revision-timestamp': startRevisionTimestamp?.toIso8601String(),
      'end-revision-timestamp': endRevisionTimestamp?.toIso8601String()
    };
    params.removeWhere((key, value) => value == null);
    return _client.readResource(dbName, dbType, name, params: params);
  }

  Future<bool> deleteResource() {
    return _client.resourceDelete(dbName, dbType, name);
  }
}
