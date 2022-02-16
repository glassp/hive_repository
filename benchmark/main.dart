import 'runner/hive.dart';
import 'runner/hive_repository.dart';

void main() async {
  final elements = 100000;
  final path = ".";
  final runners = [
    HiveRunner(elements, lazy: true, path: path),
    HiveRunner(elements, lazy: false, path: path),
    HiveRepositoryRunner(elements, path: path),
  ];
  final results = [];

  for (var runner in runners) {
    final result = await runner.run();
    results.add(result);
  }

  print(results);
}
