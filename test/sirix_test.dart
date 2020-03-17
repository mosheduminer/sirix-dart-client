import 'package:sirix/sirix.dart';
import 'package:test/test.dart';

import 'dart:io';

// need these for all tests, and are static, so here globally
var sirixUri = 'https://localhost:9444';
var login = Login('admin', 'admin');
var certificatePath = './test_resources/cert.pem';

void main() {
  group('Auth class', () {
    HttpClient client;
    Auth auth;

    setUp(() {
      client = HttpClient(
          context: SecurityContext()..setTrustedCertificates(certificatePath));
      auth = Auth(sirixUri, login, client);
    });

    test('Authentication', () async {
      var status = await auth.authenticate();
      expect(auth.tokenData.access_token, isA<String>());
      expect(auth.tokenData.refresh_token, isA<String>());
      expect(auth.tokenData.expires_in, isA<int>());
      expect(status, isTrue);
    });
    test('refresh_token', () async {
      // setup
      await auth.authenticate();

      var oldToken = auth.tokenData.access_token;
      var refreshToken = auth.tokenData.refresh_token;
      var status = await auth.refresh();
      expect(auth.tokenData.access_token, isNot(oldToken));
      expect(auth.tokenData.refresh_token, isNot(refreshToken));
      expect(status, isTrue);
    });

    tearDown(() {
      client.close();
    });
  });

  group('sirix base client', () {
    HttpClient client;
    Auth auth;
    Sirix sirix;

    setUp(() async {
      client = HttpClient(
          context: SecurityContext()..setTrustedCertificates(certificatePath));
      auth = Auth(sirixUri, login, client);
      sirix = Sirix(sirixUri, auth);
      await auth.authenticate();
    });

    test('get databases info', () async {
      var status = await sirix.getInfo();
      expect(status, isTrue);
    });
    tearDown(() {
      client.close();
    });
  });

  group('JsonDatabase class', () {
    HttpClient client;
    Auth auth;
    Sirix sirix;
    JsonDatabase database;

    setUp(() async {
      client = HttpClient(
          context: SecurityContext()..setTrustedCertificates(certificatePath));
      auth = Auth(sirixUri, login, client);
      sirix = Sirix(sirixUri, auth);
      await auth.authenticate();
      database = sirix.jsonDatabase('First');
    });

    test('create', () async {
      var status = await database.create();
      expect(status, isTrue);
    });

    test('get_info', () async {
      var status = await database.getInfo();
      expect(status, isTrue);
    });

    test('create was successful', () async {
      await database.getInfo();
      var db = database.databasesInfo.firstWhere((db) {
        return db.name == 'First';
      });
      expect(db, isNotNull);
    });

    test('get JsonResource instance', () {
      var db = database.resource('test on First');
      expect(db, isA<JsonResource>());
    });

    test('delete database', () async {
      var status = await database.deleteDatabase();
      expect(status, isTrue);
    });

    tearDown(() {
      client.close();
    });
  });

  group('JsonResource class', () {
    HttpClient client;
    Auth auth;
    Sirix sirix;
    JsonDatabase jsonDatabase;
    JsonResource jsonResource;

    setUp(() async {
      client = HttpClient(
          context: SecurityContext()..setTrustedCertificates(certificatePath));
      auth = Auth(sirixUri, login, client);
      sirix = Sirix(sirixUri, auth);
      await auth.authenticate();
      jsonDatabase = sirix.jsonDatabase('First');
      jsonResource = jsonDatabase.resource('testJsonResource');
    });

    test('exists method', () async {
      var exists = await jsonResource.exists();
      expect(exists, isFalse);
    });

    test('create method', () async {
      var data = await jsonResource.create('[]');
      expect(data, equals('[]'));
      expect(await jsonResource.exists(), isTrue);
    });

    test('delete method on nonexistent resource', () async {
      var dummyJsonResource = jsonDatabase.resource('dummy');
      var status = await dummyJsonResource.delete();
      expect(status, isFalse);
    });

    test('delete method on existing resource', () async {
      await jsonResource.create('[]');
      var status = await jsonResource.delete();
      expect(status, isTrue);
    });

    test('read resource', () async {
      await jsonResource.create('[]');
      var data = await jsonResource.read();
      expect(data, equals('[]'));
    });

    test('read resource as stream', () async {
      await jsonResource.create('[]');
      var stream = await jsonResource.readAsStream();
      expect(stream, emits('[]'));
    });

    test('get etag', () async {
      await jsonResource.create('[]');
      var etag = await jsonResource.getEtag(1);
      expect(etag, isA<String>());
    });

    test('get etag for nonexistent node', () async {
      await jsonResource.create('[]');
      var etag = await jsonResource.getEtag(2);
      expect(etag, isNull);
    });

    test('delete by etag', () async {
      await jsonResource.create('[{}]');
      var etag = await jsonResource.getEtag(2);
      var status = await jsonResource.delete(nodeId: 2, etag: etag);
      expect(status, isTrue);
      var node = await jsonResource.read(nodeId: 2);
      expect(node, isNull);
      expect(await jsonResource.read(), equals('[]'));
    });

    test('delete by nodeId', () async {
      await jsonResource.create('[{}]');
      var status = await jsonResource.delete(nodeId: 2);
      expect(status, isTrue);
      var node = await jsonResource.read(nodeId: 2);
      expect(node, isNull);
      expect(await jsonResource.read(), equals('[]'));
    });

    test('update by etag', () async {
      await jsonResource.create('[]');
      var etag = await jsonResource.getEtag(1);
      var status = await jsonResource.update(1, '{}', Insert.Right, etag: etag);
      expect(status, isTrue);
    });

    test('update by nodeId', () async {
      await jsonResource.create('[]');
      var status = await jsonResource.update(1, '{}', Insert.Right);
      expect(status, isTrue);
    });

    test('update non-existent node', () async {
      await jsonResource.create('[]');
      var status = await jsonResource.update(5, '{}', Insert.Right);
      expect(status, isFalse);
    });

    tearDown(() {
      sirix.deleteEverything();
      client.close();
    });
  });
}
