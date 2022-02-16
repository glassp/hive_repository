import 'package:database_repository/database_repository.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../deps.dart';

/// Mixin that contains the logic on how to execute the query on a hive box
mixin QueryExecutor {
  /// Tries to store queries payload in hive box
  Future<QueryResult> create(Query query, LazyBox<JSON> box) async {
    final id = query.payload['id'] as String?;
    if (id != null && box.containsKey(id)) {
      return QueryResult.failed(
        query,
        errorMsg: 'Object already exists in hive box',
      );
    }
    return _store(query, box);
  }

  /// Tries to store queries payload in hive box
  Future<QueryResult> update(Query query, LazyBox<JSON> box) =>
      _store(query, box);

  /// Shared logic for create and update
  Future<QueryResult> _store(Query query, LazyBox<JSON> box) async {
    final id = query.payload['id'] as String?;
    final key = id ?? Uuid().v1();

    final payload = JSON.from(query.payload);
    payload.update('id', (_) => key, ifAbsent: () => key);

    await box.put(key, payload);

    if (!box.containsKey(key)) {
      return QueryResult.failed(
        query,
        errorMsg: 'Could not insert object into hive box',
      );
    } else {
      return QueryResult.success(
        query,
        payload: payload,
      );
    }
  }

  /// Tries to delete payload from hive box
  Future<QueryResult> delete(Query query, LazyBox<JSON> box) async {
    final id = query.payload['id'] as String?;
    if (id == null) {
      return QueryResult.success(query, payload: query.payload);
    }

    await box.delete(id);

    final payload = JSON.from(query.payload);
    payload.update('id', (_) => null, ifAbsent: () => null);

    if (box.containsKey(id)) {
      return QueryResult.failed(
        query,
        errorMsg: 'Could not delete object from hive box',
      );
    } else {
      return QueryResult.success(
        query,
        payload: payload,
      );
    }
  }

  /// Tries to fetch payload from hive box
  Future<QueryResult> read(Query query, LazyBox<JSON> lazyBox) async {
    final id = query.payload['id'] as String?;
    late JSON payload;

    if (query.limit == 1 && id != null) {
      payload = await lazyBox.get(id) ?? {};
    } else {
      if (lazyBox.isOpen) {
        await lazyBox.close();
      }
      final box = await Hive.openBox(lazyBox.name);
      var matchingElements = box.values;

      if (query.where.isNotEmpty) {
        matchingElements = box.values.where(
          (payload) => query.where.every(
            (constraint) => constraint.evaluate(payload),
          ),
        );
      }

      if (query.limit != null && query.limit! > 0) {
        matchingElements = matchingElements.take(query.limit!);
      }

      await box.close();
      payload = {};
      for (var json in matchingElements) {
        payload.putIfAbsent(json['id'], () => JSON.from(json));
      }
    }

    if (payload.isEmpty) {
      return QueryResult.failed(
        query,
        errorMsg: 'Could not read object from hive box',
      );
    }

    return QueryResult.success(query, payload: payload);
  }
}
