import 'package:equatable/equatable.dart';
import 'package:mechanix_contacts/mechanix_contacts.dart';
import 'package:mechanix_messages/features/messages/data/models/enums.dart';
import 'package:mechanix_messages/features/messages/data/models/message_entity.dart';

class ConversationModel extends Equatable {
  final int id;
  final String phoneNumber;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ContactEntity? contact;
  final MessageEntity? lastMessage;

  const ConversationModel({
    required this.id,
    required this.phoneNumber,
    required this.createdAt,
    required this.updatedAt,
    this.contact,
    this.lastMessage,
  });

  bool get hasUnread => lastMessage != null &&
      lastMessage!.messageDirection == MessageDirection.incoming &&
      lastMessage!.readAt == null;

  ConversationModel copyWith({
    int? id,
    String? phoneNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
    ContactEntity? contact,
    MessageEntity? lastMessage,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      contact: contact ?? this.contact,
      lastMessage: lastMessage ?? this.lastMessage,
    );
  }

  @override
  List<Object?> get props => [
        id,
        phoneNumber,
        createdAt,
        updatedAt,
        contact,
        lastMessage,
      ];
}
