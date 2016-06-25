//import 'dart:html';

//import "package:angular2/core.dart";
//import "package:angular2/src/platform/browser_common.dart";

/// FIXME: It looks like GestureConfig is not supported in Angular2 Dart beta-17.
///
/// Adjusts configuration of our gesture library, Hammer.
//@Injectable()
//class MdGestureConfig extends HammerGestureConfig {
//  /* List of new event names to add to the gesture support list */
//  List<String> events = [
//    "drag",
//    "dragstart",
//    "dragend",
//    "dragright",
//    "dragleft",
//    "longpress"
//  ];
//
//  /*
//   * Builds Hammer instance manually to add custom recognizers that match the Material Design spec.
//   *
//   * Our gesture names come from the Material Design gestures spec:
//   * https://www.google.com/design/spec/patterns/gestures.html#gestures-touch-mechanics
//   *
//   * More information on default recognizers can be found in Hammer docs:
//   * http://hammerjs.github.io/recognizer-pan/
//   * http://hammerjs.github.io/recognizer-press/
//   *
//   * TODO: Confirm threshold numbers with Material Design UX Team
//   * */
//  buildHammer(Element element) {
//    var mc = new Hammer(element);
//    // create custom gesture recognizers
//    var drag = new Hammer.Pan(event: "drag", threshold: 6);
//    var longpress = new Hammer.Press(event: "longpress", time: 500);
//    // ensure custom recognizers can coexist with the default gestures (i.e. pan, press, swipe)
//    var pan = new Hammer.Pan();
//    var press = new Hammer.Press();
//    var swipe = new Hammer.Swipe();
//    drag.recognizeWith(pan);
//    drag.recognizeWith(swipe);
//    pan.recognizeWith(swipe);
//    longpress.recognizeWith(press);
//    // add customized gestures to Hammer manager
//    mc.add([drag, pan, swipe, press, longpress]);
//    return mc;
//  }
//}
