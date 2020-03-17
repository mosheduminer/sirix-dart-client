import './base_database.dart';
import './xml_resource.dart';
import './data_classes.dart';

class XmlDatabase extends BaseDatabase {
  XmlDatabase(name, databasesInfo, _client)
      : super(name, databasesInfo, _client);
  @override
  DBType dbType = DBType.XML;

  XmlResource resource(String name) {
    return XmlResource(name, this.name, databasesInfo, client);
  }
}
