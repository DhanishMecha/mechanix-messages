enum MessageDirection { incoming, outgoing }

enum MessageStatus { pending, sent, delivered, failed }

enum ConversationFilter { all, unread }

enum PhoneLabel { mobile, home, work, main, fax, other }

enum EmailLabel { home, work, personal, school, other }

enum ConversationErrorType {
  none,
  notFound,
  loadFailed,
  sendFailed,
  unknown,
}

enum MessagesErrorType {
  loadFailed,
  unknown,
}
