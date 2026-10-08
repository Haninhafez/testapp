import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:testapp/payment/domain/entities/payment_entity.dart';
import 'package:testapp/payment/presentation/cubit/payment_cubit.dart';
import 'package:testapp/payment/presentation/cubit/payment_state.dart';

// عدّل الـ imports دي حسب structure مشروعك
// import 'domain/entities/payment.dart';
// import 'presentation/cubit/payment_cubit.dart';

/// ---------------------------------------------------------------
/// 1) شاشة اختيار طريقة الدفع
/// ---------------------------------------------------------------
class PaymentMethodPage extends StatefulWidget {
  const PaymentMethodPage({super.key});

  @override
  State<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  PaymentMethodType? _selected; // null = لسه مختارش

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('طريقة الدفع')),
        body: BlocListener<PaymentCubit, PaymentState>(
          listener: _onStateChanged,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'اختار طريقة الدفع',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _methodTile(
                  value: PaymentMethodType.card,
                  title: 'كارت (Visa / Mastercard)',
                  icon: Icons.credit_card,
                ),
                _methodTile(
                  value: PaymentMethodType.wallet,
                  title: 'محفظة موبايل',
                  icon: Icons.account_balance_wallet,
                ),
                _methodTile(
                  value: PaymentMethodType.cash,
                  title: 'كاش عند الاستلام',
                  icon: Icons.payments,
                ),
                const Spacer(),
                _payButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _methodTile({
    required PaymentMethodType value,
    required String title,
    required IconData icon,
  }) {
    return Card(
      child: RadioListTile<PaymentMethodType>(
        value: value,
        groupValue: _selected,
        onChanged: (v) => setState(() => _selected = v),
        title: Text(title),
        secondary: Icon(icon),
      ),
    );
  }

  Widget _payButton() {
    return BlocBuilder<PaymentCubit, PaymentState>(
      builder: (context, state) {
        final isLoading = state is PaymentLoading;
        // الزرار بيتقفل لو مفيش اختيار أو لو فيه loading (يمنع الدفع مرتين)
        final canPay = _selected != null && !isLoading;

        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: canPay
                ? () => context.read<PaymentCubit>().pay(250, _selected!)
                : null,
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('ادفع 250 ج.م'),
          ),
        );
      },
    );
  }

  Future<void> _onStateChanged(BuildContext context, PaymentState state) async {
    if (state is PaymentError) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.message)));
      return;
    }

    if (state is PaymentReady) {
      final url = state.session.paymentUrl;

      // كاش: مفيش صفحة دفع
      if (url == null) {
        _showResultDialog(context, success: true, message: 'تم تأكيد طلبك');
        return;
      }

      // كارت / محفظة: افتح صفحة الدفع الوهمية واستنى النتيجة
      final paid = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => const FakePaymentPage()),
      );

      if (!context.mounted) return;

      // TODO (من الـ Task): بدل ما تثق في `paid`، نادي
      // checkPaymentStatus(state.session.orderId) من الـ Repository
      // وبعدين اعرض النتيجة بناءً عليها.
      _showResultDialog(
        context,
        success: paid == true,
        message: paid == true ? 'تم الدفع بنجاح' : 'فشلت عملية الدفع',
      );
    }
  }

  void _showResultDialog(
    BuildContext context, {
    required bool success,
    required String message,
  }) {
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          icon: Icon(
            success ? Icons.check_circle : Icons.error,
            color: success ? Colors.green : Colors.red,
            size: 56,
          ),
          content: Text(message, textAlign: TextAlign.center),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('تمام'),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------
/// 2) صفحة دفع وهمية بدل الـ WebView
///    بترجّع true لو نجح، false لو فشل
/// ---------------------------------------------------------------
class FakePaymentPage extends StatelessWidget {
  const FakePaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('صفحة الدفع (تجريبية)')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.lock_outline, size: 64),
              const SizedBox(height: 16),
              const Text(
                'دي بديل للـ WebView بتاع الـ Gateway.\nاختار النتيجة اللي عايز تجربها:',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('نجح الدفع'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.pop(context, false),
                child: const Text('فشل الدفع'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
