// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Ball Sort Puzzle';

  @override
  String get logoTitle => 'BALL SORT';

  @override
  String get logoSubtitle => 'QUEBRA-CABEÇA  DE  CORES';

  @override
  String playLevel(int level) {
    return 'JOGAR  ·  NÍVEL $level';
  }

  @override
  String continueLevel(int level) {
    return 'CONTINUAR  ·  NÍVEL $level';
  }

  @override
  String get levels => 'NÍVEIS';

  @override
  String levelsSolved(int solved, int total) {
    return '$solved de $total níveis resolvidos';
  }

  @override
  String get selectLevel => 'ESCOLHA O NÍVEL';

  @override
  String levelTile(int level) {
    return 'Nível $level';
  }

  @override
  String levelTileStars(int level, int stars) {
    String _temp0 = intl.Intl.pluralLogic(
      stars,
      locale: localeName,
      other: '$stars estrelas',
      one: '1 estrela',
    );
    return 'Nível $level, $_temp0';
  }

  @override
  String levelTileLocked(int level) {
    return 'Nível $level bloqueado';
  }

  @override
  String get hintMystery => 'mistério';

  @override
  String get hintSpecial => 'especial';

  @override
  String get difficultyTutorial => 'Tutorial';

  @override
  String get difficultyEasy => 'Fácil';

  @override
  String get difficultyMedium => 'Médio';

  @override
  String get difficultyHard => 'Difícil';

  @override
  String get difficultyExpert => 'Especialista';

  @override
  String get difficultyMaster => 'Mestre';

  @override
  String get difficultyChallenge => 'Desafio';

  @override
  String get difficultyLegend => 'Lenda';

  @override
  String get difficultyMythic => 'Mítico';

  @override
  String get difficultyImmortal => 'Imortal';

  @override
  String levelHeader(int level) {
    return 'NÍVEL $level';
  }

  @override
  String movesCounter(int moves) {
    return 'JOGADAS $moves';
  }

  @override
  String movesCounterTarget(int moves, int target) {
    return 'JOGADAS $moves / $target';
  }

  @override
  String newMechanic(String text) {
    return 'NOVO: $text';
  }

  @override
  String get mechanicBasicMove =>
      'Toque num tubo e depois em outro para mover uma bola';

  @override
  String get mechanicSameColor => 'Só cores iguais se empilham';

  @override
  String get mechanicPowerUps => 'Desfazer, Embaralhar e Adicionar tubo';

  @override
  String get mechanicPlanAhead => 'Planeje várias jogadas à frente';

  @override
  String get mechanicOneSpareTube => 'Só um tubo livre!';

  @override
  String get mechanicMystery =>
      'Bolas misteriosas: as cores ocultas aparecem ao chegar ao topo';

  @override
  String get mechanicTallTubes => 'Nível especial: tubos mais altos';

  @override
  String get mechanicScatteredColor =>
      'Uma cor está espalhada por quase todos os tubos';

  @override
  String get mechanicBiggerBoards => 'Tabuleiros maiores';

  @override
  String get mechanicMoveTargets =>
      'Meta de jogadas: termine dentro da meta para 3 estrelas';

  @override
  String get mechanicLegend =>
      'Níveis Lenda: tabuleiros brutais, pouca margem para erros';

  @override
  String get mechanicMythic =>
      'Níveis Míticos: todas as cores, quase sem respiro';

  @override
  String get mechanicImmortal =>
      'Níveis Imortais: cada tabuleiro levado ao limite';

  @override
  String get undo => 'DESFAZER';

  @override
  String get shuffle => 'EMBARALHAR';

  @override
  String get addTube => 'ADD TUBO';

  @override
  String powerUpSemantics(String name, int count) {
    return '$name, restam $count';
  }

  @override
  String get noUndosLeft =>
      'Sem desfazer - reinicie o nível para recarregar os poderes.';

  @override
  String get noShufflesLeft =>
      'Sem embaralhar - reinicie o nível para recarregar os poderes.';

  @override
  String get noTubesLeft =>
      'Sem tubos extras - reinicie o nível para recarregar os poderes.';

  @override
  String get nothingToUndo => 'Ainda não há nada para desfazer.';

  @override
  String get settingsLabel => 'Configurações';

  @override
  String get settings => 'CONFIGURAÇÕES';

  @override
  String get close => 'Fechar';

  @override
  String get back => 'Voltar';

  @override
  String get home => 'Início';

  @override
  String get restartLevel => 'Reiniciar nível';

  @override
  String get replayLevel => 'Jogar de novo';

  @override
  String get sectionAudio => 'SOM E VIBRAÇÃO';

  @override
  String get sectionGeneral => 'GERAL';

  @override
  String get soundEffects => 'Efeitos sonoros';

  @override
  String get music => 'Música';

  @override
  String get vibration => 'Vibração';

  @override
  String get theme => 'Tema';

  @override
  String get themeSystem => 'Auto';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get language => 'Idioma';

  @override
  String get howToPlay => 'Como jogar';

  @override
  String get resume => 'CONTINUAR';

  @override
  String get restartLevelButton => 'REINICIAR NÍVEL';

  @override
  String get exitToHome => 'VOLTAR AO INÍCIO';

  @override
  String get done => 'PRONTO';

  @override
  String get chooseLanguage => 'IDIOMA';

  @override
  String get restartTitle => 'REINICIAR?';

  @override
  String get restartBody =>
      'Começar este nível de novo?\nSeus níveis desbloqueados são mantidos.';

  @override
  String get cancel => 'CANCELAR';

  @override
  String get restart => 'REINICIAR';

  @override
  String get noMovesTitle => 'SEM JOGADAS';

  @override
  String get noMovesBody => 'Não há jogadas válidas. Use um poder ou reinicie.';

  @override
  String get timeUpTitle => 'O TEMPO ACABOU!';

  @override
  String get timeUpBody => 'O relógio zerou. Tente outra vez!';

  @override
  String get retry => 'TENTAR DE NOVO';

  @override
  String get homeButton => 'INÍCIO';

  @override
  String get specialLevelTitle => 'NÍVEL ESPECIAL';

  @override
  String specialLevelBody(int capacity, int colors) {
    return 'Tubos altos cabem $capacity bolas cada.\nOrganize $colors cores.';
  }

  @override
  String specialLevelBodyMystery(int capacity, int colors) {
    return 'Tubos altos cabem $capacity bolas cada.\nOrganize $colors cores - e cuidado com as bolas misteriosas!';
  }

  @override
  String get play => 'JOGAR';

  @override
  String get levelCompleteTitle => 'NÍVEL CONCLUÍDO!';

  @override
  String levelSolvedIn(int level) {
    return 'Nível $level resolvido em';
  }

  @override
  String movesCount(int moves) {
    String _temp0 = intl.Intl.pluralLogic(
      moves,
      locale: localeName,
      other: '$moves JOGADAS',
      one: '1 JOGADA',
    );
    return '$_temp0';
  }

  @override
  String goalReached(int target) {
    return 'Meta de $target alcançada!';
  }

  @override
  String goalMoves(int target) {
    return 'Meta: $target jogadas';
  }

  @override
  String get continueButton => 'CONTINUAR';

  @override
  String get allLevelsDone => 'TODOS OS NÍVEIS!';

  @override
  String get tutorialTapToSelect => 'Toque para escolher uma bola';

  @override
  String get tutorialTapAnother => 'Toque em outro tubo para mover a bola';

  @override
  String get tutorialSameColor => 'Só bolas da mesma cor podem ser empilhadas.';

  @override
  String get tutorialSameColorIntro =>
      'Toque para escolher uma bola\nSó cores iguais se empilham!';

  @override
  String get skipTutorial => 'Pular tutorial';

  @override
  String get skip => 'Pular';

  @override
  String get next => 'Próximo';

  @override
  String get gotIt => 'Entendi!';

  @override
  String get powerUpUndoTitle => 'Desfazer';

  @override
  String get powerUpUndoBody => 'Volte sua última jogada.';

  @override
  String get powerUpShuffleTitle => 'Embaralhar';

  @override
  String get powerUpShuffleBody =>
      'Misture as bolas num novo quebra-cabeça que ainda tem solução.';

  @override
  String get powerUpAddTubeTitle => 'Adicionar tubo';

  @override
  String get powerUpAddTubeBody => 'Ganhe um tubo vazio extra para este nível.';

  @override
  String get howToPlayTitle => 'COMO JOGAR';

  @override
  String get howGoalTitle => 'Separe as cores';

  @override
  String get howGoalBody =>
      'Encha cada tubo com bolas de uma única cor para passar de nível.';

  @override
  String get howMoveTitle => 'Mova uma bola';

  @override
  String get howMoveBody =>
      'Toque num tubo para erguer a bola de cima e depois toque em outro tubo para soltá-la.';

  @override
  String get howRuleTitle => 'Combine para empilhar';

  @override
  String get howRuleBody =>
      'Uma bola só cai sobre a mesma cor ou num tubo vazio - e cada tubo tem espaço limitado.';

  @override
  String get howPowerUpsTitle => 'Use os poderes';

  @override
  String get howPowerUpsBody =>
      'Travou? Desfaça uma jogada, embaralhe as bolas ou adicione um tubo. Reiniciar os recarrega.';

  @override
  String get howStarsTitle => 'Ganhe 3 estrelas';

  @override
  String get howStarsBody =>
      'Menos jogadas, mais estrelas. Fique de olho nas bolas misteriosas, nos relógios e nos tubos altos!';

  @override
  String pageIndicator(int page, int total) {
    return 'Página $page de $total';
  }
}
