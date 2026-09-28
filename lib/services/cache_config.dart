import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class FlagCacheManager extends CacheManager {
  static const key = 'flagCache';

  static final FlagCacheManager _instance = FlagCacheManager._();

  factory FlagCacheManager() => _instance;

  FlagCacheManager._()
      : super(
          Config(
            key,
            stalePeriod: const Duration(days: 30),
            maxNrOfCacheObjects: 500,
            repo: JsonCacheInfoRepository(databaseName: key),
            fileService: HttpFileService(),
          ),
        );
}
