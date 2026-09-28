import 'package:flutter_test/flutter_test.dart';
import 'package:country_trivia/domain/entities/country.dart';
import 'package:country_trivia/domain/repositories/country_repository.dart';
import 'package:country_trivia/presentation/providers/game_provider.dart';

class MockCountryRepository implements CountryRepository {
  List<Country> _countries = [];
  List<String> _solvedCodes = [];
  int _totalPoints = 0;

  void setCountries(List<Country> countries) {
    _countries = countries;
  }

  void setSolvedCodes(List<String> codes) {
    _solvedCodes = codes;
  }

  void setTotalPoints(int points) {
    _totalPoints = points;
  }

  @override
  Future<List<Country>> getCountries() async => _countries;

  @override
  Future<List<String>> getSolvedCountryCodes() async => _solvedCodes;

  @override
  Future<void> saveSolvedCountryCode(String code) async {
    _solvedCodes.add(code);
  }

  @override
  Future<int> getTotalPoints() async => _totalPoints;

  @override
  Future<void> saveTotalPoints(int points) async {
    _totalPoints = points;
  }

  @override
  Future<void> resetProgress() async {
    _solvedCodes = [];
    _totalPoints = 0;
  }
}

void main() {
  late MockCountryRepository mockRepository;
  late GameProvider gameProvider;

  final testCountries = [
    const Country(name: 'Germany', alpha2Code: 'de', flagUrl: 'https://flagcdn.com/w320/de.png'),
    const Country(name: 'France', alpha2Code: 'fr', flagUrl: 'https://flagcdn.com/w320/fr.png'),
    const Country(name: 'Spain', alpha2Code: 'es', flagUrl: 'https://flagcdn.com/w320/es.png'),
    const Country(name: 'Italy', alpha2Code: 'it', flagUrl: 'https://flagcdn.com/w320/it.png'),
    const Country(name: 'Japan', alpha2Code: 'jp', flagUrl: 'https://flagcdn.com/w320/jp.png'),
  ];

  setUp(() {
    mockRepository = MockCountryRepository();
    mockRepository.setCountries(testCountries);
    gameProvider = GameProvider(repository: mockRepository);
  });

  group('GameProvider', () {
    test('initial state is loading', () {
      expect(gameProvider.status, GameStatus.loading);
      expect(gameProvider.totalPoints, 0);
      expect(gameProvider.attempts, 0);
    });

    test('initialize loads countries and starts first round', () async {
      await gameProvider.initialize();

      expect(gameProvider.status, GameStatus.ready);
      expect(gameProvider.options.length, 4);
      expect(gameProvider.attempts, 0);
      expect(gameProvider.totalPoints, 0);
    });

    test('correct answer on first try awards 10 points', () async {
      await gameProvider.initialize();

      final correctCountry = gameProvider.correctCountry!;
      final correctIndex = gameProvider.options.indexWhere(
        (c) => c.alpha2Code == correctCountry.alpha2Code,
      );

      await gameProvider.selectAnswer(correctIndex);

      expect(gameProvider.status, GameStatus.answeredCorrect);
      expect(gameProvider.roundPoints, 10);
      expect(gameProvider.totalPoints, 10);
    });

    test('correct answer on second try awards 8 points', () async {
      await gameProvider.initialize();

      final correctCountry = gameProvider.correctCountry!;
      final wrongIndex = gameProvider.options.indexWhere(
        (c) => c.alpha2Code != correctCountry.alpha2Code,
      );

      await gameProvider.selectAnswer(wrongIndex);
      expect(gameProvider.status, GameStatus.answeredWrong);
      expect(gameProvider.attempts, 1);

      final correctIndex = gameProvider.options.indexWhere(
        (c) => c.alpha2Code == correctCountry.alpha2Code,
      );
      await gameProvider.selectAnswer(correctIndex);

      expect(gameProvider.status, GameStatus.answeredCorrect);
      expect(gameProvider.roundPoints, 8);
      expect(gameProvider.totalPoints, 8);
    });

    test('correct answer on third try awards 5 points', () async {
      await gameProvider.initialize();

      final correctCountry = gameProvider.correctCountry!;
      final wrongIndices = gameProvider.options
          .asMap()
          .entries
          .where((e) => e.value.alpha2Code != correctCountry.alpha2Code)
          .map((e) => e.key)
          .toList();

      await gameProvider.selectAnswer(wrongIndices[0]);
      await gameProvider.selectAnswer(wrongIndices[1]);
      expect(gameProvider.attempts, 2);

      final correctIndex = gameProvider.options.indexWhere(
        (c) => c.alpha2Code == correctCountry.alpha2Code,
      );
      await gameProvider.selectAnswer(correctIndex);

      expect(gameProvider.status, GameStatus.answeredCorrect);
      expect(gameProvider.roundPoints, 5);
      expect(gameProvider.totalPoints, 5);
    });

    test('all attempts exhausted awards 0 points and shows correct answer', () async {
      await gameProvider.initialize();

      final correctCountry = gameProvider.correctCountry!;
      final wrongIndices = gameProvider.options
          .asMap()
          .entries
          .where((e) => e.value.alpha2Code != correctCountry.alpha2Code)
          .map((e) => e.key)
          .toList();

      await gameProvider.selectAnswer(wrongIndices[0]);
      await gameProvider.selectAnswer(wrongIndices[1]);
      await gameProvider.selectAnswer(wrongIndices[2]);

      expect(gameProvider.status, GameStatus.roundOver);
      expect(gameProvider.roundPoints, 0);
      expect(gameProvider.totalPoints, 0);
      expect(gameProvider.correctCountry, correctCountry);
    });

    test('solved countries are filtered out in next rounds', () async {
      await gameProvider.initialize();

      final firstCountry = gameProvider.correctCountry!;
      final correctIndex = gameProvider.options.indexWhere(
        (c) => c.alpha2Code == firstCountry.alpha2Code,
      );
      await gameProvider.selectAnswer(correctIndex);
      await gameProvider.nextRound();

      expect(gameProvider.status, GameStatus.ready);
      expect(gameProvider.options.any((c) => c.alpha2Code == firstCountry.alpha2Code), false);
    });

    test('resetProgress clears all data', () async {
      await gameProvider.initialize();

      final correctCountry = gameProvider.correctCountry!;
      final correctIndex = gameProvider.options.indexWhere(
        (c) => c.alpha2Code == correctCountry.alpha2Code,
      );
      await gameProvider.selectAnswer(correctIndex);

      expect(gameProvider.totalPoints, 10);

      await gameProvider.resetProgress();

      expect(gameProvider.totalPoints, 0);
      expect(gameProvider.status, GameStatus.ready);
    });

    test('options are always 4 unique countries', () async {
      await gameProvider.initialize();

      final codes = gameProvider.options.map((c) => c.alpha2Code).toSet();
      expect(gameProvider.options.length, 4);
      expect(codes.length, 4);
    });

    test('correct country is always in options', () async {
      await gameProvider.initialize();

      final correctCountry = gameProvider.correctCountry!;
      expect(
        gameProvider.options.any((c) => c.alpha2Code == correctCountry.alpha2Code),
        true,
      );
    });
  });
}
