```dart
void main() {
    // Path will resolve to "${Directory.current.path}/hive"
    final pathWhereHiveShouldLive = 'hive'
    final myDatabaseAdapter = HiveDatabaseAdapter(path: pathWhereHiveShouldLive);
    
    
    // Register a Database Adapter that you want to use.
    DatabaseAdapterRegistry.register(myDatabaseAdapter);

    final repository = DatabaseRepository.fromRegistry(serializer: mySerializer, name: 'hive');
    
    // Now use some methods such as create() etc.
}
```