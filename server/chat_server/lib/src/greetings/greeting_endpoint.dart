import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Simple greeting/health-check endpoint.
class GreetingEndpoint extends Endpoint {
  Future<Greeting> hello(Session session, String name) async {
    return Greeting(
      message: 'Hello $name',
      author: 'chat-server',
      timestamp: DateTime.now().toUtc(),
    );
  }
}
