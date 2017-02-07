import "position/position_strategy.dart";

/// OverlayState is a bag of values for either the initial configuration
/// or current state of an overlay.
class OverlayState {
  /// Strategy with which to position the overlay.
  PositionStrategy positionStrategy;

  /// Whether the overlay has a backdrop.
  bool hasBackdrop = false;

  /// Custom class to add to the backdrop.
  String backdropClass = 'md-overlay-dark-backdrop';

  /// The width of the overlay panel. If a number is provided, pixel units are assumed.
  dynamic /*num | String*/ width;

  /// The height of the overlay panel. If a number is provided, pixel units are assumed.
  dynamic /*num | String*/ height;

  String direction = 'ltr';
}
