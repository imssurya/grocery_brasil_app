import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grocery_brasil_app/core/errors/exceptions.dart';
import 'package:grocery_brasil_app/core/errors/failures.dart';
import 'package:grocery_brasil_app/features/product/domain/GetMinPriceProductByUserByProductIdUseCase.dart';
import 'package:grocery_brasil_app/features/product/presentation/bloc/product_prices_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:bloc_test/bloc_test.dart';

import 'fixture.dart' as fixture;

class MockGetMinPriceProductByUserByProductIdUseCase extends Mock
    implements GetMinPriceProductByUserByProductIdUseCase {}

main() {
  MockGetMinPriceProductByUserByProductIdUseCase
      mockGetMinPriceProductByUserByProductIdUseCase;
  group('GetMinPriceProduct', () {
    mockGetMinPriceProductByUserByProductIdUseCase =
        new MockGetMinPriceProductByUserByProductIdUseCase();
    group('Should list the products', () {
      when(mockGetMinPriceProductByUserByProductIdUseCase('someId'))
          .thenAnswer((realInvocation) async => Right(fixture.oneProductPrice));
      blocTest('Should list the products',
          build: () => ProductPricesBloc(
              getMinPriceProductByUserByProductIdUseCase:
                  mockGetMinPriceProductByUserByProductIdUseCase),
          act: (bloc) =>
              bloc.add(GetMininumProductPriceAvailable(productId: 'someId')),
          expect: [
            ProductPricesSearching(),
            MininumProductPriceAvailable(productPrices: fixture.oneProductPrice)
          ]);
    });
    group('Should yield ProductError on failure', () {
      final failure = ProductFailure(
          messageId: MessageIds.UNEXPECTED, message: 'some error');
      when(mockGetMinPriceProductByUserByProductIdUseCase('otherId'))
          .thenAnswer((realInvocation) async => Left(failure));
      blocTest('Should yield ProductError on failure',
          build: () => ProductPricesBloc(
              getMinPriceProductByUserByProductIdUseCase:
                  mockGetMinPriceProductByUserByProductIdUseCase),
          act: (bloc) =>
              bloc.add(GetMininumProductPriceAvailable(productId: 'otherId')),
          expect: [
            ProductPricesSearching(),
            ProductPricesError(productFailure: failure)
          ]);
    });
  });
}
