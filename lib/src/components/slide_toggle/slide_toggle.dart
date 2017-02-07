import 'dart:html';
import 'dart:async';
import 'dart:math';
import "package:angular2/angular2.dart";
import "package:angular2/common.dart";
import "../../core/core.dart" show coerceBooleanProperty, applyCssTransform;

const Provider MD_SLIDE_TOGGLE_VALUE_ACCESSOR =
    const Provider(NG_VALUE_ACCESSOR, useExisting: MdSlideToggle, multi: true);

// A simple change event emitted by the MdSlideToggle component.
class MdSlideToggleChange {
  MdSlideToggle source;
  bool checked;
}

// Increasing integer for generating unique ids for slide-toggle components.
int _nextId = 0;

@Component(
    selector: "md-slide-toggle",
    host: const {
      "[class.md-checked]": "checked",
      "[class.md-disabled]": "disabled",
      // This md-slide-toggle prefix will change, once the temporary ripple is removed.
      "[class.md-slide-toggle-focused]": "hasFocus",
      "(mousedown)": "setMousedown()"
    },
    templateUrl: "slide_toggle.html",
    styleUrls: const ["slide_toggle.scss.css"],
    providers: const [MD_SLIDE_TOGGLE_VALUE_ACCESSOR],
    encapsulation: ViewEncapsulation.None,
    changeDetection: ChangeDetectionStrategy.OnPush)
class MdSlideToggle implements AfterContentInit, ControlValueAccessor<dynamic> {
  ElementRef _elementRef;
  Element get _nativeElement => _elementRef.nativeElement;
  Function onChange = (dynamic _) {};
  Function onTouched = () {};

  // A unique id for the slide-toggle. By default the id is auto-generated.
  String _uniqueId = 'md-slide-toggle-$_nextId';
  bool _checked = false;
  String _color;
  bool hasFocus = false;
  bool _isMousedown = false;
  SlideToggleRenderer _slideRenderer;

  @Input()
  set disabled(dynamic v) {
    _disabled = coerceBooleanProperty(v);
  }

  bool get disabled => _disabled;
  bool _disabled = false;

  @Input()
  set required(dynamic v) {
    _required = coerceBooleanProperty(v);
  }

  bool get required => _required;
  bool _required = false;

  @Input()
  String name;

  String get id {
    _nextId++;
    return _uniqueId;
  }

  @Input()
  set id(String v) {
    _uniqueId = v;
  }

  @Input()
  int tabIndex = 0;

  @Input()
  String ariaLabel;

  @Input()
  String ariaLabelledby;

  EventEmitter<MdSlideToggleChange> _change =
      new EventEmitter<MdSlideToggleChange>();

  @Output()
  Stream<MdSlideToggleChange> get change => _change;

  // Returns the unique id for the visual hidden input.
  String getInputId() => '$id-input';

  MdSlideToggle(this._elementRef);

  @override
  void ngAfterContentInit() {
    _slideRenderer = new SlideToggleRenderer(_elementRef);
  }

  /**
   * The onChangeEvent method will be also called on click.
   * This is because everything for the slide-toggle is wrapped inside of a label,
   * which triggers a onChange event on click.
   */
  void onChangeEvent(Event event) {
    // We always have to stop propagation on the change event.
    // Otherwise the change event, from the input element, will bubble up and
    // emit its event object to the component's `change` output.
    event.stopPropagation();

    // Once a drag is currently in progress,
    // we do not want to toggle the slide-toggle on a click.
    if (!disabled && !_slideRenderer.isDragging()) {
      toggle();

      // Emit our custom change event if the native input emitted one.
      // It is important to only emit it, if the native input triggered one, because
      // we don't want to trigger a change event, when the `checked` variable changes for example.
      _emitChangeEvent();
    }
  }

  void onInputClick(Event event) {
    onTouched();
    // We have to stop propagation for click events on the visual hidden input element.
    // By default, when a user clicks on a label element, a generated click event will be
    // dispatched on the associated input element. Since we are using a label element as our
    // root container, the click event on the `slide-toggle` will be executed twice.
    // The real click event will bubble up, and the generated click event also tries to bubble up.
    // This will lead to multiple click events.
    // Preventing bubbling for the second event will solve that issue.
    event.stopPropagation();
  }

  void setMousedown() {
    // We only *show* the focus style when focus has come to the button via the keyboard.
    // The Material Design spec is silent on this topic, and without doing this, the
    // button continues to look :active after clicking.
    // @see http://marcysutton.com/button-focus-hell/
    _isMousedown = true;
    new Future<Null>.delayed(const Duration(milliseconds: 100), () {
      _isMousedown = false;
    });
  }

