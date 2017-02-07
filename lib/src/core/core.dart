import 'line/line.dart';
import 'rtl/dir.dart';
import 'ripple/ripple.dart';
import 'portal/portal_directives.dart';
import 'overlay/overlay_directives.dart';
import 'overlay/overlay.dart';
import "a11y/live_announcer.dart" show a11yProviders, MdLiveAnnouncer;
import "coordination/unique_selection_dispatcher.dart";

// TODO(ntaoo): export LayoutDirection.
export "rtl/dir.dart" show RTL_DIRECTIVES, Dir;
export "portal/portal.dart"
    show Portal, PortalHost, BasePortalHost, ComponentPortal, TemplatePortal;
export "portal/portal_directives.dart"
    show PortalHostDirective, TemplatePortalDirective, PORTAL_DIRECTIVES;
export "portal/dom_portal_host.dart" show DomPortalHost;
export "overlay/overlay.dart" show Overlay, OVERLAY_PROVIDERS;
export "overlay/overlay_container.dart" show OverlayContainer;
export "overlay/overlay_ref.dart" show OverlayRef;
export "overlay/overlay_state.dart" show OverlayState;
export "overlay/overlay_directives.dart"
    show ConnectedOverlayDirective, OverlayOrigin, OVERLAY_DIRECTIVES;
export "overlay/position/connected_position.dart";
export "overlay/position/connected_position_strategy.dart";
export "ripple/ripple.dart" show MD_RIPPLE_DIRECTIVES, MdRipple;
//export "gestures/MdGestureConfig.dart";
export "a11y/live_announcer.dart" show a11yProviders, MdLiveAnnouncer, AriaLivePoliteness;
export "a11y/fake_mousedown.dart";

export "coordination/unique_selection_dispatcher.dart"
    show MdUniqueSelectionDispatcher, MdUniqueSelectionDispatcherListener;
export "line/line.dart" show MdLine, MdLineSetter;

export "style/apply_transform.dart" show applyCssTransform;
export "errors/error.dart" show MdError;
export "annotations/boolean_property.dart" show coerceBooleanProperty;
export 'animation/animation.dart';

export "coersion/number_property.dart";

const List CORE_DIRECTIVES = const <dynamic>[
  MdLine,
  RTL_DIRECTIVES,
  MdRipple,
  PORTAL_DIRECTIVES,
  OVERLAY_DIRECTIVES,
];

const List CORE_PROVIDERS = const <dynamic>[
  OVERLAY_PROVIDERS,
  a11yProviders,
  MdUniqueSelectionDispatcher,
];
