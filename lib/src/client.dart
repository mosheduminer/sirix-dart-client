import 'dart:io';
import 'dart:convert';
import 'package:pedantic/pedantic.dart';

import './auth.dart';
import './data_classes.dart';

class Client {
  Client(this._auth, this.sirixUri) : _httpClient = _auth.httpClient;
  Uri sirixUri;
  final HttpClient _httpClient;
  final Auth _auth;

  /// methods for the Sirix class
  Future<Map> getGlobalInfo({resources = true}) async {
    var request = await _httpClient
        .getUrl(sirixUri.replace(queryParameters: {'withResources': 'true'}));
    request.headers
        .add('authorization', 'Bearer ${_auth.tokenData.access_token}');
    var response = await request.close();
    var content = await response.transform(utf8.decoder);
    var data = await content.toList();
    var stringData = data.join();
    if (response.statusCode != 200) {
      print(stringData);
      return null;
    }
    return jsonDecode(stringData) as Map;
  }

  Future<bool> deleteAllDatabases() async {
    var request = await _httpClient.deleteUrl(sirixUri);
    request.headers
        .add('authorization', 'Bearer ${_auth.tokenData.access_token}');
    var response = await request.close();
    var content = await response.transform(utf8.decoder);
    var data = await content.toList();
    var stringData = data.join();
    if (response.statusCode == 204) {
      return true;
    } else {
      print(stringData);
      return false;
    }
  }

  /// methods for database classes
  Future<bool> createDatabase(String name, DBType dbType) async {
    var request = await _httpClient.putUrl(sirixUri.replace(path: name));
    request.headers
      ..add('Authorization', 'Bearer ${_auth.tokenData.access_token}')
      ..add('Content-Type', dbType.mime);
    var response = await request.close();
    var content = await response.transform(utf8.decoder);
    if (response.statusCode != 201) {
      var data = await content.toList();
      var stringData = data.join();
      print(stringData);
      return false;
    }
    unawaited(content.drain());
    return true;
  }

  Future<Map<String, dynamic>> getDatabaseInfo(String name) async {
    var request = await _httpClient.getUrl(sirixUri
        .replace(path: name, queryParameters: {'withResources': 'true'}));
    request.headers
      ..add('Authorization', 'Bearer ${_auth.tokenData.access_token}')
      ..add('Accept', 'application/json');
    var response = await request.close();
    var content = await response.transform(utf8.decoder);
    var data = await content.toList();
    var stringData = data.join();
    if (response.statusCode != 200) {
      print(stringData);
      return null;
    }
    return jsonDecode(stringData) as Map<String, dynamic>;
  }

  Future<int> deleteDatabase(String name) async {
    var request = await _httpClient.deleteUrl(sirixUri.replace(path: name));
    request.headers
        .add('Authorization', 'Bearer ${_auth.tokenData.access_token}');
    var response = await request.close();
    await response.drain();
    return response.statusCode;
  }

  Future<bool> resourceExists(String dbName, DBType dbType, String name) async {
    var request =
        await _httpClient.headUrl(sirixUri.replace(path: '$dbName/$name'));
    request.headers
      ..add('Authorization', 'Bearer ${_auth.tokenData.access_token}')
      ..add('Accept', dbType.mime);
    var response = await request.close();
    // we only need the status code
    unawaited(response.drain());
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<String> createResource(
      String dbName, DBType dbType, String name, String creationData) async {
    var request =
        await _httpClient.putUrl(sirixUri.replace(path: '$dbName/$name'));
    request.headers
      ..add('Authorization', 'Bearer ${_auth.tokenData.access_token}')
      ..add('Content-Type', dbType.mime);
    request.write(creationData);
    var response = await request.close();
    var content = await response.transform(utf8.decoder);
    var data = await content.toList();
    if (response.statusCode != 200) {
      print(data.join());
      return null;
    }
    return data.join();
  }

  /// the following two functions intentionally do not unwrap the stream of data before
  /// returning. instead, the stream itself is returned. This is so it is
  /// possible to make process the stream as it comes in, rather than waiting
  /// for a potentially long stream of data to finish. For this reason, the
  /// consumers of this method should also provide an optional raw stream
  /// implementation.
  Future<Stream<String>> readResource(String dbName, DBType dbType, String name,
      {Map<String, dynamic> params}) async {
    var request = await _httpClient.getUrl(
        sirixUri.replace(path: '$dbName/$name', queryParameters: params));
    request.headers
      ..add('Authorization', 'Bearer ${_auth.tokenData.access_token}')
      ..add('Accept', dbType.mime);
    var response = await request.close();
    if (response.statusCode != 200) {
      var content = await response.transform(utf8.decoder).toList();
      print(content.join());
      return null;
    }
    return await response.transform(utf8.decoder);
  }

  Future<Stream<String>> postQuery(String query) async {
    var request = await _httpClient.postUrl(sirixUri);
    request.headers
      ..add('authorization', 'Bearer ${_auth.tokenData.access_token}');
    request.write(query);
    var response = await request.close();
    var content = await response.transform(utf8.decoder);
    if (response.statusCode != 200) {
      var data = await content.toList();
      print(data.join());
      return null;
    }
    return content;
  }

  Future<String> getEtag(String dbName, DBType dbType, String name,
      {Map<String, String> params}) async {
    var request = await _httpClient.headUrl(
        sirixUri.replace(path: '$dbName/$name', queryParameters: params));
    request.headers
      ..add('Authorization', 'Bearer ${_auth.tokenData.access_token}')
      ..add('Accept', dbType.mime);
    var response = await request.close();
    if (response.statusCode != 200) {
      var error = await response.transform(utf8.decoder).toList();
      print(error.join());
      return null;
    }
    unawaited(response.drain());
    return response.headers.value('etag');
  }

  Future<bool> update(String dbName, DBType dbType, String name, int nodeId,
      String data, String insert, String etag) async {
    var request = await _httpClient.postUrl(sirixUri.replace(
        path: '$dbName/$name',
        queryParameters: {'nodeId': nodeId.toString(), 'insert': insert}));
    request.headers
      ..add('ETag', etag)
      ..add('Authorization', 'Bearer ${_auth.tokenData.access_token}')
      ..add('Content-Type', dbType.mime);
    request.write(data);
    var response = await request.close();
    if (response.statusCode != 200) {
      var error = await response.transform(utf8.decoder).toList();
      print(error.join());
      print(response.statusCode);
      return false;
    }
    unawaited(response.drain());
    return true;
  }

  Future<bool> resourceDelete(String dbName, DBType dbType, String name,
      int nodeId, String etag) async {
    var request = await _httpClient.deleteUrl(sirixUri.replace(
        path: '$dbName/$name', query: nodeId == null ? '' : 'nodeId=$nodeId'));
    request.headers
      ..add('Authorization', 'Bearer ${_auth.tokenData.access_token}')
      ..add('Content-Type', dbType.mime);
    if (etag != null) {
      request.headers.add('ETag', etag);
    }
    var response = await request.close();
    if (response.statusCode != 204) {
      var error = await response.transform(utf8.decoder).toList();
      print(error.join());
      print(response.statusCode);
      return false;
    }
    unawaited(response.drain());
    return true;
  }
}
