import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mechanix_messages/main.dart' as app;
import 'package:mechanix_messages/core/utils/icons.dart';
import 'test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Chat Conversation Tests', () {
    final helper = IntegrationTestHelper();

    setUp(() async {
      await helper.setUp();
    });

    tearDown(() async {
      await helper.tearDown();
    });

    testWidgets('Send Multiple Messages', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Go to Compose
      final composeBtn = IntegrationTestHelper.findMessageButton(AppIcons.edit);
      await tester.tap(composeBtn);
      await tester.pumpAndSettle();

      // Select Alice Cooper
      await IntegrationTestHelper.startChatWithContact(tester, 'Alice Cooper');

      // Send Message 1
      final chatInput = IntegrationTestHelper.chatTextField;
      await tester.enterText(chatInput, 'Hello Alice!');
      await tester.pumpAndSettle();

      final sendBtn = IntegrationTestHelper.findMessageButton(AppIcons.send);
      await tester.tap(sendBtn);
      await tester.pumpAndSettle();

      // Verify Message 1 is visible
      expect(find.text('Hello Alice!'), findsOneWidget);

      // Send Message 2
      await tester.enterText(chatInput, 'How are you?');
      await tester.pumpAndSettle();
      await tester.tap(sendBtn);
      await tester.pumpAndSettle();

      // Verify both messages are visible
      expect(find.text('Hello Alice!'), findsOneWidget);
      expect(find.text('How are you?'), findsOneWidget);
    });
  });
}
