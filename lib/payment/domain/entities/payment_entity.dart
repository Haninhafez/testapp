// domain/entities/payment.dart
enum PaymentMethodType { card, wallet, cash }

class PaymentSession {
  final String orderId;
  final String? paymentUrl; // null لو كاش
  const PaymentSession({required this.orderId, this.paymentUrl});
}