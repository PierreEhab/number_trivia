import 'package:equatable/equatable.dart';
import 'package:number_trivia/core/usecases/usecase.dart';
import 'package:number_trivia/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/repositories/number_trivia_repository.dart';

import '../../../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';

class GetConcreteNumberTrivia extends UseCase<NumberTrivia,Params>{
  final NumberTriviaRepository repository;
  GetConcreteNumberTrivia(this.repository);

  @override
  Future<Either<Failure,NumberTrivia>> call(Params params) async {
    return await repository.getConcreteNumber(params.number);
  }
}

class Params extends Equatable{
  final int number;

  const Params({required this.number});

  @override
  List<Object?> get props => [number];
}