import 'package:dartz/dartz.dart';

import '../errors/failures.dart';

class InputConverter{
  Either<Failure,int> stringToUnsignedInteger(String numberString){
    try{
      final integer = int.parse(numberString);
      if (integer < 0) throw const FormatException();
      return Right(integer);
    }on FormatException{
      return Left(InvalidInputFailure());
    }
  }
}

class InvalidInputFailure extends Failure{
  @override
  List<Object?> get props => [];
}