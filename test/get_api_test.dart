import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:testapp/test/get_api.dart';

import 'get_api_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  test('getApi', () async {
  final httpClient = MockClient();

  when(
    httpClient.get(
      Uri.parse('https://jsonplaceholder.typicode.com/todos/1'),
    ),
  ).thenAnswer(
    (_) async => http.Response(
      '{"userId": 1, "id": 1, "title": "test", "completed": false}',
      200,
    ),
  );

  final result = await getApi(httpClient);

  expect(result, isA<Map<String, dynamic>>());
  expect(result['title'], 'test');
});
}
