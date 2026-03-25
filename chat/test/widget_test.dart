import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:chat/main.dart';

void main() {
  testWidgets('App loads Home placeholder test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [Provider<String>(create: (_) => 'App initialized')],
        child: const MessagingApp(isFirebaseInitialized: true),
      ),
    );

    await tester.pumpAndSettle();

    // Verify that our home placeholder is visible
    expect(find.text('Placeholder for Home'), findsOneWidget);
  });
}
