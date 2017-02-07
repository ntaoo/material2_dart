import 'dart:html';
import 'dart:math' as math;
import 'package:angular2/angular2.dart';
import 'package:angular2/common.dart';
import '../../core/core.dart' show coerceBooleanProperty, coerceNumberProperty;

/// Visually, a 30px separation between tick marks looks best.
/// This is very subjective but it is the default separation we chose.
const num MIN_AUTO_TICK_SEPARATION = 30;

/// Provider Expression that allows md-slider to register as a ControlValueAccessor.
/// This allows it to support [(ngModel)] and formControl.
const Provider MD_SLIDER_VALUE_ACCESSOR =
    const Provider(NG_VALUE_ACCESSOR, useExisting: MdSlider, multi: true);

typedef void _ControlValueAccessorChangeFn(dynamic value);

/// A simple change event emitted by the MdSlider component.
class MdSliderChange {
  MdSlider source;
  num value;
}

@Component(
  selector: 'md-slider',
  providers: const [MD_SLIDER_VALUE_ACCESSOR],
  host: const {
    '(blur)': 'onBlur()',
    '(click)': r'onClick($event)',
    '(mouseenter)': 'onMouseenter()',
    '(slide)': r'onSlide($event)',
    '(slideend)': 'onSlideEnd()',
    '(slidestart)': r'onSlideStart($event)',
    'tabindex': '0',
    '[attr.aria-disabled]': 'disabled',
    '[attr.aria-valuemax]': 'max',
    '[attr.aria-valuemin]': 'min',
    '[attr.aria-valuenow]': 'value',
    '[class.md-slider-active]': 'isActive',
    '[class.md-slider-disabled]': 'disabled',
    '[class.md-slider-has-ticks]': 'tickInterval',
    '[class.md-slider-sliding]': 'isSliding',
    '[class.md-slider-thumb-label-showing]': 'thumbLabel',
  },
  templateUrl: 'slider.html',
  styleUrls: const ['slider.scss.css'],
  encapsulation: ViewEncapsulation.None,
)
class MdSlider implements ControlValueAccessor<dynamic> {
  /// A renderer to handle updating the slider's thumb and fill track.
  SliderRenderer _renderer;

  /// The dimensions of the slider.
  Rectangle _sliderDimensions;

  /// Whether or not the slider is disabled.
  bool _disabled = false;

  bool get disabled => _disabled;

  @Input()
  set disabled(dynamic value) {
    _disabled = coerceBooleanProperty(value);
  }

  bool _thumbLabel = false;

  bool get thumbLabel => _thumbLabel;

  /// Whether or not to show the thumb label.
  @Input('thumb-label')
  set thumbLabel(dynamic value) {
    _thumbLabel = coerceBooleanProperty(value);
  }

  _ControlValueAccessorChangeFn _controlValueAccessorChangeFn =
      (dynamic value) {};

  /// The last value for which a change event was emitted.
  num _lastEmittedValue;

  /// onTouch function registered via registerOnTouch (ControlValueAccessor).
  Function onTouched = () {};

  /// Whether or not the thumb is sliding.
  /// Used to determine if there should be a transition for the thumb and fill track.
  bool isSliding = false;

  ///Whether or not the slider is active (clicked or sliding).
  /// Used to shrink and grow the thumb as according to the Material Design spec.
  bool isActive = false;

  num _step = 1;

  num get step => _step;

  @Input()
  set step(dynamic value) {
    _step = coerceNumberProperty(value, _step);
  }

  /**
   * How often to show ticks. Relative to the step so that a tick always appears on a step.
   * Ex: Tick interval of 4 with a step of 3 will draw a tick every 4 steps (every 12 values).
   */
  dynamic _tickInterval = 0;
  dynamic get tickInterval => _tickInterval;

  @Input('tick-interval')
  set tickInterval(dynamic /*num | 'auto'*/ v) {
    if (v is String && v == 'auto') {
      _tickInterval = v;
    } else {
      _tickInterval = coerceNumberProperty(v, _tickInterval);
    }
  }

  /// The size of a tick interval as a percentage of the size of the track.
  num _tickIntervalPercent = 0;

  num get tickIntervalPercent => _tickIntervalPercent;

  /// The percentage of the slider that coincides with the value.
  num _percent = 0;

  num get percent => _clamp(_percent);

  /// Value of the slider.
  num _value;

  num get value {
    // If the value needs to be read and it is still uninitialized, initialize it to the min.
    if (_value == null) {
      value = _min;
    }
    return _value;
  }

  @Input()
  set value(num v) {
    // TODO(ntaoo): maybe _value?
    _value = coerceNumberProperty(v, _value);
    _percent = _calculatePercentage(_value);
  }

  /// The miniumum value that the slider can have.
  num _min = 0;

  num get min => _min;

  @Input()
  set min(dynamic v) {
    _min = coerceNumberProperty(v, _min);
    // If the value wasn't explicitly set by the user, set it to the min.
    if (_value == null) value = _min;
    _percent = _calculatePercentage(value);
  }

  /// The maximum value that the slider can have.
  num _max = 100;

  num get max => _max;

  @Input()
  set max(dynamic value) {
    _max = coerceNumberProperty(value, _max);
    _percent = _calculatePercentage(_value);
  }

