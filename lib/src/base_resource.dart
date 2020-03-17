import './data_classes.dart';
import './client.dart';

class BaseResource {
  BaseResource(this.name, this.dbName, this.databasesInfo, this._client);
  List<DatabaseInfo> databasesInfo;
  final Client _client;
  final String name;
  final String dbName;
  DBType dbType;

  Future<bool> exists() {
    return _client.resourceExists(dbName, dbType, name);
  }

  Future<String> create(String data) {
    return _client.createResource(dbName, dbType, name, data);
  }

  Future<dynamic> update(int nodeId, String data, Insert insert,
      {String etag}) async {
    etag ??= await getEtag(nodeId);
    return await _client.update(
        dbName, dbType, name, nodeId, insert.value, etag);
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

  Future<String> getEtag(int nodeId,
      {int revision, DateTime revisionTimestamp}) {
    var params = {
      'nodeId': nodeId.toString(),
      'revision': revision?.toString(),
      'revision-timestamp': revisionTimestamp?.toIso8601String()
    };
    params.removeWhere((key, value) => value == null);
    return _client.getEtag(dbName, dbType, name, params: params);
  }

  Future<bool> delete({int nodeId, String etag}) async {
    etag ??= await getEtag(nodeId);
    return _client.resourceDelete(dbName, dbType, name, nodeId, etag);
  }
}
