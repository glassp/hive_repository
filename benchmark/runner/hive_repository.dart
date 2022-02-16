import 'package:database_repository/database_repository.dart';
import 'package:hive_repository/src/database/adapter.dart';

import 'runner.dart';

class HiveRepositoryRunner extends Runner {
  final String path;
  late final HiveDatabaseAdapter adapter;
  HiveRepositoryRunner(int elements, {required this.path}) : super(elements);

  @override
  Future<void> delete(int key) async {
    await adapter.executeQuery(
      Query(
        entityName: 'Foo',
        action: QueryAction.delete,
        payload: {
          "id": "$key",
        },
      ),
    );
  }

  @override
  Future<void> read(int key) async{
    await adapter.executeQuery(
      Query(
        entityName: 'Foo',
        action: QueryAction.read,
        limit: 1,
        payload: {
          "id": "$key",
        },
      ),
    );
  }

  @override
  Future<void> setUp() async {
    adapter = HiveDatabaseAdapter(path: path);
  }

  @override
  Future<void> tearDown() async {
    await adapter.selfDestruct();
  }

  @override
  Future<void> write(int key, Map<String, dynamic> json) async{
    await adapter.executeQuery(
      Query(
        entityName: 'Foo',
        action: QueryAction.update,
        payload: json,
      ),
    );
  }
}
