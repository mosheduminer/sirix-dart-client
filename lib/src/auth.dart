import 'dart:convert';
import 'dart:io';

import './data_classes.dart';

class Auth {
  Auth(sirixUri, this._login, this.httpClient) {
    _sirixUri = Uri.parse(sirixUri);
  }
  final Login _login;
  Uri _sirixUri;
  final HttpClient httpClient;
  TokenData tokenData;

  Future<bool> authenticate() async {
    return await _getToken(_login.toJson());
  }

  Future<bool> refresh() async {
    return await _getToken({'refresh_token': tokenData.refresh_token});
  }

  Future<bool> _getToken(Map<String, String> body) async {
    var request = await httpClient.postUrl(_sirixUri.replace(path: 'token'));
    request.write(jsonEncode(body));
    var response = await request.close();
    if (response.statusCode != 200) {
      return false;
    }
    return await _consume(response);
  }

  Future<bool> _consume(HttpClientResponse response) async {
    try {
      var contentStream = await response.transform(utf8.decoder);
      var data = await contentStream.toList();
      tokenData = TokenData.fromJson(jsonDecode(data.join()));
    } catch (e) {
      print(e);
      return false;
    }
    return true;
  }
}
