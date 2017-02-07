import 'package:angular2/angular2.dart' show ViewContainerRef;
import 'package:material2_dart/src/core/core.dart' show AriaLivePoliteness;

/// Configuration used when opening a snack-bar.
class MdSnackBarConfig {
  /// The politeness level for the MdAriaLiveAnnouncer announcement.
  ///
  /// @Nullable
  AriaLivePoliteness politeness = AriaLivePoliteness.assertive;

  /// Message to be announced by the MdAriaLiveAnnouncer.
  ///
  /// @Nullable
  String announcementMessage = '';

  /// The view container to place the overlay for the snack bar into.
  ///
  /// @Nullable
  ViewContainerRef viewContainerRef;

  /// The length of time in milliseconds to wait before automatically dismissing the snack bar.
  /// @Nullable
  num duration = 0;
}
