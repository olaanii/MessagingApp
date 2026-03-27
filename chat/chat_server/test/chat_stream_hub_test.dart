import 'package:chat_server/src/generated/streaming/chat_stream_envelope.dart';
import 'package:chat_server/src/streaming/chat_stream_hub.dart';
import 'package:test/test.dart';

void main() {
  test('broadcast delivers to other device, respects exceptDeviceId', () async {
    final hub = ChatStreamHub.instance;
    final receivedA = <ChatStreamEnvelope>[];
    final receivedB = <ChatStreamEnvelope>[];

    final regA = ChatStreamRegistration(
      chatId: 'c1',
      deviceId: 'dev-a',
      deliver: (e) async => receivedA.add(e),
    );
    final regB = ChatStreamRegistration(
      chatId: 'c1',
      deviceId: 'dev-b',
      deliver: (e) async => receivedB.add(e),
    );

    expect(hub.register(regA), isTrue);
    expect(hub.register(regB), isTrue);

    final evt = ChatStreamEnvelope(
      type: 'typing',
      deviceId: 'dev-a',
      chatId: 'c1',
      ts: DateTime.now().toUtc(),
    );

    await hub.broadcast(null, 'c1', evt, exceptDeviceId: 'dev-a');

    expect(receivedA, isEmpty);
    expect(receivedB, hasLength(1));
    expect(receivedB.first.type, 'typing');

    hub.unregister(regA);
    hub.unregister(regB);
  });
}
