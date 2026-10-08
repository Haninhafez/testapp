// data/repositories/fake_payment_repository.dart
import 'package:testapp/payment/domain/entities/payment_entity.dart';
import 'package:testapp/payment/domain/repositories/payment_repo.dart';

class FakePaymentRepository implements PaymentRepository {
  @override
  Future<PaymentSession> createPayment({
    required double amount,
    required PaymentMethodType method,
  }) async {
    await Future.delayed(const Duration(seconds: 1)); // بيحاكي الـ network

    return PaymentSession(
      orderId: 'ORDER_${DateTime.now().millisecondsSinceEpoch}',
      paymentUrl: method == PaymentMethodType.cash
          ? null // كاش: مفيش صفحة دفع
          : 'https://example.com', // أي لينك وهمي
    );
  }

  Future<bool> checkPaymentStatus(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return true; // جرب تخليها false عشان تختبر حالة الفشل
  }
}