import 'dart:convert';

import 'package:number_trivia/core/errors/exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/number_trivia_model.dart';

abstract class NumberTriviaLocalDataSource{
  /// Gets the cached [NumberTriviaModel] which was gotten the last time
  /// the user had an internet connection.
  ///
  /// Throws [CacheException] if no cached data is present.
  Future<NumberTriviaModel?> getLastNumberTrivia();

  Future<void>? cacheNumberTrivia(NumberTriviaModel? triviaToCache);
}

const cachedNumberTriviaStringKey = 'CACHED_NUMBER_TRIVIA';


class NumberTriviaLocalDataSourceImpl implements NumberTriviaLocalDataSource{
  final SharedPreferences sharedPreferences;

  NumberTriviaLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<NumberTriviaModel?> getLastNumberTrivia() {
    final jsonString = sharedPreferences.getString(cachedNumberTriviaStringKey);
    if(jsonString != null){
      return Future.value(NumberTriviaModel.fromJson(jsonDecode(jsonString)));
    }
    else  {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheNumberTrivia(NumberTriviaModel? triviaToCache) async {
    await sharedPreferences.setString(
      cachedNumberTriviaStringKey,
      json.encode(triviaToCache!.toJson()),
    );
  }



}
