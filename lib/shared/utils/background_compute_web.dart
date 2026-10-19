import 'dart:async';

Future<T> runInBackground<T>(FutureOr<T> Function() computation) async {
  return computation();
}
