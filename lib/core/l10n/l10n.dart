import 'package:flutter/widgets.dart';

import '../../features/game/domain/models/level_config.dart';
import '../../l10n/generated/app_localizations.dart';

export '../../l10n/generated/app_localizations.dart';

/// A language the player can pick in Settings. Names are shown in their own
/// language so players can always find theirs.
class AppLanguage {
  const AppLanguage(this.code, this.nativeName, this.englishName);

  final String code;
  final String nativeName;
  final String englishName;

  static const defaultCode = 'en';

  static const supported = [
    AppLanguage('en', 'English', 'English'),
    AppLanguage('hi', 'हिन्दी', 'Hindi'),
    AppLanguage('es', 'Español', 'Spanish'),
    AppLanguage('fr', 'Français', 'French'),
    AppLanguage('de', 'Deutsch', 'German'),
    AppLanguage('pt', 'Português', 'Portuguese'),
  ];

  static AppLanguage byCode(String? code) => supported.firstWhere(
    (l) => l.code == code,
    orElse: () => supported.first,
  );

  Locale get locale => Locale(code);
}

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

extension GameStrings on AppLocalizations {
  String difficulty(Difficulty d) => switch (d) {
    Difficulty.tutorial => difficultyTutorial,
    Difficulty.easy => difficultyEasy,
    Difficulty.medium => difficultyMedium,
    Difficulty.hard => difficultyHard,
    Difficulty.expert => difficultyExpert,
    Difficulty.master => difficultyMaster,
    Difficulty.legend => difficultyLegend,
    Difficulty.mythic => difficultyMythic,
    Difficulty.immortal => difficultyImmortal,
  };

  String mechanic(LevelMechanic m) => switch (m) {
    LevelMechanic.basicMove => mechanicBasicMove,
    LevelMechanic.sameColor => mechanicSameColor,
    LevelMechanic.powerUps => mechanicPowerUps,
    LevelMechanic.planAhead => mechanicPlanAhead,
    LevelMechanic.oneSpareTube => mechanicOneSpareTube,
    LevelMechanic.mystery => mechanicMystery,
    LevelMechanic.tallTubes => mechanicTallTubes,
    LevelMechanic.scatteredColor => mechanicScatteredColor,
    LevelMechanic.biggerBoards => mechanicBiggerBoards,
    LevelMechanic.moveTargets => mechanicMoveTargets,
    LevelMechanic.legend => mechanicLegend,
    LevelMechanic.mythic => mechanicMythic,
    LevelMechanic.immortal => mechanicImmortal,
  };
}
