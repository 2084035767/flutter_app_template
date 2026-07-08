// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:my_app/core/app_config.dart' as _i122;
import 'package:my_app/core/config/user_preferences.dart' as _i257;
import 'package:my_app/core/core_module.dart' as _i316;
import 'package:my_app/core/local/file_storage.dart' as _i415;
import 'package:my_app/core/network/dio_client.dart' as _i488;
import 'package:my_app/core/storage/auth_storage.dart' as _i490;
import 'package:my_app/features/article/application/article_view_model.dart'
    as _i725;
import 'package:my_app/features/article/data/article_api.dart' as _i582;
import 'package:my_app/features/article/data/article_module.dart' as _i481;
import 'package:my_app/features/article/data/article_service.dart' as _i86;
import 'package:my_app/features/article/domain/article_repository.dart'
    as _i838;
import 'package:my_app/features/auth/application/auth_view_model.dart' as _i484;
import 'package:my_app/features/auth/data/auth_api.dart' as _i738;
import 'package:my_app/features/auth/data/auth_module.dart' as _i144;
import 'package:my_app/features/auth/data/auth_service.dart' as _i514;
import 'package:my_app/features/auth/domain/auth_repository.dart' as _i478;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final coreModule = _$CoreModule();
    final networkModule = _$NetworkModule();
    final articleModule = _$ArticleModule();
    final authModule = _$AuthModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => coreModule.prefs,
      preResolve: true,
    );
    gh.singletonAsync<_i257.UserPreferences>(() {
      final i = _i257.UserPreferences();
      return i.init().then((_) => i);
    });
    gh.singletonAsync<_i415.FileStorage>(() {
      final i = _i415.FileStorage();
      return i.init().then((_) => i);
    });
    gh.singletonAsync<_i490.AuthStorage>(() {
      final i = _i490.AuthStorage();
      return i.init().then((_) => i);
    });
    gh.lazySingletonAsync<_i361.Dio>(
      () async => networkModule.dio(await getAsync<_i257.UserPreferences>()),
    );
    gh.singletonAsync<_i122.AppConfig>(
      () async => _i122.AppConfig(
        await getAsync<_i257.UserPreferences>(),
        await getAsync<_i490.AuthStorage>(),
      ),
    );
    gh.lazySingletonAsync<_i582.ArticleApi>(
      () async => articleModule.articleApi(await getAsync<_i361.Dio>()),
    );
    gh.lazySingletonAsync<_i738.AuthApi>(
      () async => authModule.authApi(await getAsync<_i361.Dio>()),
    );
    gh.lazySingletonAsync<_i838.ArticleRepository>(
      () async => _i86.ArticleService(await getAsync<_i582.ArticleApi>()),
    );
    gh.lazySingletonAsync<_i478.AuthRepository>(
      () async => _i514.AuthService(
        await getAsync<_i738.AuthApi>(),
        await getAsync<_i490.AuthStorage>(),
      ),
    );
    gh.factoryAsync<_i484.AuthViewModel>(
      () async => _i484.AuthViewModel(await getAsync<_i478.AuthRepository>()),
    );
    gh.factoryAsync<_i725.ArticleViewModel>(
      () async =>
          _i725.ArticleViewModel(await getAsync<_i838.ArticleRepository>()),
    );
    return this;
  }
}

class _$CoreModule extends _i316.CoreModule {}

class _$NetworkModule extends _i488.NetworkModule {}

class _$ArticleModule extends _i481.ArticleModule {}

class _$AuthModule extends _i144.AuthModule {}
