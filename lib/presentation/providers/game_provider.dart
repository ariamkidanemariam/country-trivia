import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../domain/entities/country.dart';
import '../../domain/repositories/country_repository.dart';

enum GameStatus { loading, ready, answeredCorrect, answeredWrong, roundOver }

class GameProvider extends ChangeNotifier {
  final CountryRepository repository;

  GameProvider({required this.repository});

  GameStatus _status = GameStatus.loading;
  List<Country> _allCountries = [];
  List<String> _solvedCodes = [];
  int _totalPoints = 0;

  Country? _correctCountry;
  List<Country> _options = [];
  int _attempts = 0;
  int _roundPoints = 0;
  int? _selectedIndex;
  bool? _wasCorrect;

  GameStatus get status => _status;
  int get totalPoints => _totalPoints;
  int get attempts => _attempts;
  int get maxAttempts => 3;
  Country? get correctCountry => _correctCountry;
  List<Country> get options => List.unmodifiable(_options);
  int? get selectedIndex => _selectedIndex;
  bool? get wasCorrect => _wasCorrect;
  int get roundPoints => _roundPoints;

  static const List<int> _pointsTable = [10, 8, 5];

  Future<void> initialize() async {
    _status = GameStatus.loading;
    notifyListeners();

    try {
      _allCountries = await repository.getCountries();
      _solvedCodes = await repository.getSolvedCountryCodes();
      _totalPoints = await repository.getTotalPoints();
      await startNewRound();
    } catch (e) {
      _status = GameStatus.loading;
      notifyListeners();
    }
  }

  Future<void> startNewRound() async {
    final available = _allCountries
        .where((c) => !_solvedCodes.contains(c.alpha2Code))
        .toList();

    if (available.isEmpty) {
      _status = GameStatus.roundOver;
      notifyListeners();
      return;
    }

    final random = Random();
    _correctCountry = available[random.nextInt(available.length)];

    final distractors = <Country>[];
    final pool = List<Country>.from(available)
      ..remove(_correctCountry);
    pool.shuffle(random);

    for (var i = 0; i < 3 && i < pool.length; i++) {
      distractors.add(pool[i]);
    }

    _options = [_correctCountry!, ...distractors]..shuffle(random);
    _attempts = 0;
    _roundPoints = 0;
    _selectedIndex = null;
    _wasCorrect = null;
    _status = GameStatus.ready;
    notifyListeners();
  }

  Future<void> selectAnswer(int index) async {
    if (_status != GameStatus.ready || _correctCountry == null) return;

    _selectedIndex = index;
    final selected = _options[index];
    _wasCorrect = selected.alpha2Code == _correctCountry!.alpha2Code;

    if (_wasCorrect!) {
      _roundPoints = _pointsTable[_attempts];
      _totalPoints += _roundPoints;
      _status = GameStatus.answeredCorrect;
      notifyListeners();

      await repository.saveSolvedCountryCode(_correctCountry!.alpha2Code);
      await repository.saveTotalPoints(_totalPoints);
      _solvedCodes.add(_correctCountry!.alpha2Code);
    } else {
      _attempts++;
      if (_attempts >= maxAttempts) {
        _status = GameStatus.roundOver;
        notifyListeners();

        await repository.saveSolvedCountryCode(_correctCountry!.alpha2Code);
        _solvedCodes.add(_correctCountry!.alpha2Code);
      } else {
        _status = GameStatus.answeredWrong;
        notifyListeners();
      }
    }
  }

  Future<void> nextRound() async {
    await startNewRound();
  }

  Future<void> resetProgress() async {
    await repository.resetProgress();
    _solvedCodes = [];
    _totalPoints = 0;
    await initialize();
  }
}
