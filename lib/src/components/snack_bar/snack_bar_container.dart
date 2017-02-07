import 'dart:html';
import 'dart:async';
import 'package:angular2/angular2.dart';
import 'package:material2_dart/src/core/core.dart'
    show BasePortalHost, ComponentPortal, TemplatePortal, PortalHostDirective;
import 'snack_bar_config.dart';
import 'snack_bar_errors.dart';

/// In Dart, using "none" instead of "void" because "void" is the keyword.
enum SnackBarState { initial, visible, complete, none }

const String showAnimation = '225ms cubic-bezier(0.4,0.0,1,1)';
const String hideAnimation = '195ms cubic-bezier(0.0,0.0,0.2,1)';

/// Internal component that wraps user-provided snack bar content.
@Component(
  selector: 'snack-bar-container',
  templateUrl: 'snack_bar_container.html',
  styleUrls: ['snack_bar_container.scss.css'],
  host: {
    'role': 'alert',
    '[@state]': 'animationState',
    '(@state.done)': r'onAnimationEnd($event)'
  },
//  animations: [
//    trigger('state', [
//      state('initial', style({transform: 'translateY(100%)'})),
//      state('visible', style({transform: 'translateY(0%)'})),
//      state('complete', style({transform: 'translateY(100%)'})),
//      transition('visible => complete', animate(HIDE_ANIMATION)),
//      transition('initial => visible, void => visible', animate(SHOW_ANIMATION)),
//    ])
//  ],
)
class MdSnackBarContainer extends BasePortalHost implements OnDestroy {
  /** The portal host inside of this container into which the snack bar content will be loaded. */
  @ViewChild(PortalHostDirective)
  PortalHostDirective portalHost;

  final StreamController _onExitController = new StreamController<dynamic>();

  /// Subject for notifying that the snack bar has exited from view.
  Stream<dynamic> get _onExit => _onExitController.stream;

  final StreamController _onEnterController = new StreamController<dynamic>();

  /// Subject for notifying that the snack bar has finished entering the view. */
  Stream<dynamic> _onEnter = _onEnterController.stream;

  /// The state of the snack bar animations.
  SnackBarState animationState = SnackBarState.initial;

  /// The snack bar configuration.
  MdSnackBarConfig snackBarConfig;
  final NgZone _ngZone;

  MdSnackBarContainer(this._ngZone) : super();

  /// Attach a component portal as content to this snack bar container.
  /// TODO(ntaoo): AngularDart ComponentRef doesn't support parameter type. Revisit here and do some action.
  @override
  Future<ComponentRef> attachComponentPortal(ComponentPortal portal) {
    if (portalHost.hasAttached()) {
      throw new MdSnackBarContentAlreadyAttached();
    }

    return portalHost.attachComponentPortal(portal);
  }

  /// Attach a template portal as content to this snack bar container.
  @override
  Future<Map<String, dynamic>> attachTemplatePortal(TemplatePortal portal) {
    throw 'Not yet implemented';
  }

  /// Handle end of animations, updating the state of the snackbar.
  /// TODO: workaround for AnimationTransitionEvent
  onAnimationEnd(Event event) {
    if (event.toState == SnackBarState.none ||
        event.toState == SnackBarState.complete) {
      _ngZone.run(() {
        _onExitController.add(null);
        _onExitController.close();
      });
    }
    if (event.toState == SnackBarState.visible) {
      _ngZone.run(() {
        _onEnterController.add(null);
        _onEnterController.close();
      });
    }
  }

  /// Begin animation of snack bar entrance into view.
  void enter() {
    animationState = SnackBarState.visible;
  }

  /// Returns an observable resolving when the enter animation completes.
  Stream<Null> onEnter() {
    animationState = SnackBarState.visible;
    return _onEnter as Stream<Null>;
  }

  /// Begin animation of the snack bar exiting from view.
  Stream<Null> exit() {
    animationState = SnackBarState.complete;
    return onExit();
  }

  /// Returns an observable that completes after the closing animation is done.
  Stream<Null> onExit() {
    return _onExit;
  }

  /// Makes sure the exit callbacks have been invoked when the element is destroyed.
  void ngOnDestroy() {
    // Wait for the zone to settle before removing the element. Helps prevent
    // errors where we end up removing an element which is in the middle of an animation.
    _ngZone.onMicrotaskEmpty.first.then((_) {
      _onExitController.add(null);
      _onExitController.close();
    });
  }
}