  void onInputFocus() {
    // Only show the focus / ripple indicator when the focus was not triggered by a mouse
    // interaction on the component.
    if (!_isMousedown) hasFocus = true;
  }

  void onInputBlur() {
    hasFocus = false;
    onTouched();
  }

  /**
   * Implemented as part of ControlValueAccessor.
   */
  @override
  void writeValue(dynamic value) {
    checked = value;
  }

  /// Implemented as part of ControlValueAccessor.
  @override
  void registerOnChange(dynamic fn) {
    onChange = fn as Function;
  }

  /// mplemented as part of ControlValueAccessor.
  @override
  void registerOnTouched(dynamic fn) {
    onTouched = fn as Function;
  }

  bool get checked => _checked;

  @Input()
  set checked(dynamic value) {
    bool v = coerceBooleanProperty(value);
    if (!identical(checked, v)) {
      _checked = v;
      onChange(_checked);
    }
  }

  String get color => _color;

  @Input()
  set color(String value) {
    _updateColor(value);
  }

  void toggle() {
    checked = !checked;
  }

  void _updateColor(String newColor) {
    if (color != null && color.isNotEmpty) {
      _nativeElement.classes.remove('md-$color');
    }
    _nativeElement.classes.add('md-$newColor');
    _color = newColor;
  }

  // Emits the change event to the `change` output EventEmitter.
  void _emitChangeEvent() {
    var event = new MdSlideToggleChange();
    event.source = this;
    event.checked = checked;
    _change.emit(event);
  }

  void onDragStart() {
    if (!disabled) _slideRenderer.startThumbDrag(checked);
  }

  // TODO: Implement HammerJS wrapper, or wait for yet another solution.
  // HammerInput
  void onDrag(dynamic event) {
    if (_slideRenderer.isDragging()) {
      _slideRenderer.updateThumbPosition(event.deltaX);
    }
  }

  void onDragEnd() {
    if (!_slideRenderer.isDragging()) return;

    // Notice that we have to stop outside of the current event handler,
    // because otherwise the click event will be fired and will reset
    // the new checked variable.
    new Future<Null>.delayed((const Duration(milliseconds: 0)), () {
      checked = _slideRenderer.stopThumbDrag();
      _emitChangeEvent();
    });
  }
}

/// Renderer for the Slide Toggle component, which separates DOM modification
/// in its own class
class SlideToggleRenderer {
  Element _thumbEl;
  Element _thumbBarEl;
  num _thumbBarWidth = 0;
  bool _checked;
  num _percentage;

  ElementRef _elementRef;

  SlideToggleRenderer(this._elementRef) {
    _thumbEl = _elementRef.nativeElement
        .querySelector('.md-slide-toggle-thumb-container');
    _thumbBarEl =
        _elementRef.nativeElement.querySelector('.md-slide-toggle-bar');
  }

  /// Whether the slide-toggle is currently dragging.
  bool isDragging() {
    return _thumbBarWidth != 0;
  }

  /// Initializes the drag of the slide-toggle.
  void startThumbDrag(bool checked) {
    if (_thumbBarWidth == 0) {
      _thumbBarWidth = _thumbBarEl.clientWidth - _thumbEl.clientWidth;
      _checked = checked;
      _thumbEl.classes.add('md-dragging');
    }
  }

  /// Stops the current drag and returns the new checked value.
  bool stopThumbDrag() {
    if (_thumbBarWidth != 0) {
      _thumbBarWidth = 0;
      _thumbEl.classes.remove('md-dragging');

      applyCssTransform(_thumbEl, '');

      return _percentage > 50;
    }
    return false;
  }

  /// Updates the thumb containers position from the specified distance.
  void updateThumbPosition(num distance) {
    _percentage = _getThumbPercentage(distance);
    applyCssTransform(_thumbEl, 'translate3d($_percentage%, 0, 0)');
  }

  /// Retrieves the percentage of thumb from the moved distance.
  num _getThumbPercentage(num distance) {
    num percentage = (distance / _thumbBarWidth) * 100;

    // When the toggle was initially checked, then we have to start the drag at the end.
    if (_checked) {
      percentage += 100;
    }

    return max(0, min(percentage, 100));
  }
}

const List MD_SLIDE_TOGGLE_DIRECTIVES = const [MdSlideToggle];
