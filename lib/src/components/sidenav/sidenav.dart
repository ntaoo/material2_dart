import 'dart:html';
import 'dart:async';
import 'package:angular2/angular2.dart';
import '../../core/core.dart';

/** Exception thrown when two MdSidenav are matching the same side. */
class MdDuplicatedSidenavError extends MdError {
  MdDuplicatedSidenavError(String align)
      : super("A sidenav was already declared for 'align=$align'");
}

// Because Dart doesn't have union types.
void validateArgument(dynamic value, List<dynamic> list) {
  if (!list.contains(value)) throw new ArgumentError('Invalid value: $value');
}

/**
 * <md-sidenav> component.
 *
 * This component corresponds to the drawer of the sidenav.
 *
 * Please refer to sidenav.md for examples on how to use it.
 */
@Component(
    selector: 'md-sidenav',
    template: '<ng-content></ng-content>',
    host: const {
      '(transitionend)': r'onTransitionEnd($event)',
      // must prevent the browser from aligning text based on value
      '[attr.align]': 'null',
      '[class.md-sidenav-closed]': 'isClosed',
      '[class.md-sidenav-closing]': 'isClosing',
      '[class.md-sidenav-end]': 'isEnd',
      '[class.md-sidenav-opened]': 'isOpened',
      '[class.md-sidenav-opening]': 'isOpening',
      '[class.md-sidenav-over]': 'modeOver',
      '[class.md-sidenav-push]': 'modePush',
      '[class.md-sidenav-side]': 'modeSide',
      '[class.md-sidenav-invalid]': '!valid',
    },
    changeDetection: ChangeDetectionStrategy.OnPush,
    encapsulation: ViewEncapsulation.None)
class MdSidenav implements AfterContentInit {
  /// Alignment of the sidenav (direction neutral); whether 'start' or 'end'.
  String _align = 'start';

  /// Whether this md-sidenav is part of a valid md-sidenav-layout configuration.
  bool get valid => _valid;

  set valid(dynamic value) {
    value = coerceBooleanProperty(value);
    // When the drawers are not in a valid configuration we close them all until they are in a valid
    // configuration again.
    if (!value) close();
    _valid = value;
  }

  bool _valid = true;

  String get align => _align;

  @Input()
  set align(String value) {
    // Make sure we have a valid value.
    value = value == 'end' ? 'end' : 'start';
    if (value != _align) {
      _align = value;
      onAlignChanged.add(null);
    }
  }

  /// Mode of the sidenav; whether 'over' or 'side'.
  String _mode = 'over';

  String get mode => _mode;

  @Input()
  set mode(String value) {
    validateArgument(value, ['over', 'push', 'side']);
    _mode = value;
  }

  bool _opened = false;

  // Whether the sidenav is opened.
  bool get opened => _opened;

  @Input()
  set opened(dynamic v) {
    toggle(coerceBooleanProperty(v));
  }

  /** Event emitted when the sidenav is being opened. Use this to synchronize animations. */
  @Output('open-start')
  EventEmitter<Null> onOpenStart = new EventEmitter<Null>();

  /** Event emitted when the sidenav is fully opened. */
  @Output('open')
  EventEmitter<Null> onOpen = new EventEmitter<Null>();

  /** Event emitted when the sidenav is being closed. Use this to synchronize animations. */
  @Output('close-start')
  EventEmitter<Null> onCloseStart = new EventEmitter<Null>();

  /// Event emitted when the sidenav is fully closed.
  @Output('close')
  EventEmitter<Null> onClose = new EventEmitter<Null>();

  /// Event emitted when the sidenav alignment changes.
  @Output('align-changed')
  EventEmitter<Null> onAlignChanged = new EventEmitter<Null>();

  // This should be private but currently is public just for testing.
  ElementRef elementRef;

  MdSidenav(this.elementRef);

  @override
  void ngAfterContentInit() {
    // This can happen when the sidenav is set to opened in the template and the transition
    // isn't ended.
    if (_openFuture != null) {
      _openFutureSuccess();
      _openFuture = null;
    }
  }

  /** Open this sidenav, and return a Promise that will resolve when it's fully opened (or get
   * rejected if it didn't). */
  Future open() {
    return toggle(true);
  }

  /**
   * Close this sidenav, and return a Promise that will resolve when it's fully closed (or get
   * rejected if it didn't).
   */
  Future close() {
    return toggle(false);
  }

