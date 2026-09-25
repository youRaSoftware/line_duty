import 'package:domain/domain.dart';
import 'package:flutter/foundation.dart';

import '../providers/local/run_hive_provider.dart';

/// Снимок ↔ Map: цвета и бонусы — индексами enum, маршрут — плоским
/// списком чисел. Повреждённый снимок читается как отсутствующий.
class RunRepositoryImpl implements RunRepository {
  final RunHiveProvider _provider;

  RunRepositoryImpl(this._provider);

  @override
  Future<RunSnapshot?> load() async {
    final Map<String, dynamic>? m = _provider.snapshot;
    if (m == null) return null;
    try {
      final List<UnitSnapshot> units = <UnitSnapshot>[];
      for (final Object? raw in (m['units'] as List<dynamic>)) {
        final Map<dynamic, dynamic> u = raw! as Map<dynamic, dynamic>;
        final int docked = _int(u['docked']);
        units.add(UnitSnapshot(
          color: LaneColor.values[_int(u['color'])],
          x: _double(u['x']),
          y: _double(u['y']),
          headingX: _double(u['hx']),
          headingY: _double(u['hy']),
          route: (u['route'] as List<dynamic>).map(_double).toList(),
          docked: docked < 0 ? null : LaneColor.values[docked],
          shielded: u['shielded'] == true,
          ghostLeft: _double(u['ghost']),
        ));
      }
      final Map<dynamic, dynamic>? p = m['pickup'] as Map<dynamic, dynamic>?;
      return RunSnapshot(
        score: _int(m['score']),
        delivered: _int(m['delivered']),
        continues: _int(m['continues']),
        counted: m['counted'] == true,
        savedDelivered: _int(m['savedDelivered']),
        freezeLeft: _double(m['freezeLeft']),
        multiplierLeft: _double(m['multiplierLeft']),
        spawnIn: _double(m['spawnIn']),
        pickupIn: _double(m['pickupIn']),
        pickup: p == null
            ? null
            : PickupSnapshot(
                kind: BonusKind.values[_int(p['kind'])],
                x: _double(p['x']),
                y: _double(p['y']),
                life: _double(p['life']),
              ),
        units: units,
        savedAt: DateTime.fromMillisecondsSinceEpoch(_int(m['savedAt'])),
      );
    } catch (error) {
      debugPrint('RunRepositoryImpl: bad snapshot dropped: $error');
      await _provider.clear();
      return null;
    }
  }

  @override
  Future<void> save(RunSnapshot s) {
    final PickupSnapshot? p = s.pickup;
    return _provider.save(<String, dynamic>{
      'score': s.score,
      'delivered': s.delivered,
      'continues': s.continues,
      'counted': s.counted,
      'savedDelivered': s.savedDelivered,
      'freezeLeft': s.freezeLeft,
      'multiplierLeft': s.multiplierLeft,
      'spawnIn': s.spawnIn,
      'pickupIn': s.pickupIn,
      'pickup': p == null
          ? null
          : <String, dynamic>{
              'kind': p.kind.index,
              'x': p.x,
              'y': p.y,
              'life': p.life,
            },
      'units': <Map<String, dynamic>>[
        for (final UnitSnapshot u in s.units)
          <String, dynamic>{
            'color': u.color.index,
            'x': u.x,
            'y': u.y,
            'hx': u.headingX,
            'hy': u.headingY,
            'route': u.route,
            'docked': u.docked?.index ?? -1,
            'shielded': u.shielded,
            'ghost': u.ghostLeft,
          },
      ],
      'savedAt': s.savedAt.millisecondsSinceEpoch,
    });
  }

  @override
  Future<void> clear() => _provider.clear();

  static int _int(Object? v) => (v as num).toInt();

  static double _double(Object? v) => (v as num).toDouble();
}
