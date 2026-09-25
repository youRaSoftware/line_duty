import '../models/run_snapshot.dart';

/// Незавершённый забег — один снимок: сохраняется при уходе из игры,
/// стирается при проигрыше или новом забеге.
abstract interface class RunRepository {
  Future<RunSnapshot?> load();
  Future<void> save(RunSnapshot snapshot);
  Future<void> clear();
}
