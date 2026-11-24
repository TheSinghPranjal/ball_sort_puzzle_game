import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('pt'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Ball Sort Puzzle'**
  String get appTitle;

  /// No description provided for @logoTitle.
  ///
  /// In en, this message translates to:
  /// **'BALL SORT'**
  String get logoTitle;

  /// No description provided for @logoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'COLOR  PUZZLE'**
  String get logoSubtitle;

  /// No description provided for @playLevel.
  ///
  /// In en, this message translates to:
  /// **'PLAY  ·  LEVEL {level}'**
  String playLevel(int level);

  /// No description provided for @continueLevel.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE  ·  LEVEL {level}'**
  String continueLevel(int level);

  /// No description provided for @levels.
  ///
  /// In en, this message translates to:
  /// **'LEVELS'**
  String get levels;

  /// No description provided for @levelsSolved.
  ///
  /// In en, this message translates to:
  /// **'{solved} of {total} levels solved'**
  String levelsSolved(int solved, int total);

  /// No description provided for @selectLevel.
  ///
  /// In en, this message translates to:
  /// **'SELECT LEVEL'**
  String get selectLevel;

  /// No description provided for @levelTile.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String levelTile(int level);

  /// No description provided for @levelTileStars.
  ///
  /// In en, this message translates to:
  /// **'Level {level}, {stars, plural, =1{1 star} other{{stars} stars}}'**
  String levelTileStars(int level, int stars);

  /// No description provided for @levelTileLocked.
  ///
  /// In en, this message translates to:
  /// **'Level {level} locked'**
  String levelTileLocked(int level);

  /// No description provided for @hintMystery.
  ///
  /// In en, this message translates to:
  /// **'mystery'**
  String get hintMystery;

  /// No description provided for @hintSpecial.
  ///
  /// In en, this message translates to:
  /// **'special'**
  String get hintSpecial;

  /// No description provided for @difficultyTutorial.
  ///
  /// In en, this message translates to:
  /// **'Tutorial'**
  String get difficultyTutorial;

  /// No description provided for @difficultyEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get difficultyEasy;

  /// No description provided for @difficultyMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get difficultyMedium;

  /// No description provided for @difficultyHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get difficultyHard;

  /// No description provided for @difficultyExpert.
  ///
  /// In en, this message translates to:
  /// **'Expert'**
  String get difficultyExpert;

  /// No description provided for @difficultyMaster.
  ///
  /// In en, this message translates to:
  /// **'Master'**
  String get difficultyMaster;

  /// No description provided for @difficultyChallenge.
  ///
  /// In en, this message translates to:
  /// **'Challenge'**
  String get difficultyChallenge;

  /// No description provided for @difficultyLegend.
  ///
  /// In en, this message translates to:
  /// **'Legend'**
  String get difficultyLegend;

  /// No description provided for @difficultyMythic.
  ///
  /// In en, this message translates to:
  /// **'Mythic'**
  String get difficultyMythic;

  /// No description provided for @difficultyImmortal.
  ///
  /// In en, this message translates to:
  /// **'Immortal'**
  String get difficultyImmortal;

  /// No description provided for @levelHeader.
  ///
  /// In en, this message translates to:
  /// **'LEVEL {level}'**
  String levelHeader(int level);

  /// No description provided for @movesCounter.
  ///
  /// In en, this message translates to:
  /// **'MOVES {moves}'**
  String movesCounter(int moves);

  /// No description provided for @movesCounterTarget.
  ///
  /// In en, this message translates to:
  /// **'MOVES {moves} / {target}'**
  String movesCounterTarget(int moves, int target);

  /// No description provided for @newMechanic.
  ///
  /// In en, this message translates to:
  /// **'NEW: {text}'**
  String newMechanic(String text);

  /// No description provided for @mechanicBasicMove.
  ///
  /// In en, this message translates to:
  /// **'Tap a tube, then tap another to move a ball'**
  String get mechanicBasicMove;

  /// No description provided for @mechanicSameColor.
  ///
  /// In en, this message translates to:
  /// **'Only matching colors stack'**
  String get mechanicSameColor;

  /// No description provided for @mechanicPowerUps.
  ///
  /// In en, this message translates to:
  /// **'Undo, Shuffle and Add Tube'**
  String get mechanicPowerUps;

  /// No description provided for @mechanicPlanAhead.
  ///
  /// In en, this message translates to:
  /// **'Plan several moves ahead'**
  String get mechanicPlanAhead;

  /// No description provided for @mechanicOneSpareTube.
  ///
  /// In en, this message translates to:
  /// **'Only one spare tube!'**
  String get mechanicOneSpareTube;

  /// No description provided for @mechanicMystery.
  ///
  /// In en, this message translates to:
  /// **'Mystery balls: hidden colors reveal when they reach the top'**
  String get mechanicMystery;

  /// No description provided for @mechanicTallTubes.
  ///
  /// In en, this message translates to:
  /// **'Special level: taller tubes'**
  String get mechanicTallTubes;

  /// No description provided for @mechanicScatteredColor.
  ///
  /// In en, this message translates to:
  /// **'One color is scattered through nearly every tube'**
  String get mechanicScatteredColor;

  /// No description provided for @mechanicBiggerBoards.
  ///
  /// In en, this message translates to:
  /// **'Bigger boards'**
  String get mechanicBiggerBoards;

  /// No description provided for @mechanicMoveTargets.
  ///
  /// In en, this message translates to:
  /// **'Move targets: finish within the goal for 3 stars'**
  String get mechanicMoveTargets;

  /// No description provided for @mechanicLegend.
  ///
  /// In en, this message translates to:
  /// **'Legend levels: brutal boards, little room for mistakes'**
  String get mechanicLegend;

  /// No description provided for @mechanicMythic.
  ///
  /// In en, this message translates to:
  /// **'Mythic levels: the full palette, almost no room to breathe'**
  String get mechanicMythic;

  /// No description provided for @mechanicImmortal.
  ///
  /// In en, this message translates to:
  /// **'Immortal levels: every board pushed to the limit'**
  String get mechanicImmortal;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'UNDO'**
  String get undo;

  /// No description provided for @shuffle.
  ///
  /// In en, this message translates to:
  /// **'SHUFFLE'**
  String get shuffle;

  /// No description provided for @addTube.
  ///
  /// In en, this message translates to:
  /// **'ADD TUBE'**
  String get addTube;

  /// No description provided for @powerUpSemantics.
  ///
  /// In en, this message translates to:
  /// **'{name}, {count} left'**
  String powerUpSemantics(String name, int count);

  /// No description provided for @noUndosLeft.
  ///
  /// In en, this message translates to:
  /// **'No undos left - restart the level to refill power-ups.'**
  String get noUndosLeft;

  /// No description provided for @noShufflesLeft.
  ///
  /// In en, this message translates to:
  /// **'No shuffles left - restart the level to refill power-ups.'**
  String get noShufflesLeft;

  /// No description provided for @noTubesLeft.
  ///
  /// In en, this message translates to:
  /// **'No extra tubes left - restart the level to refill power-ups.'**
  String get noTubesLeft;

  /// No description provided for @nothingToUndo.
  ///
  /// In en, this message translates to:
  /// **'Nothing to undo yet.'**
  String get nothingToUndo;

  /// No description provided for @settingsLabel.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsLabel;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS'**
  String get settings;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @restartLevel.
  ///
  /// In en, this message translates to:
  /// **'Restart level'**
  String get restartLevel;

  /// No description provided for @replayLevel.
  ///
  /// In en, this message translates to:
  /// **'Replay level'**
  String get replayLevel;

  /// No description provided for @sectionAudio.
  ///
  /// In en, this message translates to:
  /// **'SOUND & FEEL'**
  String get sectionAudio;

  /// No description provided for @sectionGeneral.
  ///
  /// In en, this message translates to:
  /// **'GENERAL'**
  String get sectionGeneral;

  /// No description provided for @soundEffects.
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get soundEffects;

  /// No description provided for @music.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get music;

  /// No description provided for @vibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get vibration;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @howToPlay.
  ///
  /// In en, this message translates to:
  /// **'How to Play'**
  String get howToPlay;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'RESUME'**
  String get resume;

  /// No description provided for @restartLevelButton.
  ///
  /// In en, this message translates to:
  /// **'RESTART LEVEL'**
  String get restartLevelButton;

  /// No description provided for @exitToHome.
  ///
  /// In en, this message translates to:
  /// **'EXIT TO HOME'**
  String get exitToHome;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'DONE'**
  String get done;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'LANGUAGE'**
  String get chooseLanguage;

  /// No description provided for @restartTitle.
  ///
  /// In en, this message translates to:
  /// **'RESTART?'**
  String get restartTitle;

  /// No description provided for @restartBody.
  ///
  /// In en, this message translates to:
  /// **'Start this level over?\nYour unlocked levels are kept.'**
  String get restartBody;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get cancel;

  /// No description provided for @restart.
  ///
  /// In en, this message translates to:
  /// **'RESTART'**
  String get restart;

  /// No description provided for @noMovesTitle.
  ///
  /// In en, this message translates to:
  /// **'NO MOVES LEFT'**
  String get noMovesTitle;

  /// No description provided for @noMovesBody.
  ///
  /// In en, this message translates to:
  /// **'There are no legal moves. Try a power-up or restart.'**
  String get noMovesBody;

  /// No description provided for @timeUpTitle.
  ///
  /// In en, this message translates to:
  /// **'TIME\'S UP!'**
  String get timeUpTitle;

  /// No description provided for @timeUpBody.
  ///
  /// In en, this message translates to:
  /// **'The clock ran out. Give it another go!'**
  String get timeUpBody;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'RETRY'**
  String get retry;

  /// No description provided for @homeButton.
  ///
  /// In en, this message translates to:
  /// **'HOME'**
  String get homeButton;

  /// No description provided for @specialLevelTitle.
  ///
  /// In en, this message translates to:
  /// **'SPECIAL LEVEL'**
  String get specialLevelTitle;

  /// No description provided for @specialLevelBody.
  ///
  /// In en, this message translates to:
  /// **'Taller tubes hold {capacity} balls each.\nSort {colors} colors.'**
  String specialLevelBody(int capacity, int colors);

  /// No description provided for @specialLevelBodyMystery.
  ///
  /// In en, this message translates to:
  /// **'Taller tubes hold {capacity} balls each.\nSort {colors} colors - and watch out for mystery balls!'**
  String specialLevelBodyMystery(int capacity, int colors);

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'PLAY'**
  String get play;

  /// No description provided for @levelCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'LEVEL COMPLETE!'**
  String get levelCompleteTitle;

  /// No description provided for @levelSolvedIn.
  ///
  /// In en, this message translates to:
  /// **'Level {level} solved in'**
  String levelSolvedIn(int level);

  /// No description provided for @movesCount.
  ///
  /// In en, this message translates to:
  /// **'{moves, plural, =1{1 MOVE} other{{moves} MOVES}}'**
  String movesCount(int moves);

  /// No description provided for @goalReached.
  ///
  /// In en, this message translates to:
  /// **'Goal of {target} reached!'**
  String goalReached(int target);

  /// No description provided for @goalMoves.
  ///
  /// In en, this message translates to:
  /// **'Goal: {target} moves'**
  String goalMoves(int target);

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE'**
  String get continueButton;

  /// No description provided for @allLevelsDone.
  ///
  /// In en, this message translates to:
  /// **'ALL LEVELS DONE!'**
  String get allLevelsDone;

  /// No description provided for @tutorialTapToSelect.
  ///
  /// In en, this message translates to:
  /// **'Tap to Select Ball'**
  String get tutorialTapToSelect;

  /// No description provided for @tutorialTapAnother.
  ///
  /// In en, this message translates to:
  /// **'Tap another tube to move the ball'**
  String get tutorialTapAnother;

  /// No description provided for @tutorialSameColor.
  ///
  /// In en, this message translates to:
  /// **'Only balls of the same color can be stacked together.'**
  String get tutorialSameColor;

  /// No description provided for @tutorialSameColorIntro.
  ///
  /// In en, this message translates to:
  /// **'Tap to Select Ball\nOnly matching colors can stack!'**
  String get tutorialSameColorIntro;

  /// No description provided for @skipTutorial.
  ///
  /// In en, this message translates to:
  /// **'Skip tutorial'**
  String get skipTutorial;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it!'**
  String get gotIt;

  /// No description provided for @powerUpUndoTitle.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get powerUpUndoTitle;

  /// No description provided for @powerUpUndoBody.
  ///
  /// In en, this message translates to:
  /// **'Take back your last move.'**
  String get powerUpUndoBody;

  /// No description provided for @powerUpShuffleTitle.
  ///
  /// In en, this message translates to:
  /// **'Shuffle'**
  String get powerUpShuffleTitle;

  /// No description provided for @powerUpShuffleBody.
  ///
  /// In en, this message translates to:
  /// **'Remix the balls into a new, still-solvable puzzle.'**
  String get powerUpShuffleBody;

  /// No description provided for @powerUpAddTubeTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Tube'**
  String get powerUpAddTubeTitle;

  /// No description provided for @powerUpAddTubeBody.
  ///
  /// In en, this message translates to:
  /// **'Get an extra empty tube for this level.'**
  String get powerUpAddTubeBody;

  /// No description provided for @howToPlayTitle.
  ///
  /// In en, this message translates to:
  /// **'HOW TO PLAY'**
  String get howToPlayTitle;

  /// No description provided for @howGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Sort the colors'**
  String get howGoalTitle;

  /// No description provided for @howGoalBody.
  ///
  /// In en, this message translates to:
  /// **'Fill every tube with balls of a single color to clear the level.'**
  String get howGoalBody;

  /// No description provided for @howMoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Move a ball'**
  String get howMoveTitle;

  /// No description provided for @howMoveBody.
  ///
  /// In en, this message translates to:
  /// **'Tap a tube to lift its top ball, then tap another tube to drop it there.'**
  String get howMoveBody;

  /// No description provided for @howRuleTitle.
  ///
  /// In en, this message translates to:
  /// **'Match to stack'**
  String get howRuleTitle;

  /// No description provided for @howRuleBody.
  ///
  /// In en, this message translates to:
  /// **'A ball can only land on the same color or in an empty tube - and every tube has limited room.'**
  String get howRuleBody;

  /// No description provided for @howPowerUpsTitle.
  ///
  /// In en, this message translates to:
  /// **'Use power-ups'**
  String get howPowerUpsTitle;

  /// No description provided for @howPowerUpsBody.
  ///
  /// In en, this message translates to:
  /// **'Stuck? Undo a move, shuffle the balls or add an extra tube. Restarting refills them.'**
  String get howPowerUpsBody;

  /// No description provided for @howStarsTitle.
  ///
  /// In en, this message translates to:
  /// **'Earn 3 stars'**
  String get howStarsTitle;

  /// No description provided for @howStarsBody.
  ///
  /// In en, this message translates to:
  /// **'Solve in fewer moves for more stars. Look out for mystery balls, timers and taller tubes!'**
  String get howStarsBody;

  /// No description provided for @pageIndicator.
  ///
  /// In en, this message translates to:
  /// **'Page {page} of {total}'**
  String pageIndicator(int page, int total);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'hi',
    'pt',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
