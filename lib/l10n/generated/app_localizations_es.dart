// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Ball Sort Puzzle';

  @override
  String get logoTitle => 'BALL SORT';

  @override
  String get logoSubtitle => 'PUZLE  DE  COLORES';

  @override
  String playLevel(int level) {
    return 'JUGAR  ·  NIVEL $level';
  }

  @override
  String continueLevel(int level) {
    return 'CONTINUAR  ·  NIVEL $level';
  }

  @override
  String get levels => 'NIVELES';

  @override
  String levelsSolved(int solved, int total) {
    return '$solved de $total niveles resueltos';
  }

  @override
  String get selectLevel => 'ELIGE NIVEL';

  @override
  String levelTile(int level) {
    return 'Nivel $level';
  }

  @override
  String levelTileStars(int level, int stars) {
    String _temp0 = intl.Intl.pluralLogic(
      stars,
      locale: localeName,
      other: '$stars estrellas',
      one: '1 estrella',
    );
    return 'Nivel $level, $_temp0';
  }

  @override
  String levelTileLocked(int level) {
    return 'Nivel $level bloqueado';
  }

  @override
  String get hintMystery => 'misterio';

  @override
  String get hintSpecial => 'especial';

  @override
  String get difficultyTutorial => 'Tutorial';

  @override
  String get difficultyEasy => 'Fácil';

  @override
  String get difficultyMedium => 'Medio';

  @override
  String get difficultyHard => 'Difícil';

  @override
  String get difficultyExpert => 'Experto';

  @override
  String get difficultyMaster => 'Maestro';

  @override
  String get difficultyChallenge => 'Desafío';

  @override
  String get difficultyLegend => 'Leyenda';

  @override
  String get difficultyMythic => 'Mítico';

  @override
  String get difficultyImmortal => 'Inmortal';

  @override
  String levelHeader(int level) {
    return 'NIVEL $level';
  }

  @override
  String movesCounter(int moves) {
    return 'MOVIMIENTOS $moves';
  }

  @override
  String movesCounterTarget(int moves, int target) {
    return 'MOVIMIENTOS $moves / $target';
  }

  @override
  String newMechanic(String text) {
    return 'NUEVO: $text';
  }

  @override
  String get mechanicBasicMove =>
      'Toca un tubo y luego otro para mover una bola';

  @override
  String get mechanicSameColor => 'Solo se apilan colores iguales';

  @override
  String get mechanicPowerUps => 'Deshacer, Mezclar y Añadir tubo';

  @override
  String get mechanicPlanAhead => 'Planea varios movimientos por adelantado';

  @override
  String get mechanicOneSpareTube => '¡Solo un tubo libre!';

  @override
  String get mechanicMystery =>
      'Bolas misteriosas: los colores ocultos se revelan al llegar arriba';

  @override
  String get mechanicTallTubes => 'Nivel especial: tubos más altos';

  @override
  String get mechanicScatteredColor =>
      'Un color está repartido por casi todos los tubos';

  @override
  String get mechanicBiggerBoards => 'Tableros más grandes';

  @override
  String get mechanicMoveTargets =>
      'Objetivo de movimientos: termina dentro del objetivo para 3 estrellas';

  @override
  String get mechanicLegend =>
      'Niveles Leyenda: tableros brutales, poco margen de error';

  @override
  String get mechanicMythic =>
      'Niveles Míticos: toda la paleta, casi sin respiro';

  @override
  String get mechanicImmortal => 'Niveles Inmortales: cada tablero al límite';

  @override
  String get undo => 'DESHACER';

  @override
  String get shuffle => 'MEZCLAR';

  @override
  String get addTube => 'AÑADIR TUBO';

  @override
  String powerUpSemantics(String name, int count) {
    return '$name, quedan $count';
  }

  @override
  String get noUndosLeft =>
      'No quedan deshacer: reinicia el nivel para recargar los potenciadores.';

  @override
  String get noShufflesLeft =>
      'No quedan mezclas: reinicia el nivel para recargar los potenciadores.';

  @override
  String get noTubesLeft =>
      'No quedan tubos extra: reinicia el nivel para recargar los potenciadores.';

  @override
  String get nothingToUndo => 'Aún no hay nada que deshacer.';

  @override
  String get settingsLabel => 'Ajustes';

  @override
  String get settings => 'AJUSTES';

  @override
  String get close => 'Cerrar';

  @override
  String get back => 'Atrás';

  @override
  String get home => 'Inicio';

  @override
  String get restartLevel => 'Reiniciar nivel';

  @override
  String get replayLevel => 'Repetir nivel';

  @override
  String get sectionAudio => 'SONIDO Y TACTO';

  @override
  String get sectionGeneral => 'GENERAL';

  @override
  String get soundEffects => 'Efectos de sonido';

  @override
  String get music => 'Música';

  @override
  String get vibration => 'Vibración';

  @override
  String get theme => 'Tema';

  @override
  String get themeSystem => 'Auto';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get language => 'Idioma';

  @override
  String get howToPlay => 'Cómo jugar';

  @override
  String get resume => 'REANUDAR';

  @override
  String get restartLevelButton => 'REINICIAR NIVEL';

  @override
  String get exitToHome => 'SALIR AL INICIO';

  @override
  String get done => 'LISTO';

  @override
  String get chooseLanguage => 'IDIOMA';

  @override
  String get restartTitle => '¿REINICIAR?';

  @override
  String get restartBody =>
      '¿Empezar este nivel de nuevo?\nTus niveles desbloqueados se conservan.';

  @override
  String get cancel => 'CANCELAR';

  @override
  String get restart => 'REINICIAR';

  @override
  String get noMovesTitle => 'SIN MOVIMIENTOS';

  @override
  String get noMovesBody =>
      'No hay movimientos válidos. Usa un potenciador o reinicia.';

  @override
  String get timeUpTitle => '¡SE ACABÓ EL TIEMPO!';

  @override
  String get timeUpBody => 'El reloj llegó a cero. ¡Inténtalo otra vez!';

  @override
  String get retry => 'REINTENTAR';

  @override
  String get homeButton => 'INICIO';

  @override
  String get specialLevelTitle => 'NIVEL ESPECIAL';

  @override
  String specialLevelBody(int capacity, int colors) {
    return 'Los tubos altos caben $capacity bolas.\nOrdena $colors colores.';
  }

  @override
  String specialLevelBodyMystery(int capacity, int colors) {
    return 'Los tubos altos caben $capacity bolas.\nOrdena $colors colores, ¡y cuidado con las bolas misteriosas!';
  }

  @override
  String get play => 'JUGAR';

  @override
  String get levelCompleteTitle => '¡NIVEL COMPLETADO!';

  @override
  String levelSolvedIn(int level) {
    return 'Nivel $level resuelto en';
  }

  @override
  String movesCount(int moves) {
    String _temp0 = intl.Intl.pluralLogic(
      moves,
      locale: localeName,
      other: '$moves MOVIMIENTOS',
      one: '1 MOVIMIENTO',
    );
    return '$_temp0';
  }

  @override
  String goalReached(int target) {
    return '¡Objetivo de $target cumplido!';
  }

  @override
  String goalMoves(int target) {
    return 'Objetivo: $target movimientos';
  }

  @override
  String get continueButton => 'CONTINUAR';

  @override
  String get allLevelsDone => '¡TODOS LOS NIVELES!';

  @override
  String get tutorialTapToSelect => 'Toca para elegir una bola';

  @override
  String get tutorialTapAnother => 'Toca otro tubo para mover la bola';

  @override
  String get tutorialSameColor =>
      'Solo se pueden apilar bolas del mismo color.';

  @override
  String get tutorialSameColorIntro =>
      'Toca para elegir una bola\n¡Solo se apilan colores iguales!';

  @override
  String get skipTutorial => 'Saltar tutorial';

  @override
  String get skip => 'Saltar';

  @override
  String get next => 'Siguiente';

  @override
  String get gotIt => '¡Entendido!';

  @override
  String get powerUpUndoTitle => 'Deshacer';

  @override
  String get powerUpUndoBody => 'Anula tu último movimiento.';

  @override
  String get powerUpShuffleTitle => 'Mezclar';

  @override
  String get powerUpShuffleBody =>
      'Remezcla las bolas en un puzle nuevo que sigue teniendo solución.';

  @override
  String get powerUpAddTubeTitle => 'Añadir tubo';

  @override
  String get powerUpAddTubeBody =>
      'Consigue un tubo vacío extra para este nivel.';

  @override
  String get howToPlayTitle => 'CÓMO JUGAR';

  @override
  String get howGoalTitle => 'Ordena los colores';

  @override
  String get howGoalBody =>
      'Llena cada tubo con bolas de un solo color para superar el nivel.';

  @override
  String get howMoveTitle => 'Mueve una bola';

  @override
  String get howMoveBody =>
      'Toca un tubo para levantar su bola superior y luego toca otro tubo para soltarla.';

  @override
  String get howRuleTitle => 'Iguala para apilar';

  @override
  String get howRuleBody =>
      'Una bola solo cae sobre su mismo color o en un tubo vacío, y cada tubo tiene espacio limitado.';

  @override
  String get howPowerUpsTitle => 'Usa potenciadores';

  @override
  String get howPowerUpsBody =>
      '¿Atascado? Deshaz un movimiento, mezcla las bolas o añade un tubo. Al reiniciar se recargan.';

  @override
  String get howStarsTitle => 'Gana 3 estrellas';

  @override
  String get howStarsBody =>
      'Resuelve con menos movimientos para más estrellas. ¡Atento a las bolas misteriosas, los relojes y los tubos altos!';

  @override
  String pageIndicator(int page, int total) {
    return 'Página $page de $total';
  }
}
