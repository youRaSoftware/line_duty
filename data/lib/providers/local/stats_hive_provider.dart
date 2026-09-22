import 'package:hive/hive.dart';

class StatsHiveProvider {
  final Box<dynamic> _box;

  StatsHiveProvider(this._box);

  int get bestScore => (_box.get('bestScore') as int?) ?? 0;
  int get gamesPlayed => (_box.get('gamesPlayed') as int?) ?? 0;
  int get totalDelivered => (_box.get('totalDelivered') as int?) ?? 0;

  Future<void> save({
    required int bestScore,
    required int gamesPlayed,
    required int totalDelivered,
  }) async {
    await _box.putAll(<String, int>{
      'bestScore': bestScore,
      'gamesPlayed': gamesPlayed,
      'totalDelivered': totalDelivered,
    });
  }
}
