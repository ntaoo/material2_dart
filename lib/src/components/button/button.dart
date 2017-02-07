import 'dart:html';
import 'dart:async';
import 'package:angular2/angular2.dart';
import "../../core/core.dart" show MD_RIPPLE_DIRECTIVES, coerceBooleanProperty;

@Component(
    selector:
        'button[md-button], button[md-raised-button], button[md-icon-button], button[md-fab], button[md-mini-fab]',
    host: const {
      '[disabled]': 'disabled',
      '[class.md-button-focus]': 'isKeyboardFocused',
      '(mousedown)': 'setMousedown()',
      '(focus)': 'setKeyboardFocus()',
      '(blur)': 'removeKeyboardFocus()',
    },
    templateUrl: 'button.html',
    styleUrls: const ['button.scss.css'],
    directives: const [MD_RIPPLE_DIRECTIVES],
    encapsulation: ViewEncapsulation.None,
    changeDetection: ChangeDetectionStrategy.OnPush)
class MdButton {
  String _color;

  /// Whether the button has focus from the keyboard (not the mouse). Used for class binding.
  bool isKeyboardFocused = false;

  /// Whether a mousedown has occurred on this element in the last 100ms.
  bool isMouseDown = false;

  /// Whether the ripple effect on click should be disabled.
  bool _disableRipple = false;
  bool _disabled = false;

  /// Whether the ripple effect on click should be disabled.
  @Input()
  set disableRipple(dynamic v) {
    _disableRipple = coerceBooleanProperty(v);
  }

  bool get disableRipple => _disableRipple;

  bool get disabled => _disabled;
  @Input()
  set disabled(bool value) {
    _disabled = coerceBooleanProperty(value);
  }

  ElementRef _elementRef;
  Element get _nativeElement => _elementRef.nativeElement;

  MdButton(this._elementRef);

  String get color => _color;

  @Input()
  set color(String value) {
    _updateColor(value);
  }

  // internal
  void setMousedown() {
    // We only *show* the focus style when focus has come to the button via the keyboard.
    // The Material Design spec is silent on this topic, and without doing this, the
    // button continues to look :active after clicking.
    // @see http://marcysutton.com/button-focus-hell/
    isMouseDown = true;
    new Timer(const Duration(milliseconds: 100), () => isMouseDown = false);
  }

  void _updateColor(String newColor) {
    if (color != null && color.isNotEmpty) {
      _nativeElement.classes.remove('md-$color');
    }
    _nativeElement.classes.add('md-$newColor');
    _color = newColor;
  }

  // internal
  void setKeyboardFocus() {
    isKeyboardFocused = !isMouseDown;
  }

  // internal
  void removeKeyboardFocus() {
    isKeyboardFocused = false;
  }

  void focus() {
    _nativeElement.focus();
  }

  Element getHostElement() => _nativeElement;

  bool isRoundButton() {
    var attributes = _nativeElement.attributes;
    return attributes.containsKey('md-icon-button') ||
        attributes.containsKey('md-fab') ||
        attributes.containsKey('md-mini-fab');
  }

  bool isRippleDisabled() {
    return disableRipple || disabled;
  }
}

@Component(
    selector:
        'a[md-button], a[md-raised-button], a[md-icon-button], a[md-fab], a[md-mini-fab]',
    inputs: const ['color', 'disabled', 'disableRipple'],
    host: const {
      '[attr.disabled]': 'disabled',
      '[class.md-button-focus]': 'isKeyboardFocused',
      '(mousedown)': 'setMousedown()',
      '(focus)': 'setKeyboardFocus()',
      '(blur)': 'removeKeyboardFocus()',
      '(click)': 'haltDisabledEvents(\$event)',
    },
    templateUrl: 'button.html',
    styleUrls: const ['button.scss.css'],
    directives: const [MD_RIPPLE_DIRECTIVES],
    encapsulation: ViewEncapsulation.None)
class MdAnchor extends MdButton {

  MdAnchor(ElementRef _elementRef) : super(_elementRef);

  @HostBinding('tabIndex')
  int get tabIndex => _disabled ? -1 : 0;

  @HostBinding('attr.aria-disabled')
  // Gets the aria-disabled value for the component, which must be a string for Dart.
  String get isAriaDisabled => _disabled ? 'true' : 'false';
  
  // internal
  void haltDisabledEvents(Event event) {
    // A disabled button shouldn't apply any actions
    if (disabled) {
      event.preventDefault();
      event.stopImmediatePropagation();
    }
  }
}

const List MD_BUTTON_DIRECTIVES = const [MdButton, MdAnchor];
