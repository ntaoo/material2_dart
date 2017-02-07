import "dart:html";
import "package:angular2/angular2.dart";
import "../../core/core.dart";
import "grid_list_measure.dart";

@Component(
    selector: "md-grid-tile",
    host: const {"role": "listitem"},
    templateUrl: "grid_tile.html",
    styleUrls: const ["grid_list.scss.css"],
    encapsulation: ViewEncapsulation.None)
class MdGridTile {
  ElementRef _elementRef;
  int _rowspan = 1;
  int _colspan = 1;

  MdGridTile(this._elementRef);

  int get rowspan => _rowspan;

  int get colspan => _colspan;

  @Input()
  set rowspan(dynamic value) {
    _rowspan = coerceToNumber(value).toInt();
  }

  @Input()
  set colspan(dynamic value) {
    _colspan = coerceToNumber(value).toInt();
  }

  /// Sets the style of the grid-tile element. Needs to be set manually to avoid
  /// "Changed after checked" errors that would occur with HostBinding.
  void setStyle(String property, String value) {
    Element e = _elementRef.nativeElement;
    e.style.setProperty(property, value);
  }
}

@Component(
    selector: "md-grid-tile-header, md-grid-tile-footer",
    templateUrl: "grid_tile_text.html")
class MdGridTileText implements AfterContentInit {
  ElementRef _elementRef;

  /// Helper that watches the number of lines in a text area and sets a class
  /// on the host element that matches the line count.
  MdLineSetter lineSetter;
  @ContentChildren(MdLine)
  QueryList<MdLine> lines;

  MdGridTileText(this._elementRef);

  @override
  void ngAfterContentInit() {
    lineSetter = new MdLineSetter(lines, _elementRef);
  }
}
