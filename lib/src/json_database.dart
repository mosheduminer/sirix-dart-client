import './base_database.dart';
import './json_resource.dart';

import './data_classes.dart';

class JsonDatabase extends BaseDatabase {
  JsonDatabase(name, databasesInfo, _client)
      : super(name, databasesInfo, _client);
  @override
  DBType dbType = DBType.JSON;

  JsonResource resource(String name) {
    return JsonResource(name, this.name, databasesInfo, client);
  }
}
