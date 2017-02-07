import "package:angular2/angular2.dart";
import "../../core/core.dart";

/// Used to flag tab labels for use with the portal directive.
@Directive(selector: "[md-tab-label]")
class MdTabLabel extends TemplatePortalDirective {
  MdTabLabel(TemplateRef templateRef, ViewContainerRef viewContainerRef)
      : super(templateRef, viewContainerRef);
}
