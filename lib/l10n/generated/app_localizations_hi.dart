// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'बॉल सॉर्ट पज़ल';

  @override
  String get logoTitle => 'बॉल सॉर्ट';

  @override
  String get logoSubtitle => 'रंग  पहेली';

  @override
  String playLevel(int level) {
    return 'खेलें  ·  लेवल $level';
  }

  @override
  String continueLevel(int level) {
    return 'जारी रखें  ·  लेवल $level';
  }

  @override
  String get levels => 'लेवल';

  @override
  String levelsSolved(int solved, int total) {
    return '$total में से $solved लेवल हल किए';
  }

  @override
  String get selectLevel => 'लेवल चुनें';

  @override
  String levelTile(int level) {
    return 'लेवल $level';
  }

  @override
  String levelTileStars(int level, int stars) {
    return 'लेवल $level, $stars स्टार';
  }

  @override
  String levelTileLocked(int level) {
    return 'लेवल $level लॉक है';
  }

  @override
  String get hintMystery => 'रहस्य';

  @override
  String get hintSpecial => 'विशेष';

  @override
  String get difficultyTutorial => 'ट्यूटोरियल';

  @override
  String get difficultyEasy => 'आसान';

  @override
  String get difficultyMedium => 'मध्यम';

  @override
  String get difficultyHard => 'कठिन';

  @override
  String get difficultyExpert => 'विशेषज्ञ';

  @override
  String get difficultyMaster => 'मास्टर';

  @override
  String get difficultyChallenge => 'चुनौती';

  @override
  String get difficultyLegend => 'लीजेंड';

  @override
  String get difficultyMythic => 'मिथिक';

  @override
  String get difficultyImmortal => 'अमर';

  @override
  String levelHeader(int level) {
    return 'लेवल $level';
  }

  @override
  String movesCounter(int moves) {
    return 'चालें $moves';
  }

  @override
  String movesCounterTarget(int moves, int target) {
    return 'चालें $moves / $target';
  }

  @override
  String newMechanic(String text) {
    return 'नया: $text';
  }

  @override
  String get mechanicBasicMove =>
      'एक ट्यूब पर टैप करें, फिर गेंद ले जाने के लिए दूसरी पर टैप करें';

  @override
  String get mechanicSameColor =>
      'केवल एक जैसे रंग ही एक के ऊपर रखे जा सकते हैं';

  @override
  String get mechanicPowerUps => 'पूर्ववत करें, फेंटें और ट्यूब जोड़ें';

  @override
  String get mechanicPlanAhead => 'कई चालें आगे की योजना बनाएं';

  @override
  String get mechanicOneSpareTube => 'केवल एक खाली ट्यूब!';

  @override
  String get mechanicMystery =>
      'रहस्यमयी गेंदें: ऊपर पहुंचने पर छिपे रंग दिखते हैं';

  @override
  String get mechanicTallTubes => 'विशेष लेवल: लंबी ट्यूबें';

  @override
  String get mechanicScatteredColor => 'एक रंग लगभग हर ट्यूब में बिखरा है';

  @override
  String get mechanicBiggerBoards => 'बड़े बोर्ड';

  @override
  String get mechanicMoveTargets =>
      'चाल लक्ष्य: 3 स्टार के लिए लक्ष्य के भीतर पूरा करें';

  @override
  String get mechanicLegend => 'लीजेंड लेवल: कठिन बोर्ड, गलती की कम गुंजाइश';

  @override
  String get mechanicMythic => 'मिथिक लेवल: सारे रंग, सांस लेने की भी जगह नहीं';

  @override
  String get mechanicImmortal => 'अमर लेवल: हर बोर्ड अपनी सीमा पर';

  @override
  String get undo => 'पूर्ववत';

  @override
  String get shuffle => 'फेंटें';

  @override
  String get addTube => 'ट्यूब जोड़ें';

  @override
  String powerUpSemantics(String name, int count) {
    return '$name, $count बाकी';
  }

  @override
  String get noUndosLeft =>
      'पूर्ववत खत्म हो गए - पावर-अप भरने के लिए लेवल फिर से शुरू करें।';

  @override
  String get noShufflesLeft =>
      'फेंटना खत्म हो गया - पावर-अप भरने के लिए लेवल फिर से शुरू करें।';

  @override
  String get noTubesLeft =>
      'अतिरिक्त ट्यूबें खत्म - पावर-अप भरने के लिए लेवल फिर से शुरू करें।';

  @override
  String get nothingToUndo => 'अभी पूर्ववत करने को कुछ नहीं है।';

  @override
  String get settingsLabel => 'सेटिंग्स';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get close => 'बंद करें';

  @override
  String get back => 'वापस';

  @override
  String get home => 'होम';

  @override
  String get restartLevel => 'लेवल फिर से शुरू करें';

  @override
  String get replayLevel => 'लेवल दोबारा खेलें';

  @override
  String get sectionAudio => 'आवाज़ और कंपन';

  @override
  String get sectionGeneral => 'सामान्य';

  @override
  String get soundEffects => 'साउंड इफ़ेक्ट';

  @override
  String get music => 'संगीत';

  @override
  String get vibration => 'कंपन';

  @override
  String get theme => 'थीम';

  @override
  String get themeSystem => 'ऑटो';

  @override
  String get themeLight => 'लाइट';

  @override
  String get themeDark => 'डार्क';

  @override
  String get language => 'भाषा';

  @override
  String get howToPlay => 'कैसे खेलें';

  @override
  String get resume => 'जारी रखें';

  @override
  String get restartLevelButton => 'लेवल फिर से शुरू करें';

  @override
  String get exitToHome => 'होम पर जाएं';

  @override
  String get done => 'हो गया';

  @override
  String get chooseLanguage => 'भाषा';

  @override
  String get restartTitle => 'फिर से शुरू करें?';

  @override
  String get restartBody =>
      'यह लेवल फिर से शुरू करें?\nआपके अनलॉक किए गए लेवल सुरक्षित रहेंगे।';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get restart => 'फिर से शुरू';

  @override
  String get noMovesTitle => 'कोई चाल नहीं बची';

  @override
  String get noMovesBody =>
      'कोई मान्य चाल नहीं है। पावर-अप आज़माएं या फिर से शुरू करें।';

  @override
  String get timeUpTitle => 'समय खत्म!';

  @override
  String get timeUpBody => 'घड़ी रुक गई। एक बार और कोशिश करें!';

  @override
  String get retry => 'दोबारा कोशिश';

  @override
  String get homeButton => 'होम';

  @override
  String get specialLevelTitle => 'विशेष लेवल';

  @override
  String specialLevelBody(int capacity, int colors) {
    return 'लंबी ट्यूबों में $capacity गेंदें आती हैं।\n$colors रंग छांटें।';
  }

  @override
  String specialLevelBodyMystery(int capacity, int colors) {
    return 'लंबी ट्यूबों में $capacity गेंदें आती हैं।\n$colors रंग छांटें - और रहस्यमयी गेंदों से सावधान!';
  }

  @override
  String get play => 'खेलें';

  @override
  String get levelCompleteTitle => 'लेवल पूरा!';

  @override
  String levelSolvedIn(int level) {
    return 'लेवल $level हल किया';
  }

  @override
  String movesCount(int moves) {
    return '$moves चालों में';
  }

  @override
  String goalReached(int target) {
    return '$target का लक्ष्य पूरा!';
  }

  @override
  String goalMoves(int target) {
    return 'लक्ष्य: $target चालें';
  }

  @override
  String get continueButton => 'आगे बढ़ें';

  @override
  String get allLevelsDone => 'सभी लेवल पूरे!';

  @override
  String get tutorialTapToSelect => 'गेंद चुनने के लिए टैप करें';

  @override
  String get tutorialTapAnother =>
      'गेंद ले जाने के लिए दूसरी ट्यूब पर टैप करें';

  @override
  String get tutorialSameColor =>
      'केवल एक ही रंग की गेंदें एक साथ रखी जा सकती हैं।';

  @override
  String get tutorialSameColorIntro =>
      'गेंद चुनने के लिए टैप करें\nकेवल एक जैसे रंग ही ऊपर रखे जा सकते हैं!';

  @override
  String get skipTutorial => 'ट्यूटोरियल छोड़ें';

  @override
  String get skip => 'छोड़ें';

  @override
  String get next => 'आगे';

  @override
  String get gotIt => 'समझ गया!';

  @override
  String get powerUpUndoTitle => 'पूर्ववत';

  @override
  String get powerUpUndoBody => 'अपनी पिछली चाल वापस लें।';

  @override
  String get powerUpShuffleTitle => 'फेंटें';

  @override
  String get powerUpShuffleBody =>
      'गेंदों को एक नई, हल होने योग्य पहेली में मिलाएं।';

  @override
  String get powerUpAddTubeTitle => 'ट्यूब जोड़ें';

  @override
  String get powerUpAddTubeBody =>
      'इस लेवल के लिए एक अतिरिक्त खाली ट्यूब पाएं।';

  @override
  String get howToPlayTitle => 'कैसे खेलें';

  @override
  String get howGoalTitle => 'रंग छांटें';

  @override
  String get howGoalBody =>
      'लेवल पूरा करने के लिए हर ट्यूब को एक ही रंग की गेंदों से भरें।';

  @override
  String get howMoveTitle => 'गेंद हिलाएं';

  @override
  String get howMoveBody =>
      'ऊपर की गेंद उठाने के लिए ट्यूब पर टैप करें, फिर उसे रखने के लिए दूसरी ट्यूब पर टैप करें।';

  @override
  String get howRuleTitle => 'रंग मिलाएं';

  @override
  String get howRuleBody =>
      'गेंद केवल उसी रंग पर या खाली ट्यूब में रखी जा सकती है - और हर ट्यूब में सीमित जगह है।';

  @override
  String get howPowerUpsTitle => 'पावर-अप इस्तेमाल करें';

  @override
  String get howPowerUpsBody =>
      'अटक गए? चाल पूर्ववत करें, गेंदें फेंटें या एक ट्यूब जोड़ें। फिर से शुरू करने पर ये भर जाते हैं।';

  @override
  String get howStarsTitle => '3 स्टार पाएं';

  @override
  String get howStarsBody =>
      'कम चालों में हल करें और ज़्यादा स्टार पाएं। रहस्यमयी गेंदों, टाइमर और लंबी ट्यूबों पर नज़र रखें!';

  @override
  String pageIndicator(int page, int total) {
    return 'पेज $page / $total';
  }
}
