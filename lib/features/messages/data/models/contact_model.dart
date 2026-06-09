import 'package:mechanix_messages/features/messages/data/models/email_model.dart';
import 'package:mechanix_messages/features/messages/data/models/phone_number_model.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class ContactEntity {
  @Id()
  int id = 0;

  /// Contact display name.
  String name;

  /// Whether the contact is marked as a favorite.
  bool favorite;

  /// Reverse relation to all phone numbers linked to this contact.
  ///
  /// ObjectBox automatically populates this collection based on the
  /// `PhoneNumberEntity.contact` ToOne relationship.
  /// No manual management of this list is required.
  @Backlink('contact')
  final phoneNumbers = ToMany<PhoneNumberEntity>();

  @Backlink('contact')
  final emails = ToMany<EmailEntity>();

  ContactEntity({required this.name, this.favorite = false});
}
