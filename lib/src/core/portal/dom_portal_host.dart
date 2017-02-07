import 'dart:html';
import "dart:async";
import "package:angular2/angular2.dart";
import "portal.dart";
//import "portal_errors.dart";

/// A PortalHost for attaching portals to an arbitrary DOM element outside
/// of the Angular application context.
/// This is the only part of the portal core that directly touches the DOM.
class DomPortalHost extends BasePortalHost {
  Element _hostDomElement;
  ComponentResolver _componentResolver;
  ApplicationRef _appRef;
  Injector _defaultInjector;
  DomPortalHost(this._hostDomElement, this._componentResolver, this._appRef,
      this._defaultInjector)
      : super();

  /// Attach the given ComponentPortal to DOM element using the ComponentResolver.
  @override
  Future<ComponentRef> attachComponentPortal(ComponentPortal portal) async {
    var componentFactory =
        await _componentResolver.resolveComponent(portal.component);
    ComponentRef componentRef;

    // If the portal specifies a ViewContainerRef, we will use that as the attachment point
    // for the component (in terms of Angular's component tree, not rendering).
    // When the ViewContainerRef is missing, we use the factory to create the component directly
    // and then manually attach the ChangeDetector for that component to the application (which
    // happens automatically when using a ViewContainer).
    if (portal.viewContainerRef != null) {
      componentRef = portal.viewContainerRef.createComponent(
          componentFactory,
          portal.viewContainerRef.length,
          portal.injector != null
              ? portal.injector
              : portal.viewContainerRef.parentInjector);

      setDisposeFn(() => componentRef.destroy());
    } else {
      componentRef = componentFactory
          .create(portal.injector != null ? portal.injector : _defaultInjector);

      // When creating a component outside of a ViewContainer, we need to manually register
      // its ChangeDetector with the application. This API is unfortunately not yet published
      // in Angular core. The change detector must also be deregistered when the component
      // is destroyed to prevent memory leaks.
      //
      // See https://github.com/angular/angular/pull/12674
      // TODO(ntaoo): Dart version will fail. Consider the workaround.
      var changeDetectorRef = componentRef.changeDetectorRef;
      (_appRef as dynamic).registerChangeDetector(changeDetectorRef);

      setDisposeFn(() {
        (_appRef as dynamic).unregisterChangeDetector(changeDetectorRef);

        // Normally the ViewContainer will remove the component's nodes from the DOM.
        // Without a ViewContainer, we need to manually remove the nodes.
        _getComponentRootNode(componentRef).remove();

        componentRef.destroy();
      });
    }

    // At this point the component has been instantiated, so we move it to the location in the DOM
    // where we want it to be rendered.
    _hostDomElement.append(_getComponentRootNode(componentRef));

    return componentRef;
  }

  @override
  Future<Map<String, dynamic>> attachTemplatePortal(TemplatePortal portal) {
    var viewContainer = portal.viewContainerRef;
    var viewRef = viewContainer.createEmbeddedView(portal.templateRef);
    viewRef.rootNodes
        .forEach((Node rootNode) => _hostDomElement.append(rootNode));
    setDisposeFn((() {
      var index = viewContainer.indexOf(viewRef);
      if (index != -1) viewContainer.remove(index);
    }));
    // TODO(jelbourn): Return locals from view.
    return new Future.value(new Map<String, dynamic>());
  }

  @override
  void dispose() {
    super.dispose();
    if (_hostDomElement.parentNode != null) _hostDomElement.remove();
  }

  /// Gets the root HTMLElement for an instantiated component.
  Element _getComponentRootNode(ComponentRef componentRef) {
    return (componentRef.hostView as EmbeddedViewRef).rootNodes[0] as Element;
  }
}