  Future<Null> toggle([bool isOpen]) {
    if (!valid) return new Future.value(null);

    if (isOpen == null) isOpen = !opened;
    if (isOpen == opened) {
      if (!_transition) {
        return new Future<Null>.value();
      } else {
        return isOpen ? _openFuture : _closeFuture;
      }
    }
    _opened = isOpen;
    _transition = true;

    if (isOpen) {
      onOpenStart.emit(null);
    } else {
      onCloseStart.emit(null);
    }

    if (isOpen) {
      if (_openFuture == null) {
        var completer = new Completer<Null>();
        _openFuture = completer.future;
        _openFutureError = completer.completeError;
        _openFutureSuccess = completer.complete;
      }
      return _openFuture;
    } else {
      if (_closeFuture == null) {
        var completer = new Completer<Null>();
        _closeFuture = completer.future;
        _closeFutureError = completer.completeError;
        _closeFutureSuccess = completer.complete;
      }
      return _closeFuture;
    }
  }

  /**
   * When transition has finished, set the internal state for classes and emit the proper event.
   * The event passed is actually of type TransitionEvent, but that type is not available in
   * Android so we use any.
   */
  void onTransitionEnd(TransitionEvent transitionEvent) {
    if (transitionEvent.target == elementRef.nativeElement &&
        // Simpler version to check for prefixes.
        transitionEvent.propertyName.endsWith('transform')) {
      _transition = false;
      if (_opened) {
        if (_openFuture != null) _openFutureSuccess();
        if (_closeFuture != null) _closeFutureError();
        onOpen.emit(null);
      } else {
        if (_closeFuture != null) _closeFutureSuccess();
        if (_openFuture != null) _openFutureError();
        onClose.emit(null);
      }
      _openFuture = null;
      _closeFuture = null;
    }
  }

  bool get isClosing => !_opened && _transition;
  bool get isOpening => _opened && _transition;
  bool get isClosed => !_opened && !_transition;
  bool get isOpened => _opened && !_transition;
  bool get isEnd => align == 'end';
  bool get modeSide => mode == 'side';
  bool get modeOver => mode == 'over';
  bool get modePush => mode == 'push';

  /**
   * This is public because we need it from MdSidenavLayout, but it's undocumented and should
   * not be used outside.
   */
  num get width {
    if (elementRef.nativeElement != null) {
      return elementRef.nativeElement.offsetWidth as num;
    }
    return 0;
  }

  bool _transition = false;
  Future<Null> _openFuture;
  Function _openFutureSuccess;
  Function _openFutureError;
  Future<Null> _closeFuture;
  Function _closeFutureSuccess;
  Function _closeFutureError;
}

/**
 * <md-sidenav-layout> component.
 *
 * This is the parent component to one or two <md-sidenav>s that validates the state internally
 * and coordinates the backdrop and content styling.
 */
@Component(
    selector: 'md-sidenav-layout',
// Do not use ChangeDetectionStrategy.OnPush. It does not work for this component because
// technically it is a sibling of MdSidenav (on the content tree) and isn't updated when MdSidenav
// changes its state.
    directives: const [MdSidenav],
    templateUrl: 'sidenav.html',
    styleUrls: const ['sidenav.scss.css', 'sidenav_transitions.scss.css'],
    encapsulation: ViewEncapsulation.None)
class MdSidenavLayout implements AfterContentInit {
  @ContentChildren(MdSidenav)
  QueryList<MdSidenav> sidenavs;

//  set sidenavs(QueryList<MdSidenav> value) {
//    _sidenavs = value;
//  }

//  QueryList<MdSidenav> _sidenavs;

  /** The sidenav at the start/end alignment, independent of direction. */
  MdSidenav _start;
  MdSidenav _end;

  MdSidenav get start => _start;

  MdSidenav get end => _end;

  /**
   * The sidenav at the left/right. When direction changes, these will change as well.
   * They're used as aliases for the above to set the left/right style properly.
   * In LTR, _left == _start and _right == _end.
   * In RTL, _left == _end and _right == _start.
   */
  MdSidenav _left;
  MdSidenav _right;

  Dir _dir;
  ElementRef _elementRef;
  Element get _nativeElement => _elementRef.nativeElement;

  MdSidenavLayout(@Optional() this._dir, this._elementRef) {
    if (_dir != null) _dir.dirChange.listen((Null _) => _validateDrawers());
  }

