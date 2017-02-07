import 'package:test/test.dart';
import 'package:material2_dart/src/core/annotations/boolean_property.dart';

void main() {
  group('coerceBooleanProperty', () {
    test('should coerce null to false', () {
      expect(coerceBooleanProperty(null), isFalse);
    });
    group('Type: String', () {
      test('should coerce only "false" to false, otherwise to true', () {
        expect(coerceBooleanProperty('hello'), isTrue);
        expect(coerceBooleanProperty('true'), isTrue);
        expect(coerceBooleanProperty(''), isTrue);
        expect(coerceBooleanProperty('false'), isFalse);
      });
    });
    test('should work for bool value', () {
      expect(coerceBooleanProperty(true), isTrue);
      expect(coerceBooleanProperty(false), isFalse);
    });
    group('Type: the any other objects', () {
      test('should coerce to true', () {
        expect(coerceBooleanProperty(0), isTrue);
        expect(coerceBooleanProperty(<dynamic>[]), isTrue);
        expect(coerceBooleanProperty(<dynamic, dynamic>{}), isTrue);
      });
    });
  });
}
