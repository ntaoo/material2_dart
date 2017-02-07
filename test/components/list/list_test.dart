import 'dart:async';
import 'package:angular2/angular2.dart';
import "package:angular2/testing_internal.dart";
import 'package:material2_dart/src/components/list/list.dart';
@TestOn('browser')
import 'package:test/test.dart';

void main() {
  test('should add and remove focus class on focus/blur', () {
    return inject([TestComponentBuilder, AsyncTestCompleter],
        (TestComponentBuilder tcb, AsyncTestCompleter completer) async {
      var template = '''
        <md-list>
          <a md-list-item>
            Paprika
          </a>
        </md-list>
      ''';
      ComponentFixture fixture =
          await tcb.overrideTemplate(TestList, template).createAsync(TestList);
      var listItem = fixture.debugElement.query(By.directive(MdListItem));
      var listItemDiv = fixture.debugElement.query(By.css('.md-list-item'));
      fixture.detectChanges();
      expect(listItemDiv.nativeElement.classes,
          isNot(contains('md-list-item-focus')));
      MdListItem mdListItem = listItem.componentInstance;
      mdListItem.handleFocus();
      fixture.detectChanges();
      expect(listItemDiv.nativeElement.classes, contains('md-list-item-focus'));

      MdListItem mdListItem2 = listItem.componentInstance;
      mdListItem2.handleBlur();
      fixture.detectChanges();
      expect(listItemDiv.nativeElement.classes,
          isNot(contains('md-list-item-focus')));
      completer.done();
    });
  });

  test('should not apply any class to a list without lines', () {
    return inject([TestComponentBuilder, AsyncTestCompleter],
        (TestComponentBuilder tcb, AsyncTestCompleter completer) async {
      var template = '''
        <md-list>
          <md-list-item>
            Paprika
          </md-list-item>
        </md-list>
      ''';
      ComponentFixture fixture =
          await tcb.overrideTemplate(TestList, template).createAsync(TestList);
      var listItem = fixture.debugElement.query(By.css('md-list-item'));
      fixture.detectChanges();
      expect(listItem.nativeElement.className, isEmpty);
      completer.done();
    });
  });

  test('should apply md-2-line class to lists with two lines', () {
    return inject([TestComponentBuilder, AsyncTestCompleter],
        (TestComponentBuilder tcb, AsyncTestCompleter completer) async {
      var template = '''
        <md-list>
          <md-list-item *ngFor="let item of items">
            <img src="">
            <h3 md-line>{{item['name']}}</h3>
            <p md-line>{{item['description']}}</p>
          </md-list-item>
        </md-list>
      ''';
      ComponentFixture fixture =
          await tcb.overrideTemplate(TestList, template).createAsync(TestList);
      fixture.detectChanges();
      var listItems =
          fixture.debugElement.children.first.queryAll(By.css('md-list-item'));
      expect(listItems[0].nativeElement.className, 'md-2-line');
      expect(listItems[1].nativeElement.className, 'md-2-line');
      completer.done();
    });
  });

  test('should apply md-3-line class to lists with three lines', () {
    return inject([TestComponentBuilder, AsyncTestCompleter],
        (TestComponentBuilder tcb, AsyncTestCompleter completer) async {
      var template = '''
        <md-list>
          <md-list-item *ngFor="let item of items">
            <h3 md-line>{{item['name']}}</h3>
            <p md-line>{{item['description']}}</p>
            <p md-line>Some other text</p>
          </md-list-item>
        </md-list>
      ''';
      ComponentFixture fixture =
          await tcb.overrideTemplate(TestList, template).createAsync(TestList);
      fixture.detectChanges();
      var listItems =
          fixture.debugElement.children.first.queryAll(By.css('md-list-item'));
      expect(listItems[0].nativeElement.className, 'md-3-line');
      expect(listItems[1].nativeElement.className, 'md-3-line');
      completer.done();
    });
  });

  test('should apply md-list-avatar class to list items with avatars', () {
    return inject([TestComponentBuilder, AsyncTestCompleter],
        (TestComponentBuilder tcb, AsyncTestCompleter completer) async {
      var template = '''
        <md-list>
          <md-list-item>
            <img src="" md-list-avatar>
            Paprika
          </md-list-item>
         <md-list-item>
            Pepper
          </md-list-item>
        </md-list>
      ''';
      ComponentFixture fixture =
          await tcb.overrideTemplate(TestList, template).createAsync(TestList);
      fixture.detectChanges();
      var listItems =
          fixture.debugElement.children.first.queryAll(By.css('md-list-item'));
      expect(listItems[0].nativeElement.className, 'md-list-avatar');
      expect(listItems[1].nativeElement.className, isEmpty);
      completer.done();
    });
  });

  test('should not clear custom classes provided by user', () {
    return inject([TestComponentBuilder, AsyncTestCompleter],
        (TestComponentBuilder tcb, AsyncTestCompleter completer) async {
      var template = '''
        <md-list>
          <md-list-item class="test-class" *ngFor="let item of items">
            <h3 md-line>{{item['name']}}</h3>
            <p md-line>{{item['description']}}</p>
          </md-list-item>
        </md-list>
      ''';
      ComponentFixture fixture =
          await tcb.overrideTemplate(TestList, template).createAsync(TestList);
      fixture.detectChanges();
      var listItems =
          fixture.debugElement.children.first.queryAll(By.css('md-list-item'));
      expect(listItems[0].nativeElement.classes, contains('test-class'));
      completer.done();
    });
  });

  test('should update classes if number of lines change', () {
    return inject([TestComponentBuilder, AsyncTestCompleter],
        (TestComponentBuilder tcb, AsyncTestCompleter completer) async {
      var template = '''
        <md-list>
          <md-list-item *ngFor="let item of items">
            <h3 md-line>{{item['name']}}</h3>
            <p md-line>{{item['description']}}</p>
            <p md-line *ngIf="showThirdLine">Some other text</p>
          </md-list-item>
        </md-list>
      ''';
      ComponentFixture fixture =
          await tcb.overrideTemplate(TestList, template).createAsync(TestList);
      fixture.debugElement.componentInstance.showThirdLine = false;
      fixture.detectChanges();
      var listItem =
          fixture.debugElement.children.first.query(By.css('md-list-item'));
      expect(listItem.nativeElement.className, 'md-2-line');

      fixture.debugElement.componentInstance.showThirdLine = true;
      fixture.detectChanges();
      await new Future<Null>.microtask(() {
        expect(listItem.nativeElement.className, 'md-3-line');
      });
      completer.done();
    });
  });

  test('should add aria roles properly', () {
    return inject([TestComponentBuilder, AsyncTestCompleter],
        (TestComponentBuilder tcb, AsyncTestCompleter completer) async {
      var template = '''
        <md-list>
          <md-list-item *ngFor="let item of items">
            {{item['name']}}
          </md-list-item>
        </md-list>
      ''';
      ComponentFixture fixture =
          await tcb.overrideTemplate(TestList, template).createAsync(TestList);
      fixture.detectChanges();
      var list = fixture.debugElement.children.first;
      var listItem =
          fixture.debugElement.children.first.query(By.css('md-list-item'));
      expect(list.nativeElement.attributes['role'], 'list');
      expect(listItem.nativeElement.attributes['role'], 'listitem');
      completer.done();
    });
  });
}

@Component(
    selector: 'test-list', template: '', directives: const [MD_LIST_DIRECTIVES])
class TestList {
  List<Map> items = [
    {'name': 'Paprika', 'description': 'A seasoning'},
    {'name': 'Pepper', 'description': 'Another seasoning'}
  ];
  bool showThirdLine = false;
}
