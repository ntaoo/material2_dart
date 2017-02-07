import 'package:material2_dart/src/core/core.dart' show MdError;

/// Error that is thrown when attempting to attach a snack bar that is already attached.
class MdSnackBarContentAlreadyAttached extends MdError {
  MdSnackBarContentAlreadyAttached()
      : super(
            'Attempting to attach snack bar content after content is already attached');
}
