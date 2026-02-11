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
import 'package:my_app/core/local/file_storage.dart' as _i415;
import 'package:my_app/core/network/network_module.dart' as _i606;
import 'package:my_app/di/app_module.dart' as _i274;
import 'package:my_app/features/article/application/article_view_model.dart'
    as _i725;
import 'package:my_app/features/article/data/article_api.dart' as _i582;
import 'package:my_app/features/article/data/article_service.dart' as _i86;
import 'package:my_app/features/article/domain/article_repository.dart'
    as _i838;
import 'package:my_app/features/auth/application/auth_view_model.dart' as _i484;
import 'package:my_app/features/auth/data/auth_api.dart' as _i738;
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
    final appModule = _$AppModule();
    final networkModule = _$NetworkModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => appModule.prefs,
      preResolve: true,
    );
    gh.lazySingletonAsync<_i415.FileStorage>(() {
      final i = _i415.FileStorage();
      return i.init().then((_) => i);
    });
    gh.lazySingleton<_i361.Dio>(() => networkModule.dio);
    gh.lazySingleton<_i738.AuthApi>(() => networkModule.authApi);
    gh.lazySingleton<_i582.ArticleApi>(() => networkModule.articleApi);
    gh.lazySingleton<_i478.AuthRepository>(
      () => _i514.AuthService(gh<_i738.AuthApi>()),
    );
    gh.lazySingleton<_i838.ArticleRepository>(
      () => _i86.ArticleService(gh<_i582.ArticleApi>()),
    );
    gh.singletonAsync<_i122.AppConfig>(() {
      final i = _i122.AppConfig(gh<_i460.SharedPreferences>());
      return i.init().then((_) => i);
    });
    gh.factory<_i484.AuthViewModel>(
      () => _i484.AuthViewModel(gh<_i478.AuthRepository>()),
    );
    gh.factory<_i725.ArticleViewModel>(
      () => _i725.ArticleViewModel(gh<_i838.ArticleRepository>()),
    );
    return this;
  }
}

class _$AppModule extends _i274.AppModule {}

class _$NetworkModule extends _i606.NetworkModule {}
