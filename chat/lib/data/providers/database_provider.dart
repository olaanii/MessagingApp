import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../local/db/app_database.dart';

/// Opens one SQLite file per app process; disposed with the [ProviderScope].
///
/// Requirement 4.1: THE appDatabaseProvider SHALL create a single [AppDatabase]
/// instance and dispose it when the provider is torn down.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
