// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get allMessages => 'All messages';

  @override
  String get filterAll => 'All';

  @override
  String get filterUnread => 'Unread';

  @override
  String get noMessages => 'No messages';

  @override
  String get newMessage => 'New message';

  @override
  String get toLabel => 'To: ';

  @override
  String get searchOrEnterPhone => 'Search or enter phone number';

  @override
  String sendMessageTo(String query) {
    return 'Send message to $query';
  }

  @override
  String get noContactsFound => 'No contacts found';

  @override
  String get noMatchingContacts => 'No matching contacts';

  @override
  String get noNumber => 'No number';

  @override
  String get writeMessage => 'Write a message...';

  @override
  String get youPrefix => 'You: ';

  @override
  String get searchInMessages => 'Search in messages';

  @override
  String get yesterday => 'Yesterday';

  @override
  String todayAt(String time) {
    return 'Today at $time';
  }

  @override
  String yesterdayAt(String time) {
    return 'Yesterday at $time';
  }

  @override
  String dateAtTime(String date, String time) {
    return '$date at $time';
  }

  @override
  String get errorNotFound => 'Conversation not found';

  @override
  String get errorLoadFailed => 'Failed to load data';

  @override
  String get errorSendFailed => 'Failed to send message';

  @override
  String get errorUnknown => 'Something went wrong';
}
