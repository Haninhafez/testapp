import 'package:flutter/material.dart';
import 'package:testapp/pay_mob/paymob_service.dart';
import 'package:webview_flutter/webview_flutter.dart';

enum PayMethod { card, wallet, cash }
 
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
 
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}
 
class _CheckoutScreenState extends State<CheckoutScreen> {
  final _amountCtrl = TextEditingController(text: '100');
  PayMethod _method = PayMethod.card;
  bool _loading = false;
  String? _error;
 
  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }
 
  Future<void> _pay() async {
    final amount = int.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0) {
      setState(() => _error = 'اكتبي مبلغ صحيح');
      return;
    }
 
    // الكارت بس هو اللي متوصل بـ Paymob في الوقت الحالي
    if (_method != PayMethod.card) {
      _showResult(true, amount, note: 'محاكاة - ${_method.name}');
      return;
    }
 
    setState(() {
      _loading = true;
      _error = null;
    });
 
    try {
      if (kMockMode) {
        await Future.delayed(const Duration(seconds: 2));
        if (!mounted) return;
        _showResult(true, amount, note: 'وضع المحاكاة');
      } else {
        final url = await PaymobService().getPaymentUrl(amount);
        if (!mounted) return;
        final paid = await Navigator.push<bool>(
          context,
          MaterialPageRoute(builder: (_) => PaymentWebView(url: url)),
        );
        if (!mounted) return;
        _showResult(paid == true, amount);
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
 
  void _showResult(bool success, int amount, {String? note}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(success: success, amount: amount, note: note),
      ),
    );
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إتمام الدفع')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (kMockMode)
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('وضع المحاكاة مفعّل - مفيش اتصال بـ Paymob'),
            ),
          TextField(
            controller: _amountCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'المبلغ (ج.م)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.payments_outlined),
            ),
          ),
          const SizedBox(height: 20),
          const Text('اختاري طريقة الدفع',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _methodTile(PayMethod.card, 'كارت بنكي', Icons.credit_card),
          _methodTile(PayMethod.wallet, 'محفظة إلكترونية (محاكاة)',
              Icons.account_balance_wallet_outlined),
          _methodTile(PayMethod.cash, 'كاش (محاكاة)', Icons.money),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
          const SizedBox(height: 24),
          SizedBox(
            height: 50,
            child: FilledButton(
              onPressed: _loading ? null : _pay,
              child: _loading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('ادفعي الآن', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
 
  Widget _methodTile(PayMethod m, String title, IconData icon) {
    final selected = _method == m;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
          width: selected ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: selected ? const Icon(Icons.check_circle, color: Colors.indigo) : null,
        onTap: () => setState(() => _method = m),
      ),
    );
  }
}
 
// ---------------------- WebView ----------------------
class PaymentWebView extends StatefulWidget {
  final String url;
  const PaymentWebView({super.key, required this.url});
 
  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}
 
class _PaymentWebViewState extends State<PaymentWebView> {
  late final WebViewController _controller;
  bool _loading = true;
  bool _done = false;
 
  void _checkResult(String url) {
    if (_done) return;
    final uri = Uri.tryParse(url);
    final success = uri?.queryParameters['success'];
    if (success == 'true' || success == 'false') {
      _done = true;
      Navigator.pop(context, success == 'true');
    }
  }
 
  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() => _loading = true);
            _checkResult(url);
          },
          onPageFinished: (_) => setState(() => _loading = false),
          onUrlChange: (change) {
            if (change.url != null) _checkResult(change.url!);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الدفع بالكارت'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
 
// ---------------------- شاشة النتيجة ----------------------
class ResultScreen extends StatelessWidget {
  final bool success;
  final int amount;
  final String? note;
  const ResultScreen({super.key, required this.success, required this.amount, this.note});
 
  @override
  Widget build(BuildContext context) {
    final color = success ? Colors.green : Colors.red;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(success ? Icons.check_circle : Icons.cancel, size: 100, color: color),
                const SizedBox(height: 16),
                Text(
                  success ? 'تمت العملية بنجاح' : 'فشلت العملية',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
                ),
                const SizedBox(height: 8),
                Text('المبلغ: $amount ج.م', style: const TextStyle(fontSize: 18)),
                if (note != null) ...[
                  const SizedBox(height: 4),
                  Text(note!, style: const TextStyle(color: Colors.grey)),
                ],
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                  child: const Text('رجوع'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}