import 'dart:html';
import 'dart:svg' as svg;
import 'dart:async';
import 'dart:math' as math;
import "package:angular2/angular2.dart";
// TODO(josephperrott): Benchpress tests.

/// A single degree in radians.
const num _degreeInRadiants = math.PI / 180;
//// Duration of the indeterminate animation.
const int _durationIndeterminate = 667;

/// Duration of the indeterminate animation.
const int _durationDeterminate = 225;

/// Start animation value of the indeterminate animation
const num _startIndeterminate = 3;

/// End animation value of the indeterminate animation
const num _endIndeterminate = 80;

/// Maximum angle for the arc.
///
/// The angle can't be exactly 360, because the arc becomes hidden.
const num _maxAngle = 359.99 / 100;

enum _ProgressCircleMode { determinate, indeterminate }

typedef num _EasingFn(
    num currentTime, num startValue, num changeValue, num duration);

/**
 * <md-progress-circle> component.
 */
@Component(
    selector: "md-progress-circle",
    host: const {
      "role": "progressbar",
      "[attr.aria-valuemin]": "ariaValueMin",
      "[attr.aria-valuemax]": "ariaValueMax"
    },
    templateUrl: "progress_circle.html",
    styleUrls: const ["progress_circle.scss.css"],
    changeDetection: ChangeDetectionStrategy.OnPush)
class MdProgressCircle implements OnDestroy {
  ChangeDetectorRef _changeDetectorRef;
  NgZone _ngZone;
  ElementRef _elementRef;

  /// The id of the last requested animation.
  num _lastAnimationId = 0;

  /// The Timer of the indeterminate interval.
  Timer _interdeterminateInterval;

  /// The SVG <path> node that is used to draw the circle.
  svg.PathElement _path;

  /**
   * Values for aria max and min are only defined as numbers when in a determinate mode.  We do this
   * because voiceover does not report the progress indicator as indeterminate if the aria min
   * and/or max value are number values.
   *
   */
  num get ariaValueMin => mode == "determinate" ? 0 : null;

  num get ariaValueMax => mode == "determinate" ? 100 : null;

  Timer get interdeterminateInterval => _interdeterminateInterval;

  set interdeterminateInterval(Timer interval) {
    _interdeterminateInterval?.cancel();
    _interdeterminateInterval = interval;
  }

  // Clean up any animations that were running.
  @override
  void ngOnDestroy() {
    _cleanupIndeterminateAnimation();
  }

  /**
   * Value of the progress circle.
   *
   * Input:number
   * _value is bound to the host as the attribute aria-valuenow.
   */
  num _value;

  @HostBinding("attr.aria-valuenow")
  num get value {
    if (mode == "determinate") {
      return _value;
    }
    return null;
  }

  @Input()
  set value(num v) {
    if (v != null && v != 0 && mode == "determinate") {
      var newValue = _clamp(v);
      _animateCircle(
          (value ?? 0), newValue, _linearEase, _durationDeterminate, 0);
      _value = newValue;
    }
  }

  /**
   * Mode of the progress circle
   *
   * Input must be one of the values from ProgressMode, defaults to 'determinate'.
   * mode is bound to the host as the attribute host.
   */
  @HostBinding("attr.mode")
  String get mode => _mode == _ProgressCircleMode.determinate
      ? 'determinate'
      : 'indeterminate';

  @Input()
  set mode(String m) {
    if (!['determinate', 'indeterminate'].contains(m)) {
      throw new ArgumentError(
          'Only determinate and indeterminate are allowed.');
    }
    if (m == "indeterminate") {
      _startIndeterminateAnimation();
      _mode = _ProgressCircleMode.indeterminate;
    } else {
      _cleanupIndeterminateAnimation();
      _mode = _ProgressCircleMode.determinate;
    }
  }

  _ProgressCircleMode _mode = _ProgressCircleMode.determinate;

  MdProgressCircle(this._changeDetectorRef, this._ngZone, this._elementRef);

  /**
   * Animates the circle from one percentage value to another.
   *
   * @param animateFrom The percentage of the circle filled starting the animation.
   * @param animateTo The percentage of the circle filled ending the animation.
   * @param ease The easing function to manage the pace of change in the animation.
   * @param duration The length of time to show the animation, in milliseconds.
   * @param rotation The starting angle of the circle fill, with 0° represented at the top center of the circle.
   */
  void _animateCircle(num animateFrom, num animateTo, _EasingFn ease,
      num duration, num rotation) {
    num id = ++_lastAnimationId;
    num startTime = _now();
    num changeInValue = animateTo - animateFrom;

    // No need to animate it if the values are the same
    if (animateTo == animateFrom) {
      _renderArc(animateTo, animateFrom);
    } else {
      _ngZone.runOutsideAngular(() {
        window.animationFrame.then/*<num>*/((num _) {
          _animation(id, startTime, animateFrom, changeInValue, duration,
              rotation, ease);
        });
      });
    }
  }