  String get trackFillFlexBasis => '${percent * 100}%';
  String get ticksMarginLeft => '${tickIntervalPercent / 2 * 100}%';
  String get ticksContainerMarginLeft => '-$ticksMarginLeft';
  String get ticksBackgroundSize => '${tickIntervalPercent * 100}% 2px';

  @Output()
  EventEmitter<MdSliderChange> change = new EventEmitter<MdSliderChange>();

  MdSlider(ElementRef elementRef)
      : this._renderer = new SliderRenderer(elementRef);

  void onMouseenter() {
    if (disabled) return;

    // We save the dimensions of the slider here so we can use them to update the spacing of the
    // ticks and determine where on the slider click and slide events happen.
    _sliderDimensions = _renderer.getSliderDimensions();
    _updateTickIntervalPercent();
  }

  void onClick(MouseEvent event) {
    if (disabled) return;

    isActive = true;
    isSliding = false;
    _renderer.addFocus();
    _updateValueFromPosition(event.client.x);
    _emitValueIfChanged();
  }

  // FIXME: Blocked by Hammer not being ported.
//  void onSlide(HammerInput event) {
//    if (disabled) {
//      return;
//    }
//
//    // Prevent the slide from selecting anything else.
//    event.preventDefault();
//    updateValueFromPosition(event.center.x);
//  }

  // FIXME: Blocked by Hammer not being ported.
//  void onSlideStart(HammerInput event) {
//    if (disabled) {
//      return;
//    }
//
//    event.preventDefault();
//    isSliding = true;
//    isActive = true;
//    _renderer.addFocus();
//    updateValueFromPosition(event.center.x);
//  }

  void onSlideEnd() {
    isSliding = false;
    _emitValueIfChanged();
  }

  void onBlur() {
    isActive = false;
    onTouched();
  }

  /// Calculate the new value from the new physical location.
  /// The value will always be snapped.
  void _updateValueFromPosition(num pos) {
    if (_sliderDimensions == null) return;

    num offset = _sliderDimensions.left;
    num size = _sliderDimensions.width;

    // The exact value is calculated from the event and used to find the closest snap value.
    _percent = _clamp((pos - offset) / size);
    var exactValue = _calculateValue(percent);

    // This calculation finds the closest step by finding the closest whole number divisible by the
    // step relative to the min.
    num closestValue = ((exactValue - min) / step).round() * step + min;
    // The value needs to snap to the min and max.
    value = _clamp(closestValue, min, max);
  }

  /// Emits a change event if the current value is different from the last emitted value.
  void _emitValueIfChanged() {
    if (value != _lastEmittedValue) {
      var event = new MdSliderChange()
        ..source = this
        ..value = value;
      change.emit(event);
      _controlValueAccessorChangeFn(value);
      _lastEmittedValue = value;
    }
  }

  /// Updates the amount of space between ticks as a percentage of the width of the slider.
  void _updateTickIntervalPercent() {
    if (tickInterval == null) return;

    if (tickInterval == 'auto') {
      var pixelsPerStep = _sliderDimensions.width * step / (max - min);
      var stepsPerTick = (MIN_AUTO_TICK_SEPARATION / pixelsPerStep).ceil();
      var pixelsPerTick = stepsPerTick * step;
      _tickIntervalPercent = pixelsPerTick / _sliderDimensions.width;
    } else {
      _tickIntervalPercent = tickInterval * step / (max - min);
    }
  }

  /// Calculates the percentage of the slider that a value is.
  num _calculatePercentage(num value) {
    // Since (null - num) == (0 - num) on JS/TS.
    if (value == null) value = 0;
    return (value - min) / (max - min);
  }

  /// Calculates the value a percentage of the slider corresponds to.
  num _calculateValue(num percentage) {
    return min + percentage * (max - min);
  }

  /// Return a number between two numbers.
  num _clamp(num value, [num min = 0, num max = 1]) {
    return math.max(min, math.min(value, max));
  }

  /// Implemented as part of ControlValueAccessor.
  @override
  void writeValue(dynamic value) {
    this.value = value;
  }

  /// Implemented as part of ControlValueAccessor.
  @override
  void registerOnChange(_ControlValueAccessorChangeFn fn) {
    _controlValueAccessorChangeFn = fn;
  }

  /// Implemented as part of ControlValueAccessor.
  @override
  void registerOnTouched(Function fn) {
    onTouched = fn;
  }

  /// Implemented as part of ControlValueAccessor.
  void setDisabledState(bool isDisabled) {
    disabled = isDisabled;
  }
}

/// Renderer class in order to keep all dom manipulation in one place and outside of the main class.
class SliderRenderer {
  Element _sliderElement;

  SliderRenderer(ElementRef elementRef)
      : _sliderElement = elementRef.nativeElement;

  /// Get the bounding client rect of the slider track element.
  /// The track is used rather than the native element to ignore the extra space
  /// that the thumb can take up.
  Rectangle getSliderDimensions() {
    Element trackElement = _sliderElement.querySelector('.md-slider-track');
    return trackElement.getBoundingClientRect();
  }

  /// Focuses the native element.
  /// Currently only used to allow a blur event to fire but will be used with keyboard input later.
  void addFocus() {
    _sliderElement.focus();
  }
}

const List MD_SLIDER_DIRECTIVES = const <dynamic>[MdSlider];
