import 'dart:html';

import 'dart:async';
import "package:angular2/angular2.dart";
import "package:angular2/common.dart";
import "../../core/core.dart";

/**
 * Provider Expression that allows md-button-toggle-group to register as a ControlValueAccessor.
 * This allows it to support [(ngModel)].
 */
const Provider MD_BUTTON_TOGGLE_GROUP_VALUE_ACCESSOR = const Provider(
    NG_VALUE_ACCESSOR,
    useExisting: MdButtonToggleGroup,
    multi: true);

int _uniqueIdCounter = 0;

/// A simple change event emitted by either MdButtonToggle or MdButtonToggleGroup.
class MdButtonToggleChange {
  MdButtonToggle source;
  dynamic value;
}

/**
 * The method to be called in order to update ngModel.
 * Now `ngModel` binding is not supported in multiple selection mode.
*/
typedef void _ControlValueAccessorChangeFn(dynamic value);

/// Exclusive selection button toggle group that behaves like a radio-button group.
@Directive(
    selector: "md-button-toggle-group:not([multiple])",
    providers: const [MD_BUTTON_TOGGLE_GROUP_VALUE_ACCESSOR],
    host: const {"role": "radiogroup"})
class MdButtonToggleGroup
    implements AfterViewInit, ControlValueAccessor<dynamic> {
  /// The value for the button toggle group. Should match currently selected button toggle.
  dynamic _value;

  /// The HTML name attribute applied to toggles in this group.
  String _name = 'md-radio-group-${_uniqueIdCounter++}';

  /// Disables all toggles in the group.
  bool _disabled = false;

  /// The currently selected button toggle, should match the value.
  MdButtonToggle _selected;

  /// Whether the button toggle group is initialized or not.
  bool _isInitialized = false;

  /// The method to be called in order to update ngModel.
  _ControlValueAccessorChangeFn _controlValueAccessorChangeFn =
      (dynamic value) {};

  /// onTouch function registered via registerOnTouch (ControlValueAccessor).
  Function onTouched = () {};

  /// Event emitted when the group's value changes.
  EventEmitter<MdButtonToggleChange> _change =
      new EventEmitter<MdButtonToggleChange>();

  @Output()
  Stream<MdButtonToggleChange> get change => _change;

  /// Child button toggle buttons.
  @ContentChildren(MdButtonToggle)
  QueryList<MdButtonToggle> buttonToggles;

  @override
  void ngAfterViewInit() {
    _isInitialized = true;
  }

  String get name => _name;

  @Input()
  set name(String value) {
    _name = value;
    _updateButtonToggleNames();
  }

  bool get disabled => _disabled;

  @Input()
  set disabled(dynamic v) {
    _disabled = coerceBooleanProperty(v);
  }

  dynamic get value => _value;

  @Input()
  set value(dynamic newValue) {
    if (_value != newValue) {
      _value = newValue;
      _updateSelectedButtonToggleFromValue();

      // Only emit a change event if the view is completely initialized.
      // We don't want to emit a change event for the initial values.
      if (_isInitialized) {
        _emitChangeEvent();
      }
    }
  }

  MdButtonToggle get selected => _selected;

  @Input()
  set selected(MdButtonToggle selected) {
    _selected = selected;
    value = selected?.value;
    if (selected != null && !selected.checked) {
      selected.checked = true;
    }
  }

  void _updateButtonToggleNames() {
    if (buttonToggles == null) return;
    buttonToggles.forEach((toggle) {
      toggle.name = _name;
    });
  }

  // TODO: Refactor into shared code with radio.
  void _updateSelectedButtonToggleFromValue() {
    bool isAlreadySelected = _selected != null && _selected.value == _value;
    if (buttonToggles != null && !isAlreadySelected) {
      var matchingButtonToggle = buttonToggles.firstWhere(
          (buttonToggle) => buttonToggle.value == _value,
          orElse: () => null);
      if (matchingButtonToggle != null) {
        selected = matchingButtonToggle;
      } else if (value == null) {
        selected = null;
        buttonToggles.forEach((buttonToggle) {
          buttonToggle.checked = false;
        });
      }
    }
  }

  /// Dispatch change event with current selection and group value.
  void _emitChangeEvent() {
    var event = new MdButtonToggleChange();
    event.source = _selected;
    event.value = _value;
    _controlValueAccessorChangeFn(event.value);
    _change.emit(event);
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
}

/// Multiple selection button-toggle group. `ngModel` is not supported in this mode.
@Directive(selector: "md-button-toggle-group[multiple]")
class MdButtonToggleGroupMultiple {
  /// Disables all toggles in the group.
  bool _disabled = false;

  bool get disabled => _disabled;

  // TODO: Allow String value and treat it as booleanFieldValue?
  @Input()
  set disabled(bool value) {
    _disabled = (value != null && !identical(value, false)) ? true : null;
  }
}

//enum ToggleType { checkbox, radio }

@Component(
    selector: "md-button-toggle",
    templateUrl: "button_toggle.html",
    styleUrls: const ["button_toggle.scss.css"],
    encapsulation: ViewEncapsulation.None)
class MdButtonToggle implements OnInit {
  MdUniqueSelectionDispatcher buttonToggleDispatcher;

  /// Whether or not this button toggle is checked.
  bool _checked = false;

  /// Type of the button toggle. Either 'radio' or 'checkbox'.
  String type;

  /// The unique ID for this button toggle.
  @HostBinding()
  @Input()
  String id;

  /// HTML's 'name' attribute used to group radios for unique selection.
  @Input()
  String name;

  /// Whether or not this button toggle is disabled.
  bool _disabled = false;

  /// Value assigned to this button toggle.
  dynamic _value;

  /// Whether or not the button toggle is a single selection.
  bool _isSingleSelector = false;

  /// The parent button toggle group (exclusive selection). Optional.
  MdButtonToggleGroup buttonToggleGroup;

  /// The parent button toggle group (multiple selection). Optional.
  MdButtonToggleGroupMultiple buttonToggleGroupMultiple;

  /// Event emitted when the group value changes.
  EventEmitter<MdButtonToggleChange> _change =
      new EventEmitter<MdButtonToggleChange>();

  @Output()
  Stream<MdButtonToggleChange> get change => _change;

  MdButtonToggle(
      @Optional() MdButtonToggleGroup toggleGroup,
      @Optional() MdButtonToggleGroupMultiple toggleGroupMultiple,
      this.buttonToggleDispatcher) {
    buttonToggleGroup = toggleGroup;
    buttonToggleGroupMultiple = toggleGroupMultiple;
    if (buttonToggleGroup != null) {
      buttonToggleDispatcher.listen((String id, String name) {
        if (this.id != id && this.name == name) {
          checked = false;
        }
      });
      type = 'radio';
      name = buttonToggleGroup.name;
      _isSingleSelector = true;
    } else {
      // Even if there is no group at all, treat the button toggle as a checkbox so it can be
      // toggled on or off.
      type = 'checkbox';
      _isSingleSelector = false;
    }
  }

  @override
  void ngOnInit() {
    if (id == null) {
      id = 'md-button-toggle-${_uniqueIdCounter++}';
    }
    if (buttonToggleGroup != null && _value == buttonToggleGroup.value) {
      _checked = true;
    }
  }

  String get inputId => '$id-input';

  @HostBinding("class.md-button-toggle-checked")
  bool get checked => _checked;

  @Input()
  set checked(bool newCheckedState) {
    if (_isSingleSelector) {
      if (newCheckedState) {
        // Notify all button toggles with the same name (in the same group) to un-check.
        buttonToggleDispatcher.notify(id, name);
      }
    }

    _checked = newCheckedState;

    if (newCheckedState &&
        _isSingleSelector &&
        buttonToggleGroup.value != value) {
      buttonToggleGroup.selected = this;
    }
  }

  /// MdButtonToggleGroup reads this to assign its own value.
  dynamic get value => _value;

  @Input()
  set value(dynamic value) {
    if (_value != value) {
      if (buttonToggleGroup != null && checked) {
        buttonToggleGroup.value = value;
      }
      _value = value;
    }
  }

  /// Dispatch change event with current value.
  void _emitChangeEvent() {
    var event = new MdButtonToggleChange();
    event.source = this;
    event.value = _value;
    _change.emit(event);
  }

  @HostBinding("class.md-button-toggle-disabled")
  bool get disabled {
    return _disabled ||
        (buttonToggleGroup != null && buttonToggleGroup.disabled) ||
        (buttonToggleGroupMultiple != null &&
            buttonToggleGroupMultiple.disabled);
  }

  @Input()
  set disabled(dynamic value) {
    _disabled = coerceBooleanProperty(value);
  }

  /// Toggle the state of the current button toggle.
  void _toggle() {
    checked = !checked;
  }

  /// Checks the button toggle due to an interaction with the underlying native input.
  void onInputChange(Event event) {
    event.stopPropagation();

    if (_isSingleSelector) {
      // Propagate the change one-way via the group, which will in turn mark this
      // button toggle as checked.
      checked = true;
      buttonToggleGroup.selected = this;
      buttonToggleGroup.onTouched();
    } else {
      _toggle();
    }

    // Emit a change event when the native input does.
    _emitChangeEvent();
  }

  void onInputClick(Event event) {
    // We have to stop propagation for click events on the visual hidden input element.
    // By default, when a user clicks on a label element, a generated click event will be
    // dispatched on the associated input element. Since we are using a label element as our
    // root container, the click event on the `slide-toggle` will be executed twice.
    // The real click event will bubble up, and the generated click event also tries to bubble up.
    // This will lead to multiple click events.
    // Preventing bubbling for the second event will solve that issue.
    event.stopPropagation();
  }
}

const List MD_BUTTON_TOGGLE_DIRECTIVES = const [
  MdButtonToggleGroup,
  MdButtonToggleGroupMultiple,
  MdButtonToggle
];
