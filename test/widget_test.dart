import 'package:flutter_test/flutter_test.dart';
import 'package:mechanix_messages/features/messages/data/models/enums.dart';

void main() {
  test('Enum values test', () {
    expect(MessageDirection.incoming.index, 0);
    expect(MessageDirection.outgoing.index, 1);
  });
}
