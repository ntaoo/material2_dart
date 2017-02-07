import "dart:html";
import "dart:async";
import "package:angular2/angular2.dart";
import "overlay_state.dart";
import "../portal/dom_portal_host.dart";
import "overlay_ref.dart";
import "position/overlay_position_builder.dart";
import "position/viewport_ruler.dart";
import "overlay_container.dart";

export 'position/connected_position.dart';

/// Next overlay unique ID.
int nextUniqueId = 0;

/// The default state for newly created overlays.
OverlayState defaultState = new OverlayState();

/**
 * Service to create Overlays. Overlays are dynamically added pieces of floating UI, meant to be
 * used as a low-level building building block for other components. Dialogs, tooltips, menus,
 * selects, etc. can all be built using overlays. The service should primarily be used by authors
 * of re-usable components rather than developers building end-user applications.
 *
 * An overlay *is* a PortalHost, so any kind of Portal can be loaded into one.
 */
@Injectable()
class Overlay {
  OverlayContainer _overlayContainer;
  ComponentResolver _componentResolver;
  OverlayPositionBuilder _positionBuilder;
  ApplicationRef _appRef;
  Injector _injector;

  Overlay(this._overlayContainer, this._componentResolver,
      this._positionBuilder, this._appRef, this._injector);

  /**
   * Creates an overlay.
   */
  Future<OverlayRef> create([OverlayState state]) async {
    state ??= defaultState;
    DivElement pane = await _createPaneElement();
    return _createOverlayRef(pane, state);
  }

  /**
   * Returns a position builder that can be used, via fluent API,
   * to construct and configure a position strategy.
   */
  OverlayPositionBuilder position() => _positionBuilder;

  /**
   * Creates the DOM element for an overlay and appends it to the overlay container.
   */
  Future<DivElement> _createPaneElement() {
    DivElement pane = new DivElement()
      ..id = 'md-overlay-${nextUniqueId++}'
      ..classes.add("md-overlay-pane");
    _overlayContainer.getContainerElement().append(pane);
    return new Future.value(pane);
  }

  /// Create a DomPortalHost into which the overlay content can be loaded.
  DomPortalHost _createPortalHost(DivElement pane) =>
      new DomPortalHost(pane, _componentResolver, _appRef, _injector);

  /// Creates an OverlayRef for an overlay in the given DOM element.
  OverlayRef _createOverlayRef(DivElement pane, OverlayState state) =>
      new OverlayRef(_createPortalHost(pane), pane, state);
}

/// Providers for Overlay and its related injectables.
const List OVERLAY_PROVIDERS = const [
  ViewportRuler,
  OverlayPositionBuilder,
  Overlay
];
