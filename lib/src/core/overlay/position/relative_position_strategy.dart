import 'dart:html';
import "dart:async";
import "package:angular2/angular2.dart";
import "position_strategy.dart";

class RelativePositionStrategy implements PositionStrategy {
  ElementRef relativeTo;

  RelativePositionStrategy(this.relativeTo);

  @override
  Future apply(Element element) {
    // Not yet implemented.
    return null;
  }
}
