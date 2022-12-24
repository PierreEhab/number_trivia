import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:number_trivia/core/errors/exceptions.dart';
import 'package:number_trivia/features/number_trivia/data/data_sources/number_trivia_local_data_source.dart';
import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../fixtures/fixture_reader.dart';

class MockSharedPreferences extends Mock implements SharedPreferences{}

void main(){
  late NumberTriviaLocalDataSourceImpl dataSource;
  late MockSharedPreferences mockSharedPreferences;

  setUp((){
    mockSharedPreferences = MockSharedPreferences();
    dataSource = NumberTriviaLocalDataSourceImpl(sharedPreferences: mockSharedPreferences);
  });
  
  group('getLastNumberTrivia', ()  {

    final testNumberTriviaModel = NumberTriviaModel.fromJson(jsonDecode(fixture('trivia_cached.json')));

    test('should return NumberTrivia from SharedPreferences when there is one in the cache', ()async{
      // arrange
      when(()=>mockSharedPreferences.getString(any())).thenReturn(fixture('trivia_cached.json'));
      // act
      final result = await dataSource.getLastNumberTrivia();
      // assert
      verify(()=>mockSharedPreferences.getString(cachedNumberTriviaStringKey));
      expect(result, equals(testNumberTriviaModel));
    });

    test('should throw a CacheException when there is not a cached value', () {
      // arrange
      when(()=> mockSharedPreferences.getString(any())).thenReturn(null);
      final call = dataSource.getLastNumberTrivia;
      // assert
      expect(()=>call(), throwsA(const TypeMatcher<CacheException>()));
    });
  });

  group('cacheNumberTrivia', () {
    const testNumberTriviaModel =
    NumberTriviaModel(number: 1, text: 'test trivia');

    test('should call SharedPreferences to cache the data', () {
      // arrange
      // added this line to avoid errors with sound null safety because mocked shared preference always return null so i'm assuming here shared preference always success to set string.
      when(()=> mockSharedPreferences.setString(any(),any())).thenAnswer((_) => Future.value(true));
      // act
      dataSource.cacheNumberTrivia(testNumberTriviaModel);
      // assert
      final expectedJsonString = json.encode(testNumberTriviaModel.toJson());
      verify( ()=> mockSharedPreferences.setString(
         cachedNumberTriviaStringKey,
        expectedJsonString,
      ));
    });
  });
}