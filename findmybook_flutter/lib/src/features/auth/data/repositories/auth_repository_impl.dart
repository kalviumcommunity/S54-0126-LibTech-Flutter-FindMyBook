import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  AuthRepositoryImpl({AuthRemoteDataSource? remote}) : remote = remote ?? AuthRemoteDataSource();

  @override
  Future<String> signIn(String email, String password) async {
    return remote.signIn(email, password);
  }

  @override
  Future<String> signUp(String email, String password) async {
    return remote.signUp(email, password);
  }
}
