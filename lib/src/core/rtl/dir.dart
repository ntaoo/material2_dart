import 'package:angular2/angular2.dart';

const String ltr = 'ltr';
const String rtl = 'rtl';

/**
 * Directive to listen to changes of direction of part of the DOM.
 *
 * Applications should use this directive instead of the native attribute so that Material
 * components can listen on changes of direction.
 */
@Directive(selector: '[dir]', exportAs: r'$implicit')
class Dir {
  // Because Dart doesn't have Union Types.
  final List<String> _layoutDirections = const [ltr, rtl];

  String get dir => _dir;

  String _dir = ltr;

  @Output()
  EventEmitter dirChange = new EventEmitter<Null>();

  @HostBinding('attr.dir')
  String get attrDir => _dir;

  @Input()
  set dir(String v) {
    _validateLayoutDirection(v);
    var old = _dir;
    _dir = v;
    if (old != _dir) dirChange.emit(null);
  }

  String get value => dir;

  set value(String v) {
    _validateLayoutDirection(v);
    dir = v;
  }

  void _validateLayoutDirection(String v) {
    if (!_layoutDirections.contains(v)) {
      throw new ArgumentError('Invalid dir value.');
    }
  }
}

const List RTL_DIRECTIVES = const <dynamic>[Dir];
