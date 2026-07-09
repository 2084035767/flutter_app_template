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
    gh.factory<_i725.ArticleViewModel>(() => _i725.ArticleViewModel());
    gh.factory<_i484.AuthViewModel>(() => _i484.AuthViewModel());
    gh.singleton<_i257.UserPreferences>(() => _i257.UserPreferences());
    gh.singleton<_i415.FileStorage>(() => _i415.FileStorage());
    gh.singleton<_i490.AuthStorage>(() => _i490.AuthStorage());
    gh.factory<_i361.Dio>(() => networkModule.dio(gh<_i257.UserPreferences>()));
    gh.singleton<_i122.AppConfig>(
      () =>
          _i122.AppConfig(gh<_i257.UserPreferences>(), gh<_i490.AuthStorage>()),
    );
    gh.lazySingleton<_i582.ArticleApi>(
      () => articleModule.articleApi(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i738.AuthApi>(() => authModule.authApi(gh<_i361.Dio>()));
    gh.lazySingleton<_i838.ArticleRepository>(
      () => _i86.ArticleService(gh<_i582.ArticleApi>()),
    );
    gh.lazySingleton<_i478.AuthRepository>(
      () => _i514.AuthService(gh<_i738.AuthApi>(), gh<_i490.AuthStorage>()),
    );
    return this;
  }
}

class _$CoreModule extends _i316.CoreModule {}

class _$NetworkModule extends _i488.NetworkModule {}

class _$ArticleModule extends _i481.ArticleModule {}

class _$AuthModule extends _i144.AuthModule {}
