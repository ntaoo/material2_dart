import 'dart:html';
import 'package:angular2/angular2.dart';
import "package:angular2/testing_internal.dart";
import 'package:material2_dart/src/components/tabs/tabs.dart';
@TestOn('browser')
import 'package:test/test.dart';

void main() {
  // FIXME: package:test doesn't support test double like spyOn. I may try to port spyOn from package:guiness to an individual package, or use some other mock package.

  group('MdTabGroup', () {
    ComponentFixture fixture;

    // Checks that the `selectedIndex` has been updated; checks that the label and body have the
    // `md-active` class
    void checkSelectedIndex(int index) {
      fixture.detectChanges();

      MdTabGroup tabComponent =
          fixture.debugElement.query(By.css('md-tab-group')).componentInstance;
      expect(tabComponent.selectedIndex, index);

      Element tabLabelElement = fixture.debugElement
          .query(By.css('.md-tab-label:nth-of-type(${index + 1})'))
          .nativeElement;
      expect(tabLabelElement.classes, contains('md-tab-active'));

      Element tabContentElement = fixture.debugElement
          .query(By.css('#${tabLabelElement.id}'))
          .nativeElement;
      expect(tabContentElement.classes, contains('md-tab-active'));
    }

    group('basic behavior', () {
      test('should default to the first tab', () {
        return inject([TestComponentBuilder, AsyncTestCompleter],
            (TestComponentBuilder tcb, AsyncTestCompleter completer) async {
          fixture = await tcb.createAsync(SimpleTabsTestApp);
          checkSelectedIndex(1);
          completer.done();
        });
      });

      test('should change selected index on click', () {
        return inject([TestComponentBuilder, AsyncTestCompleter],
            (TestComponentBuilder tcb, AsyncTestCompleter completer) async {
          fixture = await tcb.createAsync(SimpleTabsTestApp);
          SimpleTabsTestApp component = fixture.debugElement.componentInstance;
          component.selectedIndex = 0;
          checkSelectedIndex(0);

          // select the second tab
          var tabLabel =
              fixture.debugElement.queryAll(By.css('.md-tab-label'))[1];
          tabLabel.nativeElement.click();
          checkSelectedIndex(1);

          // select the third tab
          tabLabel = fixture.debugElement.queryAll(By.css('.md-tab-label'))[2];
          tabLabel.nativeElement.click();
          checkSelectedIndex(2);
          completer.done();
        });
      });

      test('should support two-way binding for selectedIndex', () {
        return inject([TestComponentBuilder, AsyncTestCompleter],
            (TestComponentBuilder tcb, AsyncTestCompleter completer) async {
          fixture = await tcb.createAsync(SimpleTabsTestApp);
          SimpleTabsTestApp component = fixture.debugElement.componentInstance;
          component.selectedIndex = 0;
          fixture.detectChanges();

          var tabLabel =
              fixture.debugElement.queryAll(By.css('.md-tab-label'))[1];
          tabLabel.nativeElement.click();

          fixture.detectChanges();

          // whenStable
          expect(component.selectedIndex, 1);

          completer.done();
        });
      }, skip: 'Skip until `fixture.whenStable()` is introduced to ng2dart.');

      test(
          'should cycle through tab focus with focusNextTab/focusPreviousTab functions',
          () {
        return inject([TestComponentBuilder, AsyncTestCompleter],
            (TestComponentBuilder tcb, AsyncTestCompleter completer) async {
          fixture = await tcb.createAsync(SimpleTabsTestApp);
          fakeAsync(() async {
            SimpleTabsTestApp testComponent = fixture.componentInstance;
            MdTabGroup tabComponent = fixture.debugElement
                .query(By.css('md-tab-group'))
                .componentInstance;
//          spyOn(testComponent, 'handleFocus').and.callThrough();
            fixture.detectChanges();

            tabComponent.focusIndex = 0;
            fixture.detectChanges();
            tick();
            expect(tabComponent.focusIndex, 0);
//          expect(testComponent.handleFocus).toHaveBeenCalledTimes(1);
            expect(testComponent.focusEvent.index, 0);

            tabComponent.focusNextTab();
            fixture.detectChanges();
            tick();
            expect(tabComponent.focusIndex, 1);
//          expect(testComponent.handleFocus).toHaveBeenCalledTimes(2);
            expect(testComponent.focusEvent.index, 1);

            tabComponent.focusNextTab();
            fixture.detectChanges();
            tick();
            expect(tabComponent.focusIndex, 2);
//          expect(testComponent.handleFocus).toHaveBeenCalledTimes(3);
            expect(testComponent.focusEvent.index, 2);

            tabComponent.focusNextTab();
            fixture.detectChanges();
            tick();
            expect(tabComponent.focusIndex, 2); // should stop at 2
//          expect(testComponent.handleFocus).toHaveBeenCalledTimes(3);
            expect(testComponent.focusEvent.index, 2);

            tabComponent.focusPreviousTab();
            fixture.detectChanges();
            tick();
            expect(tabComponent.focusIndex, 1);
//          expect(testComponent.handleFocus).toHaveBeenCalledTimes(4);
            expect(testComponent.focusEvent.index, 1);

            tabComponent.focusPreviousTab();
            fixture.detectChanges();
            tick();
            expect(tabComponent.focusIndex, 0);
//          expect(testComponent.handleFocus).toHaveBeenCalledTimes(5);
            expect(testComponent.focusEvent.index, 0);

            tabComponent.focusPreviousTab();
            fixture.detectChanges();
            tick();
            expect(tabComponent.focusIndex, 0); // should stop at 0
//          expect(testComponent.handleFocus).toHaveBeenCalledTimes(5);
            expect(testComponent.focusEvent.index, 0);
          })();
          completer.done();
        });
      });

      test('should change tabs based on selectedIndex', () {
        return inject([TestComponentBuilder, AsyncTestCompleter],
            (TestComponentBuilder tcb, AsyncTestCompleter completer) async {
          fixture = await tcb.createAsync(SimpleTabsTestApp);
          fakeAsync(() {
            SimpleTabsTestApp component = fixture.componentInstance;
            MdTabGroup tabComponent = fixture.debugElement
                .query(By.css('md-tab-group'))
                .componentInstance;

//          spyOn(component, 'handleSelection').and.callThrough();

            checkSelectedIndex(1);

            tabComponent.selectedIndex = 2;

            checkSelectedIndex(2);
            tick();

//          expect(component.handleSelection).toHaveBeenCalledTimes(1);
            expect(component.selectEvent.index, 2);
          })();
          completer.done();
        });
      });
    });
    group('disable tabs', () {

    });
    group('async tabs', () {
      // FIXME: Waiting for ng2 updated to greater than rc2 and whenStable() is supported.
//        ngSetUp(() async {
//          fixture = await builder.createAsync(AsyncTabsTestApp);
//        });

//        test('should show tabs when they are available', () {
//          var labels = fixture.debugElement.queryAll(By.css('.md-tab-label'));
//
//          expect(labels.length, equals(0));
//
//          fixture.detectChanges();

      // https://github.com/angular/angular/issues/8617
//          fixture.whenStable().then(() {
//          fixture.detectChanges();
//          labels = fixture.debugElement.queryAll(By.css('.md-tab-label'));
//          expect(labels.length, equals(2));
//        });
//       });
    });
  });
}

