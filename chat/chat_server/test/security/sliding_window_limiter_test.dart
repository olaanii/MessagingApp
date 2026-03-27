import 'package:chat_server/src/security/sliding_window_limiter.dart';
import 'package:test/test.dart';

void main() {
  test('sliding window allows burst then blocks', () {
    final limiter = SlidingWindowLimiter(
      maxHits: 3,
      window: const Duration(seconds: 60),
    );
    final t0 = DateTime.utc(2026, 1, 1, 12);
    expect(limiter.tryHit('k', t0), isTrue);
    expect(limiter.tryHit('k', t0.add(const Duration(seconds: 1))), isTrue);
    expect(limiter.tryHit('k', t0.add(const Duration(seconds: 2))), isTrue);
    expect(limiter.tryHit('k', t0.add(const Duration(seconds: 3))), isFalse);
  });

  test('per-second limiter resets after window', () {
    final limiter = PerSecondLimiter(maxHits: 2);
    final t0 = DateTime.utc(2026, 1, 1, 12);
    expect(limiter.tryHit('x', t0), isTrue);
    expect(limiter.tryHit('x', t0.add(const Duration(milliseconds: 100))), isTrue);
    expect(limiter.tryHit('x', t0.add(const Duration(milliseconds: 200))), isFalse);
    expect(
      limiter.tryHit('x', t0.add(const Duration(milliseconds: 1100))),
      isTrue,
    );
  });
}
