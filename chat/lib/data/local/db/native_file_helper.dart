import 'dart:io';

import 'package:drift/drift.dart';

File createPlatformFile(String path) => File(path);

Future<QueryExecutor> openNativeOrWebDatabase({
  required Future<QueryExecutor> Function() nativeDbBuilder,
}) async {
  return nativeDbBuilder();
}
