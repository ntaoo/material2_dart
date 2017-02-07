import "../errors/error.dart";

/** Exception thrown when attempting to attach a null portal to a host. */
class MdNullPortalError extends MdError {
  MdNullPortalError() : super("Must provide a portal to attach");
}

/** Exception thrown when attempting to attach a portal to a host that is already attached. */
class MdPortalAlreadyAttachedError extends MdError {
  MdPortalAlreadyAttachedError() : super("Host already has a portal attached");
}

/** Exception thrown when attempting to attach a portal to an already-disposed host. */
class MdPortalHostAlreadyDisposedError extends MdError {
  MdPortalHostAlreadyDisposedError()
      : super("This PortalHost has already been disposed");
}

/** Exception thrown when attempting to attach an unknown portal type. */
class MdUnknownPortalTypeError extends MdError {
  MdUnknownPortalTypeError()
      : super(
            "Attempting to attach an unknown Portal type. BasePortalHost accepts either a ComponentPortal or a TemplatePortal.");
}

/** Exception thrown when attempting to attach a portal to a null host. */
class MdNullPortalHostError extends MdError {
  MdNullPortalHostError()
      : super("Attempting to attach a portal to a null PortalHost");
}

/** Exception thrown when attempting to detach a portal that is not attached. */
class MdNoPortalAttachedError extends MdError {
  MdNoPortalAttachedError()
      : super("Attempting to detach a portal that is not attached to a host");
}
