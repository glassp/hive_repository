import 'package:hive/hive.dart';

import 'runner.dart';

class HiveRunner extends Runner {
  final bool lazy;
  final String path;

  /// A [Box] or [LazyBox] depending if [lazy] is true or not.
  late BoxBase _box;

  HiveRunner(
    int elements, {
    required this.lazy,
    required this.path,
  }) : super(elements);

  @override
  Future<void> delete(int key) async {
    await _box.delete(key);
  }

  @override
  Future<void> read(int key) async {
    if (_box is LazyBox) {
      await (_box as LazyBox).get(key);
    } else if (_box is Box) {
      (_box as Box).get(key);
    }
  }

  @override
  Future<void> setUp() async {
    Hive.init(path);
    final boxName = "hive_repository_benchmark";
    if (lazy) {
      _box = await Hive.openLazyBox('lazy$boxName');
    } else {
      _box = await Hive.openBox(boxName);
    }
  }

  @override
  Future<void> tearDown() async {
    await _box.deleteFromDisk();
  }

  @override
  Future<void> write(int key, Map<String, dynamic> json) async {
    await _box.put(key, json);
  }
}
