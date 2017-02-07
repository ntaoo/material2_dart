import 'dart:html';
import 'package:angular2/angular2.dart';

/**
 * Utility for checking the interactivity of an element, such as whether is is focusable or
 * tabbable.
 *
 * NOTE: Currently does not capture any special element behaviors, browser quirks, or edge cases.
 * This is a basic/naive starting point onto which further behavior will be added.
 *
 * This class uses instance methods instead of static functions so that alternate implementations
 * can be injected.
 *
 * TODO(jelbourn): explore using ally.js directly for its significantly more robust
 * checks (need to evaluate payload size, performance, and compatibility with tree-shaking).
 */
@Injectable()
class InteractivityChecker {
  /// Gets whether an element is disabled.
  bool isDisabled(Element element) {
    // This does not capture some cases, such as a non-form control with a disabled attribute or
    // a form control inside of a disabled form, but should capture the most common cases.
    return element.attributes.containsKey('disabled');
  }

  /**
   * Gets whether an element is visible for the purposes of interactivity.
   *
   * This will capture states like `display: none` and `visibility: hidden`, but not things like
   * being clipped by an `overflow: hidden` parent or being outside the viewport.
   */
  bool isVisible(Element element) {
    // There are additional special cases that this does not capture, but this will work for
    // the most common cases.

    // Use logic from jQuery to check for `display: none`.
    // See https://github.com/jquery/jquery/blob/master/src/css/hiddenVisibleSelectors.js#L12
    if (!(element.offsetWidth > 0 ||
        element.offsetHeight > 0 ||
        element.getClientRects().length > 0)) {
      return false;
    }

    // Check for css `visibility` property.
    // TODO(jelbourn): do any browsers we support return an empty string instead of 'visible'?
    return element.getComputedStyle().getPropertyValue('visibility') ==
        'visible';
  }

  /**
   * Gets whether an element can be reached via Tab key.
   * Assumes that the element has already been checked with isFocusable.
   */
  bool isTabbable(Element element) {
    // Again, naive approach that does not capture many special cases and browser quirks.
    return element.tabIndex >= 0;
  }

  /// Gets whether an element can be focused by the user.
  bool isFocusable(Element element) {
    // Perform checks in order of left to most expensive.
    // Again, naive approach that does not capture many edge cases and browser quirks.
    return isPotentiallyFocusable(element) &&
        !isDisabled(element) &&
        isVisible(element);
  }
}

/// Gets whether an element's.
bool isNativeFormElement(Node element) {
  var nodeName = element.nodeName.toLowerCase();
  return nodeName == 'input' ||
      nodeName == 'select' ||
      nodeName == 'button' ||
      nodeName == 'textarea';
}

/// Gets whether an element is an <input type="hidden">.
bool isHiddenInput(Element element) {
  return isInputElement(element) && (element as InputElement).type == 'hidden';
}

/// Gets whether an element is an anchor that has an href attribute.
bool isAnchorWithHref(Element element) {
  return isAnchorElement(element) && element.attributes.containsKey('href');
}

/// Gets whether an element is an input element.
bool isInputElement(Element element) {
  return element.nodeName == 'input';
}

/// Gets whether an element is an anchor element.
bool isAnchorElement(Element element) {
  return element.nodeName.toLowerCase() == 'a';
}

/// Gets whether an element has a valid tabindex.
bool hasValidTabIndex(Element element) {
  if (!element.attributes.containsKey('tabindex') || element.tabIndex == null) {
    return false;
  }

  var tabIndex = element.attributes['tabindex'];

  // IE11 parses tabindex="" as the value "-32768"
  if (tabIndex == '-32768') {
    return false;
  }

  return int.parse(tabIndex, onError: (String s) => null) != null;
}

/// Gets whether an element is potentially focusable without taking current visible/disabled state into account.
bool isPotentiallyFocusable(Element element) {
  // Inputs are potentially focusable *unless* they're type="hidden".
  if (isHiddenInput(element)) {
    return false;
  }

  return isNativeFormElement(element) ||
      isAnchorWithHref(element) ||
      element.attributes.containsKey('contenteditable') ||
      hasValidTabIndex(element);
}
