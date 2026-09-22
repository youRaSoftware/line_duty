import 'package:core/core.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';

import '../cubit/menu_cubit.dart';
import 'menu_form.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MenuCubit>(
      create: (BuildContext context) =>
          MenuCubit(statsRepository: appLocator<StatsRepository>()),
      child: const MenuForm(),
    );
  }
}
