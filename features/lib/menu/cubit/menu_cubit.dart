import 'package:core/core.dart';
import 'package:domain/domain.dart';

part 'menu_state.dart';

/// Меню: рекорд из статистики. Экран создаётся заново при возврате из
/// игры (`goNamed`), поэтому рекорд всегда свежий.
class MenuCubit extends Cubit<MenuState> {
  final StatsRepository statsRepository;

  MenuCubit({required this.statsRepository}) : super(const MenuState()) {
    _init();
  }

  Future<void> _init() async {
    final GameStatsModel stats = await statsRepository.getStats();
    if (isClosed) return;
    emit(state.copyWith(bestScore: stats.bestScore));
  }
}
