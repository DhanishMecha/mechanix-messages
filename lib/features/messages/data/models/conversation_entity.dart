import 'package:mechanix_messages/features/messages/data/models/message_entity.dart';
import 'package:mechanix_contacts/mechanix_contacts.dart';

@Entity()
class ConversationEntity {
  @Id()
  int id = 0;

  @Unique()
  String phoneNumber;

  @Property(type: PropertyType.date)
  DateTime createdAt;

  @Property(type: PropertyType.date)
  DateTime updatedAt;

  @Backlink('conversation')
  final messages = ToMany<MessageEntity>();

  @Transient()
  ContactEntity? contact;

  @Transient()
  MessageEntity? lastMessage;

  @Transient()
  bool hasUnread = false;

  ConversationEntity({
    required this.phoneNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();
}
