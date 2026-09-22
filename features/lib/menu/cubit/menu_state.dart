part of 'menu_cubit.dart';

class MenuState extends Equatable {
  final int bestScore;

  const MenuState({this.bestScore = 0});

  MenuState copyWith({int? bestScore}) =>
      MenuState(bestScore: bestScore ?? this.bestScore);

  @override
  List<Object?> get props => <Object?>[bestScore];
}
