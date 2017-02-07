import 'dart:html';
import "package:quiver/strings.dart";
import "package:angular2/angular2.dart";
import "package:angular2/common.dart";
import "../../core/core.dart";

final Function noop = ([dynamic _]) {};

// Dart note: Dart does not have the forward ref problem.
const Provider MD_INPUT_CONTROL_VALUE_ACCESSOR =
    const Provider(NG_VALUE_ACCESSOR, useExisting: MdInput, multi: true);

// Invalid input type. Using one of these will throw an MdInputUnsupportedTypeError.
const List<String> MD_INPUT_INVALID_INPUT_TYPE = const [
  "file",
  "radio",
  "checkbox"
];

int nextUniqueId = 0;

class MdInputPlaceholderConflictError extends MdError {
  MdInputPlaceholderConflictError()
      : super("Placeholder attribute and child element were both specified.");
}

class MdInputUnsupportedTypeError extends MdError {
  MdInputUnsupportedTypeError(String type)
      : super('Input type "$type" isn\'t supported by md-input.');
}

class MdInputDuplicatedHintError extends MdError {
  MdInputDuplicatedHintError(String align)
      : super('A hint was already declared for \'align="$align"\'.');
}

/**
 * The placeholder directive. The content can declare this to implement more
 * complex placeholders.
 */
@Directive(selector: "md-placeholder")
class MdPlaceholder {}

/** The hint directive, used to tag content as hint labels (going under the input). */
@Directive(selector: "md-hint", host: const {
  "[class.md-right]": "align == \"end\"",
  "[class.md-hint]": "true"
})
class MdHint {
  // Whether to align the hint label at the start or end of the line.
  // start | end
  @Input()
  String align = "start";
}

typedef dynamic OnChangeCallback(dynamic _);

typedef dynamic OnTouchedCallback();

/// Component that represents a text input. It encapsulates the
/// <input> HTMLElement and improve on its behaviour,
/// along with styling it according to the Material Design.
@Component(
    selector: "md-input, md-textarea",
    templateUrl: "input.html",
    styleUrls: const ["input.scss.css"],
    providers: const [MD_INPUT_CONTROL_VALUE_ACCESSOR],
    host: const {"(click)": "focus()"},
    encapsulation: ViewEncapsulation.None)
