import "viewport_ruler.dart";
import "connected_position_strategy.dart";
import "package:angular2/angular2.dart";
import "global_position_strategy.dart";
import "connected_position.dart";
export "connected_position.dart";

/// Builder for overlay position strategy.
@Injectable()
class OverlayPositionBuilder {
  ViewportRuler _viewportRuler;

  OverlayPositionBuilder(this._viewportRuler);

  /// Creates a global position strategy.
  GlobalPositionStrategy global() => new GlobalPositionStrategy();

  /// Creates a relative position strategy.
  ConnectedPositionStrategy connectedTo(
          ElementRef elementRef,
          OriginConnectionPosition originPos,
          OverlayConnectionPosition overlayPos) =>
      new ConnectedPositionStrategy(
          elementRef, originPos, overlayPos, _viewportRuler);
}
