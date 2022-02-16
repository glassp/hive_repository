import 'package:database_repository/database_repository.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';

import '../deps.dart';

/// A DatabaseAdapter that integrates with hive
class HiveDatabaseAdapter extends DatabaseAdapter with QueryExecutor {
  @override
  final String name;

  /// The path that should be used for hive
  final String path;

  /// A mapping of Class Name to Hive Boxes
  final Map<String, LazyBox<JSON>> _hiveBoxes = {};

  /// If Hive has already been initialized
  bool _isInititalized = false;

  /// Create a DatabaseAdapter that uses hive
  HiveDatabaseAdapter({this.name = 'hive', required this.path});

  @override
  Future<QueryResult> executeQuery(Query query) async {
    if (_isInititalized) {
      await init();
      _isInititalized = true;
    }

    await _openBox(query);
    final box = _hiveBoxes[query.entityName]!;
    return await _executeQueryOnBox(query, box);
  }

  /// initialized hive if not already initialized and opens a box for the given
  /// class
  Future<void> _openBox(Query query) async {
    if (!_isInititalized) {
      await init();
      _isInititalized = true;
    }
    if (!_hiveBoxes.containsKey(query.entityName) ||
        (_hiveBoxes[query.entityName] != null &&
            !_hiveBoxes[query.entityName]!.isOpen)) {
      final box = await Hive.openLazyBox<JSON>(query.entityName);
      _hiveBoxes.update(query.entityName, (_) => box, ifAbsent: () => box);
    }
  }

  /// Executes the correct Action on the Hive box depending on the [QueryAction]
  Future<QueryResult> _executeQueryOnBox(Query query, LazyBox<JSON> box) async {
    switch (query.action) {
      case QueryAction.create:
        return create(query, box);
      case QueryAction.update:
        return update(query, box);
      case QueryAction.delete:
        return delete(query, box);
      case QueryAction.read:
        return read(query, box);
    }
  }

  /// initialize the Hive package.
  /// Can be overriden to support flutter
  @visibleForOverriding
  Future<void> init() async => Hive.init(path);

  /// destroys all hive boxes that were opened by this adapter
  /// Should only be used by the benchmark tool to cleanup.
  @internal
  Future<void> selfDestruct() async {
    for (final box in _hiveBoxes.values) {
      await box.deleteFromDisk();
    }
  }
}
