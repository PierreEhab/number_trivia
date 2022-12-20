
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:number_trivia/core/errors/exceptions.dart';
import 'package:number_trivia/core/errors/failures.dart';
import 'package:number_trivia/core/network/network_info.dart';
import 'package:number_trivia/features/number_trivia/data/data_sources/number_trivia_local_data_source.dart';
import 'package:number_trivia/features/number_trivia/data/data_sources/number_trivia_remote_data_source.dart';
import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:number_trivia/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:number_trivia/features/number_trivia/domain/entities/number_trivia.dart';

class MockRemoteDataSource extends Mock implements NumberTriviaRemoteDataSource{

}

class MockLocalDataSource extends Mock implements NumberTriviaLocalDataSource{

}

class MockNetworkInfo extends Mock implements NetworkInfo{

}

void main(){
  late NumberTriviaRepositoryImpl repository;
  late MockLocalDataSource mockLocalDataSource;
  late MockRemoteDataSource mockRemoteDataSource;
  late MockNetworkInfo mockNetworkInfo;
  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockLocalDataSource= MockLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = NumberTriviaRepositoryImpl(
      remoteDataSource:mockRemoteDataSource,
      localDataSource:mockLocalDataSource,
      networkInfo:mockNetworkInfo,
    );
  });
  void runTestsOnline(Function body) {
    group('device is online', () {
      setUp(() {
        when(()=>mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      body();
    });
  }

  void runTestsOffline(Function body) {
    group('device is offline', () {
      setUp(() {
        when(()=>mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      body();
    });
  }
  group('getConcreteNumberTrivia',(){
    const testNumber = 1;
    const testNumberTriviaModel =
    NumberTriviaModel(number: testNumber, text: 'test trivia');
    const NumberTrivia testNumberTrivia = testNumberTriviaModel;
    test('should check if the device is online',() async {
      // arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      // act
      await repository.getConcreteNumber(testNumber);
      // assert
      verify(() => mockNetworkInfo.isConnected);
    });
    // TEST FOR WHEN THE DEVICE IS ONLINE
    runTestsOnline((){

      test('should return remote data when the call to remote data source is successful',() async {
        // arrange
        when(() => mockRemoteDataSource.getConcreteNumber(any())).thenAnswer((_) async => testNumberTriviaModel);
        // act
        final result = await repository.getConcreteNumber(testNumber);
        // assert
        verify(() => mockRemoteDataSource.getConcreteNumber(testNumber));
        expect(result, equals(const Right(testNumberTrivia)));
      });
      test(
        'should cache the data locally when the call to remote data source is successful',
            () async {
          // arrange
          when(() => mockRemoteDataSource.getConcreteNumber(testNumber))
              .thenAnswer((_) async => testNumberTriviaModel);
          // act
          await repository.getConcreteNumber(testNumber);
          // assert
          verify(() => mockRemoteDataSource.getConcreteNumber(testNumber));
          verify(() => mockLocalDataSource.cacheNumberTrivia(testNumberTriviaModel));
        },
      );

      test('should return server failure when the call to remote data source is unsuccessful',() async {
        // arrange
        when(() => mockRemoteDataSource.getConcreteNumber(any())).thenThrow(ServerException());
        // act
        final result = await repository.getConcreteNumber(testNumber);
        // assert
        verify(() => mockRemoteDataSource.getConcreteNumber(testNumber));
        verifyZeroInteractions(mockLocalDataSource);
        expect(result, equals(Left(ServerFailure())));
      });


    });
    // TEST FOR WHEN THE DEVICE IS OFFLINE
    runTestsOffline((){
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      test(
        'should return last locally cached data when the cached data is present',
            () async {
          // arrange
          when(()=>mockLocalDataSource.getLastNumberTrivia())
              .thenAnswer((_) async => testNumberTriviaModel);
          // act
          final result = await repository.getConcreteNumber(testNumber);
          // assert
          verifyZeroInteractions(mockRemoteDataSource);
          verify(()=>mockLocalDataSource.getLastNumberTrivia());
          expect(result, equals(const Right(testNumberTrivia)));
        },
      );

      test(
        'should return CacheFailure when there is no cached data present',
            () async {
          // arrange
          when(()=>mockLocalDataSource.getLastNumberTrivia())
              .thenThrow(CacheException());
          // act
          final result = await repository.getConcreteNumber(testNumber);
          // assert
          verifyZeroInteractions(mockRemoteDataSource);
          verify(()=>mockLocalDataSource.getLastNumberTrivia());
          expect(result, equals(Left(CacheFailure())));
        },
      );

    });
  });

  group('getRandomNumberTrivia', () {
    const testNumberTriviaModel =
    NumberTriviaModel(number: 123, text: 'test trivia');
    const NumberTrivia testNumberTrivia = testNumberTriviaModel;

    test('should check if the device is online', () {
      //arrange
      when(()=>mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      // act
      repository.getRandomNumber();
      // assert
      verify(()=>mockNetworkInfo.isConnected);
    });

    runTestsOnline(() {
      test(
        'should return remote data when the call to remote data source is successful',
            () async {
          // arrange
          when(()=> mockRemoteDataSource.getRandomNumber())
              .thenAnswer((_) async => testNumberTriviaModel);
          // act
          final result = await repository.getRandomNumber();
          // assert
          verify(()=> mockRemoteDataSource.getRandomNumber());
          expect(result, equals(const Right(testNumberTrivia)));
        },
      );

      test(
        'should cache the data locally when the call to remote data source is successful',
            () async {
          // arrange
          when(()=>mockRemoteDataSource.getRandomNumber())
              .thenAnswer((_) async => testNumberTriviaModel);
          // act
          await repository.getRandomNumber();
          // assert
          verify(()=>mockRemoteDataSource.getRandomNumber());
          verify(()=>mockLocalDataSource.cacheNumberTrivia(testNumberTriviaModel));
        },
      );

      test(
        'should return server failure when the call to remote data source is unsuccessful',
            () async {
          // arrange
          when(()=>mockRemoteDataSource.getRandomNumber())
              .thenThrow(ServerException());
          // act
          final result = await repository.getRandomNumber();
          // assert
          verify(()=>mockRemoteDataSource.getRandomNumber());
          verifyZeroInteractions(mockLocalDataSource);
          expect(result, equals(Left(ServerFailure())));
        },
      );
    });

    runTestsOffline(() {
      test(
        'should return last locally cached data when the cached data is present',
            () async {
          // arrange
          when(()=>mockLocalDataSource.getLastNumberTrivia())
              .thenAnswer((_) async => testNumberTriviaModel);
          // act
          final result = await repository.getRandomNumber();
          // assert
          verifyZeroInteractions(mockRemoteDataSource);
          verify(()=>mockLocalDataSource.getLastNumberTrivia());
          expect(result, equals(Right(testNumberTrivia)));
        },
      );

      test(
        'should return CacheFailure when there is no cached data present',
            () async {
          // arrange
          when(()=>mockLocalDataSource.getLastNumberTrivia())
              .thenThrow(CacheException());
          // act
          final result = await repository.getRandomNumber();
          // assert
          verifyZeroInteractions(mockRemoteDataSource);
          verify(()=>mockLocalDataSource.getLastNumberTrivia());
          expect(result, equals(Left(CacheFailure())));
        },
      );
    });
  });

}