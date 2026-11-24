// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Ball Sort Puzzle';

  @override
  String get logoTitle => 'BALL SORT';

  @override
  String get logoSubtitle => 'COLOR  PUZZLE';

  @override
  String playLevel(int level) {
    return 'PLAY  ·  LEVEL $level';
  }

  @override
  String continueLevel(int level) {
    return 'CONTINUE  ·  LEVEL $level';
  }

  @override
  String get levels => 'LEVELS';

  @override
  String levelsSolved(int solved, int total) {
    return '$solved of $total levels solved';
  }

  @override
  String get selectLevel => 'SELECT LEVEL';

  @override
  String levelTile(int level) {
    return 'Level $level';
  }

  @override
  String levelTileStars(int level, int stars) {
    String _temp0 = intl.Intl.pluralLogic(
      stars,
      locale: localeName,
      other: '$stars stars',
      one: '1 star',
    );
    return 'Level $level, $_temp0';
  }

  @override
  String levelTileLocked(int level) {
    return 'Level $level locked';
  }

  @override
  String get hintMystery => 'mystery';

  @override
  String get hintSpecial => 'special';

  @override
  String get difficultyTutorial => 'Tutorial';

  @override
  String get difficultyEasy => 'Easy';

  @override
  String get difficultyMedium => 'Medium';

  @override
  String get difficultyHard => 'Hard';

  @override
  String get difficultyExpert => 'Expert';

  @override
  String get difficultyMaster => 'Master';

  @override
  String get difficultyChallenge => 'Challenge';

  @override
  String get difficultyLegend => 'Legend';

  @override
  String get difficultyMythic => 'Mythic';

  @override
  String get difficultyImmortal => 'Immortal';

  @override
  String levelHeader(int level) {
    return 'LEVEL $level';
  }

  @override
  String movesCounter(int moves) {
    return 'MOVES $moves';
  }

  @override
  String movesCounterTarget(int moves, int target) {
    return 'MOVES $moves / $target';
  }

  @override
  String newMechanic(String text) {
    return 'NEW: $text';
  }

  @override
  String get mechanicBasicMove => 'Tap a tube, then tap another to move a ball';

  @override
  String get mechanicSameColor => 'Only matching colors stack';

  @override
  String get mechanicPowerUps => 'Undo, Shuffle and Add Tube';

  @override
  String get mechanicPlanAhead => 'Plan several moves ahead';

  @override
  String get mechanicOneSpareTube => 'Only one spare tube!';

  @override
  String get mechanicMystery =>
      'Mystery balls: hidden colors reveal when they reach the top';

  @override
  String get mechanicTallTubes => 'Special level: taller tubes';

  @override
  String get mechanicScatteredColor =>
      'One color is scattered through nearly every tube';

  @override
  String get mechanicBiggerBoards => 'Bigger boards';

  @override
  String get mechanicMoveTargets =>
      'Move targets: finish within the goal for 3 stars';

  @override
  String get mechanicLegend =>
      'Legend levels: brutal boards, little room for mistakes';

  @override
  String get mechanicMythic =>
      'Mythic levels: the full palette, almost no room to breathe';

  @override
  String get mechanicImmortal =>
      'Immortal levels: every board pushed to the limit';

  @override
  String get undo => 'UNDO';

  @override
  String get shuffle => 'SHUFFLE';

  @override
  String get addTube => 'ADD TUBE';

  @override
  String powerUpSemantics(String name, int count) {
    return '$name, $count left';
  }

  @override
  String get noUndosLeft =>
      'No undos left - restart the level to refill power-ups.';

  @override
  String get noShufflesLeft =>
      'No shuffles left - restart the level to refill power-ups.';

  @override
  String get noTubesLeft =>
      'No extra tubes left - restart the level to refill power-ups.';

  @override
  String get nothingToUndo => 'Nothing to undo yet.';

  @override
  String get settingsLabel => 'Settings';

  @override
  String get settings => 'SETTINGS';

  @override
  String get close => 'Close';

  @override
  String get back => 'Back';

  @override
  String get home => 'Home';

  @override
  String get restartLevel => 'Restart level';

  @override
  String get replayLevel => 'Replay level';

  @override
  String get sectionAudio => 'SOUND & FEEL';

  @override
  String get sectionGeneral => 'GENERAL';

  @override
  String get soundEffects => 'Sound Effects';

  @override
  String get music => 'Music';

  @override
  String get vibration => 'Vibration';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'Auto';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get howToPlay => 'How to Play';

  @override
  String get resume => 'RESUME';

  @override
  String get restartLevelButton => 'RESTART LEVEL';

  @override
  String get exitToHome => 'EXIT TO HOME';

  @override
  String get done => 'DONE';

  @override
  String get chooseLanguage => 'LANGUAGE';

  @override
  String get restartTitle => 'RESTART?';

  @override
  String get restartBody =>
      'Start this level over?\nYour unlocked levels are kept.';

  @override
  String get cancel => 'CANCEL';

  @override
  String get restart => 'RESTART';

  @override
  String get noMovesTitle => 'NO MOVES LEFT';

  @override
  String get noMovesBody =>
      'There are no legal moves. Try a power-up or restart.';

  @override
  String get timeUpTitle => 'TIME\'S UP!';

  @override
  String get timeUpBody => 'The clock ran out. Give it another go!';

  @override
  String get retry => 'RETRY';

  @override
  String get homeButton => 'HOME';

  @override
  String get specialLevelTitle => 'SPECIAL LEVEL';

  @override
  String specialLevelBody(int capacity, int colors) {
    return 'Taller tubes hold $capacity balls each.\nSort $colors colors.';
  }

  @override
  String specialLevelBodyMystery(int capacity, int colors) {
    return 'Taller tubes hold $capacity balls each.\nSort $colors colors - and watch out for mystery balls!';
  }

  @override
  String get play => 'PLAY';

  @override
  String get levelCompleteTitle => 'LEVEL COMPLETE!';

  @override
  String levelSolvedIn(int level) {
    return 'Level $level solved in';
  }

  @override
  String movesCount(int moves) {
    String _temp0 = intl.Intl.pluralLogic(
      moves,
      locale: localeName,
      other: '$moves MOVES',
      one: '1 MOVE',
    );
    return '$_temp0';
  }

  @override
  String goalReached(int target) {
    return 'Goal of $target reached!';
  }

  @override
  String goalMoves(int target) {
    return 'Goal: $target moves';
  }

  @override
  String get continueButton => 'CONTINUE';

  @override
  String get allLevelsDone => 'ALL LEVELS DONE!';

  @override
  String get tutorialTapToSelect => 'Tap to Select Ball';

  @override
  String get tutorialTapAnother => 'Tap another tube to move the ball';

  @override
  String get tutorialSameColor =>
      'Only balls of the same color can be stacked together.';

  @override
  String get tutorialSameColorIntro =>
      'Tap to Select Ball\nOnly matching colors can stack!';

  @override
  String get skipTutorial => 'Skip tutorial';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get gotIt => 'Got it!';

  @override
  String get powerUpUndoTitle => 'Undo';

  @override
  String get powerUpUndoBody => 'Take back your last move.';

  @override
  String get powerUpShuffleTitle => 'Shuffle';

  @override
  String get powerUpShuffleBody =>
      'Remix the balls into a new, still-solvable puzzle.';

  @override
  String get powerUpAddTubeTitle => 'Add Tube';

  @override
  String get powerUpAddTubeBody => 'Get an extra empty tube for this level.';

  @override
  String get howToPlayTitle => 'HOW TO PLAY';

  @override
  String get howGoalTitle => 'Sort the colors';

  @override
  String get howGoalBody =>
      'Fill every tube with balls of a single color to clear the level.';

  @override
  String get howMoveTitle => 'Move a ball';

  @override
  String get howMoveBody =>
      'Tap a tube to lift its top ball, then tap another tube to drop it there.';

  @override
  String get howRuleTitle => 'Match to stack';

  @override
  String get howRuleBody =>
      'A ball can only land on the same color or in an empty tube - and every tube has limited room.';

  @override
  String get howPowerUpsTitle => 'Use power-ups';

  @override
  String get howPowerUpsBody =>
      'Stuck? Undo a move, shuffle the balls or add an extra tube. Restarting refills them.';

  @override
  String get howStarsTitle => 'Earn 3 stars';

  @override
  String get howStarsBody =>
      'Solve in fewer moves for more stars. Look out for mystery balls, timers and taller tubes!';

  @override
  String pageIndicator(int page, int total) {
    return 'Page $page of $total';
  }
}
