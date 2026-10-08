import 'package:testapp/payment/domain/entities/payment_entity.dart';

sealed class PaymentState {}
class PaymentInitial extends PaymentState {}
class PaymentLoading extends PaymentState {}
class PaymentReady extends PaymentState {
  final PaymentSession session;
  PaymentReady(this.session);
}
class PaymentError extends PaymentState {
  final String message;
  PaymentError(this.message);
}