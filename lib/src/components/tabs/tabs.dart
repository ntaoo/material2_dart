import 'dart:html';
import 'dart:async';
import 'package:angular2/angular2.dart';
import "../../core/core.dart";
import "tab_label.dart";
import "tab_label_wrapper.dart";
import 'tab_nav_bar/tab_nav_bar.dart';
import "ink_bar.dart";

export "tab_label.dart";
export "tab_label_wrapper.dart";
export "ink_bar.dart";
export 'tab_nav_bar/tab_nav_bar.dart';

/// Used to generate unique ID's for each tab component.
int _nextId = 0;

/// A simple change event emitted on focus or selection changes.
class MdTabChangeEvent {
  int index;
  MdTab tab;
}

@Component(selector: "md-tab", templateUrl: 'tab.html')
class MdTab implements OnInit {
  /// Content for the tab label given by <template md-tab-label>.
  @ContentChild(MdTabLabel)
  MdTabLabel templateLabel;

  /// Template inside the MdTab view that contains an <ng-content>.
  @ViewChild(TemplateRef)
  TemplateRef templateRef;

  /// The plain text label for the tab, used when there is no template label.
  @Input('label')
  String textLabel = '';

  TemplatePortal _contentPortal;
  ViewContainerRef _viewContainerRef;
  MdTab(this._viewContainerRef);

  @override
  void ngOnInit() {
    _contentPortal = new TemplatePortal(templateRef, _viewContainerRef);
  }

  bool _disabled = false;
  @Input()
  set disabled(bool value) {
    _disabled = coerceBooleanProperty(value);
  }

  bool get disabled => _disabled;

  TemplatePortal get content => _contentPortal;
}

/// Material design tab-group component.
/// Supports basic tab pairs (label + content) and includes
/// animated ink-bar, keyboard navigation, and screen reader.
/// See: https://www.google.com/design/spec/components/tabs.html
@Component(
    selector: "md-tab-group",
    templateUrl: "tab_group.html",
    styleUrls: const ["tab_group.scss.css"],
    directives: const [PortalHostDirective, MdTabLabelWrapper, MdInkBar])
class MdTabGroup implements AfterViewChecked {
  NgZone _zone;
  @ContentChildren(MdTab)
  QueryList<MdTab> tabs;
  @ViewChildren(MdTabLabelWrapper)
  QueryList<MdTabLabelWrapper> labelWrappers;
  @ViewChildren(MdInkBar)
  QueryList<MdInkBar> inkBar;
  bool _isInitialized = false;
  int _selectedIndex = 0;

  @Input()
  set selectedIndex(int value) {
    if (value != _selectedIndex && isValidIndex(value)) {
      _selectedIndex = value;
      if (_isInitialized) {
        _onSelectChange.emit(_createChangeEvent(value));
      }
    }
  }

  int get selectedIndex => _selectedIndex;

  /// Determines if an index is valid.
  /// If the tabs are not ready yet, we assume that the user is
  /// providing a valid index and return true.
  bool isValidIndex(int index) {
    if (tabs != null && tabs.isNotEmpty) {
      final tab = tabs.toList()[index];
      return tab != null && !tab.disabled;
    } else {
      return true;
    }
  }

  /// Output to enable support for two-way binding on `selectedIndex`.
  @Output('selectedIndexChange')
  Stream<int> get selectedIndexChange =>
      selectChange.map((MdTabChangeEvent event) => event.index);

  EventEmitter<MdTabChangeEvent> _onFocusChange =
      new EventEmitter<MdTabChangeEvent>();

  @Output("focusChange")
  Stream<MdTabChangeEvent> get focusChange => _onFocusChange;

  EventEmitter<MdTabChangeEvent> _onSelectChange =
      new EventEmitter<MdTabChangeEvent>();

  @Output("selectChange")
  Stream<MdTabChangeEvent> get selectChange => _onSelectChange;

  int _focusIndex = 0;
  int _groupId;

  MdTabGroup(this._zone) {
    _groupId = _nextId++;
  }

  /// Waits one frame for the view to update, then updates the ink bar
  /// Note: This must be run outside of the zone
  /// or it will create an infinite change detection loop
  @override
  void ngAfterViewChecked() {
    _zone.runOutsideAngular(() {
      window.requestAnimationFrame((_) {
        _updateInkBar();
      });
    });
    _isInitialized = true;
  }

  /// Tells the ink-bar to align itself to the current label wrapper.
  void _updateInkBar() {
    inkBar.toList().first.alignToElement(_currentLabelWrapper);
  }

  /// Reference to the current label wrapper;
  /// defaults to null for initial render before the
  /// ViewChildren references are ready.
  Element get _currentLabelWrapper {
    return labelWrappers != null && labelWrappers.isNotEmpty
        ? labelWrappers.toList()[selectedIndex].elementRef.nativeElement
            as Element
        : null;
  }

  /// Tracks which element has focus; used for keyboard navigation.
  int get focusIndex => _focusIndex;

  /// When the focus index is set, we must manually send focus to the correct label.
  set focusIndex(int value) {
    if (isValidIndex(value)) {
      _focusIndex = value;

      if (_isInitialized) {
        _onFocusChange.add(_createChangeEvent(value));
      }

      if (labelWrappers != null && labelWrappers.isNotEmpty) {
        labelWrappers.toList()[value].focus();
      }
    }
  }

  MdTabChangeEvent _createChangeEvent(int index) {
    final event = new MdTabChangeEvent();
    event.index = index;
    if (tabs != null && tabs.isNotEmpty) {
      event.tab = tabs.toList()[index];
    }
    return event;
  }

  /// Returns a unique id for each tab label element.
  String getTabLabelId(int i) => 'md-tab-label-$_groupId-$i';

  /// Returns a unique id for each tab content element.
  String getTabContentId(int i) => 'md-tab-content-$_groupId-$i';

  void handleKeydown(KeyboardEvent event) {
    switch (event.keyCode) {
      case KeyCode.RIGHT:
        focusNextTab();
        break;
      case KeyCode.LEFT:
        focusPreviousTab();
        break;
      case KeyCode.ENTER:
        selectedIndex = focusIndex;
        break;
    }
  }

  /// Moves the focus left or right depending on the offset provided.
  /// Valid offsets are 1 and -1.
  void moveFocus(int offset) {
    if (labelWrappers != null && labelWrappers.isNotEmpty) {
      final List<MdTab> tabs = this.tabs.toList();
      for (var i = focusIndex + offset;
          i < tabs.length && i >= 0;
          i += offset) {
        if (isValidIndex(i)) {
          focusIndex = i;
          return;
        }
      }
    }
  }

  /// Increment the focus index by 1; prevent going over the number of tabs.
  void focusNextTab() {
    moveFocus(1);
  }

  /// Decrement the focus index by 1; prevent going below 0.
  void focusPreviousTab() {
    moveFocus(-1);
  }
}

const List MD_TABS_DIRECTIVES = const [
  MdTabGroup,
  MdTabLabel,
  MdTab,
  MdTabNavBar,
  MdTabLink,
];
