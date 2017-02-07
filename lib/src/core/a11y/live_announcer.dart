import 'dart:html';
import 'dart:async';
import "package:angular2/angular2.dart";
import 'interactivity_checker.dart';

const List a11yProviders = const <dynamic>[
  MdLiveAnnouncer,
  InteractivityChecker
];

const OpaqueToken LIVE_ANNOUNCER_ELEMENT_TOKEN =
    const OpaqueToken("mdLiveAnnouncerElement");

@Injectable()
class MdLiveAnnouncer {
  Element _liveElement;

  MdLiveAnnouncer(
      @Optional() @Inject(LIVE_ANNOUNCER_ELEMENT_TOKEN) Element elementToken) {
    _liveElement = elementToken ?? _createLiveElement();
  }

  /**
   * @param message Message to be announced to the screenreader
   * @param politeness The politeness of the announcer element.
   *
   * type AriaLivePoliteness politeness = 'off' | 'polite' | 'assertive';
   */
  void announce(String message, [String politeness = "polite"]) {
    _liveElement.text = "";
    // TODO: ensure changing the politeness works on all environments we support.
    _liveElement.setAttribute("aria-live", politeness);
    // This 100ms timeout is necessary for some browser + screen-reader combinations:
    // - Both JAWS and NVDA over IE11 will not announce anything without a non-zero timeout.
    // - With Chrome and IE11 with NVDA or JAWS, a repeated (identical) message won't be read a
    //   second time without clearing and then using a non-zero delay.
    // (using JAWS 17 at time of this writing).
    new Future<Null>.delayed(const Duration(milliseconds: 100), () {
      _liveElement.text = message;
    });
  }

  /// Removes the aria-live element from the DOM.
  void _removeLiveElement() {
    _liveElement?.remove();
  }

  Element _createLiveElement() {
    DivElement liveElement = new DivElement()
      ..classes.add("md-visually-hidden")
      ..attributes["aria-atomic"] = "true"
      ..attributes["aria-live"] = "polite";
    document.body.append(liveElement);
    return liveElement;
  }
}
