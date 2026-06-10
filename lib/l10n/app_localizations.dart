import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// Title of the messages list screen showing all messages
  ///
  /// In en, this message translates to:
  /// **'All messages'**
  String get allMessages;

  /// Label for filter conversations tab to show all messages
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// Label for filter conversations tab to show only unread messages
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get filterUnread;

  /// Text shown when there are no messages in the list
  ///
  /// In en, this message translates to:
  /// **'No messages'**
  String get noMessages;

  /// Title of the new message screen
  ///
  /// In en, this message translates to:
  /// **'New message'**
  String get newMessage;

  /// Prefix for the search field to target contact selection
  ///
  /// In en, this message translates to:
  /// **'To: '**
  String get toLabel;

  /// Placeholder hint inside search input in select contact screen
  ///
  /// In en, this message translates to:
  /// **'Search or enter phone number'**
  String get searchOrEnterPhone;

  /// Action tile label to start a new chat with a direct phone number
  ///
  /// In en, this message translates to:
  /// **'Send message to {query}'**
  String sendMessageTo(String query);

  /// Message indicating no contacts exist in the local database
  ///
  /// In en, this message translates to:
  /// **'No contacts found'**
  String get noContactsFound;

  /// Message indicating no contacts match the current query
  ///
  /// In en, this message translates to:
  /// **'No matching contacts'**
  String get noMatchingContacts;

  /// Label used for contact with empty phone number
  ///
  /// In en, this message translates to:
  /// **'No number'**
  String get noNumber;

  /// Hint text for message composer text input
  ///
  /// In en, this message translates to:
  /// **'Write a message...'**
  String get writeMessage;

  /// Hint text in the messages list search bar
  ///
  /// In en, this message translates to:
  /// **'Search in messages'**
  String get searchInMessages;

  /// Label for yesterday date
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// Label for message sent today at specific time
  ///
  /// In en, this message translates to:
  /// **'Today at {time}'**
  String todayAt(String time);

  /// Label for message sent yesterday at specific time
  ///
  /// In en, this message translates to:
  /// **'Yesterday at {time}'**
  String yesterdayAt(String time);

  /// Label for message sent on a specific date at specific time
  ///
  /// In en, this message translates to:
  /// **'{date} at {time}'**
  String dateAtTime(String date, String time);

  /// Error message when a conversation cannot be found
  ///
  /// In en, this message translates to:
  /// **'Conversation not found'**
  String get errorNotFound;

  /// Error message when data load fails
  ///
  /// In en, this message translates to:
  /// **'Failed to load data'**
  String get errorLoadFailed;

  /// Error message when sending a message fails
  ///
  /// In en, this message translates to:
  /// **'Failed to send message'**
  String get errorSendFailed;

  /// Fallback error message for unknown errors
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorUnknown;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
