import 'package:sirix/sirix.dart';

import 'dart:io';

void main() async {
  var sirixUri = 'https://localhost:9443';
  var login = Login('admin', 'admin');
  var client = HttpClient(
      context: SecurityContext()
        ..setTrustedCertificates('C:/Users/moshe/sirix-data/cert.pem'));
  var auth = Auth(sirixUri, login, client);
  var status = await auth.authenticate();
  if (!status) {
    print('failed to authenticate!');
    exit(1);
  }
  var sirix = Sirix(sirixUri, auth);
  //status = await sirix.getInfo();
  //if (!status) {
  //  print('failed to retrieve info!');
  //}
  //for (var db in sirix.databasesInfo) {
  //  print(db.name);
  //}
  var db = sirix.jsonDatabase('First');
  print(await db.getInfo());
  client.close();
}
