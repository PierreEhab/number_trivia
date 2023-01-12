import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:number_trivia/core/errors/failures.dart';
import 'package:number_trivia/core/usecases/usecase.dart';
import '../../../../core/util/input_converter.dart';
import '../../domain/entities/number_trivia.dart';
import '../../domain/usecases/get_concrete_number_trivia.dart';
import '../../domain/usecases/get_random_number_trivia.dart';

part 'number_trivia_event.dart';

part 'number_trivia_state.dart';

const String serverFailureMessage = 'Server Failure';
const String cacheFailureMessage = 'Cache Failure';
const String invalidInputFailureMessage =
    'Invalid Input - The number must be a positive integer or zero.';

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  final GetConcreteNumberTrivia getConcreteNumberTrivia;
  final GetRandomNumberTrivia getRandomNumberTrivia;
  final InputConverter inputConverter;

  NumberTriviaBloc({
    required this.inputConverter,
    required GetConcreteNumberTrivia concrete,
    required GetRandomNumberTrivia random,
  })  : getConcreteNumberTrivia = concrete,
        getRandomNumberTrivia = random,
        super(Empty()) {
    on<NumberTriviaEvent>((event, emit) async {
      if (event is GetTriviaForConcreteNumber) {
        final inputEither =
            inputConverter.stringToUnsignedInteger(event.numberString);
        await inputEither.fold(
          (failure) {
            emit(const Error(errorMessage: invalidInputFailureMessage));
          },
          (integer) async {
            emit(Loading());
            final failureOrTrivia = await getConcreteNumberTrivia(
              Params(
                number: integer,
              ),
            );
            await failureOrTrivia!.fold(
              (failure) async {
                emit(
                  Error(errorMessage: _mapFailureToMessage(failure!)),
                );
              },
              (trivia) async{
                emit(
                  Loaded(
                    trivia: trivia!,
                  ),
                );
              }
            );
          },
        );
      }
      else if(event is GetTriviaForRandomNumber){
        emit(Loading());
        final failureOrTrivia = await getRandomNumberTrivia(NoParams());
        failureOrTrivia!.fold(
              (failure) => emit(
            Error(errorMessage: _mapFailureToMessage(failure!)),
          ),
              (trivia) => emit(
            Loaded(
              trivia: trivia!,
            ),
          ),
        );
      }
      else if (event is Empty) {
        emit(Empty());
      }
    });
  }

  NumberTriviaState get initialState => Empty();

  String _mapFailureToMessage(Failure failure) {
    // Instead of a regular 'if (failure is ServerFailure)...'
    switch (failure.runtimeType) {
      case ServerFailure:
        return serverFailureMessage;
      case CacheFailure:
        return cacheFailureMessage;
      default:
        return 'Unexpected Error';
    }
  }
}
