import 'package:test/test.dart';
import 'package:material2_dart/src/core/coersion/number_property.dart';

void main() {
  group('coerceNumberProperty', () {
    test('should coerce null to 0 or default', () {
      expect(coerceNumberProperty(null), 0);
      expect(coerceNumberProperty(null, 111), 111);
    });

    test('should coerce true to 0 or default', () {
      expect(coerceNumberProperty(true), 0);
      expect(coerceNumberProperty(true, 111), 111);
    });

    test('should coerce false to 0 or default', () {
      expect(coerceNumberProperty(false), 0);
      expect(coerceNumberProperty(false, 111), 111);
    });

    test('should coerce the empty string to 0 or default', () {
      expect(coerceNumberProperty(''), 0);
      expect(coerceNumberProperty('', 111), 111);
    });

    test('should coerce the string "1" to 1', () {
      expect(coerceNumberProperty('1'), 1);
      expect(coerceNumberProperty('1', 111), 1);
    });

    test('should coerce the string "123.456" to 123.456', () {
      expect(coerceNumberProperty('123.456'), 123.456);
      expect(coerceNumberProperty('123.456', 111), 123.456);
    });

    test('should coerce the string "-123.456" to -123.456', () {
      expect(coerceNumberProperty('-123.456'), -123.456);
      expect(coerceNumberProperty('-123.456', 111), -123.456);
    });

    test('should coerce an arbitrary string to 0 or default', () {
      expect(coerceNumberProperty('pink'), 0);
      expect(coerceNumberProperty('pink', 111), 111);
    });

    test(
        'should coerce an arbitrary string prefixed with a number to 0 or default',
        () {
      expect(coerceNumberProperty('123pink'), 0);
      expect(coerceNumberProperty('123pink', 111), 111);
    });

    test('should coerce the number 1 to 1', () {
      expect(coerceNumberProperty(1), 1);
      expect(coerceNumberProperty(1, 111), 1);
    });

    test('should coerce the number 123.456 to 123.456', () {
      expect(coerceNumberProperty(123.456), 123.456);
      expect(coerceNumberProperty(123.456, 111), 123.456);
    });

    test('should coerce the number -123.456 to -123.456', () {
      expect(coerceNumberProperty(-123.456), -123.456);
      expect(coerceNumberProperty(-123.456, 111), -123.456);
    });

    test('should coerce an Map to 0 or default', () {
      expect(coerceNumberProperty(<dynamic, dynamic>{}), 0);
      expect(coerceNumberProperty(<dynamic, dynamic>{}, 111), 111);
    });

    test('should coerce an List to 0 or default', () {
      expect(coerceNumberProperty(<dynamic>[]), 0);
      expect(coerceNumberProperty(<dynamic>[], 111), 111);
    });
  });
}
