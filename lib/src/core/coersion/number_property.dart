/// Coerces a data-bound value (typically a string) to a number.
num coerceNumberProperty(dynamic value, [num fallbackValue = 0]) {
  if (value is num) return value;
  if (value is String) return num.parse(value, (_) => fallbackValue);
  return fallbackValue;
}
