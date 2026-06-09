import 'package:mechanix_messages/core/utils/enums.dart';
import 'package:mechanix_messages/features/messages/data/models/contact_model.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class PhoneNumberEntity {
  @Id()
  int id = 0;

  String number;

  int labelIndex = PhoneLabel.mobile.index;

  final contact = ToOne<ContactEntity>();

  PhoneNumberEntity({
    required this.number,
    PhoneLabel label = PhoneLabel.mobile,
  }) : labelIndex = label.index;

  @Transient()
  PhoneLabel get label => PhoneLabel.values[labelIndex];

  set label(PhoneLabel value) {
    labelIndex = value.index;
  }
}
