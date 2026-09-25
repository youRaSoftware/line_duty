import 'package:core/core.dart';
import 'package:domain/domain.dart';

part 'menu_state.dart';

/// Меню: рекорд из статистики и незавершённый забег для «Продолжить».
/// Экран создаётся заново при возврате из игры (`goNamed`), поэтому и
/// рекорд, и снимок всегда свежие.
class MenuCubit extends Cubit<MenuState> {
  final StatsRepository statsRepository;
  final RunRepository runRepository;

  MenuCubit({required this.statsRepository, required this.runRepository})
      : super(const MenuState()) {
    _init();
  }

  Future<void> _init() async {
    final GameStatsModel stats = await statsRepository.getStats();
    final RunSnapshot? saved = await runRepository.load();
    if (isClosed) return;
    emit(state.copyWith(bestScore: stats.bestScore, saved: saved));
  }

  /// «Новый забег» — сохранённый стирается.
  Future<void> discardSaved() async {
    await runRepository.clear();
    if (isClosed) return;
    emit(state.copyWith(clearSaved: true));
  }
}
