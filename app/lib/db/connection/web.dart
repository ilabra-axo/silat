import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

QueryExecutor openConnection() => driftDatabase(
      name: 'silat',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.dart.js'),
      ),
    );
