import 'dart:convert';

import 'package:http/http.dart' as htttp;

Future<Map<String, dynamic>> getApi(htttp.Client client) async {
  final response = await client.get(
    Uri.parse('https://jsonplaceholder.typicode.com/todos/1'),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body) as Map<String, dynamic>;
  } else {
    throw Exception('Failed to load data');
  }
}