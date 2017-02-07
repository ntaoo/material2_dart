import 'dart:html';
import 'dart:async';
import 'package:angular2/angular2.dart';
import 'ripple_renderer.dart';

@Directive(selector: '[md-ripple]')
class MdRipple implements OnInit, OnDestroy, OnChanges {
  /// The element that triggers the ripple when click events are received.
  /// Defaults to the directive's host element.
  @Input('md-ripple-trigger')
  Element trigger;

  /// Whether the ripple always originates from the center of the host element's bounds,
  /// rather than originating from the location of the click event.
  @Input('md-ripple-centered')
  bool centered = false;

  /// Whether click events will not trigger the ripple.
  /// It can still be triggered by manually calling start() and end().
  @Input('md-ripple-disabled')
  bool disabled  = false;

  /// If set, the radius in pixels of foreground ripples when fully expanded.
  /// If unset, the radius will be the distance from the center of the ripple
  /// to the furthest corner of the host element's bounding rectangle.
  @Input('md-ripple-max-radius')
  num maxRadius = 0;

  /// If set, the normal duration of ripple animations is divided by this value.
  /// For example, setting it to 0.5 will cause the animations to take twice as long.
  @Input('md-ripple-speed-factor')
  num speedFactor = 1;

  /// Custom color for ripples.
  @Input('md-ripple-color')
  String color;

  /// Custom color for the ripple background.
  @Input('md-ripple-background-color')
  String backgroundColor;

  /// Whether the ripple background will be highlighted to indicated a focused state.
  @HostBinding('class.md-ripple-focused')
  @Input('md-ripple-focused')
  bool focused = false;

  /// Whether foreground ripples should be visible outside the component's bounds.
  @HostBinding('class.md-ripple-unbounded')
  @Input('md-ripple-unbounded')
  bool unbounded = false;

  RippleRenderer _rippleRenderer;
  ElementRef _elementRef;
  MdRipple(this._elementRef) {
    // By _addEventHandlers, the event handlers are attached to the element that triggers the ripple animations.
    _rippleRenderer = new RippleRenderer(_elementRef, _addEventHandlers);
  }

  @override
  void ngOnInit() {
    // If no trigger element was explicity set, use the host element
    if (trigger == null) {
      _rippleRenderer.setTriggerElementToHost();
    }
  }

  @override
  void ngOnDestroy() {
    // Remove event listeners on the trigger element.
    _rippleRenderer.clearTriggerElement();
  }

  @override
  void ngOnChanges(Map<String, SimpleChange> changes) {
    // If the trigger element changed (or is being initially set), add event listeners to it.
    final changedInputs = changes.keys;
    if (changedInputs.contains('trigger')) {
      _rippleRenderer.setTriggerElement(trigger);
    }
  }

  /// Responds to the start of a ripple animation trigger by fading the background in.
  void start() {
    _rippleRenderer.fadeInRippleBackground(backgroundColor);
  }

  /// Responds to the end of a ripple animation trigger by fading the background out,
  /// and creating a foreground ripple that expands from the event location
  /// (or from the center of the element if the "centered" property is set or
  /// forceCenter is true).
  void end(num left, num top, [bool forceCenter = true]) {
    _rippleRenderer.createForegroundRipple(
        left,
        top,
        color,
        centered || forceCenter,
        maxRadius,
        speedFactor,
        (ForegroundRipple ripple, TransitionEvent e) =>
            _rippleTransitionEnded(ripple, e));
    _rippleRenderer.fadeOutRippleBackground();
  }

  void _rippleTransitionEnded(ForegroundRipple ripple, TransitionEvent event) {
    if (event.propertyName == 'opacity') {
      // If the ripple finished expanding, start fading it out.
      // If it finished fading out, remove it from the DOM.
      switch (ripple.state) {
        case ForegroundRippleState.emerging:
          break;
        case ForegroundRippleState.expanding:
          _rippleRenderer.fadeOutForegroundRipple(ripple.rippleElement);
          ripple.state = ForegroundRippleState.fadingOut;
          break;
        case ForegroundRippleState.fadingOut:
          _rippleRenderer.removeRippleFromDom(ripple.rippleElement);
          break;
      }
    }
  }

  List<StreamSubscription<MouseEvent>> _addEventHandlers(Element trigger) {
    return [
      trigger.onMouseDown.listen(_onMouseDown),
      trigger.onClick.listen(_onClick),
      trigger.onMouseLeave.listen(_onMouseLeave),
    ];
  }

  /// Called when the trigger element receives a mousedown event.
  /// Starts the ripple animation by fading in the background.
  void _onMouseDown(MouseEvent event) {
    if (!disabled && event.button == 0) {
      start();
    }
  }

  /**
   * Called when the trigger element receives a click event. Creates a foreground ripple and
   * runs its animation.
   */
  void _onClick(MouseEvent event) {
    if (!disabled && event.button == 0) {
      // If screen and page positions are all 0, this was probably triggered by a keypress.
      // In that case, use the center of the bounding rect as the ripple origin.
      // FIXME: This fails on IE11, which still sets pageX/Y and screenX/Y on keyboard clicks.
      bool isKeyEvent = [
        event.screen.x,
        event.screen.y,
        event.page.x,
        event.page.y
      ].every((num e) => e == 0);
      end(event.page.x, event.page.y, isKeyEvent);
    }
  }

  /// Called when the trigger element receives a mouseleave event. Fades out the background.
  void _onMouseLeave(MouseEvent event) {
    // We can always fade out the background here; It's a no-op if it was already inactive.
    _rippleRenderer.fadeOutRippleBackground();
  }

  // TODO: Reactivate the background div if the user drags out and back in.
}

const List MD_RIPPLE_DIRECTIVES = const [MdRipple];