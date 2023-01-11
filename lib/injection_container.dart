import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:number_trivia/core/network/network_info.dart';
import 'package:number_trivia/core/util/input_converter.dart';
import 'package:number_trivia/features/number_trivia/data/data_sources/number_trivia_local_data_source.dart';
import 'package:number_trivia/features/number_trivia/data/data_sources/number_trivia_remote_data_source.dart';
import 'package:number_trivia/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:number_trivia/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:number_trivia/features/number_trivia/presentation/bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

final serviceLocator = GetIt.instance;

Future<void> init() async {
  // - FEATURES - NUMBER TRIVIA
  // BLOC
  serviceLocator.registerFactory(
    () => NumberTriviaBloc(
      inputConverter: serviceLocator(),
      concrete: serviceLocator(),
      random: serviceLocator(),
    ),
  );
  // USE CASES
  serviceLocator
      .registerLazySingleton(() => GetConcreteNumberTrivia(serviceLocator()));
  serviceLocator
      .registerLazySingleton(() => GetRandomNumberTrivia(serviceLocator()));

  // REPOSITORY
  serviceLocator.registerLazySingleton<NumberTriviaRepository>(
    () => NumberTriviaRepositoryImpl(
      remoteDataSource: serviceLocator(),
      localDataSource: serviceLocator(),
      networkInfo: serviceLocator(),
    ),
  );

  // DATA SOURCES
  serviceLocator.registerLazySingleton<NumberTriviaRemoteDataSource>(() => NumberTriviaRemoteDataSourceImpl(client: serviceLocator()));
  serviceLocator.registerLazySingleton<NumberTriviaLocalDataSource>(() => NumberTriviaLocalDataSourceImpl(sharedPreferences: serviceLocator()));
  // - CORE
  serviceLocator.registerLazySingleton(() => InputConverter());
  serviceLocator.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(serviceLocator()));
  // - EXTERNAL
  final sharedPreferences = await SharedPreferences.getInstance();
  serviceLocator.registerLazySingleton(()  => sharedPreferences);
  serviceLocator.registerLazySingleton(() => http.Client);
  serviceLocator.registerLazySingleton(() => InternetConnectionChecker());
}
