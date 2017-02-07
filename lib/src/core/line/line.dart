import 'dart:html';
import "package:angular2/angular2.dart";

/**
 * Shared directive to count lines inside a text area, such as a list item.
 * Line elements can be extracted with a @ContentChildren(MdLine) query, then
 * counted by checking the query list's length.
 */
@Directive(selector: "[md-line]")
class MdLine {}

/* Helper that takes a query list of lines and sets the correct class on the host */
class MdLineSetter {
  QueryList<MdLine> lines;
  ElementRef _elementRef;
  Element get _nativeElement => _elementRef.nativeElement;
  MdLineSetter(this.lines, this._elementRef) {
    _setLineClass(lines.length);
    lines.changes.listen((_) {
      _setLineClass(lines.length);
    });
  }

  void _setLineClass(num count) {
    _resetClasses();
    if (count == 2 || count == 3) {
      _nativeElement.classes.add('md-$count-line');
    } else if (count > 3) {
      _nativeElement.classes.add('md-multi-line');
    }
  }

  void _resetClasses() {
    _nativeElement.classes
        .removeAll(['md-2-line', 'md-3-line', 'md-multi-line']);
  }
}
