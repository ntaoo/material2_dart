import 'dart:html';
import 'package:angular2/angular2.dart';
import '../../core/core.dart';
export '../../core/line/line.dart';

@Directive(selector: 'md-divider')
class MdListDivider {}

@Component(
    selector: 'md-list, md-nav-list',
    host: const {'role': 'list'},
    template: '<ng-content></ng-content>',
    styleUrls: const ['list.scss.css'],
    encapsulation: ViewEncapsulation.None)
class MdList {}

/* Need directive for a ContentChild query in list-item */
@Directive(selector: '[md-list-avatar]')
class MdListAvatar {}

@Component(
    selector: 'md-list-item, a[md-list-item]',
    host: const {
      'role': 'listitem',
      '(focus)': 'handleFocus()',
      '(blur)': 'handleBlur()',
    },
    templateUrl: 'list_item.html',
    encapsulation: ViewEncapsulation.None)
class MdListItem implements AfterContentInit {
  bool hasFocus = false;

  MdLineSetter lineSetter;
  @ContentChildren(MdLine)
  QueryList<MdLine> lines;

  @override
  void ngAfterContentInit() {
    lineSetter = new MdLineSetter(lines, _elementRef);
  }

  @ContentChild(MdListAvatar)
  set hasAvatar(MdListAvatar avatar) {
    if (avatar != null) {
      _nativeElement.classes.add('md-list-avatar');
    } else {
      _nativeElement.classes.remove('md-list-avatar');
    }
  }

  ElementRef _elementRef;
  Element get _nativeElement => _elementRef.nativeElement;

  MdListItem(this._elementRef);

  void handleFocus() {
    hasFocus = true;
  }

  void handleBlur() {
    hasFocus = false;
  }
}

const List MD_LIST_DIRECTIVES = const [
  MdList,
  MdListDivider,
  MdListItem,
  MdLine,
  MdListAvatar
];
