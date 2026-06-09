import 'package:mechanix_messages/core/utils/enums.dart';
import 'package:mechanix_messages/features/messages/data/models/contact_model.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class EmailEntity {
  @Id()
  int id = 0;

  String email;

  int labelIndex = EmailLabel.home.index;

  final contact = ToOne<ContactEntity>();

  EmailEntity({required this.email, EmailLabel label = EmailLabel.home})
    : labelIndex = label.index;

  @Transient()
  EmailLabel get label {
    if (labelIndex < 0 || labelIndex >= EmailLabel.values.length) {
      return EmailLabel.home;
    }
    return EmailLabel.values[labelIndex];
  }

  set label(EmailLabel value) {
    labelIndex = value.index;
  }
}
