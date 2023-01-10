import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:number_trivia/core/errors/failures.dart';
import 'package:number_trivia/core/usecases/usecase.dart';
import 'package:number_trivia/core/util/input_converter.dart';
import 'package:number_trivia/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:number_trivia/features/number_trivia/presentation/bloc/bloc.dart';

class MockGetConcreteNumberTrivia extends Mock
    implements GetConcreteNumberTrivia {}

class MockGetRandomNumberTrivia extends Mock implements GetRandomNumberTrivia {}

class MockInputConverter extends Mock implements InputConverter {}

class ParamsFake extends Fake implements Params {}

class NoParamsFake extends Fake implements NoParams {}

void main() {
  late NumberTriviaBloc bloc;
  late MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  late MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  late MockInputConverter mockInputConverter;

  setUp(() {
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockInputConverter = MockInputConverter();
    registerFallbackValue(NoParamsFake());
    registerFallbackValue(ParamsFake());
    bloc = NumberTriviaBloc(inputConverter: mockInputConverter, concrete: mockGetConcreteNumberTrivia, random: mockGetRandomNumberTrivia);
  });

  test('initialState should be Empty', () {
    // assert
    expect(bloc.initialState, equals(Empty(),),);
  });

  group('GetTriviaForConcreteNumber', () {
    // The event takes in a String
    const testNumberString = '1';
    // This is the successful output of the InputConverter
    final testNumberParsed = int.parse(testNumberString);
    // NumberTrivia instance is needed too, of course
    const testNumberTrivia = NumberTrivia(number: 1, text: 'test trivia');

    void setUpMockInputConverterSuccess() =>
        when(()=>mockInputConverter.stringToUnsignedInteger(any(),),)
            .thenReturn(Right(testNumberParsed));

    void setUpGetConcreteNumberTriviaSuccess() =>
        when(()=>mockGetConcreteNumberTrivia(any()))
            .thenAnswer((_) async => const Right(testNumberTrivia));

    test(
      'should call the InputConverter to validate and convert the string to an unsigned integer',
          () async {
        // arrange
            setUpMockInputConverterSuccess();
            setUpGetConcreteNumberTriviaSuccess();

        // act
        bloc.add(const GetTriviaForConcreteNumber(testNumberString));
        await untilCalled(()=>mockGetConcreteNumberTrivia.call(any()));
        // assert
        verify(()=>mockInputConverter.stringToUnsignedInteger(testNumberString));
      },
    );

    test(
      'should emit [Error] when the input is invalid',
          () async {
        // arrange
        when(()=>mockInputConverter.stringToUnsignedInteger(any()))
            .thenReturn(Left(InvalidInputFailure()));
        // assert later
        final expected = [
          // The initial state is always emitted first
          // Empty(),
          const Error(errorMessage: invalidInputFailureMessage),
        ];
        expectLater(bloc.stream, emitsInOrder(expected));
        // act
        bloc.add(const GetTriviaForConcreteNumber('xyz'));
      },
    );
    test(
      'should get data from the concrete use case',
          () async {
        // arrange
            setUpMockInputConverterSuccess();
            setUpGetConcreteNumberTriviaSuccess();
        // act
        bloc.add(const GetTriviaForConcreteNumber(testNumberString));
        await untilCalled(()=> mockGetConcreteNumberTrivia(any()));
        // assert
        verify(()=> mockGetConcreteNumberTrivia(Params(number: testNumberParsed)));
      },
    );

    test(
      'should emit [Loading, Loaded] when data is gotten successfully',
          () async {
        // arrange
        setUpMockInputConverterSuccess();
        when(()=>mockGetConcreteNumberTrivia(any()))
            .thenAnswer((_) async => const Right(testNumberTrivia));
        // assert later
        final expected = [
          // Empty(),
          Loading(),
          const Loaded(trivia: testNumberTrivia),
        ];
        expectLater(bloc.stream, emitsInOrder(expected));
        // act
        bloc.add(const GetTriviaForConcreteNumber(testNumberString));
      },
    );
    test(
      'should emit [Loading, Error] when getting data fails',
          () async {
        // arrange
        setUpMockInputConverterSuccess();
        when(()=>mockGetConcreteNumberTrivia(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        // assert later
        final expected = [
          // Empty(),
          Loading(),
          const Error(errorMessage: serverFailureMessage),
        ];
        expectLater(bloc.stream, emitsInOrder(expected));
        // act
        bloc.add(const GetTriviaForConcreteNumber(testNumberString));
      },
    );    test(
      'should emit [Loading, Error] with a proper message for the error when getting data fails',
          () async {
        // arrange
        setUpMockInputConverterSuccess();
        when(()=>mockGetConcreteNumberTrivia(any()))
            .thenAnswer((_) async => Left(CacheFailure()));
        // assert later
        final expected = [
          // Empty(),
          Loading(),
          const Error(errorMessage: cacheFailureMessage),
        ];
        expectLater(bloc.stream, emitsInOrder(expected));
        // act
        bloc.add(const GetTriviaForConcreteNumber(testNumberString));
      },
    );


  });

  group('GetTriviaForRandomNumber', () {
    const testNumberTrivia = NumberTrivia(number: 1, text: 'test trivia');
    test(
      'should get data from the random use case',
          () async {
        // arrange
        when(()=>mockGetRandomNumberTrivia(any()))
            .thenAnswer((_) async => const Right(testNumberTrivia));
        // act
        bloc.add(GetTriviaForRandomNumber());
        await untilCalled(()=>mockGetRandomNumberTrivia(any()));
        // assert
        verify(()=>mockGetRandomNumberTrivia(NoParams()));
      },
    );

    test(
      'should emit [Loading, Loaded] when data is gotten successfully',
          () async {
        // arrange
        when(()=>mockGetRandomNumberTrivia(any()))
            .thenAnswer((_) async => const Right(testNumberTrivia));
        // assert later
        final expected = [
          // Empty(),
          Loading(),
          const Loaded(trivia: testNumberTrivia),
        ];
        expectLater(bloc.stream, emitsInOrder(expected));
        // act
        bloc.add(GetTriviaForRandomNumber());
      },
    );

    test(
      'should emit [Loading, Error] when getting data fails',
          () async {
        // arrange
        when(()=>mockGetRandomNumberTrivia(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        // assert later
        final expected = [
          // Empty(),
          Loading(),
          const Error(errorMessage: serverFailureMessage),
        ];
        expectLater(bloc.stream, emitsInOrder(expected));
        // act
        bloc.add(GetTriviaForRandomNumber());
      },
    );

    test(
      'should emit [Loading, Error] with a proper message for the error when getting data fails',
          () async {
        // arrange
        when(()=>mockGetRandomNumberTrivia(any()))
            .thenAnswer((_) async => Left(CacheFailure()));
        // assert later
        final expected = [
          // Empty(),
          Loading(),
          const Error(errorMessage: cacheFailureMessage),
        ];
        expectLater(bloc.stream, emitsInOrder(expected));
        // act
        bloc.add(GetTriviaForRandomNumber());
      },
    );
  });
}
