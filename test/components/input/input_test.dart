import 'dart:html';
import 'package:angular2/angular2.dart';
//import 'package:angular2/testing.dart';
import "package:angular2/testing_internal.dart";
import 'package:material2_dart/src/components/input/input.dart';
@TestOn('browser')
import 'package:test/test.dart';

void main() {
  group('MdInput', () {
    test('creates a native <input> element', () {
      return inject([TestComponentBuilder, AsyncTestCompleter],
          (TestComponentBuilder tcb, AsyncTestCompleter completer) async {
        var fixture = await tcb.createAsync(MdInputBaseTestController);
        fixture.detectChanges();
        expect(fixture.debugElement.query(By.css('input')), isNotNull);
        completer.done();
      });
    });

    test('support ngModel', () {
      return inject([TestComponentBuilder, AsyncTestCompleter],
          (TestComponentBuilder tcb, AsyncTestCompleter completer) async {
        var fixture = await tcb.createAsync(MdInputBaseTestController);
        fixture.detectChanges();
        fakeAsync(() {
          MdInputBaseTestController instance = fixture.componentInstance;
          MdInput component = fixture.debugElement
              .query(By.directive(MdInput))
              .componentInstance;
          InputElement el =
              fixture.debugElement.query(By.css('input')).nativeElement;

          instance.model = 'hello';
          fixture.detectChanges();
          tick();
          expect(el.value, 'hello');
          component.value = 'world';
          fixture.detectChanges();
          tick();
          expect(el.value, 'world');
        })();
        completer.done();
      });
    });

    test('should have a different ID for outer element and internal input', () {
      return inject([TestComponentBuilder, AsyncTestCompleter],
          (TestComponentBuilder tcb, AsyncTestCompleter completer) async {
        var fixture = await tcb
            .overrideTemplate(MdInputBaseTestController,
                ' <md-input id="test-id"></md-input>')
            .createAsync(MdInputBaseTestController);
        fixture.detectChanges();
        fakeAsync(() {
          final Element componentElement =
              fixture.debugElement.query(By.directive(MdInput)).nativeElement;
          final InputElement inputElement =
              fixture.debugElement.query(By.css('input')).nativeElement;
          expect(componentElement.id, 'test-id');
          expect(inputElement.id, isNotEmpty);
          expect(inputElement.id, isNot(componentElement.id));
        })();
        completer.done();
      });
    });
    test('counts characters', () {
      return inject([TestComponentBuilder, AsyncTestCompleter],
          (TestComponentBuilder tcb, AsyncTestCompleter completer) async {
        var fixture = await tcb.createAsync(MdInputBaseTestController);
        MdInputBaseTestController instance = fixture.componentInstance;
        fixture.detectChanges();
        MdInput inputInstance =
            fixture.debugElement.query(By.directive(MdInput)).componentInstance;
        instance.model = 'hello';
        fixture.detectChanges();
        expect(inputInstance.characterCount, 5);
        completer.done();
      });
    });
    test('copies aria attributes to the inner input', () {
      return inject([TestComponentBuilder, AsyncTestCompleter],
          (TestComponentBuilder tcb, AsyncTestCompleter completer) async {
        var fixture = await tcb.createAsync(MdInputAriaTestController);
        MdInputAriaTestController instance = fixture.componentInstance;
        fixture.detectChanges();
        InputElement el =
            fixture.debugElement.query(By.css('input')).nativeElement;
        expect(el.attributes['aria-label'], 'label');
        instance.ariaLabel = 'label 2';
        fixture.detectChanges();
        expect(el.getAttribute('aria-label'), 'label 2');
        expect(el.getAttribute('aria-disabled'), isNotNull);
        completer.done();
      });
    });
  });

  /// TODO(ntaoo): Porting tests is in progress.
}

@Component(
    selector: 'test-input-controller',
    template: '''
    <md-input type="number" [(ngModel)]="value">
    </md-input>
  ''',
    directives: const [MD_INPUT_DIRECTIVES])
