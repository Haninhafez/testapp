// domain/usecases/create_payment.dart
import 'package:testapp/payment/domain/entities/payment_entity.dart';
import 'package:testapp/payment/domain/repositories/payment_repo.dart';

class CreatePayment {
  final PaymentRepository repository;
  CreatePayment(this.repository);

  Future<PaymentSession> call(double amount, PaymentMethodType method) =>
      repository.createPayment(amount: amount, method: method);
}