import 'package:mechanix_messages/core/utils/enums.dart';
import 'package:mechanix_messages/features/messages/data/models/conversation_model.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class MessageEntity {
  @Id()
  int id = 0;

  final conversation = ToOne<ConversationEntity>();

  String sender;

  String recipient;

  String body;

  /// Store enum.index
  int direction;

  /// Store enum.index
  int status;

  @Property(type: PropertyType.date)
  DateTime createdAt;

  @Property(type: PropertyType.date)
  DateTime? deliveredAt;

  @Property(type: PropertyType.date)
  DateTime? readAt;

  MessageEntity({
    required this.sender,
    required this.recipient,
    required this.body,
    required this.direction,
    required this.status,
    DateTime? createdAt,
    this.deliveredAt,
    this.readAt,
  }) : createdAt = createdAt ?? DateTime.now();

  MessageDirection get messageDirection => MessageDirection.values[direction];

  MessageStatus get messageStatus => MessageStatus.values[status];
}
