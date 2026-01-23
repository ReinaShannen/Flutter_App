import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/theme/theme_provider.dart';


class HomeTopBar extends StatelessWidget {
  final ThemeProvider themeProvider;

  const HomeTopBar({super.key, required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onBackground;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            context.l10n.profileManager,
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          Row(
            children: [
              PopupMenuButton<Locale>(
                icon: Icon(Icons.language, color: textColor),
                onSelected: (locale) {
                  context.read<LocaleProvider>().setLocale(locale);
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: Locale('en'),
                    child: Text('English'),
                  ),
                  PopupMenuItem(
                    value: Locale('ta'),
                    child: Text('தமிழ்'),
                  ),
                ],
              ),
              PopupMenuButton<ThemeMode>(
                icon: Icon(Icons.color_lens, color: textColor),
                onSelected: themeProvider.setThemeMode,
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: ThemeMode.system,
                    child: Text('System'),
                  ),
                  PopupMenuItem(
                    value: ThemeMode.light,
                    child: Text('Light'),
                  ),
                  PopupMenuItem(
                    value: ThemeMode.dark,
                    child: Text('Dark'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
