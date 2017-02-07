import 'dart:async';
import "package:angular2/angular2.dart";
import "overlay.dart";
import "overlay_ref.dart";
import "../portal/portal.dart";
import "../rtl/dir.dart";
import "overlay_state.dart";
import "position/connected_position.dart";
import "position/connected_position_strategy.dart";

/// Default set of positions for the overlay. Follows the behavior of a dropdown.
List<ConnectionPositionPair> defaultPositionList = [
  new ConnectionPositionPair(
      new OriginConnectionPosition(
          HorizontalConnectionPos.start, VerticalConnectionPos.bottom),
      new OverlayConnectionPosition(
          HorizontalConnectionPos.start, VerticalConnectionPos.top)),
  new ConnectionPositionPair(
      new OriginConnectionPosition(
          HorizontalConnectionPos.start, VerticalConnectionPos.top),
      new OverlayConnectionPosition(
          HorizontalConnectionPos.start, VerticalConnectionPos.bottom)),
];

/**
 * Directive applied to an element to make it usable as an origin for an Overlay using a
 * ConnectedPositionStrategy.
 */
@Directive(selector: "[overlay-origin]", exportAs: "overlayOrigin")
class OverlayOrigin {
  ElementRef _elementRef;

  OverlayOrigin(this._elementRef);

  ElementRef get elementRef => _elementRef;
}

/**
 * Directive to facilitate declarative creation of an Overlay using a ConnectedPositionStrategy.
 */
@Directive(selector: "[connected-overlay]")
class ConnectedOverlayDirective implements OnDestroy {
  Overlay _overlay;
  OverlayRef _overlayRef;
  TemplatePortal _templatePortal;
  bool _open = false;
  bool _hasBackdrop = false;
  StreamSubscription _backdropSubscription;

  @Input()
  OverlayOrigin origin;
  @Input()
  List<ConnectionPositionPair> positions;

  /// The offset in pixels for the overlay connection point on the x-axis.
  @Input()
  num offsetX = 0;

  /// The offset in pixels for the overlay connection point on the y-axis.
  @Input()
  num offsetY = 0;

  @Input()
  dynamic /*num | String*/ width;
  @Input()
  dynamic /*num | String*/ height;

  /// The custom class to be set on the backdrop element.
  @Input()
  String backdropClass;

  /// Whether or not the overlay should attach a backdrop.
  bool get hasBackdrop => _hasBackdrop;

  // もしかしてDart版はStringでなくexpressionはparseされているのでは？
  // お試し中 もしそうなら、@Input() bool hasBackdrop;だけで良くなる。
  @Input()
  set hasBackdrop(bool value) {
    if (value == null) value = false;
    _hasBackdrop = value;
  }

  bool get open => _open;

  @Input()
  set open(bool value) {
    value ? _attachOverlay() : _detachOverlay();
    _open = value;
  }

  /// Event emitted when the backdrop is clicked.
  @Output()
  EventEmitter<Null> backdropClick = new EventEmitter();

  Dir _dir;

  ConnectedOverlayDirective(this._overlay, TemplateRef templateRef,
      ViewContainerRef viewContainerRef, @Optional() this._dir)
      : _templatePortal = new TemplatePortal(templateRef, viewContainerRef);

  OverlayRef get overlayRef => _overlayRef;

  String get dir => _dir != null ? _dir.value : 'ltr';

  @override
  void ngOnDestroy() {
    _destroyOverlay();
  }

  /// Creates an overlay.
  Future<Null> _createOverlay() async {
    if (positions == null || positions.length != 0) {
      positions = defaultPositionList;
    }
    _overlayRef = await _overlay.create(_buildConfig());
  }

  /// Builds the overlay config based on the directive's inputs.
  OverlayState _buildConfig() {
    var overlayConfig = new OverlayState();
    if (width == null) overlayConfig.width = width;
    if (height == null) overlayConfig.height = height;
    overlayConfig.hasBackdrop = hasBackdrop;
    if (backdropClass != null && backdropClass.isNotEmpty)
      overlayConfig.backdropClass = backdropClass;
    overlayConfig.positionStrategy = _createPositionStrategy();
    overlayConfig.direction = dir;
    return overlayConfig;
  }

//  /// Returns the position of the overlay to be set on the overlay config.
//  ConnectedPositionStrategy _getPosition() {
//    return _overlay
//        .position()
//        .connectedTo(
//            origin.elementRef,
//            new OriginConnectionPosition(
//                positions[0].overlayX, positions[0].originY),
//            new OverlayConnectionPosition(
//                positions[0].overlayX, positions[0].overlayY))
//        .setDirection(_dir);
//  }

  /// Returns the position strategy of the overlay to be set on the overlay config.
  ConnectedPositionStrategy _createPositionStrategy() {
    final pos = positions[0];
    final originPoint = new OriginConnectionPosition(pos.originX, pos.originY);
    final overlayPoint = new OverlayConnectionPosition(pos.overlayX, pos.overlayY);
    return _overlay.position()
      .connectedTo(origin.elementRef, originPoint, overlayPoint)
      .withDirection(dir)
      .withOffsetX(offsetX)
      .withOffsetY(offsetY);
  }
  
  /// Attaches the overlay and subscribes to backdrop clicks if backdrop exists.
  Future _attachOverlay() async {
    if (_overlayRef == null) await _createOverlay();
    if (_overlayRef != null && !_overlayRef.hasAttached())
      await _overlayRef.attach(_templatePortal);

    if (hasBackdrop) {
      _backdropSubscription = _overlayRef.backdropClick.listen((_) {
        backdropClick.add(null);
      });
    }
  }

  /// Detaches the overlay and unsubscribes to backdrop clicks if backdrop exists.
  Future _detachOverlay() async {
    if (_overlayRef != null) await _overlayRef.detach();

    if (_backdropSubscription != null) {
      await _backdropSubscription.cancel();
      _backdropSubscription = null;
    }
  }

  /// Destroys the overlay created by this directive.
  void _destroyOverlay() {
    if (_overlayRef != null) _overlayRef.dispose();
    if (_backdropSubscription != null) _backdropSubscription.cancel();
  }
}

const List OVERLAY_DIRECTIVES = const [
  ConnectedOverlayDirective,
  OverlayOrigin
];
