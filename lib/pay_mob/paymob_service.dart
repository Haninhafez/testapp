
import 'dart:convert';

import 'package:http/http.dart' as http;

const bool kMockMode = false; // true = محاكاة بدون Paymob | false = Paymob Test حقيقي
const String kApiKey = 'ZXlKaGJHY2lPaUpJVXpVeE1pSXNJblI1Y0NJNklrcFhWQ0o5LmV5SmpiR0Z6Y3lJNklrMWxjbU5vWVc1MElpd2ljSEp2Wm1sc1pWOXdheUk2TVRJME16YzBNaXdpYm1GdFpTSTZJbWx1YVhScFlXd2lmUS5neG1MaWpKZDhMTzBhS3NYOG9tSk9FemM3a0tWTlpHZTdjZURvbzdGdkxhNTVFYVZybURKYTY0TzVJeUdXNkdzSS1UYmNSeExFYm8yTHBfaVlUbi1BZw==';
const int kIntegrationId = 5988989;
const String kIframeId = '1087967';

class PaymobService {
  static const _base = 'https://accept.paymob.com/api';
 
  Future<String> getPaymentUrl(int amountEgp) async {
    final amountCents = amountEgp * 100;
    const headers = {'Content-Type': 'application/json'};
 
    final auth = await http.post(
      Uri.parse('$_base/auth/tokens'),
      headers: headers,
      body: jsonEncode({'api_key': kApiKey}),
    );
    if (auth.statusCode >= 400) {
      throw Exception('Auth failed (${auth.statusCode}): ${auth.body}');
    }
    final authToken = jsonDecode(auth.body)['token'];
 
    final order = await http.post(
      Uri.parse('$_base/ecommerce/orders'),
      headers: headers,
      body: jsonEncode({
        'auth_token': authToken,
        'delivery_needed': false,
        'amount_cents': amountCents,
        'currency': 'EGP',
        'items': [
       
        ],
      }),
    );
    if (order.statusCode >= 400) {
      throw Exception('Order failed (${order.statusCode}): ${order.body}');
    }
    final orderId = jsonDecode(order.body)['id'];
 
    final key = await http.post(
      Uri.parse('$_base/acceptance/payment_keys'),
      headers: headers,
      body: jsonEncode({
        'auth_token': authToken,
        'amount_cents': amountCents,
        'expiration': 3600,
        'order_id': orderId,
        'currency': 'EGP',
        'integration_id': kIntegrationId,
        'billing_data': {
          'first_name': 'Test',
          'last_name': 'User',
          'email': 'test@example.com',
          'phone_number': '01000000000',
          'apartment': 'NA',
          'floor': 'NA',
          'street': 'NA',
          'building': 'NA',
          'shipping_method': 'NA',
          'postal_code': 'NA',
          'city': 'NA',
          'country': 'EG',
          'state': 'NA',
        },
      }),
    );
    if (key.statusCode >= 400) {
      throw Exception('Payment key failed (${key.statusCode}): ${key.body}');
    }
    final paymentToken = jsonDecode(key.body)['token'];
 
    return '$_base/acceptance/iframes/$kIframeId?payment_token=$paymentToken';
  }
}