  void _animation(num id, num startTime, num animateFrom, num changeInValue,
      num duration, num rotation, _EasingFn ease) {
    var currentTime = _now();
    num elapsedTime = math.max(0, math.min(currentTime - startTime, duration));
    _renderArc(
        ease(elapsedTime, animateFrom, changeInValue, duration), rotation);
    // Prevent overlapping animations by checking if a new animation has been called for and
    // if the animation has lasted longer than the animation duration.
    if (id == _lastAnimationId && elapsedTime < duration) {
      window.animationFrame.then/*<num>*/((num _) {
        _animation(id, startTime, animateFrom, changeInValue, duration,
            rotation, ease);
      });
    }
  }

  ///Starts the indeterminate animation interval, if it is not already running.
  void _startIndeterminateAnimation() {
    num rotationStartPoint = 0;
    num start = _startIndeterminate;
    num end = _endIndeterminate;
    num duration = _durationIndeterminate;
    var animate = () {
      _animateCircle(start, end, _materialEase, duration, rotationStartPoint);
      // Prevent rotation from reaching Number.MAX_SAFE_INTEGER.
      rotationStartPoint = (rotationStartPoint + end) % 100;
      var temp = start;
      start = -end;
      end = -temp;
    };

    if (interdeterminateInterval == null) {
      _ngZone.runOutsideAngular(() {
        interdeterminateInterval = new Timer.periodic(
            new Duration(milliseconds: duration.toInt() + 50), (_) => animate);
        animate();
      });
    }
  }

  /// Removes interval, ending the animation.
  void _cleanupIndeterminateAnimation() {
    interdeterminateInterval = null;
  }

  /// Renders the arc onto the SVG element. Proxies `getArc`
  /// while setting the proper DOM attribute on the `<path>`.
  void _renderArc(num currentValue, num rotation) {
    // Caches the path reference so it doesn't have to be looked up every time.
    svg.PathElement path;
    if (_path == null) {
      path = _elementRef.nativeElement.querySelector('path');
    } else {
      path = _path;
    }
    // Ensure that the path was found. This may not be the case if the
    // animation function fires too early.
    if (path != null) {
      path.attributes['d'] = _getSvgArc(currentValue, rotation);
    }
  }
}

/**
 * <md-spinner> component.
 *
 * This is a component definition to be used as a convenience reference to create an
 * indeterminate <md-progress-circle> instance.
 */
@Component(
    selector: "md-spinner",
    host: const {"role": "progressbar", "mode": "indeterminate"},
    templateUrl: "progress_circle.html",
    styleUrls: const ["progress_circle.scss.css"])
class MdSpinner extends MdProgressCircle {
  MdSpinner(
      ChangeDetectorRef changeDetectorRef, ElementRef elementRef, NgZone ngZone)
      : super(changeDetectorRef, ngZone, elementRef) {
    mode = "indeterminate";
  }
}

/**
 * Module functions.
 */

/** Clamps a value to be between 0 and 100. */
num _clamp(num v) {
  return math.max(0, math.min(100, v));
}

/// Returns the current timestamp either based on the performance global
/// or a date object.
num _now() => new DateTime.now().millisecondsSinceEpoch;

/**
 * Converts Polar coordinates to Cartesian.
 */
String _polarToCartesian(num radius, num pathRadius, num angleInDegrees) {
  var angleInRadians = (angleInDegrees - 90) * _degreeInRadiants;
  return (radius + (pathRadius * math.cos(angleInRadians))).toString() +
      "," +
      (radius + (pathRadius * math.sin(angleInRadians))).toString();
}

/**
 * Easing function for linear animation.
 */
num _linearEase(
    num currentTime, num startValue, num changeInValue, num duration) {
  return changeInValue * currentTime / duration + startValue;
}

/**
 * Easing function to match material design indeterminate animation.
 */
num _materialEase(
    num currentTime, num startValue, num changeInValue, num duration) {
  var time = currentTime / duration;
  var timeCubed = math.pow(time, 3);
  var timeQuad = math.pow(time, 4);
  var timeQuint = math.pow(time, 5);
  return startValue +
      changeInValue * ((6 * timeQuint) + (-15 * timeQuad) + (10 * timeCubed));
}

/**
 * Determines the path value to define the arc.  Converting percentage values to to polar
 * coordinates on the circle, and then to cartesian coordinates in the viewport.
 *
 * @param currentValue The current percentage value of the progress circle, the percentage of the
 *    circle to fill.
 * @param rotation The starting point of the circle with 0 being the 0 degree point.
 * @return A string for an SVG path representing a circle filled from the starting point to the
 *    percentage value provided.
 */
String _getSvgArc(num currentValue, num rotation) {
  var startPoint = rotation ?? 0;
  var radius = 50;
  var pathRadius = 40;

  var startAngle = startPoint * _maxAngle;
  var endAngle = currentValue * _maxAngle;
  var start = _polarToCartesian(radius, pathRadius, startAngle);
  var end = _polarToCartesian(radius, pathRadius, endAngle + startAngle);
  var arcSweep = endAngle < 0 ? 0 : 1;
  num largeArcFlag;
  if (endAngle < 0) {
    largeArcFlag = endAngle >= -180 ? 0 : 1;
  } else {
    largeArcFlag = endAngle <= 180 ? 0 : 1;
  }
  return 'M${start}A$pathRadius,$pathRadius 0 $largeArcFlag,$arcSweep $end';
}

const List MD_PROGRESS_CIRCLE_DIRECTIVES = const [MdProgressCircle, MdSpinner];
