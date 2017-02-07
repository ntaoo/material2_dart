import 'dart:html';
import "package:angular2/angular2.dart";

/**
 * The ink-bar is used to display and animate the line underneath the current active tab label.
 */
@Directive(selector: "md-ink-bar")
class MdInkBar {
  ElementRef _elementRef;

  MdInkBar(this._elementRef);

  /// Calculates the styles from the provided element
  /// in order to align the ink-bar to that element.
  void alignToElement(Element element) {
    Element e = _elementRef.nativeElement;
    e.style
      ..left = _getLeftPosition(element)
      ..width = _getElementWidth(element);
  }

  /**
   * Generates the pixel distance from the left based on the provided element in string format.
   */
  String _getLeftPosition(Element element) {
    return element != null ? element.offsetLeft.toString() + "px" : "0";
  }

  /**
   * Generates the pixel width from the provided element in string format.
   */
  String _getElementWidth(Element element) {
    return element != null ? element.offsetWidth.toString() + "px" : "0";
  }
}
