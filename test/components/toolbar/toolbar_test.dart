import 'package:angular2/angular2.dart';
import "package:angular2/testing_internal.dart";
import 'package:material2_dart/src/components/toolbar/toolbar.dart';
@TestOn('browser')
import 'package:test/test.dart';

void main() {
  test('should apply class based on color attribute', () {
    return inject([TestComponentBuilder, AsyncTestCompleter],
        (TestComponentBuilder tcb, AsyncTestCompleter completer) async {
      ComponentFixture fixture = await tcb.createAsync(TestApp);
      TestApp testComponent = fixture.debugElement.componentInstance;
      var toolbarDebugElement =
          fixture.debugElement.query(By.css('md-toolbar'));

      testComponent.toolbarColor = 'primary';
      fixture.detectChanges();

      expect(toolbarDebugElement.nativeElement.classes, contains('md-primary'));

      testComponent.toolbarColor = 'accent';
      fixture.detectChanges();

      expect(toolbarDebugElement.nativeElement.classes,
          isNot(contains('md-primary')));
      expect(toolbarDebugElement.nativeElement.classes, contains('md-accent'));

      testComponent.toolbarColor = 'warn';
      fixture.detectChanges();

      expect(toolbarDebugElement.nativeElement.classes,
          isNot(contains('md-accent')));
      expect(toolbarDebugElement.nativeElement.classes, contains('md-warn'));
      completer.done();
    });
  });
}

@Component(
    selector: 'test-app',
    template: '''
    <md-toolbar [color]="toolbarColor">
      <span>Test Toolbar</span>
    </md-toolbar>
  ''',
    directives: const [MdToolbar])
class TestApp {
  String toolbarColor;
}
