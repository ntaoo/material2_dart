import 'dart:html';
import 'package:angular2/angular2.dart';
import "package:angular2/testing_internal.dart";
import 'package:material2_dart/material.dart';
@TestOn('browser')
import 'package:test/test.dart';

void main() {
  group('Portals', () {
    group('PortalHostDirective', () {
      test('should load a component into the portal', () {
        return inject([TestComponentBuilder, AsyncTestCompleter],
            (TestComponentBuilder tcb, AsyncTestCompleter completer) {
          fakeAsync(() async {
            ComponentFixture appFixture;
            ComponentFixture fixture = await tcb.createAsync(PortalTestApp);
            appFixture = fixture;
            // Flush the async creation of the PortalTestApp.
            flushMicrotasks();
            // Set the selectedHost to be a ComponentPortal.
            PortalTestApp testAppComponent =
                appFixture.debugElement.componentInstance;
            testAppComponent.selectedPortal = new ComponentPortal(PizzaMsg);
            appFixture.detectChanges();

            // Flush the attachment of the Portal.
            flushMicrotasks();

            Element hostContainer =
                appFixture.nativeElement.querySelector('.portal-container');
            expect(hostContainer.text, contains('Pizza'));
          })();
          completer.done();
        });
      });

      test('should load a component into the portal with a given injector', () {
        return inject([TestComponentBuilder, AsyncTestCompleter],
            (TestComponentBuilder tcb, AsyncTestCompleter completer) {
          fakeAsync(() async {
            ComponentFixture appFixture = await tcb.createAsync(PortalTestApp);

            // Flush the async creation of the PortalTestApp.
            flushMicrotasks();

            // Create a custom injector for the component.
            var chocolateInjector =
                new ChocolateInjector(appFixture.componentInstance.injector);

            // Set the selectedHost to be a ComponentPortal.
            PortalTestApp testAppComponent =
                appFixture.debugElement.componentInstance;

            testAppComponent.selectedPortal =
                new ComponentPortal(PizzaMsg, null, chocolateInjector);
            appFixture.detectChanges();

            // Flush the attachment of the Portal.
            flushMicrotasks();
            appFixture.detectChanges();

            // Expect that the content of the attached portal is present.
            Element hostContainer =
                appFixture.nativeElement.querySelector('.portal-container');
            expect(hostContainer.text, contains('Pizza'));
            expect(hostContainer.text, contains('Chocolate'));
          })();
          completer.done();
        });
      });

      test('should load a <template> portal', () {
        return inject([TestComponentBuilder, AsyncTestCompleter],
            (TestComponentBuilder tcb, AsyncTestCompleter completer) {
          fakeAsync(() async {
            ComponentFixture appFixture = await tcb.createAsync(PortalTestApp);

            // Flush the async creation of the PortalTestApp.
            flushMicrotasks();
            // Set the selectedHost to be a ComponentPortal.
            PortalTestApp testAppComponent =
                appFixture.debugElement.componentInstance;

            appFixture.detectChanges();
            testAppComponent.selectedPortal = testAppComponent.cakePortal;
            appFixture.detectChanges();

            // Flush the attachment of the Portal.
            flushMicrotasks();

            var hostContainer = appFixture.nativeElement
                .querySelector('.portal-container') as Element;
            expect(hostContainer.text, contains('Cake'));
          })();
          completer.done();
        });
      });

      test('should load a <template> portal with the `*` sugar', () {
        return inject([TestComponentBuilder, AsyncTestCompleter],
            (TestComponentBuilder tcb, AsyncTestCompleter completer) {
          fakeAsync(() async {
            ComponentFixture appFixture = await tcb.createAsync(PortalTestApp);

            // Flush the async creation of the PortalTestApp.
            flushMicrotasks();
            // Set the selectedHost to be a ComponentPortal.
            PortalTestApp testAppComponent =
                appFixture.debugElement.componentInstance;

            appFixture.detectChanges();

            testAppComponent.selectedPortal = testAppComponent.piePortal;
            appFixture.detectChanges();

            // Flush the attachment of the Portal.
            flushMicrotasks();

            var hostContainer = appFixture.nativeElement
                .querySelector('.portal-container') as Element;
            expect(hostContainer.text, contains('Pie'));
          })();
          completer.done();
        });
      });

      test('should load a <template> portal with a binding', () {
        return inject([TestComponentBuilder, AsyncTestCompleter],
            (TestComponentBuilder tcb, AsyncTestCompleter completer) {
          fakeAsync(() async {
            ComponentFixture appFixture = await tcb.createAsync(PortalTestApp);

            // Flush the async creation of the PortalTestApp.
            flushMicrotasks();

            // Set the selectedHost to be a ComponentPortal.
            PortalTestApp testAppComponent =
                appFixture.debugElement.componentInstance;

            appFixture.detectChanges();

            testAppComponent.selectedPortal =
                testAppComponent.portalWithBinding;
            appFixture.detectChanges();

            // Flush the attachment of the Portal.
            flushMicrotasks();

            // Now that the portal is attached, change detection has to happen again in order
            // for the bindings to update.
            appFixture.detectChanges();

            // Expect that the content of the attached portal is present.
            var hostContainer = appFixture.nativeElement
                .querySelector('.portal-container') as Element;
            expect(hostContainer.text, contains('Banana'));

            // When updating the binding value.
            testAppComponent.fruit = 'Mango';
            appFixture.detectChanges();

            // Expect the new value to be reflected in the rendered output.
            expect(hostContainer.text, contains('Mango'));
          })();
          completer.done();
        });
      });

      test('should change the attached portal', () {
        return inject([TestComponentBuilder, AsyncTestCompleter],
            (TestComponentBuilder tcb, AsyncTestCompleter completer) {
          fakeAsync(() async {
            ComponentFixture appFixture = await tcb.createAsync(PortalTestApp);

            // Flush the async creation of the PortalTestApp.
            flushMicrotasks();

            // Set the selectedHost to be a ComponentPortal.
            PortalTestApp testAppComponent =
                appFixture.debugElement.componentInstance;

            // Detect changes initially so that the component's ViewChildren are resolved.
            appFixture.detectChanges();

            testAppComponent.selectedPortal = testAppComponent.piePortal;
            appFixture.detectChanges();

            // Flush the attachment of the Portal.
            flushMicrotasks();

            // Now that the portal is attached, change detection has to happen again in order
            // for the bindings to update.
            appFixture.detectChanges();

            // Expect that the content of the attached portal is present.
            var hostContainer = appFixture.nativeElement
                .querySelector('.portal-container') as Element;
            expect(hostContainer.text, contains('Pie'));

            testAppComponent.selectedPortal = new ComponentPortal(PizzaMsg);
            appFixture.detectChanges();

            flushMicrotasks();

            expect(hostContainer.text, contains('Pizza'));
          })();
          completer.done();
        });
      });
    });
    group('DomPortalHost', () {
      ViewContainerRef aViewContainerRef;
      DivElement aDivElement;
      DomPortalHost host;
      Injector aInjector;

      setUp(() {
        aDivElement = new DivElement();
      });

      test('should attach and detach a component portal', () {
        return inject(
            [TestComponentBuilder, AsyncTestCompleter, ComponentResolver],
            (TestComponentBuilder tcb,
                AsyncTestCompleter completer,
                ComponentResolver resolver,
                ApplicationRef appref,
                Injector injector) async {
          host = new DomPortalHost(aDivElement, resolver, appref, injector);
          fakeAsync(() async {
            ComponentFixture fixture =
                await tcb.createAsync(ArbitraryViewContainerRefComponent);
            aViewContainerRef = fixture.componentInstance.viewContainerRef;

            // Flush the async creation of the PortalTestApp.
            flushMicrotasks();

            var portal = new ComponentPortal(PizzaMsg, aViewContainerRef);

            PizzaMsg componentInstance;

            componentInstance = (await portal.attach(host)).instance;

            flushMicrotasks();

            expect(componentInstance, new isInstanceOf<PizzaMsg>());
            expect(aDivElement.text, contains('Pizza'));

            await host.detach();
            flushMicrotasks();

            expect(aDivElement.innerHtml, isEmpty);
          })();
          completer.done();
        });
      });

      test('should attach and detach a component portal with a given injector',
          () {
        return inject(
            [TestComponentBuilder, AsyncTestCompleter, ComponentResolver],
            (TestComponentBuilder tcb,
                AsyncTestCompleter completer,
                ComponentResolver resolver,
                ApplicationRef appref,
                Injector injector) async {
          host = new DomPortalHost(aDivElement, resolver, appref, injector);
          fakeAsync(() async {
            ComponentFixture fixture =
                await tcb.createAsync(ArbitraryViewContainerRefComponent);
            aViewContainerRef = fixture.componentInstance.viewContainerRef;
            aInjector = fixture.componentInstance.injector;

            // Flush the async creation of the PortalTestApp.
            flushMicrotasks();

            var chocolateInjector = new ChocolateInjector(aInjector);
            var portal = new ComponentPortal(
                PizzaMsg, aViewContainerRef, chocolateInjector);

            PizzaMsg componentInstance;
            var ref = await portal.attach(host);
            componentInstance = ref.instance;

            flushMicrotasks();
            fixture.detectChanges();

            expect(componentInstance, new isInstanceOf<PizzaMsg>());
            expect(aDivElement.text, contains('Pizza'));
            expect(aDivElement.text, contains('Chocolate'));

            await host.detach();
            flushMicrotasks();

            expect(aDivElement.innerHtml, '');
          })();
          completer.done();
        });
      });

      test('should attach and detach a template portal', () {
        return inject(
            [TestComponentBuilder, AsyncTestCompleter, ComponentResolver],
            (TestComponentBuilder tcb,
                AsyncTestCompleter completer,
                ComponentResolver resolver,
                ApplicationRef appref,
                Injector injector) {
          host = new DomPortalHost(aDivElement, resolver, appref, injector);
          fakeAsync(() async {
            ComponentFixture appFixture = await tcb.createAsync(PortalTestApp);
            flushMicrotasks();
            appFixture.detectChanges();
            await (appFixture.componentInstance as PortalTestApp)
                .cakePortal
                .attach(host);
            flushMicrotasks();

            expect(aDivElement.text, contains('Cake'));
            completer.done();
          })();
        });
      });

      test('should attach and detach a template portal with a binding', () {
        return inject(
            [TestComponentBuilder, AsyncTestCompleter, ComponentResolver],
            (TestComponentBuilder tcb,
                AsyncTestCompleter completer,
                ComponentResolver resolver,
                ApplicationRef appref,
                Injector injector) {
          host = new DomPortalHost(aDivElement, resolver, appref, injector);
          fakeAsync(() async {
            ComponentFixture appFixture = await tcb.createAsync(PortalTestApp);
            flushMicrotasks();
            PortalTestApp testAppComponent =
                appFixture.debugElement.componentInstance;
            appFixture.detectChanges();
            await testAppComponent.portalWithBinding.attach(host);
            appFixture.detectChanges();
            flushMicrotasks();
            // Now that the portal is attached, change detection has to happen again in order
            // for the bindings to update.
            appFixture.detectChanges();

            // Expect that the content of the attached portal is present.
            expect(aDivElement.text, contains('Banana'));

            // When updating the binding value.
            testAppComponent.fruit = 'Mango';
            appFixture.detectChanges();

            // Expect the new value to be reflected in the rendered output.
            expect(aDivElement.text, contains('Mango'));

            await host.detach();
            expect(aDivElement.innerHtml, isEmpty);
            completer.done();
          })();
        });
      });

      test('should change the attached portal', () {
        return inject(
            [TestComponentBuilder, AsyncTestCompleter, ComponentResolver],
            (TestComponentBuilder tcb,
                AsyncTestCompleter completer,
                ComponentResolver resolver,
                ApplicationRef appref,
                Injector injector) {
          host = new DomPortalHost(aDivElement, resolver, appref, injector);
          fakeAsync(() async {
            aViewContainerRef =
                (await tcb.createAsync(ArbitraryViewContainerRefComponent))
                    .componentInstance
                    .viewContainerRef;
            flushMicrotasks();

            ComponentFixture appFixture = await tcb.createAsync(PortalTestApp);
            flushMicrotasks();
            appFixture.detectChanges();
            appFixture.componentInstance.piePortal.attach(host);
            flushMicrotasks();

            expect(aDivElement.text, contains('Pie'));

            await host.detach();
            flushMicrotasks();

            await host.attach(new ComponentPortal(PizzaMsg, aViewContainerRef));
            flushMicrotasks();

            expect(aDivElement.text, contains('Pizza'));
            completer.done();
          })();
        });
      });
    });
  });
}

