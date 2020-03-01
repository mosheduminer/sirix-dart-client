class DatabaseInfo {
  String name;
  String type;
  List<String> resources;
  DatabaseInfo.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        type = json['type'],
        resources = (json['resources'] as List).map((i) {
          return i as String;
        }).toList();
}

class Login {
  Login(this.username, this.password);
  final String username;
  final String password;
  Map<String, String> toJson() => {'username': username, 'password': password};
}

class TokenData {
  String access_token;
  int expires_in;
  int refresh_expires_in;
  String refresh_token;
  String token_type;
  int not_before_policy;
  String session_state;
  String scope;
  TokenData.fromJson(Map<String, dynamic> json)
      : access_token = json['access_token'],
        expires_in = json['expires_in'],
        refresh_expires_in = json['refresh_expires_in'],
        refresh_token = json['refresh_token'],
        token_type = json['token_type'],
        not_before_policy = json['not_before_policy'],
        session_state = json['session_state'],
        scope = json['scope'];
}

enum DBType { XML, JSON }

extension DBTypeExtension on DBType {
  String get mime => types[this];
  static const types = {
    DBType.XML: 'application/xml',
    DBType.JSON: 'application/json',
  };
  String get value => values[this];
  static const values = {DBType.XML: 'xml', DBType.JSON: 'json'};
}

enum Insert { Child, Left, Right, Replace }

extension InsertExtension on Insert {
  String get value => values[this];
  static const values = {
    Insert.Child: 'asFirstChild',
    Insert.Left: 'asLeftSibling',
    Insert.Right: 'asRightSibling',
    Insert.Replace: 'replace',
  };
}
