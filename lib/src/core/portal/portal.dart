import "dart:async";
import "package:angular2/angular2.dart";
import "portal_errors.dart";

/// A `Portal` is something that you want to render somewhere else.
/// It can be attach to / detached from a `PortalHost`.
// [attach] and [detach] remain async because ComponentResolver is async
// unlike ComponentFactoryResolver introduced instead of ComponentResolver
// in AngularTS.
abstract class Portal<T> {
  PortalHost _attachedHost;

  /** Attach this portal to a host. */
  Future<T> attach(PortalHost host) {
    if (host == null) {
      throw new MdNullPortalHostError();
    }
    if (host.hasAttached()) {
      throw new MdPortalAlreadyAttachedError();
    }
    this._attachedHost = host;
    return (host.attach(this) as Future<T>);
  }

  /** Detach this portal from its host */
  Future detach() {
    var host = _attachedHost;
    if (host == null) {
      throw new MdNoPortalAttachedError();
    }
    _attachedHost = null;
    return host.detach();
  }

  /** Whether this portal is attached to a host. */
  bool get isAttached => _attachedHost != null;

  /// Sets the PortalHost reference without performing `attach()`. This is used directly by
  /// the PortalHost when it is performing an `attach()` or `detatch()`.
  void setAttachedHost(PortalHost host) {
    _attachedHost = host;
  }
}

/// A `ComponentPortal` is a portal that instantiates some Component upon attachment.
class ComponentPortal extends Portal<ComponentRef> {
  /// The type of the component that will be instantiated for attachment.
  // Using Type instead of defining ComponentType for ComponentResolver in AngularDart.
  Type component;

  /// [Optional] Where the attached component should live in Angular's *logical* component tree.
  /// This is different from where the component *renders*, which is determined by the PortalHost.
  /// The origin necessary when the host is outside of the Angular application context.
  ViewContainerRef viewContainerRef;

  /// [Optional] Injector used for the instantiation of the component.
  Injector injector;

  ComponentPortal(Type component,
      [ViewContainerRef viewContainerRef = null, Injector injector = null])
      : super() {
    this.component = component;
    this.viewContainerRef = viewContainerRef;
    this.injector = injector;
  }
}

/**
 * A `TemplatePortal` is a portal that represents some embedded template (TemplateRef).
 */
class TemplatePortal extends Portal<Map<String, dynamic>> {
  /** The embedded template that will be used to instantiate an embedded View in the host. */
  TemplateRef templateRef;

  /** Reference to the ViewContainer into which the template will be stamped out. */
  ViewContainerRef viewContainerRef;

  /**
   * Additional locals for the instantiated embedded view.
   * These locals can be seen as "exports" for the template, such as how ngFor has
   * index / event / odd.
   * See https://angular.io/docs/ts/latest/api/core/EmbeddedViewRef-class.html
   */
  Map<String, dynamic> locals = new Map<String, dynamic>();

  TemplatePortal(this.templateRef, this.viewContainerRef);

  ElementRef get origin => templateRef.elementRef;

  @override
  Future<Map<String, dynamic>> attach(PortalHost host,
      [Map<String, dynamic> locals]) {
    locals = locals == null ? new Map<String, dynamic>() : locals;
    return super.attach(host);
  }

  @override
  Future detach() {
    locals = new Map<String, dynamic>();
    return super.detach();
  }
}

/**
 * A `PortalHost` is an space that can contain a single `Portal`.
 */
abstract class PortalHost {
  Future<dynamic> attach(Portal<dynamic> portal);

  Future<dynamic> detach();

  void dispose();

  bool hasAttached();
}

/**
 * Partial implementation of PortalHost that only deals with attaching either a
 * ComponentPortal or a TemplatePortal.
 */
abstract class BasePortalHost implements PortalHost {
  /** The portal currently attached to the host. */
  Portal<dynamic> _attachedPortal;

  /** A function that will permanently dispose this host. */
  dynamic /* () => void */ _disposeFn;

  /** Whether this host has already been permanently disposed. */
  bool _isDisposed = false;

  /// Whether this host has an attached portal.
  @override
  bool hasAttached() => _attachedPortal != null;

  @override
  Future<dynamic> attach(Portal<dynamic> portal) {
    if (portal == null) {
      throw new MdNullPortalError();
    }
    if (hasAttached()) {
      throw new MdPortalAlreadyAttachedError();
    }
    if (_isDisposed) {
      throw new MdPortalHostAlreadyDisposedError();
    }
    if (portal is ComponentPortal) {
      _attachedPortal = portal;
      return attachComponentPortal(portal);
    } else if (portal is TemplatePortal) {
      _attachedPortal = portal;
      return attachTemplatePortal(portal);
    }
    throw new MdUnknownPortalTypeError();
  }

  Future<ComponentRef> attachComponentPortal(ComponentPortal portal);

  Future<Map<String, dynamic>> attachTemplatePortal(TemplatePortal portal);

  @override
  Future detach() {
    if (_attachedPortal != null) {
      _attachedPortal.setAttachedHost(null);
    }

    _attachedPortal = null;
    if (_disposeFn != null) {
      _disposeFn();
      _disposeFn = null;
    }
    return new Future<Null>.value();
  }

  @override
  void dispose() {
    if (hasAttached()) detach();
    _isDisposed = true;
  }

  void setDisposeFn(void fn()) {
    _disposeFn = fn;
  }
}
