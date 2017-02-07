import 'dart:html';
import 'package:angular2/angular2.dart';
import 'interactivity_checker.dart';

/**
 * Directive for trapping focus within a region.
 *
 * NOTE: This directive currently uses a very simple (naive) approach to focus trapping.
 * It assumes that the tab order is the same as DOM order, which is not necessarily true.
 * Things like tabIndex > 0, flex `order`, and shadow roots can cause to two to misalign.
 * This will be replaced with a more intelligent solution before the library is considered stable.
 */
@Component(
  selector: 'focus-trap',
  // TODO(jelbourn): move this to a separate file.
  template: '''
  <div tabindex="0" (focus)="reverseWrapFocus()"></div>
  <div #trappedContent><ng-content></ng-content></div>
  <div tabindex="0" (focus)="wrapFocus()"></div>
  ''',
  encapsulation: ViewEncapsulation.None,
)
class FocusTrap {
  @ViewChild('trappedContent')
  ElementRef trappedContent;

  InteractivityChecker _checker;
  FocusTrap(this._checker);

  /// Wrap focus from the end of the trapped region to the beginning.
  void wrapFocus() {
    var redirectToElement =
        _getFirstTabbableElement(trappedContent.nativeElement);
    redirectToElement?.focus();
  }

  /// Wrap focus from the beginning of the trapped region to the end.
  void reverseWrapFocus() {
    var redirectToElement =
        _getLastTabbableElement(trappedContent.nativeElement);
    redirectToElement?.focus();
  }

  // Get the first tabbable element from a DOM subtree (inclusive).
  Element _getFirstTabbableElement(Element root) {
    if (_checker.isFocusable(root) && _checker.isTabbable(root)) {
      return root;
    }

    // Iterate in DOM order.
    var childCount = root.children.length;
    for (var i = 0; i < childCount; i++) {
      Element tabbableChild = _getFirstTabbableElement(root.children[i]);
      if (tabbableChild != null) {
        return tabbableChild;
      }
    }

    return null;
  }

  /// Get the last tabbable element from a DOM subtree (inclusive).
  Element _getLastTabbableElement(Element root) {
    if (_checker.isFocusable(root) && _checker.isTabbable(root)) {
      return root;
    }

    // Iterate in reverse DOM order.
    for (var i = root.children.length - 1; i >= 0; i--) {
      Element tabbableChild = _getLastTabbableElement(root.children[i]);
      if (tabbableChild != null) {
        return tabbableChild;
      }
    }

    return null;
  }
}
