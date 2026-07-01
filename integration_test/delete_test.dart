import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mechanix_messages/main.dart' as app;
import 'package:mechanix_messages/core/utils/icons.dart';
import 'test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Delete Conversation Tests', () {
    final helper = IntegrationTestHelper();

    setUp(() async {
      await helper.setUp();
    });

    tearDown(() async {
      await helper.tearDown();
    });

    // ─────────────────────────────────────────────────────────────────────────
    // Helper: seed one conversation with Alice and return to home screen.
    // ─────────────────────────────────────────────────────────────────────────
    Future<void> seedAliceConversation(WidgetTester tester) async {
      final composeBtn = IntegrationTestHelper.findMessageButton(AppIcons.edit);
      await tester.tap(composeBtn);
      await tester.pumpAndSettle();

      await IntegrationTestHelper.startChatWithContact(tester, 'Alice Cooper');

      final chatInput = IntegrationTestHelper.chatTextField;
      await tester.enterText(chatInput, 'Hello Alice!');
      await tester.pumpAndSettle();

      final sendBtn = IntegrationTestHelper.findMessageButton(AppIcons.send);
      await tester.tap(sendBtn);
      await tester.pumpAndSettle();

      final backBtn =
          IntegrationTestHelper.findIconButtonWithAsset(AppIcons.arrowLeft);
      await tester.tap(backBtn);
      await tester.pumpAndSettle();
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Helper: seed a second conversation with Bob.
    // ─────────────────────────────────────────────────────────────────────────
    Future<void> seedBobConversation(WidgetTester tester) async {
      final composeBtn = IntegrationTestHelper.findMessageButton(AppIcons.edit);
      await tester.tap(composeBtn);
      await tester.pumpAndSettle();

      await IntegrationTestHelper.startChatWithContact(tester, 'Bob Smith');

      final chatInput = IntegrationTestHelper.chatTextField;
      await tester.enterText(chatInput, 'Hello Bob!');
      await tester.pumpAndSettle();

      final sendBtn = IntegrationTestHelper.findMessageButton(AppIcons.send);
      await tester.tap(sendBtn);
      await tester.pumpAndSettle();

      final backBtn =
          IntegrationTestHelper.findIconButtonWithAsset(AppIcons.arrowLeft);
      await tester.tap(backBtn);
      await tester.pumpAndSettle();
    }

    // =========================================================================
    // Test 1 — Long-press activates selection mode
    // =========================================================================
    testWidgets('Long-press on conversation card activates selection mode',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await seedAliceConversation(tester);

      // Long-press Alice's card to enter selection mode
      await tester.longPress(find.text('Alice Cooper'));
      await tester.pumpAndSettle();

      // Delete icon in the bottom action bar should now be visible
      final deleteBtn =
          IntegrationTestHelper.findMessageButton(AppIcons.delete);
      expect(deleteBtn, findsOneWidget);

      // Close / cancel icon should also appear
      final closeBtn = IntegrationTestHelper.findMessageButton(AppIcons.close);
      expect(closeBtn, findsOneWidget);
    });

    // =========================================================================
    // Test 2 — Cancel clears selection mode
    // =========================================================================
    testWidgets('Tapping close clears selection mode without deleting',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await seedAliceConversation(tester);

      // Enter selection mode
      await tester.longPress(find.text('Alice Cooper'));
      await tester.pumpAndSettle();

      // Tap the close (cancel) button
      final closeBtn = IntegrationTestHelper.findMessageButton(AppIcons.close);
      await tester.tap(closeBtn);
      await tester.pumpAndSettle();

      // Bottom bar should be gone; conversation still present
      expect(IntegrationTestHelper.findMessageButton(AppIcons.delete),
          findsNothing);
      expect(find.text('Alice Cooper'), findsOneWidget);
    });

    // =========================================================================
    // Test 3 — Delete bottom sheet shows SINGULAR title for 1 conversation
    // =========================================================================
    testWidgets(
        'Delete bottom sheet shows singular title when 1 conversation selected',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await seedAliceConversation(tester);

      // Enter selection mode
      await tester.longPress(find.text('Alice Cooper'));
      await tester.pumpAndSettle();

      // Tap the delete icon to open bottom sheet
      final deleteBtn =
          IntegrationTestHelper.findMessageButton(AppIcons.delete);
      await tester.tap(deleteBtn);
      await tester.pumpAndSettle();

      // Title should be SINGULAR
      expect(find.text('Delete conversation'), findsOneWidget);
      expect(find.text('Delete conversations'), findsNothing);

      // Body should also be SINGULAR
      expect(
        find.text(
            'Are you sure you want to delete the selected conversation?'),
        findsOneWidget,
      );
    });

    // =========================================================================
    // Test 4 — Delete bottom sheet shows PLURAL title for 2+ conversations
    // =========================================================================
    testWidgets(
        'Delete bottom sheet shows plural title when multiple conversations selected',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await seedAliceConversation(tester);
      await seedBobConversation(tester);

      // Long-press Alice to enter selection mode
      await tester.longPress(find.text('Alice Cooper'));
      await tester.pumpAndSettle();

      // Tap Bob to add to selection
      await tester.tap(find.text('Bob Smith'));
      await tester.pumpAndSettle();

      // Open delete bottom sheet
      final deleteBtn =
          IntegrationTestHelper.findMessageButton(AppIcons.delete);
      await tester.tap(deleteBtn);
      await tester.pumpAndSettle();

      // Title should be PLURAL
      expect(find.text('Delete conversations'), findsOneWidget);
      expect(find.text('Delete conversation'), findsNothing);

      // Body should also be PLURAL
      expect(
        find.text(
            'Are you sure you want to delete the selected conversations?'),
        findsOneWidget,
      );
    });

    // =========================================================================
    // Test 5 — Cancel button in bottom sheet dismisses without deleting
    // =========================================================================
    testWidgets(
        'Tapping Cancel in the bottom sheet dismisses it without deleting',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await seedAliceConversation(tester);

      // Enter selection mode & open bottom sheet
      await tester.longPress(find.text('Alice Cooper'));
      await tester.pumpAndSettle();
      await tester.tap(IntegrationTestHelper.findMessageButton(AppIcons.delete));
      await tester.pumpAndSettle();

      // Tap Cancel
      expect(find.text('Cancel'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Bottom sheet is gone; conversation still present
      expect(find.text('Delete conversation'), findsNothing);
      expect(find.text('Alice Cooper'), findsOneWidget);
    });

    // =========================================================================
    // Test 6 — Confirm delete removes a single conversation
    // =========================================================================
    testWidgets('Confirming delete removes the selected conversation',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await seedAliceConversation(tester);
      expect(find.text('Alice Cooper'), findsOneWidget);

      // Enter selection mode
      await tester.longPress(find.text('Alice Cooper'));
      await tester.pumpAndSettle();

      // Open delete bottom sheet
      await tester.tap(IntegrationTestHelper.findMessageButton(AppIcons.delete));
      await tester.pumpAndSettle();

      // Tap the Delete confirmation button
      expect(find.text('Delete'), findsOneWidget);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Conversation should be gone; empty state visible
      expect(find.text('Alice Cooper'), findsNothing);
      expect(find.text('No messages'), findsOneWidget);
    });

    // =========================================================================
    // Test 7 — Confirm delete removes multiple conversations
    // =========================================================================
    testWidgets('Confirming delete removes all selected conversations',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await seedAliceConversation(tester);
      await seedBobConversation(tester);

      expect(find.text('Alice Cooper'), findsOneWidget);
      expect(find.text('Bob Smith'), findsOneWidget);

      // Long-press Alice, then tap Bob to select both
      await tester.longPress(find.text('Alice Cooper'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bob Smith'));
      await tester.pumpAndSettle();

      // Open delete bottom sheet
      await tester.tap(IntegrationTestHelper.findMessageButton(AppIcons.delete));
      await tester.pumpAndSettle();

      // Confirm delete
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Both conversations should be removed
      expect(find.text('Alice Cooper'), findsNothing);
      expect(find.text('Bob Smith'), findsNothing);
      expect(find.text('No messages'), findsOneWidget);
    });

    // =========================================================================
    // Test 8 — Deleting one of two conversations keeps the other intact
    // =========================================================================
    testWidgets(
        'Deleting one conversation leaves the other conversation untouched',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await seedAliceConversation(tester);
      await seedBobConversation(tester);

      // Select only Alice
      await tester.longPress(find.text('Alice Cooper'));
      await tester.pumpAndSettle();

      // Open delete bottom sheet
      await tester.tap(IntegrationTestHelper.findMessageButton(AppIcons.delete));
      await tester.pumpAndSettle();

      // Confirm delete
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Alice is gone; Bob is still present
      expect(find.text('Alice Cooper'), findsNothing);
      expect(find.text('Bob Smith'), findsOneWidget);
    });
  });
}
