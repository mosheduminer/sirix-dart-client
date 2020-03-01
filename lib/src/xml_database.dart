import 'dart:io';

import 'package:sirix/sirix.dart';

class XmlDatabase {
  XmlDatabase(this.name, this._httpClient, this.auth, this.sirixUri, this.databasesInfo);
  final String name;
  final HttpClient _httpClient;
  Auth auth;
  Uri sirixUri;
  List<DatabaseInfo> databasesInfo;
}