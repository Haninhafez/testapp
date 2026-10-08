// data/repositories/payment_repository_impl.dart
import 'package:dio/dio.dart';
import 'package:testapp/payment/domain/entities/payment_entity.dart';
import 'package:testapp/payment/domain/repositories/payment_repo.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final Dio dio;
  PaymentRepositoryImpl(this.dio);

  @override
  Future<PaymentSession> createPayment({
    required double amount,
    required PaymentMethodType method,
  }) async {
    final res = await dio.post('/payments', data: {
      'amount': amount,
      'method': method.name,
    });
    return PaymentSession(
      orderId: res.data['order_id'],
      paymentUrl: res.data['payment_url'],
    );
  }
}