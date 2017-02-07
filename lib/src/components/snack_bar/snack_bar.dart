import 'dart:async';
import 'package:angular2/angular2.dart';
import 'package:material2_dart/src/core/core.dart';
import 'snack_bar_config.dart';
import 'snack_bar_ref.dart';
import 'snack_bar_container.dart';
import 'simple_snack_bar.dart';

/// Service to dispatch Material Design snack bar messages.
@Injectable()
class MdSnackBar {
  /// A reference to the current snack bar in the view.
  MdSnackBarRef<dynamic> _snackBarRef;
  Overlay _overlay;
  // TODO(ntaoo): Rename to LiveAnnouncer;
  MdLiveAnnouncer _live;
  MdSnackBar(this._overlay, this._live);

  /// Creates and dispatches a snack bar with a custom component for the content, removing any
  /// currently opened snack bars.
  /// @param component Component to be instantiated.
  /// @param config Extra configuration for the snack bar.
  Future<MdSnackBarRef<T>> openFromComponent<T>(
      Type component, MdSnackBarConfig config) async {
    config = _applyConfigDefaults(config);
    var overlayRef = await _createOverlay();
    var snackBarContainer = await _attachSnackBarContainer(overlayRef, config);
    var snackBarRef = await _attachSnackbarContent<T>(
        component, snackBarContainer, overlayRef);

    // When the snackbar is dismissed, clear the reference to it.
    snackBarRef.afterDismissed().listen((_) {
      // Clear the snackbar ref if it hasn't already been replaced by a newer snackbar.
      if (_snackBarRef == snackBarRef) _snackBarRef = null;
    });

    // If a snack bar is already in view, dismiss it and enter the new snack bar after exit
    // animation is complete.
    if (_snackBarRef != null) {
      _snackBarRef.afterDismissed().listen((_) {
        snackBarRef.containerInstance.enter();
      });
      _snackBarRef.dismiss();
      // If no snack bar is in view, enter the new snack bar.
    } else {
      snackBarRef.containerInstance.enter();
    }

    // If a dismiss timeout is provided, set up dismiss based on after the snackbar is opened.
    if (config.duration > 0) {
      snackBarRef.afterOpened().listen((_) {
        new Timer(new Duration(milliseconds: config.duration), () {
          snackBarRef.dismiss();
        });
      });
    }

    // TODO(ntaoo): Edit the #announce's argument not to use the `.toString().split('.').last`.
    _live.announce(config.announcementMessage,
        config.politeness.toString().split('.').last);
    _snackBarRef = snackBarRef;
    return _snackBarRef as MdSnackBarRef<T>;
  }

  /// Opens a snackbar with a message and an optional action.
  /// @param message The message to show in the snackbar.
  /// @param action The label for the snackbar action.
  /// @param config Additional configuration options for the snackbar.
  Future<MdSnackBarRef<SimpleSnackBar>> open(String message,
      [String action = '', MdSnackBarConfig config]) async {
    config.announcementMessage = message;
    var simpleSnackBarRef =
        await openFromComponent<dynamic>(SimpleSnackBar, config);
    simpleSnackBarRef.instance.snackBarRef = simpleSnackBarRef;
    simpleSnackBarRef.instance.message = message;
    simpleSnackBarRef.instance.action = action;
    return simpleSnackBarRef as MdSnackBarRef<SimpleSnackBar>;
  }

  /// Attaches the snack bar container component to the overlay.
  Future<MdSnackBarContainer> _attachSnackBarContainer(
      OverlayRef overlayRef, MdSnackBarConfig config) async {
    var containerPortal =
        new ComponentPortal(MdSnackBarContainer, config.viewContainerRef);
    // ComponentRef<MdSnackBarContainer>
    ComponentRef containerRef = await overlayRef.attach(containerPortal);
    containerRef.instance.snackBarConfig = config;

    return containerRef.instance;
  }

  /// Places a new component as the content of the snack bar container.
  Future<MdSnackBarRef<T>> _attachSnackbarContent<T>(Type component,
      MdSnackBarContainer container, OverlayRef overlayRef) async {
    var portal = new ComponentPortal(component);
    var contentRef = await container.attachComponentPortal(portal);
    return new MdSnackBarRef<dynamic>(
        contentRef.instance, container, overlayRef);
  }

  /// Creates a new overlay and places it in the correct location.
  Future<OverlayRef> _createOverlay() {
    var state = new OverlayState();
    state.positionStrategy =
        _overlay.position().global().centerHorizontally().bottom('0');
    return _overlay.create(state);
  }
}

/// Applies default options to the snackbar config.
///
/// @param config The configuration to which the defaults will be applied.
/// @returns The new configuration object with defaults applied.
MdSnackBarConfig _applyConfigDefaults(MdSnackBarConfig config) {
  var newConfig = new MdSnackBarConfig();
  if (config == null) return newConfig;

  if (config.politeness != null) newConfig.politeness = config.politeness;
  if (config.announcementMessage != null)
    newConfig.announcementMessage = config.announcementMessage;
  if (config.viewContainerRef != null)
    newConfig.viewContainerRef = config.viewContainerRef;
  if (config.duration != null) newConfig.duration = config.duration;
  return newConfig;
}

//@NgModule({
//  imports: [OverlayModule, PortalModule, CommonModule, DefaultStyleCompatibilityModeModule],
//  exports: [MdSnackBarContainer, DefaultStyleCompatibilityModeModule],
//  declarations: [MdSnackBarContainer, SimpleSnackBar],
//  entryComponents: [MdSnackBarContainer, SimpleSnackBar],
//})
//export class MdSnackBarModule {
//  static forRoot(): ModuleWithProviders {
//    return {
//      ngModule: MdSnackBarModule,
//      providers: [MdSnackBar, OVERLAY_PROVIDERS, LiveAnnouncer]
//    };
//  }
//}
