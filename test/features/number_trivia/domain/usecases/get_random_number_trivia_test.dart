import 'package:dartz/dartz.dart';
import 'package:mocktail/mocktail.dart';
import 'package:number_trivia/core/usecases/usecase.dart';
import 'package:number_trivia/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_random_number_trivia.dart';

class MockNumberTriviaRepository extends Mock implements NumberTriviaRepository{

}

void main(){
  late GetRandomNumberTrivia usecase;
  late MockNumberTriviaRepository mockNumberTriviaRepository;

  setUp((){
    mockNumberTriviaRepository = MockNumberTriviaRepository();
    usecase = GetRandomNumberTrivia(mockNumberTriviaRepository);
  });

  const testNumberTrivia = NumberTrivia(text: 'test', number: 1);

  test('should get trivia from the repository', ()async{
    // arrange
    when(()=>mockNumberTriviaRepository.getRandomNumber()).thenAnswer((_) async =>const Right(testNumberTrivia));
    // act
    final result = await usecase(NoParams());
    // assert
    expect(result,const Right(testNumberTrivia));
    verify(()=>mockNumberTriviaRepository.getRandomNumber());
    verifyNoMoreInteractions(mockNumberTriviaRepository);
  });
}