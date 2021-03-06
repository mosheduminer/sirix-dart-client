import './data_classes.dart';
import './base_resource.dart';

class JsonResource extends BaseResource {
  JsonResource(name, dbName, databasesInfo, client)
      : super(name, dbName, databasesInfo, client);
  @override
  DBType dbType = DBType.JSON;
}
