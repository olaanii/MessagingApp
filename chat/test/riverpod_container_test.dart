import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final _unitProvider = Provider<int>((ref) => 42);

void main() {
  test('ProviderContainer reads provider (Riverpod bootstrap)', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(_unitProvider), 42);
  });
}
