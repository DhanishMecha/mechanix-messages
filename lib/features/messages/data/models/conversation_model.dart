import 'package:mechanix_messages/features/messages/data/models/message_model.dart';
import 'package:mechanix_messages/features/messages/data/models/phone_number_model.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class ConversationEntity {
  @Id()
  int id = 0;

  /// Source of truth for SMS routing.
  /// Kept even if the contact is deleted.
  @Unique()
  String phoneNumber;

  /// Optional link to a saved contact's phone number entry.
  final phone = ToOne<PhoneNumberEntity>();

  @Property(type: PropertyType.date)
  DateTime createdAt;

  @Property(type: PropertyType.date)
  DateTime updatedAt;

  @Backlink('conversation')
  final messages = ToMany<MessageEntity>();

  ConversationEntity({
    required this.phoneNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();
}