class MdInput
    implements ControlValueAccessor<dynamic>, AfterContentInit, OnChanges {
  bool _focused = false;
  String _value = "";

  // Callback registered via registerOnTouched (ControlValueAccessor)
  OnTouchedCallback _onTouchedCallback = noop as OnTouchedCallback;

  // Callback registered via registerOnChange (ControlValueAccessor)
  OnChangeCallback _onChangeCallback = noop as OnChangeCallback;

  // Aria related inputs.

  @Input("aria-label")
  String ariaLabel;

  @Input("aria-labelledby")
  String ariaLabelledBy;

  @Input("aria-disabled")
  set ariaDisabled(dynamic v) {
    _ariaDisabled = coerceBooleanProperty(v);
  }

  bool get ariaDisabled => _ariaDisabled;
  bool _ariaDisabled;

  @Input("aria-required")
  set ariaRequired(dynamic v) {
    _ariaRequired = coerceBooleanProperty(v);
  }

  bool get ariaRequired => _ariaRequired;
  bool _ariaRequired;

  @Input("aria-invalid")
  set ariaInvalid(dynamic v) {
    _ariaInvalid = coerceBooleanProperty(v);
  }

  bool get ariaInvalid => _ariaInvalid;
  bool _ariaInvalid;

  /**
   * Content directives.
   */
  @ContentChild(MdPlaceholder)
  MdPlaceholder placeholderChild;

  @ContentChildren(MdHint)
  QueryList<MdHint> hintChildren;

  /** Readonly properties. */
  bool get focused => _focused;

  bool get empty => (_value == null || _value.isEmpty) && type != 'date';

  int get characterCount => empty ? 0 : _value.length;

  String get inputId => '$id-input';

  // start | end
  /**
   * Bindings.
   */
  @Input()
  String align = "start";

  // 'primary' | 'accent' | 'warn'
  @Input()
  String dividerColor = "primary";

  @Input()
  set floatingPlaceholder(dynamic v) {
    _floatingPlaceholder = coerceBooleanProperty(v);
  }

  bool get floatingPlaceholder => _floatingPlaceholder;
  bool _floatingPlaceholder = true;

  @Input()
  String hintLabel = "";

  @Input()
  String autocomplete;

  @Input()
  String autocorrect;

  @Input()
  String autocapitalize;

  @Input()
  set autofocus(dynamic v) {
    _autoFocus = coerceBooleanProperty(v);
  }

  bool get autofocus => _autoFocus;
  bool _autoFocus = false;

  @Input()
  set disabled(dynamic v) {
    _disabled = coerceBooleanProperty(v);
  }

  bool get disabled => _disabled;
  bool _disabled = false;

  @Input()
  String id = 'md-input-${nextUniqueId++}';

  @Input()
  String list;

  @Input()
  set max(dynamic v) {
    _max = coerceNumberProperty(v);
  }

  int get max => _max;
  int _max;

  @Input()
  set min(dynamic v) {
    _min = coerceNumberProperty(v);
  }

  int get min => _min;
  int _min;

  @Input()
  set maxlength(dynamic v) {
    _maxLength = coerceNumberProperty(v);
  }

  int get maxLength => _maxLength;
  int get maxlength => _maxLength;
  int _maxLength;

  @Input()
  num minlength;

  @Input()
  String placeholder;

  @Input()
  set readonly(dynamic v) {
    _readOnly = coerceBooleanProperty(v);
  }

  bool get readonly => _readOnly;
  bool _readOnly = false;

  @Input()
  set required(dynamic v) {
    _required = coerceBooleanProperty(v);
  }

  bool get required => _required;
  bool _required = false;

  @Input()
  set spellcheck(dynamic v) {
    _spellCheck = coerceBooleanProperty(v);
  }

  bool get spellcheck => _spellCheck;
  bool _spellCheck = false;

  @Input()
  num step;

  @Input()
  int tabindex;

  @Input()
  String type = "text";

  @Input()
  String name;

  // textarea-specific
  @Input()
  num rows;
  @Input()
  num cols;
  @Input()
  String /*'soft' | 'hard'*/ wrap;

  EventEmitter<FocusEvent> _blurEmitter = new EventEmitter<FocusEvent>();
  EventEmitter<FocusEvent> _focusEmitter = new EventEmitter<FocusEvent>();

  @Output("blur")
  Stream<FocusEvent> get onBlur => _blurEmitter;

  @Output("focus")
  Stream<FocusEvent> get onFocus => _focusEmitter;

  String get value => _value;

  @Input()
  set value(dynamic v) {
    v = _convertValueForInputType(v);
    if (!identical(v, _value)) {
      _value = v as String;
      _onChangeCallback(v);
    }
  }

  // This is to remove the `align` property of the `md-input` itself. Otherwise HTML5
  // might place it as RTL when we don't want to. We still want to use `align` as an
  // Input though, so we use HostBinding.
  @HostBinding("attr.align")
  dynamic get alignAttr => null;

  @ViewChild("input")
  ElementRef inputElement;

  String /* 'input' | 'textarea' */ elementType;

  MdInput(ElementRef elementRef)
      : elementType =
            elementRef.nativeElement.nodeName.toLowerCase() == 'md-input'
                ? 'input'
                : 'textarea';

  /// Set focus on input.
  void focus() {
    inputElement.nativeElement.focus();
  }

  void handleFocus(FocusEvent event) {
    _focused = true;
    _focusEmitter.emit(event);
  }

  void handleBlur(FocusEvent event) {
    _focused = false;
    _onTouchedCallback();
    _blurEmitter.emit(event);
  }

  void handleChange(Event event) {
    value = (event.target as InputElement).value;
    _onTouchedCallback();
  }

  bool hasPlaceholder() => !isBlank(placeholder) || placeholderChild != null;

  /// Implemented as part of ControlValueAccessor.
  @override
  void writeValue(dynamic value) {
    _value = value.toString();
  }

  /// Implemented as part of ControlValueAccessor.
  @override
  void registerOnChange(dynamic fn) {
    _onChangeCallback = fn as OnChangeCallback;
  }

  /// Implemented as part of ControlValueAccessor.
  @override
  void registerOnTouched(dynamic fn) {
    _onTouchedCallback = fn as OnTouchedCallback;
  }

  @override
  void ngAfterContentInit() {
    _validateConstraints();
    // Trigger validation when the hint children change.
    hintChildren.changes.listen((_) {
      _validateConstraints();
    });
  }

  @override
  void ngOnChanges(Map<String, SimpleChange> changes) {
    _validateConstraints();
  }

  /**
   * Convert the value passed in to a value that is expected from the type of the md-input.
   * This is normally performed by the *_VALUE_ACCESSOR in forms, but since the type is bound
   * on our internal input it won't work locally.
   * @private
   */
  // FIXME(ntaoo): At current version of the input demo, Typing String value to the input field which `type` attribute is "number" causes parse error. I will check _VALUE_ACCESSOR again and fix this method in a future version.
  dynamic _convertValueForInputType(dynamic v) {
    switch (type) {
      case "number":
        return num.parse(v as String);
      default:
        return v;
    }
  }

  /// Ensure that all constraints defined by the API are validated, or throw errors otherwise.
  /// Constraints for now:
  ///   - placeholder attribute and <md-placeholder> are mutually exclusive.
  ///   - type attribute is not one of the forbidden types (see constant at the top).
  ///   - Maximum one of each `<md-hint>` alignment specified, with the attribute being
  ///     considered as align="start".
  void _validateConstraints() {
    if (placeholder != "" && placeholder != null && placeholderChild != null) {
      throw new MdInputPlaceholderConflictError();
    }
    if (MD_INPUT_INVALID_INPUT_TYPE.indexOf(type) != -1) {
      throw new MdInputUnsupportedTypeError(type);
    }
    if (hintChildren != null && hintChildren.isNotEmpty) {
      // Validate the hint labels.
      MdHint startHint;
      MdHint endHint;
      hintChildren.forEach((MdHint hint) {
        if (hint.align == "start") {
          if (startHint != null || !isBlank(hintLabel)) {
            throw new MdInputDuplicatedHintError("start");
          }
          startHint = hint;
        } else if (hint.align == "end") {
          if (endHint != null) {
            throw new MdInputDuplicatedHintError("end");
          }
          endHint = hint;
        }
      });
    }
  }
}

const List MD_INPUT_DIRECTIVES = const [MdPlaceholder, MdInput, MdHint];
