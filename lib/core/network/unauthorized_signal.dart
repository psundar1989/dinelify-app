/// Decouples the Dio 401 interceptor from AuthController so neither provider
/// has to depend on the other's type (which would create an unresolvable
/// Riverpod top-level type-inference cycle, since AuthController also
/// depends on Dio transitively through the repositories). DioClient fires
/// this signal; AuthController registers itself as the listener at startup.
class UnauthorizedSignal {
  void Function()? _listener;

  void register(void Function() listener) => _listener = listener;

  void fire() => _listener?.call();
}
