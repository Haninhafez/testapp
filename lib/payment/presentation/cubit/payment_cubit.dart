import 'package:bloc/bloc.dart';
import 'package:testapp/payment/domain/entities/payment_entity.dart';
import 'package:testapp/payment/domain/usecases/create_payment_usecase.dart';
import 'package:testapp/payment/presentation/cubit/payment_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  final CreatePayment createPayment;
  PaymentCubit(this.createPayment) : super(PaymentInitial());

  Future<void> pay(double amount, PaymentMethodType method) async {
    emit(PaymentLoading());
    try {
      final session = await createPayment(amount, method);
      emit(PaymentReady(session));
    } catch (e) {
      emit(PaymentError('حصلت مشكلة في الدفع، حاول تاني'));
    }
  }
}