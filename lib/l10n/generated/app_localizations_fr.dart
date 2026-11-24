// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Ball Sort Puzzle';

  @override
  String get logoTitle => 'BALL SORT';

  @override
  String get logoSubtitle => 'PUZZLE  DE  COULEURS';

  @override
  String playLevel(int level) {
    return 'JOUER  ·  NIVEAU $level';
  }

  @override
  String continueLevel(int level) {
    return 'CONTINUER  ·  NIVEAU $level';
  }

  @override
  String get levels => 'NIVEAUX';

  @override
  String levelsSolved(int solved, int total) {
    return '$solved niveaux résolus sur $total';
  }

  @override
  String get selectLevel => 'CHOISIR UN NIVEAU';

  @override
  String levelTile(int level) {
    return 'Niveau $level';
  }

  @override
  String levelTileStars(int level, int stars) {
    String _temp0 = intl.Intl.pluralLogic(
      stars,
      locale: localeName,
      other: '$stars étoiles',
      one: '1 étoile',
    );
    return 'Niveau $level, $_temp0';
  }

  @override
  String levelTileLocked(int level) {
    return 'Niveau $level verrouillé';
  }

  @override
  String get hintMystery => 'mystère';

  @override
  String get hintSpecial => 'spécial';

  @override
  String get difficultyTutorial => 'Tutoriel';

  @override
  String get difficultyEasy => 'Facile';

  @override
  String get difficultyMedium => 'Moyen';

  @override
  String get difficultyHard => 'Difficile';

  @override
  String get difficultyExpert => 'Expert';

  @override
  String get difficultyMaster => 'Maître';

  @override
  String get difficultyChallenge => 'Défi';

  @override
  String get difficultyLegend => 'Légende';

  @override
  String get difficultyMythic => 'Mythique';

  @override
  String get difficultyImmortal => 'Immortel';

  @override
  String levelHeader(int level) {
    return 'NIVEAU $level';
  }

  @override
  String movesCounter(int moves) {
    return 'COUPS $moves';
  }

  @override
  String movesCounterTarget(int moves, int target) {
    return 'COUPS $moves / $target';
  }

  @override
  String newMechanic(String text) {
    return 'NOUVEAU : $text';
  }

  @override
  String get mechanicBasicMove =>
      'Touchez un tube, puis un autre pour déplacer une boule';

  @override
  String get mechanicSameColor => 'Seules les couleurs identiques s\'empilent';

  @override
  String get mechanicPowerUps => 'Annuler, Mélanger et Ajouter un tube';

  @override
  String get mechanicPlanAhead => 'Prévoyez plusieurs coups à l\'avance';

  @override
  String get mechanicOneSpareTube => 'Un seul tube libre !';

  @override
  String get mechanicMystery =>
      'Boules mystère : les couleurs cachées se révèlent en arrivant en haut';

  @override
  String get mechanicTallTubes => 'Niveau spécial : tubes plus hauts';

  @override
  String get mechanicScatteredColor =>
      'Une couleur est dispersée dans presque tous les tubes';

  @override
  String get mechanicBiggerBoards => 'Plateaux plus grands';

  @override
  String get mechanicMoveTargets =>
      'Objectif de coups : terminez dans l\'objectif pour 3 étoiles';

  @override
  String get mechanicLegend =>
      'Niveaux Légende : plateaux redoutables, peu de marge d\'erreur';

  @override
  String get mechanicMythic =>
      'Niveaux Mythiques : toute la palette, presque aucun répit';

  @override
  String get mechanicImmortal =>
      'Niveaux Immortels : chaque plateau poussé à la limite';

  @override
  String get undo => 'ANNULER';

  @override
  String get shuffle => 'MÉLANGER';

  @override
  String get addTube => 'AJOUTER';

  @override
  String powerUpSemantics(String name, int count) {
    return '$name, $count restants';
  }

  @override
  String get noUndosLeft =>
      'Plus d\'annulations - recommencez le niveau pour recharger les bonus.';

  @override
  String get noShufflesLeft =>
      'Plus de mélanges - recommencez le niveau pour recharger les bonus.';

  @override
  String get noTubesLeft =>
      'Plus de tubes bonus - recommencez le niveau pour recharger les bonus.';

  @override
  String get nothingToUndo => 'Rien à annuler pour l\'instant.';

  @override
  String get settingsLabel => 'Paramètres';

  @override
  String get settings => 'PARAMÈTRES';

  @override
  String get close => 'Fermer';

  @override
  String get back => 'Retour';

  @override
  String get home => 'Accueil';

  @override
  String get restartLevel => 'Recommencer le niveau';

  @override
  String get replayLevel => 'Rejouer le niveau';

  @override
  String get sectionAudio => 'SON ET VIBRATIONS';

  @override
  String get sectionGeneral => 'GÉNÉRAL';

  @override
  String get soundEffects => 'Effets sonores';

  @override
  String get music => 'Musique';

  @override
  String get vibration => 'Vibrations';

  @override
  String get theme => 'Thème';

  @override
  String get themeSystem => 'Auto';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get language => 'Langue';

  @override
  String get howToPlay => 'Comment jouer';

  @override
  String get resume => 'REPRENDRE';

  @override
  String get restartLevelButton => 'RECOMMENCER';

  @override
  String get exitToHome => 'RETOUR À L\'ACCUEIL';

  @override
  String get done => 'OK';

  @override
  String get chooseLanguage => 'LANGUE';

  @override
  String get restartTitle => 'RECOMMENCER ?';

  @override
  String get restartBody =>
      'Recommencer ce niveau ?\nVos niveaux débloqués sont conservés.';

  @override
  String get cancel => 'ANNULER';

  @override
  String get restart => 'RECOMMENCER';

  @override
  String get noMovesTitle => 'PLUS DE COUPS';

  @override
  String get noMovesBody =>
      'Aucun coup possible. Essayez un bonus ou recommencez.';

  @override
  String get timeUpTitle => 'TEMPS ÉCOULÉ !';

  @override
  String get timeUpBody => 'Le chrono est à zéro. Retentez votre chance !';

  @override
  String get retry => 'RÉESSAYER';

  @override
  String get homeButton => 'ACCUEIL';

  @override
  String get specialLevelTitle => 'NIVEAU SPÉCIAL';

  @override
  String specialLevelBody(int capacity, int colors) {
    return 'Les grands tubes contiennent $capacity boules.\nTriez $colors couleurs.';
  }

  @override
  String specialLevelBodyMystery(int capacity, int colors) {
    return 'Les grands tubes contiennent $capacity boules.\nTriez $colors couleurs - et gare aux boules mystère !';
  }

  @override
  String get play => 'JOUER';

  @override
  String get levelCompleteTitle => 'NIVEAU TERMINÉ !';

  @override
  String levelSolvedIn(int level) {
    return 'Niveau $level résolu en';
  }

  @override
  String movesCount(int moves) {
    String _temp0 = intl.Intl.pluralLogic(
      moves,
      locale: localeName,
      other: '$moves COUPS',
      one: '1 COUP',
    );
    return '$_temp0';
  }

  @override
  String goalReached(int target) {
    return 'Objectif de $target atteint !';
  }

  @override
  String goalMoves(int target) {
    return 'Objectif : $target coups';
  }

  @override
  String get continueButton => 'CONTINUER';

  @override
  String get allLevelsDone => 'TOUS LES NIVEAUX !';

  @override
  String get tutorialTapToSelect => 'Touchez pour choisir une boule';

  @override
  String get tutorialTapAnother =>
      'Touchez un autre tube pour déplacer la boule';

  @override
  String get tutorialSameColor =>
      'Seules les boules de même couleur peuvent s\'empiler.';

  @override
  String get tutorialSameColorIntro =>
      'Touchez pour choisir une boule\nSeules les couleurs identiques s\'empilent !';

  @override
  String get skipTutorial => 'Passer le tutoriel';

  @override
  String get skip => 'Passer';

  @override
  String get next => 'Suivant';

  @override
  String get gotIt => 'Compris !';

  @override
  String get powerUpUndoTitle => 'Annuler';

  @override
  String get powerUpUndoBody => 'Annulez votre dernier coup.';

  @override
  String get powerUpShuffleTitle => 'Mélanger';

  @override
  String get powerUpShuffleBody =>
      'Remélangez les boules en un nouveau puzzle toujours soluble.';

  @override
  String get powerUpAddTubeTitle => 'Ajouter un tube';

  @override
  String get powerUpAddTubeBody =>
      'Obtenez un tube vide supplémentaire pour ce niveau.';

  @override
  String get howToPlayTitle => 'COMMENT JOUER';

  @override
  String get howGoalTitle => 'Triez les couleurs';

  @override
  String get howGoalBody =>
      'Remplissez chaque tube de boules d\'une seule couleur pour réussir le niveau.';

  @override
  String get howMoveTitle => 'Déplacez une boule';

  @override
  String get howMoveBody =>
      'Touchez un tube pour soulever sa boule du haut, puis touchez un autre tube pour l\'y déposer.';

  @override
  String get howRuleTitle => 'Associez pour empiler';

  @override
  String get howRuleBody =>
      'Une boule ne se pose que sur la même couleur ou dans un tube vide - et chaque tube a une place limitée.';

  @override
  String get howPowerUpsTitle => 'Utilisez les bonus';

  @override
  String get howPowerUpsBody =>
      'Bloqué ? Annulez un coup, mélangez les boules ou ajoutez un tube. Recommencer les recharge.';

  @override
  String get howStarsTitle => 'Gagnez 3 étoiles';

  @override
  String get howStarsBody =>
      'Moins de coups, plus d\'étoiles. Attention aux boules mystère, aux chronos et aux grands tubes !';

  @override
  String pageIndicator(int page, int total) {
    return 'Page $page sur $total';
  }
}
