import 'dart:async';
import 'package:material2_dart/src/core/core.dart' show OverlayRef;
import 'snack_bar_container.dart';

/// Reference to a snack bar dispatched from the snack bar service.
class MdSnackBarRef<T> {
  T _instance;

  /// The instance of the component making up the content of the snack bar.
  T get instance => _instance;

  /// The instance of the component making up the content of the snack bar.
  MdSnackBarContainer containerInstance;

  StreamController<dynamic> _afterClosedController = new StreamController<dynamic>();
  /// Subject for notifying the user that the snack bar has closed.
  Stream<dynamic> get _afterClosed => _afterClosedController.stream;

  StreamController<dynamic> _afterOpenedController = new StreamController<dynamic>();
  /// Subject for notifying the user that the snack bar has opened and appeared.
  Stream<dynamic> get _afterOpened => _afterOpenedController.stream;

  StreamController<dynamic> _onActionController = new StreamController<dynamic>();
  /// Subject for notifying the user that the snack bar action was called.
  Stream<dynamic> get _onAction => _onActionController.stream;

  final OverlayRef _overlayRef;
  MdSnackBarRef(this._instance, this.containerInstance, this._overlayRef) {
    // Sets the readonly instance of the snack bar content component.
    // Dismiss snackbar on action.
    onAction().listen((_) => dismiss());
    containerInstance.onExit().listen((_) => _finishDismiss());
  }

  /// Dismisses the snack bar.
  void dismiss() {
    if (!_afterClosedController.isClosed) {
      containerInstance.exit();
    }
  }

  /// Marks the snackbar action clicked.
  void action() {
    if (!_onActionController.isClosed) {
      _onActionController.add(null);
      _onActionController.close();
    }
  }

  /// Marks the snackbar as opened.
  void open() {
    if (!_afterOpenedController.isClosed) {
      _afterOpenedController.add(null);
      _afterOpenedController.close();
    }
  }

  /// Cleans up the DOM after closing.
  void _finishDismiss() {
    _overlayRef.dispose();
    _afterClosedController.add(null);
    _afterClosedController.close();
  }

  /// Gets an observable that is notified when the snack bar is finished closing.
  Stream<Null> afterDismissed() {
    return _afterClosed as Stream<Null>;
  }

  /// Gets an observable that is notified when the snack bar has opened and appeared.
  Stream<Null> afterOpened() {
    return containerInstance.onEnter();
  }

  /// Gets an observable that is notified when the snack bar action is called.
  Stream<Null> onAction() {
    return _onAction as Stream<Null>;
  }
}
