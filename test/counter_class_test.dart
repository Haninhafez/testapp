import 'package:flutter_test/flutter_test.dart';
import 'package:testapp/test/counter_class.dart';

void main() {
  group('Counter class', () {
    test('increment', () {
      final counter = Counter();
      counter.increment();
      expect(counter.count, equals(1));
    });
    test('decrement', () {
      final counter = Counter();
      counter.decrement();
      expect(counter.count, equals(-1));
    });
  });
  test('Counter increments smoke test', () {
    final counter = Counter();

    expect(counter.count, equals(0));
    counter.increment();
    expect(counter.count, equals(1));
    counter.decrement();
    expect(counter.count, equals(0));
  });
}