@Component(
    selector: 'test-app',
    template: r'''
    <md-tab-group class="tab-group"
        [selectedIndex]="selectedIndex"
        (focusChange)="handleFocus($event)"
        (selectChange)="handleSelection($event)">
      <md-tab>
        <template md-tab-label>Tab One</template>
        <template md-tab-content>Tab one content</template>
      </md-tab>
      <md-tab>
        <template md-tab-label>Tab Two</template>
        <template md-tab-content>Tab two content</template>
      </md-tab>
      <md-tab>
        <template md-tab-label>Tab Three</template>
        <template md-tab-content>Tab three content</template>
      </md-tab>
    </md-tab-group>
  ''',
    directives: const [MD_TABS_DIRECTIVES])
class SimpleTabsTestApp {
  int selectedIndex = 1;
  dynamic focusEvent;
  dynamic selectEvent;

  void handleFocus(dynamic event) {
    focusEvent = event;
  }

  void handleSelection(dynamic event) {
    selectEvent = event;
  }
}

//@Component(
//    selector: 'test-app',
//    template: '''
//    <md-tab-group class="tab-group">
//      <md-tab *ngFor="let tab of tabs | async">
//        <template md-tab-label>{{ tab.label }}</template>
//        <template md-tab-content>{{ tab.content }}</template>
//      </md-tab>
//   </md-tab-group>
//  ''',
//    directives: const [MD_TABS_DIRECTIVES],
//    pipes: const [AsyncPipe])
//class AsyncTabsTestApp {
//  List<Map> _tabs = [
//    {'label': 'one', 'content': 'one'},
//    {'label': 'two', 'content': 'two'}
//  ];
//
//  Stream<dynamic> tabs;
//
//  AsyncTabsTestApp() {
//    tabs = window.animationFrame.then((_) => _tabs).asStream();
//  }
//}
