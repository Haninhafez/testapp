// domain/repositories/payment_repository.dart
import 'package:testapp/payment/domain/entities/payment_entity.dart';

abstract class PaymentRepository {
  Future<PaymentSession> createPayment({
    required double amount,
    required PaymentMethodType method,
  });
}