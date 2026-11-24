// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Ball Sort Puzzle';

  @override
  String get logoTitle => 'BALL SORT';

  @override
  String get logoSubtitle => 'FARBEN  PUZZLE';

  @override
  String playLevel(int level) {
    return 'SPIELEN  ·  LEVEL $level';
  }

  @override
  String continueLevel(int level) {
    return 'WEITER  ·  LEVEL $level';
  }

  @override
  String get levels => 'LEVELS';

  @override
  String levelsSolved(int solved, int total) {
    return '$solved von $total Levels gelöst';
  }

  @override
  String get selectLevel => 'LEVEL WÄHLEN';

  @override
  String levelTile(int level) {
    return 'Level $level';
  }

  @override
  String levelTileStars(int level, int stars) {
    String _temp0 = intl.Intl.pluralLogic(
      stars,
      locale: localeName,
      other: '$stars Sterne',
      one: '1 Stern',
    );
    return 'Level $level, $_temp0';
  }

  @override
  String levelTileLocked(int level) {
    return 'Level $level gesperrt';
  }

  @override
  String get hintMystery => 'Rätsel';

  @override
  String get hintSpecial => 'Spezial';

  @override
  String get difficultyTutorial => 'Tutorial';

  @override
  String get difficultyEasy => 'Leicht';

  @override
  String get difficultyMedium => 'Mittel';

  @override
  String get difficultyHard => 'Schwer';

  @override
  String get difficultyExpert => 'Experte';

  @override
  String get difficultyMaster => 'Meister';

  @override
  String get difficultyChallenge => 'Herausforderung';

  @override
  String get difficultyLegend => 'Legende';

  @override
  String get difficultyMythic => 'Mythisch';

  @override
  String get difficultyImmortal => 'Unsterblich';

  @override
  String levelHeader(int level) {
    return 'LEVEL $level';
  }

  @override
  String movesCounter(int moves) {
    return 'ZÜGE $moves';
  }

  @override
  String movesCounterTarget(int moves, int target) {
    return 'ZÜGE $moves / $target';
  }

  @override
  String newMechanic(String text) {
    return 'NEU: $text';
  }

  @override
  String get mechanicBasicMove =>
      'Tippe auf ein Röhrchen und dann auf ein anderes, um eine Kugel zu bewegen';

  @override
  String get mechanicSameColor => 'Nur gleiche Farben lassen sich stapeln';

  @override
  String get mechanicPowerUps => 'Rückgängig, Mischen und Röhrchen hinzufügen';

  @override
  String get mechanicPlanAhead => 'Plane mehrere Züge voraus';

  @override
  String get mechanicOneSpareTube => 'Nur ein freies Röhrchen!';

  @override
  String get mechanicMystery =>
      'Rätselkugeln: Verdeckte Farben zeigen sich, sobald sie oben sind';

  @override
  String get mechanicTallTubes => 'Spezial-Level: höhere Röhrchen';

  @override
  String get mechanicScatteredColor =>
      'Eine Farbe ist über fast alle Röhrchen verteilt';

  @override
  String get mechanicBiggerBoards => 'Größere Spielfelder';

  @override
  String get mechanicMoveTargets => 'Zugziele: Bleib im Ziel für 3 Sterne';

  @override
  String get mechanicLegend =>
      'Legenden-Level: brutale Felder, kaum Raum für Fehler';

  @override
  String get mechanicMythic => 'Mythische Level: alle Farben, fast keine Luft';

  @override
  String get mechanicImmortal => 'Unsterbliche Level: jedes Feld am Limit';

  @override
  String get undo => 'ZURÜCK';

  @override
  String get shuffle => 'MISCHEN';

  @override
  String get addTube => 'RÖHRCHEN';

  @override
  String powerUpSemantics(String name, int count) {
    return '$name, noch $count';
  }

  @override
  String get noUndosLeft =>
      'Kein Rückgängig mehr - starte das Level neu, um Power-ups aufzufüllen.';

  @override
  String get noShufflesLeft =>
      'Kein Mischen mehr - starte das Level neu, um Power-ups aufzufüllen.';

  @override
  String get noTubesLeft =>
      'Keine Extra-Röhrchen mehr - starte das Level neu, um Power-ups aufzufüllen.';

  @override
  String get nothingToUndo => 'Noch nichts rückgängig zu machen.';

  @override
  String get settingsLabel => 'Einstellungen';

  @override
  String get settings => 'EINSTELLUNGEN';

  @override
  String get close => 'Schließen';

  @override
  String get back => 'Zurück';

  @override
  String get home => 'Startseite';

  @override
  String get restartLevel => 'Level neu starten';

  @override
  String get replayLevel => 'Level wiederholen';

  @override
  String get sectionAudio => 'TON & VIBRATION';

  @override
  String get sectionGeneral => 'ALLGEMEIN';

  @override
  String get soundEffects => 'Soundeffekte';

  @override
  String get music => 'Musik';

  @override
  String get vibration => 'Vibration';

  @override
  String get theme => 'Design';

  @override
  String get themeSystem => 'Auto';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get language => 'Sprache';

  @override
  String get howToPlay => 'Spielanleitung';

  @override
  String get resume => 'FORTSETZEN';

  @override
  String get restartLevelButton => 'LEVEL NEU STARTEN';

  @override
  String get exitToHome => 'ZUR STARTSEITE';

  @override
  String get done => 'FERTIG';

  @override
  String get chooseLanguage => 'SPRACHE';

  @override
  String get restartTitle => 'NEU STARTEN?';

  @override
  String get restartBody =>
      'Dieses Level neu beginnen?\nDeine freigeschalteten Levels bleiben erhalten.';

  @override
  String get cancel => 'ABBRECHEN';

  @override
  String get restart => 'NEU STARTEN';

  @override
  String get noMovesTitle => 'KEINE ZÜGE MEHR';

  @override
  String get noMovesBody =>
      'Es gibt keine gültigen Züge. Nutze ein Power-up oder starte neu.';

  @override
  String get timeUpTitle => 'ZEIT ABGELAUFEN!';

  @override
  String get timeUpBody => 'Die Uhr ist abgelaufen. Versuch es noch einmal!';

  @override
  String get retry => 'NOCHMAL';

  @override
  String get homeButton => 'START';

  @override
  String get specialLevelTitle => 'SPEZIAL-LEVEL';

  @override
  String specialLevelBody(int capacity, int colors) {
    return 'Hohe Röhrchen fassen je $capacity Kugeln.\nSortiere $colors Farben.';
  }

  @override
  String specialLevelBodyMystery(int capacity, int colors) {
    return 'Hohe Röhrchen fassen je $capacity Kugeln.\nSortiere $colors Farben - und achte auf Rätselkugeln!';
  }

  @override
  String get play => 'SPIELEN';

  @override
  String get levelCompleteTitle => 'LEVEL GESCHAFFT!';

  @override
  String levelSolvedIn(int level) {
    return 'Level $level gelöst in';
  }

  @override
  String movesCount(int moves) {
    String _temp0 = intl.Intl.pluralLogic(
      moves,
      locale: localeName,
      other: '$moves ZÜGEN',
      one: '1 ZUG',
    );
    return '$_temp0';
  }

  @override
  String goalReached(int target) {
    return 'Ziel von $target erreicht!';
  }

  @override
  String goalMoves(int target) {
    return 'Ziel: $target Züge';
  }

  @override
  String get continueButton => 'WEITER';

  @override
  String get allLevelsDone => 'ALLE LEVELS GESCHAFFT!';

  @override
  String get tutorialTapToSelect => 'Tippe, um eine Kugel zu wählen';

  @override
  String get tutorialTapAnother =>
      'Tippe auf ein anderes Röhrchen, um die Kugel zu bewegen';

  @override
  String get tutorialSameColor =>
      'Nur Kugeln derselben Farbe lassen sich stapeln.';

  @override
  String get tutorialSameColorIntro =>
      'Tippe, um eine Kugel zu wählen\nNur gleiche Farben lassen sich stapeln!';

  @override
  String get skipTutorial => 'Tutorial überspringen';

  @override
  String get skip => 'Überspringen';

  @override
  String get next => 'Weiter';

  @override
  String get gotIt => 'Verstanden!';

  @override
  String get powerUpUndoTitle => 'Rückgängig';

  @override
  String get powerUpUndoBody => 'Nimm deinen letzten Zug zurück.';

  @override
  String get powerUpShuffleTitle => 'Mischen';

  @override
  String get powerUpShuffleBody =>
      'Mische die Kugeln zu einem neuen, weiterhin lösbaren Rätsel.';

  @override
  String get powerUpAddTubeTitle => 'Röhrchen hinzufügen';

  @override
  String get powerUpAddTubeBody =>
      'Erhalte ein zusätzliches leeres Röhrchen für dieses Level.';

  @override
  String get howToPlayTitle => 'SPIELANLEITUNG';

  @override
  String get howGoalTitle => 'Farben sortieren';

  @override
  String get howGoalBody =>
      'Fülle jedes Röhrchen mit Kugeln einer einzigen Farbe, um das Level zu schaffen.';

  @override
  String get howMoveTitle => 'Kugel bewegen';

  @override
  String get howMoveBody =>
      'Tippe auf ein Röhrchen, um die oberste Kugel anzuheben, und dann auf ein anderes, um sie abzulegen.';

  @override
  String get howRuleTitle => 'Gleiches auf Gleiches';

  @override
  String get howRuleBody =>
      'Eine Kugel landet nur auf derselben Farbe oder in einem leeren Röhrchen - und jedes Röhrchen hat begrenzten Platz.';

  @override
  String get howPowerUpsTitle => 'Power-ups nutzen';

  @override
  String get howPowerUpsBody =>
      'Festgefahren? Mach einen Zug rückgängig, mische die Kugeln oder füge ein Röhrchen hinzu. Ein Neustart füllt sie auf.';

  @override
  String get howStarsTitle => '3 Sterne holen';

  @override
  String get howStarsBody =>
      'Weniger Züge bringen mehr Sterne. Achte auf Rätselkugeln, Timer und hohe Röhrchen!';

  @override
  String pageIndicator(int page, int total) {
    return 'Seite $page von $total';
  }
}
