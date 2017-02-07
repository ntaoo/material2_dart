import 'dart:html';
import 'package:angular2/angular2.dart';

/// The OverlayContainer is the container in which all overlays will load.
/// It should be provided in the root component to ensure it is properly shared.
@Injectable()
class OverlayContainer {
  Element _containerElement;

  /// This method returns the overlay container element.  It will lazily
  /// create the element the first time  it is called to facilitate using
  /// the container in non-browser environments.
  /// @returns {HTMLElement} the container element
  Element getContainerElement() {
    if (_containerElement == null) {
      _createContainer();
    }
    return _containerElement;
  }

  /// Create the overlay container element, which is simply a div
  /// with the 'md-overlay-container' class on the document body.
  void _createContainer() {
    var container = new DivElement()..classes.add('md-overlay-container');
    document.body.append(container);
    _containerElement = container;
  }
}
