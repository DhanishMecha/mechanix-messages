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

  @override
  String deleteConversationTitle(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Delete conversations',
      one: 'Delete conversation',
    );
    return '$_temp0';
  }

  @override
  String deleteConversationBody(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Are you sure you want to delete the selected conversations?',
      one: 'Are you sure you want to delete the selected conversation?',
    );
    return '$_temp0';
  }

  @override
  String get deleteConversationButton => 'Delete';

  @override
  String get cancelButton => 'Cancel';
}
