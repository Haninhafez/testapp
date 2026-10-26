import 'package:flutter_test/flutter_test.dart';
import 'package:testapp/test/time_helper.dart';

void main() {
  test('TimeHelper  getCurrentTime', () {
    final timeHelper = TimeHelper();
    final time = DateTime(2026, 10, 22, 10);
    expect(timeHelper.getCurrentTime(time), equals("Good Morning"));
  });
  test('TimeHelper  getCurrentTime', () {
    final timeHelper = TimeHelper();
    final time = DateTime(2026, 10, 22, 18);
    expect(timeHelper.getCurrentTime(time), equals("Good Evening"));
  });
  test('TimeHelper  getCurrentTime', () {
    final timeHelper = TimeHelper();
    final time = DateTime(2026, 10, 22, 12);
    expect(timeHelper.getCurrentTime(time), equals("Good Afternoon"));
  });
}
