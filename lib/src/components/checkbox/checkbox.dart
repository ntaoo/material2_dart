import 'dart:html';
import "package:angular2/angular2.dart";
import "package:angular2/common.dart";
import "../../core/core.dart" show coerceBooleanProperty, MD_RIPPLE_DIRECTIVES;

/// Monotonically increasing integer used to auto-generate unique ids for checkbox components.
int _nextId = 0;

/**
 * Provider Expression that allows md-checkbox to register as a ControlValueAccessor. This allows it
 * to support [(ngModel)].
 */
const Provider MD_CHECKBOX_CONTROL_VALUE_ACCESSOR =
    const Provider(NG_VALUE_ACCESSOR, useExisting: MdCheckbox, multi: true);
/**
 * Represents the different states that require custom transitions between them.
 */
enum TransitionCheckState {
  /** The initial state of the component before any user interaction. */
  Init,
  /** The state representing the component when it's becoming checked. */
  Checked,
  /** The state representing the component when it's becoming unchecked. */
  Unchecked,
  /** The state representing the component when it's becoming indeterminate. */
  Indeterminate
}

// A simple change event emitted by the MdCheckbox component.
class MdCheckboxChange {
  MdCheckbox source;
  bool checked;
}

/**
 * A material design checkbox component. Supports all of the functionality of an HTML5 checkbox,
 * and exposes a similar API. An MdCheckbox can be either checked, unchecked, indeterminate, or
 * disabled. Note that all additional accessibility attributes are taken care of by the component,
 * so there is no need to provide them yourself. However, if you want to omit a label and still
 * have the checkbox be accessible, you may supply an [aria-label] input.
 * See: https://www.google.com/design/spec/components/selection-controls.html
 */
@Component(
    selector: "md-checkbox",
    templateUrl: "checkbox.html",
    styleUrls: const ["checkbox.scss.css"],
    host: const {
      "[class.md-checkbox-indeterminate]": "indeterminate",
      "[class.md-checkbox-checked]": "checked",
      "[class.md-checkbox-disabled]": "disabled",
      "[class.md-checkbox-align-end]": "align == \"end\"",
      "[class.md-checkbox-focused]": "hasFocus"
    },
    providers: const [MD_CHECKBOX_CONTROL_VALUE_ACCESSOR],
    directives: const [MD_RIPPLE_DIRECTIVES],
    encapsulation: ViewEncapsulation.None,
    changeDetection: ChangeDetectionStrategy.OnPush)
class MdCheckbox implements ControlValueAccessor<dynamic> {
  ElementRef _elementRef;
  Element get _nativeElement => _elementRef.nativeElement;
  /**
   * Attached to the aria-label attribute of the host element. In most cases, arial-labelledby will
   * take precedence so this may be omitted.
   */
  @Input("aria-label")
  String ariaLabel = "";

  /**
   * Users can specify the `aria-labelledby` attribute which will be forwarded to the input element
   */
  @Input("aria-labelledby")
  String ariaLabelledby;

  /// A unique id for the checkbox. If one is not supplied, it is auto-generated.
  @Input()
  String id = 'md-checkbox-${++_nextId}';

  /// Whether the ripple effect on click should be disabled.
  bool _disableRipple = false;
  bool get disableRipple => _disableRipple;
  @Input()
  set disableRipple(dynamic value) {
    _disableRipple = coerceBooleanProperty(value);
  }

  /** ID to be applied to the `input` element */
  String get inputId => 'input-$id';

  @Input()
  set required(dynamic v) {
    _required = coerceBooleanProperty(v);
  }

  bool get required => _required;
  bool _required = false;

  /// Whether or not the checkbox should come before or after the label.
  // 'start' | 'end'
  @Input()
  String align = "start";

  /// Whether the checkbox is disabled. When the checkbox is disabled it cannot be interacted with.
  /// The correct ARIA attributes are applied to denote this to assistive technology.
  @Input()
  set disabled(dynamic disabled) {
    _disabled = coerceBooleanProperty(disabled);
  }

  bool get disabled => _disabled;
  bool _disabled = false;

  /**
   * The tabindex attribute for the checkbox. Note that when the checkbox is disabled, the attribute
   * on the host element will be removed. It will be placed back when the checkbox is re-enabled.
   */
  @Input()
  int tabindex = 0;

  /** Name value will be applied to the input element if present */
  @Input()
  String name;

  /** Event emitted when the checkbox's `checked` value changes. */
  @Output()
  EventEmitter<MdCheckboxChange> change = new EventEmitter<MdCheckboxChange>();

  /** Called when the checkbox is blurred. Needed to properly implement ControlValueAccessor. */
  Function onTouched = () {};

  String _currentAnimationClass = "";
  TransitionCheckState _currentCheckState = TransitionCheckState.Init;
  bool _checked = false;
  bool _indeterminate = false;

  String _color = 'accent';
  String get color => _color;

  /// Sets the color of the checkbox.
  @Input()
  set color(String newColor) {
    if (color != null && color.isNotEmpty)
      _nativeElement.classes.remove('md-$_color');
    if (newColor != null && newColor.isNotEmpty)
      _nativeElement.classes.add('md-$newColor');
    _color = newColor;
  }

  // TODO: Its argument type can be narrower.
  Function _controlValueAccessorChangeFn = (dynamic value) {};
  bool hasFocus = false;

  MdCheckbox(this._elementRef);

