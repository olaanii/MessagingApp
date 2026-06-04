import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

File createPlatformFile(String path) => File(path);

Future<QueryExecutor> openNativeOrWebDatabase({
  required Future<QueryExecutor> Function() nativeDbBuilder,
}) async {
  return nativeDbBuilder();
}

Future<QueryExecutor> buildNativeDatabase() async {
  if (Platform.isAndroid) {
    await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
  }
  final dir = await getApplicationDocumentsDirectory();
  final file = File(p.join(dir.path, 'chat_local.db'));
  return NativeDatabase.createInBackground(file);
}
