import 'dart:html';
import "package:angular2/angular2.dart";

/**
 * Simple utility for getting the bounds of the browser viewport.
 */
@Injectable()
class ViewportRuler {
  // TODO(jelbourn): cache the document's bounding rect and only update it when the window

  // is resized (debounced).

  /** Gets a ClientRect for the viewport's bounds. */
  Rectangle getViewportRect() {
    // Use the document element's bounding rect rather than the window scroll properties
    // (e.g. pageYOffset, scrollY) due to in issue in Chrome and IE where window scroll
    // properties and client coordinates (boundingClientRect, clientX/Y, etc.) are in different
    // conceptual viewports. Under most circumstances these viewports are equivalent, but they
    // can disagree when the page is pinch-zoomed (on devices that support touch).
    // See https://bugs.chromium.org/p/chromium/issues/detail?id=489206#c4
    // We use the documentElement instead of the body because, by default (without a css reset)
    // browsers typically give the document body an 8px margin, which is not included in
    // getBoundingClientRect().
    final scrollPosition = getViewportScrollPosition(
        document.documentElement.getBoundingClientRect());
    return new Rectangle(scrollPosition['left'], scrollPosition['top'],
        window.innerWidth, window.innerHeight);
  }

   /// Gets the (top, left) scroll position of the viewport.
  Map<String, num> getViewportScrollPosition([Rectangle documentRect]) {
    documentRect ??= document.documentElement.getBoundingClientRect();
    // The top-left-corner of the viewport is determined by the scroll position of the document
    // body, normally just (scrollLeft, scrollTop). However, Chrome and Firefox disagree about
    // whether `document.body` or `document.documentElement` is the scrolled element, so reading
    // `scrollTop` and `scrollLeft` is inconsistent. However, using the bounding rect of
    // `document.documentElement` works consistently, where the `top` and `left` values will
    // equal negative the scroll position.
    final top = documentRect.top < 0 && document.body.scrollTop == 0
        ? -documentRect.top
        : document.body.scrollTop;
    final left = documentRect.left < 0 && document.body.scrollLeft == 0
        ? -documentRect.left
        : document.body.scrollLeft;
    return {"top": top, "left": left};
  }
}