  @override
  void ngAfterContentInit() {
    // On changes, assert on consistency.
    sidenavs.changes.listen((_) => _validateDrawers());
    sidenavs.forEach((MdSidenav sidenav) {
      _watchSidenavToggle(sidenav);
      _watchSidenavAlign(sidenav);
    });
    _validateDrawers();
  }

  /**
   * Subscribes to sidenav events in order to set a class on the main layout element when the
   * sidenav is open and the backdrop is visible. This ensures any overflow on the layout element is
   * properly hidden.
   */
  void _watchSidenavToggle(MdSidenav sidenav) {
    if (sidenav == null || sidenav.mode == 'side') return;
    sidenav.onOpen.listen((Null _) => _setLayoutClass(sidenav, true));
    sidenav.onClose.listen((Null _) => _setLayoutClass(sidenav, false));
  }

  /**
   * Subscribes to sidenav onAlignChanged event in order to re-validate drawers when the align
   * changes.
   */
  void _watchSidenavAlign(MdSidenav sidenav) {
    if (sidenav == null) return;
    sidenav.onAlignChanged.listen((_) => _validateDrawers());
  }

  /// Toggles the 'md-sidenav-opened' class on the main 'md-sidenav-layout' element.
  void _setLayoutClass(MdSidenav sidenav, bool bool) {
    if (bool) {
      _nativeElement.classes.add('md-sidenav-opened');
    } else {
      _nativeElement.classes.remove('md-sidenav-opened');
    }
  }

  /// Sets the valid state of the drawers.
  void _setDrawersValid(bool valid) {
    sidenavs.forEach((sidenav) {
      sidenav.valid = valid;
    });
    if (!valid) {
      _start = _end = _left = _right = null;
    }
  }

  /// Validate the state of the sidenav children components.
  void _validateDrawers() {
    _start = _end = null;

    // Ensure that we have at most one start and one end sidenav.
    for (MdSidenav sidenav in sidenavs) {
      if (sidenav.align == 'end') {
        if (_end != null) {
          _setDrawersValid(false);
          return;
        }
        _end = sidenav;
      } else {
        if (_start != null) {
          _setDrawersValid(false);
          return;
        }
        _start = sidenav;
      }
    }

    _right = _left = null;

    // Detect if we're LTR or RTL.
    if (_dir == null || _dir.value == 'ltr') {
      _left = _start;
      _right = _end;
    } else {
      _left = _end;
      _right = _start;
    }
    
    _setDrawersValid(true);
  }

  void closeModalSidenav() {
    if (_start != null && _start.mode != 'side') {
      _start.close();
    }
    if (_end != null && _end.mode != 'side') {
      _end.close();
    }
  }

  bool get isShowingBackdrop {
    return (_isSidenavOpen(_start) && _start.mode != 'side') ||
        (_isSidenavOpen(_end) && _end.mode != 'side');
  }

  bool _isSidenavOpen(MdSidenav side) => side != null && side.opened;

  /**
   * Return the width of the sidenav, if it's in the proper mode and opened.
   * This may relayout the view, so do not call this often.
   * @param sidenav
   * @param mode
   */
  num _getSidenavEffectiveWidth(MdSidenav sidenav, String mode) {
    return (_isSidenavOpen(sidenav) && sidenav.mode == mode)
        ? sidenav.width
        : 0;
  }

  num get marginLeft => _getSidenavEffectiveWidth(_left, 'side');

  num get marginRight => _getSidenavEffectiveWidth(_right, 'side');

  num get positionLeft => _getSidenavEffectiveWidth(_left, 'push');

  num get positionRight => _getSidenavEffectiveWidth(_right, 'push');

  /**
   * Returns the horizontal offset for the content area.  There should never be a value for both
   * left and right, so by subtracting the right value from the left value, we should always get
   * the appropriate offset.
   */
  num get positionOffset => positionLeft - positionRight;

  /**
   * This is using ngStyle rather than separate [style...] properties because style.transform
   * doesn't seem to work right now.
   */
  Map get styles {
    return {
      'marginLeft': '${marginLeft}px',
      'marginRight': '${marginRight}px',
      'transform': 'translate3d($positionOffset}px, 0, 0)'
    };
  }
}

const List MD_SIDENAV_DIRECTIVES = const [MdSidenavLayout, MdSidenav];
