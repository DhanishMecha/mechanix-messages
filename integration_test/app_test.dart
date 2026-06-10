import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mechanix_messages/main.dart' as app;
import 'package:mechanix_messages/core/utils/icons.dart';
import 'test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Comprehensive End-to-End Test', () {
    final helper = IntegrationTestHelper();

    setUp(() async {
      await helper.setUp();
    });

    tearDown(() async {
      await helper.tearDown();
    });

    testWidgets('Send Message E2E Flow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 1. Verify empty state initially
      expect(find.text('No messages'), findsOneWidget);

      // 2. Click compose button
      final composeBtn = IntegrationTestHelper.findMessageButton(AppIcons.edit);
      expect(composeBtn, findsOneWidget);
      await tester.tap(composeBtn);
      await tester.pumpAndSettle();

      // 3. Find Alice Cooper and tap to start chat
      await IntegrationTestHelper.startChatWithContact(tester, 'Alice Cooper');

      // 4. Type a message
      final chatInput = IntegrationTestHelper.chatTextField;
      expect(chatInput, findsOneWidget);
      await tester.enterText(chatInput, 'Hello Alice E2E!');
      await tester.pumpAndSettle();

      // 5. Tap send
      final sendBtn = IntegrationTestHelper.findMessageButton(AppIcons.send);
      expect(sendBtn, findsOneWidget);
      await tester.tap(sendBtn);
      await tester.pumpAndSettle();

      // 6. Verify message shows in chat bubble
      expect(find.text('Hello Alice E2E!'), findsOneWidget);

      // 7. Click back to home using the app bar back button
      final backBtn = IntegrationTestHelper.findIconButtonWithAsset(AppIcons.arrowLeft);
      expect(backBtn, findsOneWidget);
      await tester.tap(backBtn);
      await tester.pumpAndSettle();

      // 8. Verify conversation listed on Home with preview
      expect(find.text('Alice Cooper'), findsOneWidget);
      expect(find.text('Hello Alice E2E!'), findsOneWidget);
    });
  });
}
