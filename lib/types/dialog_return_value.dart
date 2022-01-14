/// To use when you need flow control to discard a returned value by a dialog
/// if the user aborted change (with a cancel or close button).
class DialogReturnValue<T> {
  DialogReturnValue({
    required this.validated,
    required this.value,
  });

  /// True if the dialog was submitted and not cancelled.
  final bool validated;

  /// Value returned by the dialog.
  final T value;
}
