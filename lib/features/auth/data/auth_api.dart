import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:my_app/features/auth/domain/models/user.dart';
import 'package:retrofit/retrofit.dart';

part 'auth_api.g.dart';

@RestApi()
abstract class AuthApi {
  @factoryMethod
  factory AuthApi(Dio dio, {String baseUrl}) = _AuthApi;

  @POST('/login')
  Future<User> login(@Query("email") String email, @Query("pwd") String pwd);
  @GET('/logout')
  Future<void> logout();
}