class Chocolate {
  @override
  String toString() => 'Chocolate';
}

class ChocolateInjector implements Injector {
  Injector parentInjector;
  ChocolateInjector(this.parentInjector);

  @override
  dynamic get(dynamic token, [dynamic notFoundValue]) {
    return token == Chocolate ? new Chocolate() : parentInjector.get(token);
  }
}

/// Simple component for testing ComponentPortal.
@Component(selector: 'pizza-msg', template: '<p>Pizza</p><p>{{snack}}</p>')
class PizzaMsg {
  Chocolate snack;
  PizzaMsg(@Optional() this.snack);
}

/// Simple component to grab an arbitrary ViewContainerRef
@Component(selector: 'some-placeholder', template: '<p>Hello</p>')
class ArbitraryViewContainerRefComponent {
  ViewContainerRef viewContainerRef;
  Injector injector;
  ArbitraryViewContainerRefComponent(this.viewContainerRef, this.injector);
}

/// Test-bed component that contains a portal host and a couple of template portals.
@Component(
    selector: 'portal-test',
    template: '''
  <div class="portal-container">
    <template [portalHost]="selectedPortal"></template>
  </div>

  <template portal>Cake</template>

  <div *portal>Pie</div>

  <template portal> {{fruit}} </template>
  ''',
    directives: const [PortalHostDirective, TemplatePortalDirective])
class PortalTestApp {
  @ViewChildren(TemplatePortalDirective)
  QueryList<TemplatePortalDirective> portals;
  Portal<dynamic> selectedPortal;
  String fruit = 'Banana';
  Injector injector;

  PortalTestApp(this.injector);

  Portal get cakePortal => portals.first;

  Portal get piePortal => portals.toList()[1];

  Portal get portalWithBinding => portals.toList()[2];
}
