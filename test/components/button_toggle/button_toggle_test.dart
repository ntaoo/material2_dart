//import 'dart:html';

//import 'package:angular2/angular2.dart';
//
//import 'package:angular2/platform/browser.dart';
//import 'package:angular2_testing/angular2_testing.dart';
//import 'package:material2_dart/components/button_toggle/button_toggle.dart';
//import 'package:material2_dart/core/coordination/unique_selection_dispatcher.dart';
@TestOn('browser')
import 'package:test/test.dart';

void main() {
//  initAngularTests();
//
//  group('MdButtonToggle', () {
//    TestComponentBuilder builder;
//    MdUniqueSelectionDispatcher dispatcher;
//    const mdUniqueSelectionDispatcher =
//        const OpaqueToken('MdUniqueSelectionDispatcher');
//    MdUniqueSelectionDispatcher mdUniqueSelectionDispatcherFactory() =>
//        new MdUniqueSelectionDispatcher();
//    setUpProviders(() {
//      return [
//        const Provider(TestComponentBuilder, useClass: TestComponentBuilder),
//        new Provider(mdUniqueSelectionDispatcher,
//            useFactory: mdUniqueSelectionDispatcherFactory)
//      ];
//    });

//    ngSetUp((TestComponentBuilder tcb) {
//      builder = tcb;
//    });
//    group('inside of an exclusive selection group', () {
//      ComponentFixture fixture;
//      DebugElement groupDebugElement;
//      Element groupNativeElement;
//      List<DebugElement> buttonToggleDebugElements;
//      List<Element> buttonToggleNativeElements;
//      MdButtonToggleGroup groupInstance;
//      List<MdButtonToggle> buttonToggleInstances;
//      ButtonTogglesInsideButtonToggleGroup testComponent;
//      ngSetUp(() async {
//        fixture =
//            await builder.createAsync(ButtonTogglesInsideButtonToggleGroup);
//        fixture.detectChanges();
//        testComponent = fixture.debugElement.componentInstance;
//        groupDebugElement =
//            fixture.debugElement.query(By.directive(MdButtonToggleGroup));
//        groupNativeElement = groupDebugElement.nativeElement;
//        groupInstance = groupDebugElement.injector.get(MdButtonToggleGroup);
//
//        buttonToggleDebugElements =
//            fixture.debugElement.queryAll(By.directive(MdButtonToggle));
//        buttonToggleNativeElements = buttonToggleDebugElements
//            .map((DebugElement debugEl) => debugEl.nativeElement)
//            .toList() as List<Element>;
//        buttonToggleInstances = buttonToggleDebugElements
//            .map((debugEl) => debugEl.componentInstance)
//            .toList() as List<MdButtonToggle>;
//      });
//      ngTest(
//          'should set individual button toggle names based on the group name',
//          () {
//        expect(groupInstance.name, isNotEmpty);
//      }, skip: 'FIXME: For some reason the build failed.');
//    });
//  });
}

//@Component(
//    directives: const [MD_BUTTON_TOGGLE_DIRECTIVES],
//    template: '''
//  <md-button-toggle-group [disabled]="isGroupDisabled" [value]="groupValue">
//    <md-button-toggle value="test1">Test1</md-button-toggle>
//    <md-button-toggle value="test2">Test2</md-button-toggle>
//    <md-button-toggle value="test3">Test3</md-button-toggle>
//  </md-button-toggle-group>
//  ''')
//class ButtonTogglesInsideButtonToggleGroup {
//  bool isGroupDisabled = false;
//  String groupValue = null;
//}
//
//@Component(
//    directives: const [MD_BUTTON_TOGGLE_DIRECTIVES],
//    template: '''
//  <md-button-toggle-group [disabled]="isGroupDisabled" multiple>
//    <md-button-toggle value="eggs">Eggs</md-button-toggle>
//    <md-button-toggle value="flour">Flour</md-button-toggle>
//    <md-button-toggle value="sugar">Sugar</md-button-toggle>
//  </md-button-toggle-group>
//  ''')
//class ButtonTogglesInsideButtonToggleGroupMultiple {
//  bool isGroupDisabled = false;
//}
//
//@Component(
//    directives: const [MD_BUTTON_TOGGLE_DIRECTIVES],
//    template: '''
//  <md-button-toggle>Yes</md-button-toggle>
//  ''')
//class StandaloneButtonToggle {}
