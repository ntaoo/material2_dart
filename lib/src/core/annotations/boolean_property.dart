bool coerceBooleanProperty(dynamic input) {
  if (input == null) return false;
  if (input is String && input == 'false') return false;
  if (input is bool) return input;
  return true;
}