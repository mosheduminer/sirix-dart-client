import './data_classes.dart';
import './base_resource.dart';

class XmlResource extends BaseResource {
  XmlResource(name, dbName, databasesInfo, client)
      : super(name, dbName, databasesInfo, client);
  @override
  DBType dbType = DBType.XML;
}