class MdInputNumberTypeConservedTestComponent {
  int value = 0;
}

@Component(
    selector: 'test-input-controller',
    template: '''
    <md-input required placeholder="hello">
    </md-input>
  ''',
    directives: const [MD_INPUT_DIRECTIVES])
class MdInputPlaceholderRequiredTestComponent {}

@Component(
    selector: 'test-input-controller',
    template: '''
    <md-input>
      <md-placeholder>{{placeholder}}</md-placeholder>
    </md-input>
  ''',
    directives: const [MD_INPUT_DIRECTIVES])
class MdInputPlaceholderElementTestComponent {
  String placeholder = 'Default Placeholder';
}

@Component(
    selector: 'test-input-controller',
    template: '''
    <md-input [placeholder]="placeholder">
    </md-input>
  ''',
    directives: const [MD_INPUT_DIRECTIVES])
class MdInputPlaceholderAttrTestComponent {
  String placeholder = '';
}

@Component(
    selector: 'test-input-controller',
    template: '''
    <md-input>
      <md-hint>{{label}}</md-hint>
    </md-input>
  ''',
    directives: const [MD_INPUT_DIRECTIVES])
class MdInputHintLabel2TestController {
  String label = '';
}

@Component(
    selector: 'test-input-controller',
    template: '''
    <md-input [hintLabel]="label">
    </md-input>
  ''',
    directives: const [MD_INPUT_DIRECTIVES])
class MdInputHintLabelTestController {
  String label = '';
}

@Component(
    selector: 'test-input-controller',
    template: '''
    <md-input type="file">
    </md-input>
  ''',
    directives: const [MD_INPUT_DIRECTIVES])
class MdInputInvalidTypeTestController {}

@Component(
    selector: 'test-input-controller',
    template: '''
    <md-input placeholder="Hello">
      <md-placeholder>World</md-placeholder>
    </md-input>
  ''',
    directives: const [MD_INPUT_DIRECTIVES])
class MdInputInvalidPlaceholderTestController {}

@Component(
    selector: 'test-input-controller',
    template: '''
    <md-input hintLabel="Hello">
      <md-hint>World</md-hint>
    </md-input>
  ''',
    directives: const [MD_INPUT_DIRECTIVES])
class MdInputInvalidHint2TestController {}

@Component(
    selector: 'test-input-controller',
    template: '''
<md-input>
<md-hint>Hello</md-hint>
<md-hint>World</md-hint>
</md-input>
''',
    directives: const [MD_INPUT_DIRECTIVES])
class MdInputInvalidHintTestController {}

@Component(
    selector: 'test-input-controller',
    template: '''
<md-input [(ngModel)]="model">
</md-input>
''',
    directives: const [MdInput])
class MdInputBaseTestController {
  dynamic model = '';
}

@Component(
    selector: 'test-input-controller',
    template: '''
      <md-input [aria-label]="ariaLabel" [aria-disabled]="ariaDisabled">
      </md-input>
    ''',
    directives: const [MdInput])
class MdInputAriaTestController {
  String ariaLabel = 'label';
  bool ariaDisabled = true;
}

@Component(
    selector: 'test-input-controller',
    template: r'''
<md-input (focus)="onFocus($event)" (blur)="onBlur($event)"></md-input>
''',
    directives: const [MdInput])
class MdInputWithBlurAndFocusEvents {
  void onBlur(FocusEvent event) {}

  void onFocus(FocusEvent event) {}
}

@Component(
    selector: 'test-input-controller',
    template: '''
    <md-input></md-input>
    ''',
    directives: const [MdInput])
class MdInputOptionalAttributeController {}

@Component(
    selector: 'test-input-controller',
    template: '''
    <md-input name="some-name"></md-input>
  ''',
    directives: const [MdInput])
class MdInputWithNameTestController {}
