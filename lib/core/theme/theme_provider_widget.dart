import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:autoquill_ai/core/theme/app_theme.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_state.dart';

class ThemeProviderWidget extends StatelessWidget {
  final Widget child;

  const ThemeProviderWidget({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      buildWhen: (previous, current) => previous.themeMode != current.themeMode,
      builder: (context, state) {
        return Theme(
          data: state.themeMode == ThemeMode.dark ? minimalistDarkTheme : minimalistLightTheme,
          child: child,
        );
      },
    );
  }
}
