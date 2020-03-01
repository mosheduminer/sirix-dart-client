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

  Future<bool> resourceExists(String dbName, String name) async {
    //TODO: do we need dbType here as well?
    var request =
        await _httpClient.headUrl(sirixUri.replace(path: '$dbName/$name'));
    request.headers
        .add('Authorization', 'Bearer ${_auth.tokenData.access_token}');
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
      String dbName, DBType dbType, String name, String data) async {
    var request =
        await _httpClient.postUrl(sirixUri.replace(path: '$dbName/$name'));
    request.headers
      ..add('Authorization', 'Bearer ${_auth.tokenData.access_token}')
      ..add('Content-Type', dbType.mime);
    var response = await request.close();
    var content = await response.transform(utf8.decoder);
    var data = await content.toList();
    if (response.statusCode != 200) {
      print(data.join());
      return null;
    }
    return data.join();
  }

  /// this function intentionally does not unwrap the stream of data before
  /// returning. instead, the stream itself is returned. This is so it is
  /// possible to make process the stream as it comes in, rather than waiting
  /// for a potentially long stream of data to finish. For this reason, the
  /// consumers of this method should also provide an optional raw stream
  /// implementation.
  Future<Stream<String>> readResource(String dbName, DBType dbType, String name,
      {Map<String, String> params}) async {
    //TODO implement params
    var request =
        await _httpClient.getUrl(sirixUri.replace(path: '$dbName/$name'));
    request.headers
      ..add('Authorization', 'Bearer ${_auth.tokenData.access_token}')
      ..add('Content-Type', dbType.mime);
    var response = await request.close();
    return await response.transform(utf8.decoder);
  }
}
