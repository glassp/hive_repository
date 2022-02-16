import 'dart:convert';

import 'package:meta/meta.dart';

abstract class Runner {
  final int elements;
  final Stopwatch _readTimer = Stopwatch();
  final Stopwatch _writeTimer = Stopwatch();
  final Stopwatch _deleteTimer = Stopwatch();
  final Map<String, dynamic> json = {
    "uid": 0,
    "foo": "bar",
    "user": {
      "firstName": "Foo",
      "lastName": "Bar",
    },
    "groups": ["admin", "dev"],
    "isLoggedIn": false,
  };

  Runner(this.elements);

  @visibleForOverriding
  Future<void> setUp();

  @visibleForOverriding
  Future<void> tearDown();

  Future<void> _batchedRead() async {
    _readTimer.start();
    for (var i = 0; i < elements.abs(); i++) {
      await read(i);
    }
    _readTimer.stop();
  }

  Future<void> _batchedWrite() async {
    _writeTimer.start();
    for (var i = 0; i < elements.abs(); i++) {
      await write(i, json);
    }
    _writeTimer.stop();
  }

  Future<void> _batchedDelete() async {
    _deleteTimer.start();
    for (var i = 0; i < elements.abs(); i++) {
      await delete(i);
    }
    _deleteTimer.stop();
  }

  @visibleForOverriding
  Future<void> read(int key);

  @visibleForOverriding
  Future<void> write(int key, Map<String, dynamic> json);

  @visibleForOverriding
  Future<void> delete(int key);

  @nonVirtual
  Future<Result> run() async {
    await setUp();
    await _batchedWrite();
    await _batchedRead();
    await _batchedDelete();
    await tearDown();

    return Result(_readTimer, _writeTimer, _deleteTimer, elements);
  }
}

class Result {
  final Stopwatch _readTimer;
  final Stopwatch _writeTimer;
  final Stopwatch _deleteTimer;
  final int _elements;

  Result(this._readTimer, this._writeTimer, this._deleteTimer, this._elements);

  num get totalTime =>
      _readTimer.elapsedMicroseconds +
      _writeTimer.elapsedMicroseconds +
      _deleteTimer.elapsedMicroseconds;

  num get readTime => _readTimer.elapsedMicroseconds;
  num get writeTime => _writeTimer.elapsedMicroseconds;
  num get deleteTime => _deleteTimer.elapsedMicroseconds;

  num get totalTimePerElement => totalTime / _elements;
  num get readTimePerElement => readTime / _elements;
  num get writeTimePerElement => writeTime / _elements;
  num get deleteTimePerElement => deleteTime / _elements;

  @override
  String toString() {
    final jsonEncoder = JsonEncoder.withIndent('  ');
    return jsonEncoder.convert({
      "total": totalTime,
      "read": readTime,
      "write": writeTime,
      "delete": deleteTime,
      "total1": totalTimePerElement,
      "read1": readTimePerElement,
      "write1": writeTimePerElement,
      "delete1": deleteTimePerElement,
    });
  }
}