  /**
   * Whether the checkbox is checked. Note that setting `checked` will immediately set
   * `indeterminate` to false.
   */
  bool get checked => _checked;

  @Input()
  set checked(bool checked) {
    if (checked != _checked) {
      _indeterminate = false;
      _checked = checked;
      _transitionCheckState(_checked
          ? TransitionCheckState.Checked
          : TransitionCheckState.Unchecked);
    }
  }

  /// Whether the checkbox is indeterminate. This is also known as "mixed" mode and can be used to
  /// represent a checkbox with three states, e.g. a checkbox that represents a nested list of
  /// checkable items. Note that whenever `checked` is set, indeterminate is immediately set to
  /// false. This differs from the web platform in that indeterminate state on native
  /// checkboxes is only remove when the user manually checks the checkbox (rather than setting the
  /// `checked` property programmatically). However, we feel that this behavior is more accommodating
  /// to the way consumers would envision using this component.
  bool get indeterminate => _indeterminate;

  @Input()
  set indeterminate(bool indeterminate) {
    _indeterminate = indeterminate;
    if (_indeterminate) {
      _transitionCheckState(TransitionCheckState.Indeterminate);
    } else {
      _transitionCheckState(checked
          ? TransitionCheckState.Checked
          : TransitionCheckState.Unchecked);
    }
  }

  bool isRippleDisabled() {
    return disableRipple || disabled;
  }

  /// Implemented as part of ControlValueAccessor.
  @override
  void writeValue(dynamic value) {
    // FIXME(ntaoo): I'm assuming the value is either bool or String or null, that may be wrong.
    if (value == null) {
      checked = false;
    } else if (value is bool) {
      checked = value;
    } else if (value is String) {
      checked = value.isNotEmpty;
    }
  }

  /// Implemented as part of ControlValueAccessor.
  @override
  void registerOnChange(dynamic fn) {
    _controlValueAccessorChangeFn = fn as Function;
  }

  /// Implemented as part of ControlValueAccessor.
  @override
  void registerOnTouched(dynamic fn) {
    onTouched = fn as Function;
  }

  void _transitionCheckState(TransitionCheckState newState) {
    var oldState = _currentCheckState;
    if (identical(oldState, newState)) {
      return;
    }
    if (_currentAnimationClass.length > 0) {
      _nativeElement.classes.remove(_currentAnimationClass);
    }
    _currentAnimationClass =
        _getAnimationClassForCheckStateTransition(oldState, newState);
    _currentCheckState = newState;
    if (_currentAnimationClass.length > 0) {
      _nativeElement.classes.add(_currentAnimationClass);
    }
  }

  void _emitChangeEvent() {
    var event = new MdCheckboxChange();
    event.source = this;
    event.checked = checked;
    _controlValueAccessorChangeFn(checked);
    change.emit(event);
  }

  /**
   * Informs the component when the input has focus so that we can style accordingly
   */
  void onInputFocus() {
    hasFocus = true;
  }

  /**
   * Informs the component when we lose focus in order to style accordingly
   * @internal
   */
  void onInputBlur() {
    hasFocus = false;
    onTouched();
  }

  /**
   * Toggles the `checked` value between true and false
   */
  void toggle() {
    checked = !checked;
  }

  /// Event handler for checkbox input element.
  /// Toggles checked state if element is not disabled.
  void onInteractionEvent(Event event) {
    // We always have to stop propagation on the change event.

    // Otherwise the change event, from the input element, will bubble up and

    // emit its event object to the `change` output.
    event.stopPropagation();
    if (!disabled) {
      toggle();

      // Emit our custom change event if the native input emitted one.
      // It is important to only emit it, if the native input triggered one, because
      // we don't want to trigger a change event, when the `checked` variable changes for example.
      _emitChangeEvent();
    }
  }

  void onInputClick(Event event) {
    // We have to stop propagation for click events on the visual hidden input element.
    // By default, when a user clicks on a label element, a generated click event will be
    // dispatched on the associated input element. Since we are using a label element as our
    // root container, the click event on the `checkbox` will be executed twice.
    // The real click event will bubble up, and the generated click event also tries to bubble up.
    // This will lead to multiple click events.
    // Preventing bubbling for the second event will solve that issue.
    event.stopPropagation();
  }

  String _getAnimationClassForCheckStateTransition(
      TransitionCheckState oldState, TransitionCheckState newState) {
    String animSuffix;
    switch (oldState) {
      case TransitionCheckState.Init:
        // Handle edge case where user interacts with checkbox that does not have [(ngModel)] or

        // [checked] bound to it.
        if (identical(newState, TransitionCheckState.Checked)) {
          animSuffix = "unchecked-checked";
        } else {
          return "";
        }
        break;
      case TransitionCheckState.Unchecked:
        animSuffix = identical(newState, TransitionCheckState.Checked)
            ? "unchecked-checked"
            : "unchecked-indeterminate";
        break;
      case TransitionCheckState.Checked:
        animSuffix = identical(newState, TransitionCheckState.Unchecked)
            ? "checked-unchecked"
            : "checked-indeterminate";
        break;
      case TransitionCheckState.Indeterminate:
        animSuffix = identical(newState, TransitionCheckState.Checked)
            ? "indeterminate-checked"
            : "indeterminate-unchecked";
    }
    return 'md-checkbox-anim-$animSuffix';
  }

  Element getHostElement() => _nativeElement;
}

const List MD_CHECKBOX_DIRECTIVES = const [MdCheckbox];
