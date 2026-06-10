import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mechanix_contacts/mechanix_contacts.dart';
import 'package:mechanix_messages/core/services/objectbox_service.dart';
import 'package:mechanix_messages/core/utils/message_button.dart';
import 'package:mechanix_contacts/objectbox.g.dart' as contacts_g;
import 'package:mechanix_messages/features/messages/data/models/conversation_entity.dart';
import 'package:mechanix_messages/features/messages/data/models/message_entity.dart';

class IntegrationTestHelper {
  Store? contactsStore;
  Directory? tempDirContacts;

  Future<void> setUp() async {
    // 1. Create temporary directory to isolate contacts database
    tempDirContacts = await Directory.systemTemp.createTemp('contacts_db_test_');

    // 2. Initialize contacts store in temporary directory
    contactsStore = Store(
      contacts_g.getObjectBoxModel(),
      directory: tempDirContacts!.path,
    );

    // 3. Inject contacts store into Services
    ContactsStoreService.storeForTesting = contactsStore;

    // 4. Clean up messages in original/production database
    final messagesService = await ObjectBoxService.init();
    messagesService.store.box<ConversationEntity>().removeAll();
    messagesService.store.box<MessageEntity>().removeAll();

    // 5. Seed contacts database
    _seedContacts();
  }

  void _seedContacts() {
    final contactBox = contactsStore!.box<ContactEntity>();
    final phoneBox = contactsStore!.box<PhoneNumberEntity>();

    final alice = ContactEntity(name: 'Alice Cooper');
    final bob = ContactEntity(name: 'Bob Smith');
    final charlie = ContactEntity(name: 'Charlie Brown');

    contactBox.putMany([alice, bob, charlie]);

    final alicePhone = PhoneNumberEntity(number: '+1111111111');
    alicePhone.contact.target = alice;

    final bobPhone = PhoneNumberEntity(number: '+2222222222');
    bobPhone.contact.target = bob;

    final charliePhone = PhoneNumberEntity(number: '+3333333333');
    charliePhone.contact.target = charlie;

    phoneBox.putMany([alicePhone, bobPhone, charliePhone]);
  }

  Future<void> tearDown() async {
    contactsStore?.close();
    
    ContactsStoreService.storeForTesting = null;

    if (tempDirContacts != null && await tempDirContacts!.exists()) {
      await tempDirContacts!.delete(recursive: true);
    }
  }

  // Helper Finders & Actions
  static Finder findMessageButton(String iconPath) {
    return find.byWidgetPredicate(
      (widget) => widget is MessageButton && widget.iconPath == iconPath,
    );
  }

  static Finder findIconButtonWithAsset(String asset) {
    return find.byWidgetPredicate(
      (widget) =>
          widget is IconButton &&
          widget.icon is Image &&
          (widget.icon as Image).image is AssetImage &&
          ((widget.icon as Image).image as AssetImage).assetName == asset,
    );
  }

  static Finder get searchTextField => find.byKey(const ValueKey('search_text_field'));

  static Finder get chatTextField => find.byType(TextField);

  static Future<void> startChatWithContact(
    WidgetTester tester,
    String name,
  ) async {
    final contactTile = find.text(name);
    expect(contactTile, findsOneWidget);
    await tester.tap(contactTile);
    await tester.pumpAndSettle();
  }
}
