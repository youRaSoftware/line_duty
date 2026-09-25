import 'package:hive/hive.dart';

/// Снимок забега одним значением под ключом `snapshot`: Map с примитивами
/// и списками (Hive хранит их без адаптеров). Разбор — в
/// `RunRepositoryImpl`.
class RunHiveProvider {
  static const String _key = 'snapshot';

  final Box<dynamic> _box;

  RunHiveProvider(this._box);

  Map<String, dynamic>? get snapshot {
    final Object? raw = _box.get(_key);
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
  }

  Future<void> save(Map<String, dynamic> data) => _box.put(_key, data);

  Future<void> clear() => _box.delete(_key);
}
