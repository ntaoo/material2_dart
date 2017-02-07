import 'package:angular2/angular2.dart';
import 'snack_bar_ref.dart';

/// A component used to open as the default snack bar, matching material spec.
///
/// This should only be used internally by the snack bar service.
@Component(
  selector: 'simple-snack-bar',
  templateUrl: 'simple_snack_bar.html',
  styleUrls: const ['simple_snack_bar.scss.css'],
  directives: const [NgIf]
)
class SimpleSnackBar {
  /// The message to be shown in the snack bar.
  String message;

  /// The label for the button in the snack bar.
  String action;

  /// The instance of the component making up the content of the snack bar.
  MdSnackBarRef<SimpleSnackBar> snackBarRef;

  /// Dismisses the snack bar.
  void dismiss() {
    snackBarRef.action();
  }

  /// If the action button should be shown.
  bool get hasAction {
    if (hasAction == null) return false;
    return action.isNotEmpty;
  }
}
