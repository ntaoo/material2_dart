import 'dart:html';
import 'package:angular2/angular2.dart';
import "package:angular2/testing_internal.dart";
import 'package:material2_dart/src/components/button/button.dart';
@TestOn('browser')
import 'package:test/test.dart';

void main() {
  test('should apply class based on color attribute', () {
    return inject([TestComponentBuilder, AsyncTestCompleter],
        (TestComponentBuilder tcb, AsyncTestCompleter completer) async {
      ComponentFixture fixture = await tcb.createAsync(TestApp);
      TestApp testComponent = fixture.debugElement.componentInstance;
      var buttonDebugElement = fixture.debugElement.query(By.css('button'));
      var aDebugElement = fixture.debugElement.query(By.css('a'));

      testComponent.buttonColor = 'primary';
      fixture.detectChanges();

      expect(buttonDebugElement.nativeElement.classes.contains('md-primary'),
          isTrue);
      expect(
          aDebugElement.nativeElement.classes.contains('md-primary'), isTrue);
      completer.done();
    });
  });

  test('should should not clear previous defined classes', () {
    return inject([TestComponentBuilder, AsyncTestCompleter],
        (TestComponentBuilder tcb, AsyncTestCompleter completer) async {
      ComponentFixture fixture = await tcb.createAsync(TestApp);
      TestApp testComponent = fixture.debugElement.componentInstance;
      var buttonDebugElement = fixture.debugElement.query(By.css('button'));

      buttonDebugElement.nativeElement.classes.add('custom-class');

      testComponent.buttonColor = 'primary';
      fixture.detectChanges();

      expect(buttonDebugElement.nativeElement.classes.contains('md-primary'),
          isTrue);
      expect(buttonDebugElement.nativeElement.classes.contains('custom-class'),
          isTrue);

      testComponent.buttonColor = 'accent';
      fixture.detectChanges();

      expect(buttonDebugElement.nativeElement.classes.contains('md-primary'),
          isFalse);
      expect(buttonDebugElement.nativeElement.classes.contains('md-accent'),
          isTrue);
      expect(buttonDebugElement.nativeElement.classes.contains('custom-class'),
          isTrue);
      completer.done();
    });
  });

  group('button[md-button]', () {
    test('should handle a click on the button', () {
      return inject([TestComponentBuilder, AsyncTestCompleter],
          (TestComponentBuilder tcb, AsyncTestCompleter completer) async {
        ComponentFixture fixture = await tcb.createAsync(TestApp);
        TestApp testComponent = fixture.debugElement.componentInstance;
        var buttonDebugElement = fixture.debugElement.query(By.css('button'));
        Element e = buttonDebugElement.nativeElement;
        e.click();
        expect(testComponent.clickCount, 1);
        completer.done();
      });
    });
    test('should not increment if disabled', () {
      return inject([TestComponentBuilder, AsyncTestCompleter],
          (TestComponentBuilder tcb, AsyncTestCompleter completer) async {
        ComponentFixture fixture = await tcb.createAsync(TestApp);
        TestApp testComponent = fixture.debugElement.componentInstance;
        var buttonDebugElement = fixture.debugElement.query(By.css('button'));

        testComponent.isDisabled = true;
        fixture.detectChanges();
        Element e = buttonDebugElement.nativeElement;
        e.click();
        expect(testComponent.clickCount, equals(0));
        completer.done();
      });
    });
  });

  group('a[md-button]', () {
    test('should not redirect if disabled', () {
      return inject([TestComponentBuilder, AsyncTestCompleter],
          (TestComponentBuilder tcb, AsyncTestCompleter completer) async {
        ComponentFixture fixture = await tcb.createAsync(TestApp);
        TestApp testComponent = fixture.debugElement.componentInstance;
        var buttonDebugElement = fixture.debugElement.query(By.css('a'));

        testComponent.isDisabled = true;
        fixture.detectChanges();

        Element e = buttonDebugElement.nativeElement;
        e.click();
        // will error if page reloads.
        completer.done();
      });
    });

    test('should remove tabindex if disabled', () {
      return inject([TestComponentBuilder, AsyncTestCompleter],
          (TestComponentBuilder tcb, AsyncTestCompleter completer) async {
        ComponentFixture fixture = await tcb.createAsync(TestApp);
        TestApp testComponent = fixture.debugElement.componentInstance;
        var buttonDebugElement = fixture.debugElement.query(By.css('a'));
        Element e = buttonDebugElement.nativeElement;
        expect(e.attributes['tabIndex'], isNull);

        testComponent.isDisabled = true;
        fixture.detectChanges();
        expect(e.attributes['tabIndex'], '-1');
        completer.done();
      });
    });

    test('should add aria-disabled attribute if disabled', () {
      return inject([TestComponentBuilder, AsyncTestCompleter],
          (TestComponentBuilder tcb, AsyncTestCompleter completer) async {
        ComponentFixture fixture = await tcb.createAsync(TestApp);
        TestApp testComponent = fixture.debugElement.componentInstance;
        var buttonDebugElement = fixture.debugElement.query(By.css('a'));

        fixture.detectChanges();
        expect(buttonDebugElement.nativeElement.attributes['aria-disabled'],
            equals('false'));
        testComponent.isDisabled = true;
        fixture.detectChanges();
        expect(buttonDebugElement.nativeElement.attributes['aria-disabled'],
            equals('true'));
        completer.done();
      });
    });
  });

  // Ripple tests.
  group('button ripples', () {
    test('should remove ripple if md-ripple-disabled input is set', () {
      return inject([TestComponentBuilder, AsyncTestCompleter],
          (TestComponentBuilder tcb, AsyncTestCompleter completer) async {
        ComponentFixture fixture = await tcb.createAsync(TestApp);
        TestApp testComponent = fixture.debugElement.componentInstance;
        var buttonDebugElement = fixture.debugElement.query(By.css('button'));

        fixture.detectChanges();
        expect(
            buttonDebugElement
                .nativeElement.querySelectorAll('[md-ripple]').length,
            1);

        testComponent.rippleDisabled = true;
        fixture.detectChanges();
        expect(
            buttonDebugElement
                .nativeElement.querySelectorAll('[md-ripple]').length,
            0);
        completer.done();
      });
    });
  });
}

/// Test component that contains an MdButton.
@Component(
    selector: 'test-app',
    template: '''
    <button md-button type="button" (click)="increment()"
      [disabled]="isDisabled" [color]="buttonColor" [disableRipple]="rippleDisabled">
      Go
    </button>
    <a href="http://www.google.com" md-button [disabled]="isDisabled" [color]="buttonColor">Link</a>
  ''',
    directives: const [MdButton, MdAnchor])
class TestApp {
  int clickCount = 0;
  bool isDisabled = false;
  String buttonColor;
  bool rippleDisabled = false;

  void increment() {
    clickCount++;
  }
}
