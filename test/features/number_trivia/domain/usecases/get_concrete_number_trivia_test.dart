import 'package:dartz/dartz.dart';
import 'package:mocktail/mocktail.dart';
import 'package:number_trivia/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';

class MockNumberTriviaRepository extends Mock implements NumberTriviaRepository{

}

void main(){
  late GetConcreteNumberTrivia usecase;
  late MockNumberTriviaRepository mockNumberTriviaRepository;
   
  setUp((){
    mockNumberTriviaRepository = MockNumberTriviaRepository();
    usecase = GetConcreteNumberTrivia(mockNumberTriviaRepository);
  });
  
  final testNumber = 1;
  final testNumberTrivia = NumberTrivia(text: 'test', number: 1);
  
  test('should get trivia for the number from the repository', ()async{
    // arrange
    when(()=>mockNumberTriviaRepository.getConcreteNumber(any())).thenAnswer((_) async =>Right(testNumberTrivia));
    // act
    final result = await usecase(Params(number: testNumber));
    // assert
    expect(result,Right(testNumberTrivia));
    verify(()=>mockNumberTriviaRepository.getConcreteNumber(testNumber));
    verifyNoMoreInteractions(mockNumberTriviaRepository);
  });
}