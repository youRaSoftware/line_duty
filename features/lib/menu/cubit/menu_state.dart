part of 'menu_cubit.dart';

class MenuState extends Equatable {
  final int bestScore;

  /// Незавершённый забег, который можно продолжить.
  final RunSnapshot? saved;

  const MenuState({this.bestScore = 0, this.saved});

  bool get canResume => saved != null;

  MenuState copyWith({
    int? bestScore,
    RunSnapshot? saved,
    bool clearSaved = false,
  }) =>
      MenuState(
        bestScore: bestScore ?? this.bestScore,
        saved: clearSaved ? null : (saved ?? this.saved),
      );

  @override
  List<Object?> get props => <Object?>[bestScore, saved];
}
