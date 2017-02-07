import 'dart:html';
import 'dart:async';
import 'dart:math';
import 'package:angular2/angular2.dart';

enum ForegroundRippleState {
  emerging, // It's `NEW` in the TS version. Because `new` is a reserved keyword in Dart.
  expanding,
  fadingOut,
}

///Wrapper for a foreground ripple DOM element and its animation state.
class ForegroundRipple {
  ForegroundRippleState state = ForegroundRippleState.emerging;
  Element rippleElement;
  ForegroundRipple(this.rippleElement);
}

const num rippleSpeedPxPerSecond = 1000;
const num minRippleFillTimeSeconds = 0.1;
const num maxRippleFillTimeSeconds = 0.3;

/// Returns the distance from the point (x, y) to the furthest corner of a rectangle.
num distanceToFurthestCorner(num x, num y, Rectangle rectangle) {
  var distanceX = max((x - rectangle.left).abs(), (x - rectangle.right).abs());
  var distanceY = max((y - rectangle.top).abs(), (y - rectangle.bottom).abs());
  return sqrt(pow(distanceX, 2) + pow(distanceY, 2));
}

typedef void EventHandler(Event event);
typedef void TransitionEndCallback(ForegroundRipple r, TransitionEvent e);
typedef List<StreamSubscription<MouseEvent>> AddEventHandlers(Element trigger);

/// Helper service that performs DOM manipulations. Not intended to be used outside this module.
/// The constructor takes a reference to the ripple directive's host element and a map of DOM
/// event handlers to be installed on the element that triggers ripple animations.
/// This will eventually become a custom renderer once Angular support exists.
class RippleRenderer {
  Element _backgroundDiv;
  Element get _rippleElement => _elementRef.nativeElement;
  Element _triggerElement; // Nullable.
  ElementRef _elementRef;
  AddEventHandlers _addEventHandlers;
  List<StreamSubscription<MouseEvent>> _eventSubscriptions;
  RippleRenderer(this._elementRef, this._addEventHandlers) {
    // It might be nice to delay creating the background until it's needed, but doing this in
    // fadeInRippleBackground causes the first click event to not be handled reliably.
    _backgroundDiv = new DivElement()..classes.add('md-ripple-background');
    _rippleElement.append(_backgroundDiv);
  }

  /// Installs event handlers on the given trigger element,
  /// and removes event handlers from the previous trigger if needed.
  Future<Null> setTriggerElement(Element newTrigger) {
    return new Future.sync(() async {
      if (_triggerElement == newTrigger) return null;

      if (_triggerElement != null && _eventSubscriptions != null) {
        await Future
            .wait/*<dynamic>*/(_eventSubscriptions
                .map((StreamSubscription es) => es.cancel())
                .where((Future f) => f != null))
            .then/*<Null>*/((_) {
          _eventSubscriptions = null;
        });
      }
      _triggerElement = newTrigger;
      if (_triggerElement != null) {
        _eventSubscriptions = _addEventHandlers(_triggerElement);
      }
    });
  }

  /// Installs event handlers on the host element of the md-ripple directive.
  void setTriggerElementToHost() {
    setTriggerElement(_rippleElement);
  }

  /// Removes event handlers from the current trigger element if needed.
  void clearTriggerElement() {
    setTriggerElement(null);
  }

  /// Creates a foreground ripple and sets its animation to expand and fade in from the position
  /// given by rippleOriginLeft and rippleOriginTop (or from the center of the <md-ripple>
  /// bounding rect if centered is true).
  void createForegroundRipple(
      num rippleOriginLeft,
      num rippleOriginTop,
      String color,
      bool centered,
      num radius,
      num speedFactor,
      TransitionEndCallback transitionEndCallback) {
    final parentRect = _rippleElement.getBoundingClientRect();
    // Create a foreground ripple div with the size and position of the fully expanded ripple.
    // When the div is created, it's given a transform style that causes the ripple to be displayed
    // small and centered on the event location (or the center of the bounding rect if the centered
    // argument is true). Removing that transform causes the ripple to animate to its natural size.
    final startX =
        centered ? (parentRect.left + parentRect.width / 2) : rippleOriginLeft;
    final startY =
        centered ? (parentRect.top + parentRect.height / 2) : rippleOriginTop;
    final offsetX = startX - parentRect.left;
    final offsetY = startY - parentRect.top;
    final maxRadius = radius > 0
        ? radius
        : distanceToFurthestCorner(startX, startY, parentRect);

    final rippleDiv = new DivElement();
    _rippleElement.append(rippleDiv);
    rippleDiv.classes.add('md-ripple-foreground');

    final fadeInSeconds = (1 /
            (speedFactor == null || speedFactor == 0 ? 1 : speedFactor)) *
        max(minRippleFillTimeSeconds,
            min(maxRippleFillTimeSeconds, maxRadius / rippleSpeedPxPerSecond));

    rippleDiv.style
      ..left = '${offsetX - maxRadius}px'
      ..top = '${offsetY - maxRadius}px'
      ..width = '${2 * maxRadius}px'
      ..height = rippleDiv.style.width
      // If color input is not set, this will default to the background color defined in CSS.
      ..backgroundColor = color
      // Start the ripple tiny.
      ..transform = 'scale(0.001)'
      ..transitionDuration = '${fadeInSeconds}s';

    // https://timtaubert.de/blog/2012/09/css-transitions-for-dynamically-created-dom-elements/
    rippleDiv.getComputedStyle().opacity;

    rippleDiv
      ..classes.add('md-ripple-fade-in')
      // Clearing the transform property causes the ripple to animate to its full size.
      ..style.transform = '';
    final ripple = new ForegroundRipple(rippleDiv)
      ..state = ForegroundRippleState.expanding;

    rippleDiv.onTransitionEnd.listen(
        (TransitionEvent event) => transitionEndCallback(ripple, event));
  }

  /// Fades out a foreground ripple after it has fully expanded and faded in.
  void fadeOutForegroundRipple(Element ripple) {
    ripple.classes
      ..remove('md-ripple-fade-in')
      ..add('md-ripple-fade-out');
  }

  /// Removes a foreground ripple from the DOM after it has faded out.
  void removeRippleFromDom(Element ripple) {
    ripple.remove();
  }

  /// Fades in the ripple background.
  void fadeInRippleBackground(String color) {
    _backgroundDiv
      ..classes.add('md-ripple-active')
      // If color is not set, this will default to the background color defined in CSS.
      ..style.backgroundColor = color;
  }

  /// Fades out the ripple background.
  void fadeOutRippleBackground() {
    if (_backgroundDiv != null) {
      _backgroundDiv.classes.remove('md-ripple-active');
    }
  }
}
