import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:leaderboard_app/models/verification_models.dart';
import 'package:leaderboard_app/models/auth_models.dart';

part 'rest_client.g.dart';

@RestApi()
abstract class RestClient {
  factory RestClient(Dio dio, {String baseUrl}) = _RestClient;

  // AUTH
  @POST('/auth/signup')
  Future<AuthResponse> signUp(@Body() Map<String, dynamic> body);

  @POST('/auth/login')
  Future<AuthResponse> signIn(@Body() Map<String, dynamic> body);

  @GET('/user/profile')
  Future<Map<String, dynamic>> getProfile();

  // VERIFICATION
  @POST('/verification/start')
  Future<VerificationStart> startVerification(@Body() Map<String, dynamic> body);

  @GET('/verification/status/{username}')
  Future<VerificationStatus> getVerificationStatus(@Path('username') String username);
}
