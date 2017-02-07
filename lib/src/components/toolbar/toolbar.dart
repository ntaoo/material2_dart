import 'dart:html';
import 'package:angular2/angular2.dart';

@Directive(selector: 'md-toolbar-row')
class MdToolbarRow {}

@Component(
    selector: 'md-toolbar',
    templateUrl: 'toolbar.html',
    styleUrls: const ['toolbar.scss.css'],
    changeDetection: ChangeDetectionStrategy.OnPush,
    encapsulation: ViewEncapsulation.None)
class MdToolbar {
  String get color => _color;

  @Input()
  set color(String value) {
    _updateColor(value);
  }

  String _color;
  ElementRef _elementRef;
  Element get _nativeElement => _elementRef.nativeElement;
  MdToolbar(this._elementRef);

  void _updateColor(String newColor) {
    if (color != null && color.isNotEmpty) {
      _nativeElement.classes.remove('md-$color');
    }
    _nativeElement.classes.add('md-$newColor');
    _color = newColor;
  }
}

const List MD_TOOLBAR_DIRECTIVES = const [MdToolbar, MdToolbarRow];
