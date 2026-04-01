import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

// Stub for dart:io File — not used on web.
class File {
  File(String path);
}

File createPlatformFile(String path) => File(path);

Future<QueryExecutor> openNativeOrWebDatabase({
  required Future<QueryExecutor> Function() nativeDbBuilder,
}) async {
  // Web uses WASM-based sqlite3 via drift's wasm executor.
  final result = await WasmDatabase.open(
    databaseName: 'chat_local',
    sqlite3Uri: Uri.parse('sqlite3.wasm'),
    driftWorkerUri: Uri.parse('drift_worker.dart.js'),
  );
  
  return result.resolvedExecutor;
}
