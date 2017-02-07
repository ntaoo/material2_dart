import 'dart:html';
import 'package:angular2/angular2.dart';
import '../ink_bar.dart';

/// Provides anchored navigation with animated ink bar.
@Component(
  selector: '[md-tab-nav-bar]',
  templateUrl: 'tab_nav_bar.html',
  styleUrls: const ['tab_nav_bar.scss.css'],
  encapsulation: ViewEncapsulation.None,
)
class MdTabNavBar {
  @ViewChild(MdInkBar)
  MdInkBar inkBar;

  /// Animates the ink bar to the position of the active link element.
  void updateActiveLink(Element element) {
    inkBar.alignToElement(element);
  }
}

@Directive(
  selector: '[md-tab-link]',
)
class MdTabLink {
  MdTabNavBar _mdTabNavBar;
  ElementRef _elementRef;
  bool _isActive = false;

  @Input()
  bool get active => _isActive;

  set active(bool value) {
    _isActive = value;
    if (value) {
      _mdTabNavBar.updateActiveLink(_elementRef.nativeElement);
    }
  }

  MdTabLink(this._mdTabNavBar, this._elementRef);
}
