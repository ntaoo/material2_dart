import "dart:html";
import "package:angular2/angular2.dart";
import "../../core/core.dart";
import "grid_tile.dart";
import "tile_coordinator.dart";
import "tile_styler.dart";
import "grid_list_errors.dart";
import "grid_list_measure.dart";

export "../../core/line/line.dart";
export "grid_tile.dart";

// TODO(kara): Conditional (responsive) column count / row size.
// TODO(kara): Re-layout on window resize / media change (debounced).
// TODO(kara): gridTileHeader and gridTileFooter.
const String MD_FIT_MODE = "fit";

@Component(
    selector: "md-grid-list",
    templateUrl: "grid_list.html",
    styleUrls: const ["grid_list.scss.css"],
    encapsulation: ViewEncapsulation.None)
class MdGridList implements OnInit, AfterContentChecked {
  ElementRef _elementRef;
  Dir _dir;

  /** Number of columns being rendered. */
  int _cols;

  /**
   * Row height value passed in by user. This can be one of three types:
   * - Number value (ex: "100px"):  sets a fixed row height to that value
   * - Ratio value (ex: "4:3"): sets the row height based on width:height ratio
   * - "Fit" mode (ex: "fit"): sets the row height to total height divided by number of rows
   */
  String _rowHeight;

  /** The amount of space between tiles. This will be something like '5px' or '2em'. */
  String _gutter = "1px";

  /** Sets position and size styles for a tile */
  TileStyler _tileStyler;

  /** Query list of tiles that are being rendered. */
  @ContentChildren(MdGridTile)
  QueryList<MdGridTile> tiles;

  MdGridList(this._elementRef, @Optional() this._dir);

  int get cols => _cols;

  @Input()
  set cols(dynamic value) {
    _cols = coerceToNumber(value).toInt();
  }

  String get gutterSize => _gutter;

  @Input("gutterSize")
  set gutterSize(dynamic value) {
    _gutter = coerceToString(value);
  }

  /** Set internal representation of row height from the user-provided value. */
  @Input()
  set rowHeight(dynamic /* String | num */ value) {
    _rowHeight = coerceToString(value);
    _setTileStyler();
  }

  @override
  void ngOnInit() {
    _checkCols();
    _checkRowHeight();
  }

  /// The layout calculation is fairly cheap if nothing changes, so there's little cost
  /// to run it frequently.
  @override
  void ngAfterContentChecked() {
    _layoutTiles();
  }

  /// Throw a friendly error if cols property is missing.
  void _checkCols() {
    if (cols == 0) {
      throw new MdGridListColsError();
    }
  }

  /** Default to equal width:height if rowHeight property is missing */
  void _checkRowHeight() {
    if (_rowHeight == null) {
      _tileStyler = new RatioTileStyler("1:1");
    }
  }

  /** Creates correct Tile Styler subtype based on rowHeight passed in by user */
  void _setTileStyler() {
    if (identical(_rowHeight, MD_FIT_MODE)) {
      _tileStyler = new FitTileStyler();
    } else if (_rowHeight != null && _rowHeight.contains(':')) {
      _tileStyler = new RatioTileStyler(_rowHeight);
    } else {
      _tileStyler = new FixedTileStyler(_rowHeight);
    }
  }

  /// Computes and applies the size and position for all children grid tiles.
  void _layoutTiles() {
    List<MdGridTile> tiles = this.tiles.toList();
    TileCoordinator tracker = new TileCoordinator(cols, tiles);
    var direction = _dir != null ? _dir.value : "ltr";
    _tileStyler.init(gutterSize, tracker, cols, direction);
    for (int i = 0; i < tiles.length; i++) {
      var pos = tracker.positions[i];
      var tile = tiles[i];
      _tileStyler.setStyle(tile, pos.row, pos.col);
    }
    setListStyle(_tileStyler.getComputedHeight());
  }

  /// Sets style on the main grid-list element, given the style name and value.
  void setListStyle(List<String> style) {
    if (style != null) {
      Element e = _elementRef.nativeElement;
      e.style.setProperty(style.first, style.last);
    }
  }
}

const List<dynamic> MD_GRID_LIST_DIRECTIVES = const [
  MdGridList,
  MdGridTile,
  MdLine,
  MdGridTileText
];
