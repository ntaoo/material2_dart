import "dart:math" as math;
import "package:angular2/angular2.dart";
// TODO(josephperrott): Benchpress tests.

// TODO(josephperrott): Add ARIA attributes for progressbar "for".

/**
 * <md-progress-bar> component.
 */
@Component(
    selector: "md-progress-bar",
    host: const {
      "role": "progressbar",
      "aria-valuemin": "0",
      "aria-valuemax": "100"
    },
    templateUrl: "progress_bar.html",
    styleUrls: const ["progress_bar.scss.css"],
    changeDetection: ChangeDetectionStrategy.OnPush)
class MdProgressBar {
  /** Value of the progressbar. Defaults to zero. Mirrored to aria-valuenow. */
  num _value = 0;

  @HostBinding("attr.aria-valuenow")
  num get value => _value;

  @Input()
  set value(num v) {
    _value = clamp(v ?? 0);
  }

  /** Buffer value of the progress bar. Defaults to zero. */
  num _bufferValue = 0;

  num get bufferValue => _bufferValue;

  @Input()
  set bufferValue(num v) {
    _bufferValue = clamp(v ?? 0);
  }

  /**
   * Mode of the progress bar.
   *
   * Input must be one of these values: determinate, indeterminate, buffer, query, defaults to
   * 'determinate'.
   * Mirrored to mode attribute.
   * 'determinate' | 'indeterminate' | 'buffer' | 'query'
   */
  @Input()
  @HostBinding("attr.mode")
  String mode = "determinate";

  /**
   * Gets the current transform value for the progress bar's primary indicator.
   */
  Map primaryTransform() {
    var scale = value / 100;
    return {"transform": 'scaleX($scale)'};
  }

  /**
   * Gets the current transform value for the progress bar's buffer indicator.  Only used if the
   * progress mode is set to buffer, otherwise returns an undefined, causing no transformation.
   */
  Map bufferTransform() {
    if (mode == "buffer") {
      var scale = bufferValue / 100;
      return {"transform": '''scaleX($scale)'''};
    }
    return null;
  }
}

/** Clamps a value to be between two numbers, by default 0 and 100. */
num clamp(num v, [int min = 0, int max = 100]) {
  return math.max(min, math.min(max, v));
}

const List MD_PROGRESS_BAR_DIRECTIVES = const [MdProgressBar];
